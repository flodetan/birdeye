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
	import birdeye.vis.control.ElementDrawerThread;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.interfaces.data.IExportableSVG;
	import birdeye.vis.interfaces.elements.IPositionableElement;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;

	public class PointElement extends StackElement implements IPositionableElement
	{
		private var _dataField:String;
		/** Define the dataField used to catch the data to be passed to the itemRenderer.*/
		public function set dataField(val:String):void
		{
			_dataField = val;
			invalidateDisplayList();
		}
		public function get dataField():String
		{
			return _dataField;
		}
		
		override public function get svgData():String
		{
			var child:Object;
			var localOriginPoint:Point = localToGlobal(new Point(x, y)); 
			var nestedScenesSVG:String = "";
			for (var i:uint = 0; i<numChildren; i++)
			{
				child = getChildAt(i);
				if (child is IExportableSVG)
					nestedScenesSVG += '<svg x="' + String(-localOriginPoint.x) +
										   '" y="' + String(-localOriginPoint.y) + '">' + 
										   IExportableSVG(child).svgData + 
										'</svg>';
			}
			return _svgData + nestedScenesSVG;
		}
		
		private var _itemRenderer:IFactory;
		/** Set the item renderer following the standard Flex approach. The item renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set itemRenderer(val:IFactory):void
		{
			_itemRenderer = val;
			invalidatingDisplay();
		}
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		public function PointElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(CircleRenderer);
		}

		public function getItemPosition(itemId:Object):Point {
			const item:Object = getDataItemById(itemId);
			if (item) {
				const pos:Object = determinePositions(item[dim1], item[dim2], item[dim3],
					 							  			   item[colorField], item[sizeField], item);
				return new Point(pos["pos1"], pos["pos2"]);
			} else {
				return new Point(0,0);
			}
		}

		public function isItemVisible(itemId:Object):Boolean {
			return true;
		}

		private var plot:IGeometry;
		
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace (getTimer(), "drawing point ele");
				super.drawElement();
				
				if (!graphicRenderer)
					graphicRenderer = new ClassFactory(CircleRenderer);

					
				if (itemRenderer != null)
				{
					placeItemRenderers();	
				}

				if (graphicRenderer)
				{
					plot = graphicRenderer.newInstance();
					
					var elThr:ElementDrawerThread = new ElementDrawerThread();
					elThr.element = this;
					elThr.data = createDrawingData();
	
					elThr.start(0.8);
				}				
				_invalidatedElementGraphic = false;
trace (getTimer(), "drawing point ele");
	
			}
		}
		
		public function createDrawingData():Array
		{
			var drawingData:Array = new Array();
			var currentItem:Object;
			
			y0 = getYMinPosition();
			x0 = getYMinPosition();
			
			var widthAutosize:Number = NaN;
			var heightAutosize:Number = NaN;
			if (scale1 && scale1 is IEnumerableScale)
			{
				widthAutosize = IEnumerableScale(scale1).size/IEnumerableScale(scale1).dataProvider.length - 10;					
			} 
			
			if (scale2 && scale2 is IEnumerableScale)
			{
				heightAutosize = IEnumerableScale(scale2).size/IEnumerableScale(scale2).dataProvider.length - 10;
			}

			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				currentItem = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				if (dim1 && currentItem[dim1] == undefined ||
					dim2 && currentItem[dim2] == undefined ||
					dim3 && currentItem[dim3] == undefined)
					continue;
				
				var bounds:Rectangle = new Rectangle(scaleResults[POS1] - scaleResults[SIZE], scaleResults[POS2] - scaleResults[SIZE], scaleResults[SIZE] * 2, scaleResults[SIZE] * 2);
	
				var d:Object = new Object();
				d.bounds = bounds;
				d.fill = scaleResults[COLOR];
				d.stroke = stroke;
				
				drawingData.push(d);
				
			}
			
			return drawingData;
		}
		
		private function placeItemRenderers():void
		{	
			var currentItem:Object;
			
			y0 = getYMinPosition();
			x0 = getYMinPosition();
			
			var widthAutosize:Number = NaN;
			var heightAutosize:Number = NaN;
			if (scale1 && scale1 is IEnumerableScale)
			{
				widthAutosize = IEnumerableScale(scale1).size/IEnumerableScale(scale1).dataProvider.length - 10;					
			} 
			
			if (scale2 && scale2 is IEnumerableScale)
			{
				heightAutosize = IEnumerableScale(scale2).size/IEnumerableScale(scale2).dataProvider.length - 10;
			}

			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				currentItem = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				if (dim1 && currentItem[dim1] == undefined ||
					dim2 && currentItem[dim2] == undefined ||
					dim3 && currentItem[dim3] == undefined)
					continue;
				
				var itmDisplay:DisplayObject = itemRenderer.newInstance();
				if (dataField && itmDisplay is IDataRenderer)
					(itmDisplay as IDataRenderer).data = currentItem[dataField];
				addChild(itmDisplay);
				
				if (sizeScale && sizeField && scaleResults[SIZE] > 0)
				{
					itmDisplay.width = itmDisplay.height = scaleResults[SIZE];
				}
				else if (!isNaN(widthAutosize) && !isNaN(heightAutosize)) 
				{
					itmDisplay.height = heightAutosize;
					itmDisplay.width = widthAutosize;
				} 
				else if (!isNaN(widthAutosize) && !scale2)
				{
					itmDisplay.height = this.height;
					itmDisplay.width = widthAutosize;							
				}
				else if (!isNaN(heightAutosize) && !scale1)
				{
					itmDisplay.height = heightAutosize;
					itmDisplay.width = this.width;
				}							
				else if (sizeRenderer > 0)
				{
					itmDisplay.width = itmDisplay.height = sizeRenderer;
				}	
				else 
				{
					if (rendererWidth > 0)
						itmDisplay.width = rendererWidth;
					if (rendererHeight > 0)
						itmDisplay.height = rendererHeight;
				}
				
				if (!isNaN(scaleResults[POS1]))
				{
					itmDisplay.x = scaleResults[POS1] - itmDisplay.width/2;
				}
				else
				{
					itmDisplay.x = 0;
				}
				
				if (!isNaN(scaleResults[POS2]))
				{
					itmDisplay.y = scaleResults[POS2] - itmDisplay.height/2;
				}
				else
				{
					itmDisplay.y = 0;
				}
				
				if (draggableItems)
					itmDisplay.addEventListener(MouseEvent.MOUSE_DOWN, super.startDragging);
			}
		}
		
		
		public function drawDataPoint(d:Object):void
		{	
			if (plot is IBoundedRenderer)
				{
					(plot as IBoundedRenderer).bounds = d.bounds;
					addSVGData((plot as IBoundedRenderer).svgData);
					
					plot.fill = d.fill;
					plot.stroke = d.stroke;
					
					plot.draw(this.graphics, null);
					
				}
			
		}
	
	}
}