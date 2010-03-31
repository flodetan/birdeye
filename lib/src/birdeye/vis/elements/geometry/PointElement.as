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
	import birdeye.vis.VisScene;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.interfaces.data.IExportableSVG;
	import birdeye.vis.interfaces.elements.IPositionableElement;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.scales.*;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	
	import org.greenthreads.IThread;
	
	public class PointElement extends StackElement implements IPositionableElement, IThread
	{
		
		public function PointElement()
		{
			super();
	
			invalidatingDisplay();
		}
		
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
		
		private var _itemRendererInst:DisplayObject;
		private var _itemRenderer:IFactory;
		private var _itemRendererChanged:Boolean = false;
		/** Set the item renderer following the standard Flex approach. The item renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set itemRenderer(val:IFactory):void
		{
			_itemRenderer = val;
			_itemRendererChanged = true;
			invalidateProperties();
		}
		
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (_itemRendererChanged)
			{
				_itemRendererChanged = false;
				
				invalidatingDisplay();
				
			}
			
		}
		
		override protected function createDefaultGraphicsRenderer():void
		{
			_graphicsRendererInst = new CircleRenderer();
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
		
		
		private var _drawingData:Array;
		
		override public function preDraw():Boolean
		{
			if (!(isReadyForLayout() && _invalidatedElementGraphic) )
			{
				return false;
			}
			
			this.graphics.clear();
			var currentItem:Object;
			
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
			
			 _drawingData= new Array();
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				currentItem = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				if (visScene.coordType == VisScene.POLAR)
				{
					var xPos:Number = PolarCoordinateTransform.getX(scaleResults[POS1], scaleResults[POS2], visScene.origin);
					var yPos:Number = PolarCoordinateTransform.getY(scaleResults[POS1], scaleResults[POS2], visScene.origin);
					scaleResults[POS1] = xPos;
					scaleResults[POS2] = yPos; 
				}
				
				if (dim1 && currentItem[dim1] == undefined ||
					dim2 && currentItem[dim2] == undefined ||
					dim3 && currentItem[dim3] == undefined)
					continue;
				
				
				var d:Object = new Object();
				
				if (!scaleResults[SIZE] || isNaN(scaleResults[SIZE]))
				{
					scaleResults[SIZE] = _graphicRendererSize;		
				}
				
				// save bounds (for graphicRenderer)
				d.bounds = new Rectangle(scaleResults[POS1] - scaleResults[SIZE], scaleResults[POS2] - scaleResults[SIZE], scaleResults[SIZE] * 2, scaleResults[SIZE] * 2);
				
				// save inner data
				d.data = currentItem[dataField];
				
				// save fill and stroke
				d.fill = scaleResults[COLOR];
				d.stroke = stroke;
				
				// determine width, height, x and y (for itemRenderers)
				if (sizeScale && sizeField && scaleResults[SIZE] > 0)
				{
					d.width = d.height = scaleResults[SIZE];
				}
				else if (!isNaN(widthAutosize) && !isNaN(heightAutosize)) 
				{
					d.height = heightAutosize;
					d.width = widthAutosize;
				} 
				else if (!isNaN(widthAutosize) && !scale2)
				{
					d.height = this.height;
					d.width = widthAutosize;							
				}
				else if (!isNaN(heightAutosize) && !scale1)
				{
					d.height = heightAutosize;
					d.width = this.width;
				}							
				else if (sizeRenderer > 0)
				{
					d.width = d.height = sizeRenderer;
				}	
				else 
				{
					if (rendererWidth > 0)
						d.width = rendererWidth;
					if (rendererHeight > 0)
						d.height = rendererHeight;
				}
				
				if (!isNaN(scaleResults[POS1]))
				{
					d.x = scaleResults[POS1] - d.width/2;
				}
				else
				{
					d.x = 0;
				}
				
				if (!isNaN(scaleResults[POS2]))
				{
					d.y = scaleResults[POS2] - d.height/2;
				}
				else
				{
					d.y = 0;
				}
				
				_drawingData.push(d);
			}
			
			return true && super.preDraw();
		}

		override public function drawDataItem() :Boolean
		{
			var d:Object = _drawingData[_currentItemIndex];

			if (_graphicsRendererInst)
			{
				if (_graphicsRendererInst is IBoundedRenderer)
				{		
					(_graphicsRendererInst as IBoundedRenderer).bounds = d.bounds;
				}										
				
				_graphicsRendererInst.fill = d.fill;
				_graphicsRendererInst.stroke = d.stroke;
					
				_graphicsRendererInst.draw(this.graphics, null);
					
			}
			
			
			if (_itemRenderer)
			{
				var itemInst:DisplayObject = _itemRenderer.newInstance();
				
				this.addChild(itemInst);
				
				if (itemInst is IDataRenderer)
				{
					(itemInst as IDataRenderer).data = d.data;
				}
				itemInst.x = d.x;
				itemInst.y = d.y;
				itemInst.width = d.width;
				itemInst.height = d.height;
			}
			
			return true && super.drawDataItem();
		}
	}
}