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
 
package birdeye.vis.elements.geometry {

	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.Position;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;

	public class NodeElement extends BaseElement implements IGraphLayoutableElement {

		public function NodeElement() {
			super();
		}
		
		private var _graphLayout:IGraphLayout;

		public function set graphLayout(layout:IGraphLayout):void {
			_graphLayout = layout;
		}

		public function get graphLayout():IGraphLayout {
			return _graphLayout;
		}

		private var _dimId:String;
		
		public function set dimId(val:String):void {
			_dimId = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		public function get dimId():String {
			return _dimId;
		}

		private var _dimName:String;
		
		public function set dimName(val:String):void {
			_dimName = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		public function get dimName():String {
			return _dimName;
		}
		
		override protected function createGlobalGeometryGroup():void {
			// do nothing: no need to create the global group 
	    }

		public function getItemIndexById(id:Object):int {
			const items:Vector.<Object> = dataItems;
			if (!items) return -1;
			for (var i:int = 0; i < items.length; i++) {
				if (items[i][_dimId] == id) return i;
			}
			return -1;
		}

		public function isItemVisible(itemId:Object):Boolean {
			return _graphLayout.isNodeItemVisible(itemId);
		}
		
		public function getItemPosition(itemId:Object):Position {
			return _graphLayout.getNodeItemPosition(itemId);
		}
		
		protected function createItemRenderer():IGeometry {
			const bounds:Rectangle = new Rectangle(0 - _size, 0 - _size, _size * 2, _size * 2);
			var renderer:IGeometry;
 			if (_source)
				renderer = new RasterRenderer(bounds, _source);
 			else {
 				if (itemRenderer) {
 					renderer = itemRenderer.newInstance();
 					if (renderer is IBoundedRenderer) (renderer as IBoundedRenderer).bounds = bounds;
 				} else {
					renderer = new CircleRenderer(bounds);
				}
			}
			renderer.fill = fill;
			renderer.stroke = stroke;
			return renderer;
		}
		
		protected function createLabelRenderer(text:String):IGeometry {
			const label:TextRenderer = TextRenderer.createTextLabel(
				   0, 0 + _size,
				   text,
				   new SolidFill(0xffffff),  // TODO: add textFill property
				   true, false
			);
			label.fontSize = 9;
			label.fontFamily = "arial";
			return label;
		}
		
		override public function drawElement():void {
			super.drawElement();
				
			prepareForItemDisplayObjectsCreation();

			const items:Vector.<Object> = dataItems;
			if (items) {
				items.forEach(function(item:Object, index:int, items:Vector.<Object>):void {
					const itemId:Object = item[dimId];
					if (isItemVisible(itemId)) {
						const position:Position = getItemPosition(itemId);
						if (position != null) {
							createItemDisplayObject(
								position, itemId,
								[createItemRenderer(), createLabelRenderer(item[dimName])]);
						}
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
