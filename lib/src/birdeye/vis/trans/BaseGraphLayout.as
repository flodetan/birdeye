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
	
	/**
	 * This is an abstract class which mustn't be instantiated.
	 **/
	public class BaseGraphLayout implements IGraphLayout {

		public function BaseGraphLayout() {
			
		}
		
		protected var _node:IGraphLayoutableElement;
		public function set applyToNode(val:IGraphLayoutableElement):void {
			_node = val;
			_node.graphLayout = this;
		}
		
		private var nodeItemPositions:Array = [];

		protected function setItemPosition(itemIndex:int, pos1:Number, pos2:Number, pos3:Number):void {
			nodeItemPositions[itemIndex] = new Position(pos1, pos2, pos3);
		}

		public function getNodeItemPosition(itemIndex:int):Position {
			return nodeItemPositions[itemIndex];
		}

		/**
		 * This is an abstract method which must be implemented by subclasses.
		 **/
		public function apply(width:int, height:int):void { }
	}
}
