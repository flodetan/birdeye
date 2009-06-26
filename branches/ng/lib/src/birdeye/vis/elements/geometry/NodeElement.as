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
 
package birdeye.vis.elements.geometry
{
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.Position;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	[Event(name="objectMovedEvent", type="com.roguedevelopment.objecthandles.ObjectHandleEvent")]
	public class NodeElement extends BaseElement implements IGraphLayoutableElement
	{
		public function NodeElement() {
			super();
		}
		
		private var _layout:IGraphLayout;

		public function set graphLayout(val:IGraphLayout):void {
			_layout = val;
		}

		public function get graphLayout():IGraphLayout {
			return _layout;
		}

		private var _dimId:String;
		
		public function set dimId(val:String):void
		{
			_dimId = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dimId():String
		{
			return _dimId;
		}

		private var _dimName:String;
		
		public function set dimName(val:String):void
		{
			_dimName = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dimName():String
		{
			return _dimName;
		}

		public function getItemIndexById(id:Object):int {
			if (!_dataItems) return -1;
			for (var i:int = 0; i < _dataItems.length; i++) {
				if (_dataItems[i][_dimId] == id) return i;
			}
			return -1;
		}

		public function getItemPosition(id:Object):Position {
			var index:int = getItemIndexById(id);
			if (index >= 0)	{
				return _layout.getNodeItemPosition(index);
			} else {
				return null;
			}
		}
		
		protected function createItemRenderer(bounds:Rectangle):IGeometry {
			var renderer:IGeometry;
 			if (_source)
				renderer = new RasterRenderer(bounds, _source);
 			else {
 				if (itemRenderer)
					renderer = new itemRenderer(bounds);
				else
					renderer = new CircleRenderer(bounds);
			}
			renderer.fill = fill;
			renderer.stroke = stroke;
			return renderer;
		}
		
		/*
		protected function createLabelRenderer(bounds:Rectangle, text:String):IGeometry {
			var renderer:IGeometry;
			renderer = new LabelRenderer(bounds);
			renderer.fill = fill;
			renderer.stroke = stroke;
			return renderer;
		}
		*/

		private function bounds(x:int, y:int):Rectangle {
			return new Rectangle(x - _size, y - _size, _size * 2, _size * 2);
		}
		
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			super.drawElement();
				
			prepareForItemGeometriesCreation();

			const dataFieldNames:Array = [dimId, dimName];
			const dataItems = dataItems;
				
			const thisNode:NodeElement = this;
			
			if (dataItems) {
				dataItems.forEach(function(item:Object, index:int, items:Vector.<Object>) {
					var pos1:Number = NaN, pos2:Number = NaN, pos3:Number = NaN;
	
					const position:Position = _layout.getNodeItemPosition(index);
	
					// We cannot use scale.getPosition here, because
					// scales work in an inherently different way, than
					// what we need: they calc min/max of the input data
					// values. In case of Node/Edge we don't have these
					// values (positions), so the scales think we have no data
					// and create a zero-size viewport.
	
	//				if (scale1) {
	//					pos1 = scale1.getPosition(position.pos1);
	//				}
	//				if (scale2) {
	//					pos2 = scale2.getPosition(position.pos2);
	//				}
	
					if (position != null) {
						pos1 = position.pos1;
						pos2 = position.pos2;
			
						createTTGG(item, dataFieldNames, pos1, pos2, 1.0, _size * 2);
						
						var group:GeometryGroup = createItemGeometryGroup();
						group.geometry = [
							createItemRenderer(bounds(pos1, pos2)),
							TextRenderer.createTextLabel(
								   pos1, pos2 + _size,
								   item[dimName], 
								   new SolidFill(0xffffff),  // TODO: add textFill property
								   true, false
							)
						];
					}
				});
			}
		}

		/*
		protected function addMoveEventListeneres() : void {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);		
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);			
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private var isMoving:Boolean;
		private var originalPosition:Point = new Point();
		
		protected function onMouseDown(event:MouseEvent):void {
			isMoving = true;
			originalPosition.x = x;
			originalPosition.y = y;
		} 

		protected function onMouseUp(event:MouseEvent):void {
			if (isMoving) {
				isMoving = false;
			}
		} 

		protected function onMouseMove(event:MouseEvent):void {
			if (isMoving) {
				var dest:Point = parent.globalToLocal(new Point(event.stageX, event.stageY));
				x = dest.x;
				y = dest.y;
			}
		} 
		*/

	}
}
