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
	import birdeye.vis.trans.graphs.events.VGraphEvent;
	import birdeye.vis.trans.graphs.model.INode;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class VisualNode implements IVisualNode
	{
		private var _node:INode;
		private var _moveable:Boolean;
		private var _visible:Boolean;
		private var _visualGraph:IVisualGraph;
		private var _x:Number = NaN;
		private var _y:Number = NaN;
		
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
		
		public function set visible(visible:Boolean):void
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
		
		public function commit():void {
			const v:DisplayObject = view;
			if (v) {
				if (_visualGraph.useIntegerPositions) {
					v.x = Math.round(_x - v.width * v.scaleX/2);
					v.y = Math.round(_y - v.height * v.scaleY/2);
				} else {
					v.x = _x - v.width * v.scaleX/2;
					v.y = _y - v.height * v.scaleY/2;
				}
				v.dispatchEvent(new VGraphEvent(VGraphEvent.VNODE_UPDATED));
			}
		}
		
		public function refresh():void
		{
			const v:DisplayObject = view;
			if (v) {
				_x = v.x + v.width * v.scaleX/2;
				_y = v.y + v.height * v.scaleY/2;
			}
		}

		private function get view():DisplayObject {
			return _visualGraph.getNodeDisplayObject(node.id);
		}
		
		public function get width():Number {
			const v:DisplayObject = view;
			if (!v) {
				return 0;
			} else {
				return view.width;
			}
		}

		public function get height():Number {
			const v:DisplayObject = view;
			if (!v) {
				return 0;
			} else {
				return view.height;
			}
		}

		public function get viewScaleX():Number {
			const v:DisplayObject = view;
			if (!v) {
				return 1.0;	
			} else {
				return v.scaleX;
			}
		}

		public function set viewScaleX(scaleX:Number):void {
			const v:DisplayObject = view;
			if (v) {
				v.scaleX = scaleX;
			}
		}

		public function get viewScaleY():Number {
			const v:DisplayObject = view;
			if (!v) {
				return 1.0;	
			} else {
				return v.scaleY;
			}
		}

		public function set viewScaleY(scaleY:Number):void {
			const v:DisplayObject = view;
			if (v) {
				v.scaleY = scaleY;
			}
		}

	}
}
