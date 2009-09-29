/* 
 * The MIT License
 *
 * Copyright (c) 2007 The SixDegrees Project Team
 * (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package birdeye.vis.trans.graphs.layout
{

	import birdeye.vis.trans.graphs.model.INode;
	import birdeye.vis.trans.graphs.util.LogUtil;
	import birdeye.vis.trans.graphs.util.MathUtil;
	import birdeye.vis.trans.graphs.visual.IVisualNode;
	
	import flash.utils.Dictionary;
		
	/**
	 * This is an implementation of the circular layout -
	 * all visible nodes are arranged in a circle
	 * 
	 * @author Nitin Lamba
	 * */
	public class CircularLayouter extends AnimatedBaseLayouter {
		
		private static const _LOG:String = "graphLayout.layout.CircularLayouter";
		
		/**
		 * The radius of the layout
		 */
		private var _radius:Number = 200;
		
		/* The initial starting angle of the layout
	   */
		private var _phi:Number = 0;
		
		/**
		 * this holds the data for a layout drawing.
		 * */
		private var _currentDrawing:BaseLayoutDrawing;
		
		/**
		 * The constructor only initialises some data structures.
		 * @inheritDoc
		 * */
		public function CircularLayouter():void {
			super();
			animationType = ANIM_RADIAL; // inherited
			_currentDrawing = null;
		}

		/**
		 * This main interface method computes and
		 * and executes the new layout.
		 * @return Currently the return value is not set or used.
		 * */
		override public function layoutPass():Boolean {
			//LogUtil.debug(_LOG, "layoutPass called");
			
			if(!_graphLayout) {
				LogUtil.warn(_LOG, "No Vgraph set in CircularLayouter, aborting...");
				return false;
			}
			
			/* nothing to do if we have no nodes */
			if(_graph.noNodes < 1) {
				return false;
			}
			
			/* if there is a timer, we have to stop it to
			 * prevent inconsistencies */
			killTimer();
								
			/* need to see where how we could get a clear
			 * list of situation how to deal with hab
			 * if the layout was changed (or any parameter)
			 * we have to reinit the model */
			if(_layoutChanged) {
				initDrawing();
			}

			/* this is complicated. */
			if(_autoFitEnabled) {
				/* we calculate the best radius of the circle */
				calculateAutoFit();
			}

			/* do a calculation pass */
			calculateNodes()
		
			/* reset animation cycle */
			resetAnimation();
			
			/* start the animation, does also the commit */
			startAnimation();		
		
			//_vgraph.refresh();
			_layoutChanged = true;
			return true;
		}
	
		/**
		 * @inheritDoc
		 * */
		[Bindable]
		override public function get linkLength():Number {
			return _radius;
		}
		/**
		 * @private
		 * */
		override public function set linkLength(rr:Number):void {
			_radius = rr;
		}
		
		/**
		 * Access the starting angle of the layout
		 * */
		[Bindable]
		public function get phi():Number {
			return _phi
		}
		/**
		 * Set the starting angle of the layout. Modifying this 
		 * value rotates the layout by a given angle
		 * */
		public function set phi(p:Number):void {
			_phi = p;
		}
		
		/* private methods */
		 
		/**
		 * @internal
		 * Create a new layout drawing object, which is required
		 * on any root change (and possibly during other occasions)
		 * and intialise various parameters of the drawing.
		 * */
		protected override function initDrawing():void {
			super.initDrawing();

			_currentDrawing = new BaseLayoutDrawing();
			
			/* Also set the object also in the BaseLayouter */
			super.currentDrawing = _currentDrawing;
			
			_currentDrawing.originOffset = _graphLayout.origin;
			_currentDrawing.centerOffset = _graphLayout.center;
			_currentDrawing.centeredLayout = true;

//			_vgraph.origin.x = 0;
//			_vgraph.origin.y = 0;
		}
		
		/**
		 * @internal
		 * Calculate the polar angles of the nodes */
		private function calculateNodes():void {
			
			/* needed for the calculation */
			var phi:Number;
			var vn:IVisualNode;
			var ni:INode;
			
			var visVNodes:Dictionary;
			var i:int;

			var nodes:Vector.<IVisualNode> = _graphLayout.nodes;

			var numVisibleNodes:int = 0;
			for each(vn in nodes) {
				if (vn.visible) numVisibleNodes++;
			}

			i = 1;
			for each(vn in nodes) {
				/* position only visible nodes */
				if (vn.visible) {
        			phi = _phi + (360 * i) / numVisibleNodes;
					phi = MathUtil.normaliseAngleDeg(phi);
					
					/* set the values */
					ni = vn.node;
					_currentDrawing.setPolarCoordinates(ni, _radius, phi);
					//LogUtil.debug(_LOG, "CircularLayouter: node set to (r, phi) = " + _radius + ", " + phi);
				
					/* set the orientation into the visual node */
					vn.orientAngle = phi;
				}
				i += 1;
			}
			//LogUtil.debug(_LOG, "CircularLayouter: nodes set to new (r, phi)...");
			return;
		}


		/**
		 * @internal
		 * Do all the calculations required for autoFit
		 * */
		private function calculateAutoFit():void {
			_radius = Math.min(_graphLayout.width,_graphLayout.height) / 2.0 - DEFAULT_MARGIN;
		}
	}
}
