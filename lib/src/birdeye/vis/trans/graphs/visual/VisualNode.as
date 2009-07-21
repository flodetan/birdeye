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

package birdeye.vis.trans.graphs.visual
{
	import birdeye.vis.trans.graphs.model.INode;
	
	import com.degrafa.IGraphic;

	public class VisualNode implements IVisualNode
	{
		private var _node:INode;
		private var _moveable:Boolean;
		private var _visible:Boolean;
		private var _visualGraph:IVisualGraph;
		private var _x:Number = 0;
		private var _y:Number = 0;
		
		public function VisualNode(visualGraph:IVisualGraph, node:INode, moveable:Boolean)
		{
			_visualGraph = visualGraph;
			_node = node;
			_moveable = moveable;
		}

		public function get moveable():Boolean
		{
			return _moveable;
		}

		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(visible:Boolean)
		{
			_visible = visible;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get node():INode
		{
			return _node;
		}
		
		public function get orientAngle():Number
		{
			//TODO: implement function
			return 0;
		}
		
		public function set orientAngle(oa:Number):void
		{
			//TODO: implement function
		}
		
		public function commit():void
		{
			//TODO: implement function
		}
		
		public function refresh():void
		{
			//TODO: implement function
		}

		public function get view():IGraphic {
			return _visualGraph.getNodeGraphic(node.id);
		}
		
		public function get width():Number {
			const v:IGraphic = view;
			if (!v) return 0;
			return v.width;
		}

		public function get height():Number {
			const v:IGraphic = view;
			if (!v) return 0;
			return view.height;
		}

		public function get viewScaleX():Number {
			// TODO: implement VisualNode.viewScaleX
			return 1.0;
		}

		public function set viewScaleX(scaleX:Number):void {
		}

		public function get viewScaleY():Number {
			// TODO: implement VisualNode.viewScaleY
			return 1.0;
		}

		public function set viewScaleY(scaleY:Number):void {
		}

	}
}
