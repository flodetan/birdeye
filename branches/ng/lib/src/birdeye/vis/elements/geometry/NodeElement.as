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

	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.Position;
	import birdeye.vis.elements.RenderableElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IExportableSVG;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IDataRenderer;

	public class NodeElement extends RenderableElement implements IGraphLayoutableElement {

		public function NodeElement() {
			super();
		}
		
		private var renderers:Array = [];
		override public function get svgData():String
		{
			_svgData = "";
			for each (var itemDisplayObject:DisplayObject in _itemDisplayObjects)
			{
				if (itemDisplayObject is DataItemLayout)
				{
					for each (var geom:Geometry in DataItemLayout(itemDisplayObject).geometry)
					{
						if (geom is IExportableSVG)
						{
							var initialPoint:Point = localToContent(new Point(
												itemDisplayObject.x - geom.bounds.width/2, 
												itemDisplayObject.y - geom.bounds.height/2));
							
							_svgData += 
									'\n<svg x="' + initialPoint.x + '" y="' + initialPoint.y + '">' +
									'\n<g x="' + geom.bounds.width/2 + '" y="' + geom.bounds.height/2 + 
									'" style="' +
									'fill:' + ((rgbFill) ? '#' + rgbFill:'none') + 
									';fill-opacity:' + alphaFill + ';' + 
									'stroke:' + ((rgbStroke) ? '#' + rgbStroke:'none') + 
									';stroke-opacity:' + alphaStroke + ';' + ';">\n' + 
									IExportableSVG(geom).svgData +  
									'\n</g>\n' +
									'</svg>\n';
						}
					}
				}
			}
			return _svgData;
		}

		private var _graphLayout:IGraphLayout;

		public function set graphLayout(layout:IGraphLayout):void {
			_graphLayout = layout;
		}

		public function get graphLayout():IGraphLayout {
			return _graphLayout;
		}

		private var _labelFillColor:int = 0xffffff;

		public function set labelFillColor(color:int):void {
			_labelFillColor = color;
		}

		public function get labelFillColor():int {
			return _labelFillColor;
		}

		override protected function createGlobalGeometryGroup():void {
			// do nothing: no need to create the global group 
	    }

		public function getItemIndexById(id:Object):int {
			const items:Vector.<Object> = dataItems;
			if (!items) return -1;
			for (var i:int = 0; i < items.length; i++) {
				if (items[i][itemIdField] == id) return i;
			}
			return -1;
		}

		public function isItemVisible(itemId:Object):Boolean {
			return _graphLayout.isNodeItemVisible(itemId);
		}
		
		public function getItemPosition(itemId:Object):Position {
			return _graphLayout.getNodeItemPosition(itemId);
		}
		
		protected function createItemRenderer(currentItem:Object, position:Position):DisplayObject
		{
			var obj:DisplayObject = null;
			if (itemRenderer != null) {
				obj = itemRenderer.newInstance();
				if (dataField  &&  obj is IDataRenderer) {
					(obj as IDataRenderer).data = currentItem[dataField];
				}
				addChild(obj);
				if (sizeRenderer > 0) {
					obj.width = obj.height = sizeRenderer;
				}
					
				obj.x = position.pos1;
				obj.y = position.pos2;
			}
			return obj;
		}

		protected function createGraphicRenderer(currentItem:Object, position:Position):IGeometry {
			const bounds:Rectangle = new Rectangle(0 - _graphicRendererSize, 0 - _graphicRendererSize, _graphicRendererSize * 2, _graphicRendererSize * 2);
			var renderer:IGeometry;

			if (_source)
				renderer = new RasterRenderer(bounds, _source);
 			else {
 				if (graphicRenderer) {
 					renderer = graphicRenderer.newInstance();
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
			return new TextRenderer(
							   0, 0 + _graphicRendererSize,
							   text,
							   new SolidFill(labelFillColor),
							   true, false, sizeLabel, fontLabel);
		}
		
		override public function drawElement():void {
			super.drawElement();
				
			prepareForItemDisplayObjectsCreation();
			renderers = [];
			
			var dataFields:Array = [];
			if (dimName) dataFields["dimName"] = dimName;

			const items:Vector.<Object> = dataItems;
			if (items) {
				items.forEach(function(item:Object, index:int, items:Vector.<Object>):void {
					const itemId:Object = item[itemIdField];
					if (isItemVisible(itemId)) {
						const position:Position = getItemPosition(itemId);
						if (position != null) {
							var renderer:Object = {itemRenderer: createItemRenderer(item, position),
													graphicRenderer: [createGraphicRenderer(item, position), 
																	createLabelRenderer(item[dimName])]}
							createItemDisplayObject(
								item, dataFields, position, itemId,
								renderer);
							renderers.push(renderer);
						}
					}
				});
			}
			_invalidatedElementGraphic = false;
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
