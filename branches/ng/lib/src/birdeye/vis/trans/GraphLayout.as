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

package birdeye.vis.trans
{
	import birdeye.vis.elements.Position;
	import birdeye.vis.elements.geometry.EdgeElement;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	
	public class GraphLayout implements IGraphLayout {

		public static const SINGLE_CYCLE:String = "single-cycle";
		public static const CONCENTRIC:String = "concentric";
		public static const FORCE:String = "force";
		public static const HYPERBOLIC:String = "hyperbolic";
		
		protected var _type:String;

		[Inspectable(defaultValue = "single-cycle", enumeration = "single-cycle,concentric,force,hyperbolic")]
		public function set type(val:String):void {
			_type = val;
		}

		public function GraphLayout() {
			
		}
		
		protected var _node:IGraphLayoutableElement;
		public function set applyToNode(val:IGraphLayoutableElement):void {
			_node = val;
			_node.graphLayout = this;
		}
		
		protected var _edge:EdgeElement;
		public function set applyToEdge(val:EdgeElement):void {
			_edge = val;
			_edge.graphLayout = this;
		}

		private var nodeItemPositions:Array = [];

		protected function setItemPosition(itemIndex:int, pos1:Number, pos2:Number, pos3:Number):void {
			nodeItemPositions[itemIndex] = new Position(pos1, pos2, pos3);
		}

		public function getNodeItemPosition(itemIndex:int):Position {
			return nodeItemPositions[itemIndex];
		}


		private var _viewportWidth:Number;
		
		public function get viewportWidth():Number {
			return _viewportWidth;
		}
		
		public function set viewportWidth(width:Number):void {
			_viewportWidth = width;
		}
		

		private var _viewportHeight:Number;
		
		public function get viewportHeight():Number {
			return _viewportHeight;
		}
		
		public function set viewportHeight(height:Number):void {
			_viewportHeight = height;
		}
		
		public function apply():void {

		    const numItems = _node.getDataItemsCount();
		
			switch (_type) {
				case SINGLE_CYCLE:
					const mx:Number = Math.min(viewportWidth, viewportHeight), my:int = 200, r:int = 140;
					for (var i:int = 0; i < numItems; i++) {
						setItemPosition(i, 
							mx + Math.cos(2 * Math.PI * i / numItems) * r, 
							my - Math.sin(2 * Math.PI * i / numItems) * r, NaN);
					}
				break;
				
				case CONCENTRIC:
				
				break;
			}
		}

	}
}
