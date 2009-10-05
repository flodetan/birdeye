/*  
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
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
	import __AS3__.vec.Vector;
	
	import birdeye.vis.interfaces.transforms.IGraphLayout;
	import birdeye.vis.trans.graphs.model.IGTree;
	import birdeye.vis.trans.graphs.model.IGraph;
	import birdeye.vis.trans.graphs.model.INode;
	import birdeye.vis.trans.graphs.visual.IVisualNode;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[Exclude(name="disableAnimation", kind="property")]
	[Exclude(name="graph", kind="property")]
	[Exclude(name="graphLayout", kind="property")]
	[Exclude(name="phi", kind="property")]
	[Exclude(name="layoutChanged", kind="method")]
	[Exclude(name="activate", kind="event")]
	[Exclude(name="deactivate", kind="event")]
	
	/**
	 * This is an base class to various layout implementations
	 * it does not really do any layouting but implements
	 * everything required by the Interface.
	 * */
	[ExcludeClass]
	public class BaseLayouter extends EventDispatcher implements ILayoutAlgorithm {
		
		private static const _LOG:String = "graphLayout.layout.BaseLayouter";
		
		/**
		 * The default minimum node height to be used if the exact node
		 * height cannot be determined yet.
		 * */
		public static const MINIMUM_NODE_HEIGHT:Number = 5;
		
		/**
		 * The default minimum node width to be used if the exact node
		 * height cannot be determined yet.
		 * */
		public static const MINIMUM_NODE_WIDTH:Number = 5;
		
		/**
		 * The default margin to be considered when using
		 * autoFit.
		 * */
		public static const DEFAULT_MARGIN:Number = 30;
		
		/**
		 * If set to true, animation is disabled and direct
		 * node location setting occurs (instantaneously).
		 * @default false
		 * */
		protected var _disableAnimation:Boolean = false;
		
		/**
		 * All layouters need access to the graph layout.
		 * */
		protected var _graphLayout:IGraphLayout = null;
		
		/**
		 * All layouters need access to the Graph.
		 * */
		protected var _graph:IGraph = null;
		
		/**
		 * This keeps track if the layout has changed
		 * and can be accessed by any derived layouter.
		 * */
		protected var _layoutChanged:Boolean = false;

		/** 
		 * A spanning tree of the graph, since probably every layout 
		 * will work on a spanning tree, we keep this one in this
		 * base class.
		 * */
		protected var _stree:IGTree;

		/**
		 * The current root node of the layout.
		 * */
		protected var _root:INode;
		
		/**
		 * The indicator if AutoFit should currently be used or not.
		 * */
		protected var _autoFitEnabled:Boolean = false;

		/**
		 * this holds the data for a layout drawing.
		 * */
		private var _currentDrawing:BaseLayoutDrawing;

		public function BaseLayouter():void {
		}

		/**
		 * @inheritDoc
		 * */
		public function set graphLayout(vg:IGraphLayout):void {
			_graphLayout = vg;
			_graph = _graphLayout.graph;
			resetAll();
		}


		/**
		 * Intended for override to create a new layout
		 **/ 
		protected function cleanup():void {
		}

		/**
		 * Intended for override to create a new layout 
		 * drawing object, which is required
		 * on any root change (and possibly during other occasions)
		 * and intialise various parameters of the drawing.
		 * */
		protected function initDrawing():void {
		}
		
		public function resetAll():void {
			cleanup();			
			_layoutChanged = true;
			initDrawing();
		}

		/**
		 * @inheritDoc
		 * */
		public function set graph(g:IGraph):void {
			_graph = g;
		}

		/**
		 * @inheritDoc
		 * */	
		public function get layoutChanged():Boolean {
			return _layoutChanged;
		}
		
		/**
		 * @private
		 * */
		public function set layoutChanged(lc:Boolean):void {
			_layoutChanged = lc;
		}
		
		/**
		 * @inheritDoc
		 * */
		[Bindable]
		[Inspectable(enumeration="true,false")]
		public function get autoFitEnabled():Boolean {
			return _autoFitEnabled;	
		}
		
		/**
		 * @private
		 * */
		public function set autoFitEnabled(af:Boolean):void {
			_autoFitEnabled = af;
		}

		/**
		 * This is a NOP in the BaseLayouter class. It does not set
		 * anything and always returns 0.
		 * 
		 * @inheritDoc
		 * */
		[Bindable]
		public function set linkLength(r:Number):void {
			/* NOP */
		}
		
		/**
		 * @private
		 * */
		public function get linkLength():Number {
			/* NOP
			 * but must not return 0, since some layouter
			 * do not care about LL, but the graphLayout will
			 * not draw if LL is 0
			 * so default is something else, like 1
			 */
			return 1;
		}

		/**
		 * @inheritDoc
		 * */
		public function get animInProgress():Boolean {
			/* since the base layouter is ignorant of animation
			 * it would always return false. The AnimatedBaseLayouter
			 * though needs to override this to always return the
			 * correct value. */
			return false;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set disableAnimation(d:Boolean):void {
			_disableAnimation = d;
		};
		
		/**
		 * @private
		 * */
		public function get disableAnimation():Boolean {
			return _disableAnimation;
		}
		
		/**
		 * This is a NOP in the BaseLayouter class and always returns true.
		 * 
		 * @inheritDoc
		 * */
		public function layoutPass():Boolean {
		 	/* NOP */
		 	return true;
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function refreshInit():void {
			/* NOP */
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function dragEvent(event:MouseEvent, vn:IVisualNode):void {
			/* NOP */
			// LogUtil.debug(_LOG, "Node: " + vn.node.id + " started DRAG");
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function dragContinue(event:MouseEvent, vn:IVisualNode):void {
			/* NOP */
			// LogUtil.debug(_LOG, "Node: " + vn.node.id + " being DRAGGED...");
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function dropEvent(event:MouseEvent, vn:IVisualNode):void {
			/* NOP */
			// LogUtil.debug(_LOG, "Node: " + vn.node.id + " DROPPED");
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function bgDragEvent(event:MouseEvent):void {
			/* NOP */
			//LogUtil.debug(_LOG, "Canvas started DRAG");
		}

		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function bgDragContinue(event:MouseEvent):void {
			/* NOP */
			//LogUtil.debug(_LOG, "Canvas being DRAGGED...");
		}
		
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		public function bgDropEvent(event:MouseEvent):void {
			/* NOP */
			//LogUtil.debug(_LOG, "Canvas DROPPED");
		}
		
		/**
		 * Allow to set the reference to the drawing object from
		 * derived classes. This is important because of the 
		 * type issue, the _currentDrawing variable will be declared
		 * separately in each derived layouter, but this one must
		 * have access to it anyway, to do the animation
		 * @param dr The drawing object that needs to be assigned.
		 * */
		protected function set currentDrawing(dr:BaseLayoutDrawing):void {
			_currentDrawing = dr;
		}
		
		
		/**
		 * Sets the current absolute target coordinates of a node
		 * in the node's vnode. This does not yet move the node,
		 * as for this the vnode's commit() method must be called.
		 * @param n The node to get its target coordinates updated.
		 * */ 
		protected function applyTargetCoordinates(n:INode):void {
			
			var coords:Point;
			/* add the points coordinates to its origin */		
			coords = _currentDrawing.getAbsCartCoordinates(n);
		
			n.vnode.x = coords.x;
			n.vnode.y = coords.y;
		}
		
		/**
		 * Applies the target coordinates to all nodes that
		 * are in the Dictionary object passed as argument.
		 * The items are expected to be VNodes (as typically
		 * a list of currently visible VNodes is passed).
		 * */
		protected function applyTargetToNodes(nodes:Vector.<IVisualNode>):void {
			var vn:IVisualNode;
			for each(vn in nodes) {			
				if (vn.visible) {
					applyTargetCoordinates(vn.node);
					vn.commit();
				}
			}
		}

		private function forceRedraw(e:MouseEvent):void {
			e.updateAfterEvent();
		}
	}
}
