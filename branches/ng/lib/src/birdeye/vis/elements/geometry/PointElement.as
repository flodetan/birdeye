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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.Position;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IPositionableElement;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.DisplayObject;
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

		public function getItemPosition(itemId:Object):Position {
			const item:Object = getDataItemById(itemId);
			if (item) {
				const pos:Object = determinePositions(item[dim1], item[dim2], item[dim3],
					 							  			   item[colorField], item[sizeField], item);
				return new Position(pos["pos1"], pos["pos2"], pos["pos3Relative"]);
			} else {
				return Position.ZERO;
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
				clearAll();
				
				if (!graphicRenderer)
					graphicRenderer = new ClassFactory(CircleRenderer);
				
				ggIndex = 0;
				
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
	 				if (graphicsCollection.items && graphicsCollection.items.length>ggIndex)
						gg = graphicsCollection.items[ggIndex];
					else
					{
						gg = new DataItemLayout();
						graphicsCollection.addItem(gg);
					}
					gg.target = this;
					ggIndex++;
					
					currentItem = _dataItems[cursorIndex];
					
					scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
															currentItem[colorField], currentItem[sizeField], currentItem);
				
					if (dim1 && currentItem[dim1] == undefined ||
						dim2 && currentItem[dim2] == undefined ||
						dim3 && currentItem[dim3] == undefined)
						continue;

					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(currentItem, dataFields, scaleResults[POS1], scaleResults[POS2], scaleResults[POS3relative], scaleResults[SIZE]);
	
					if (itemRenderer != null)
					{
						var itmDisplay:DisplayObject = itemRenderer.newInstance();
						if (dataField && itmDisplay is IDataRenderer)
							(itmDisplay as IDataRenderer).data = currentItem[dataField];
						addChild(itmDisplay);

						if (sizeScale && sizeField && scaleResults[SIZE] > 0)
						{
							DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = scaleResults[SIZE];
						}
						else if (!isNaN(widthAutosize) && !isNaN(heightAutosize)) 
						{
							DisplayObject(itmDisplay).height = heightAutosize;
							DisplayObject(itmDisplay).width = widthAutosize;
						} 
						else if (!isNaN(widthAutosize) && !scale2)
						{
							DisplayObject(itmDisplay).height = this.height;
							DisplayObject(itmDisplay).width = widthAutosize;							
						}
						else if (!isNaN(heightAutosize) && !scale1)
						{
							DisplayObject(itmDisplay).height = heightAutosize;
							DisplayObject(itmDisplay).width = this.width;
						}							
						else if (sizeRenderer > 0)
						{
							DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = sizeRenderer;
						}	
 						else 
 						{
							if (rendererWidth > 0)
								DisplayObject(itmDisplay).width = rendererWidth;
							if (rendererHeight > 0)
								DisplayObject(itmDisplay).height = rendererHeight;
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
					}
					
					if (dim3)
					{
						if (!isNaN(scaleResults[POS3]))
						{
							// why is this created again???
							// is just setting the z value not enough?
							gg = new DataItemLayout();
							gg.target = this;
							graphicsCollection.addItem(gg);
							ttGG.z = gg.z = scaleResults[POS3];
						} else
							scaleResults[POS3] = 0;
					}
					
					if (_extendMouseEvents)
					{
						gg = ttGG;
						gg.target = this;
					}


					createPlotItems(currentItem, scaleResults);

					if (dim3)
					{
						gg.z = scaleResults[POS3];
						if (isNaN(scaleResults[POS3]))
							scaleResults[POS3] = 0;
					}
				}
				if (dim3)
					zSort();
	
				createSVG();
				_invalidatedElementGraphic = false;
trace (getTimer(), "drawing point ele");
	
			}
		}

		private function createPlotItems(currentItem:Object, scaleResults:Object):void
		{
			var bounds:Rectangle = new Rectangle(scaleResults[POS1] - scaleResults[SIZE], scaleResults[POS2] - scaleResults[SIZE], scaleResults[SIZE] * 2, scaleResults[SIZE] * 2);
	
			if (scaleResults[SIZE] > 0)
			{
 				if (_source)
 				{
					plot = new RasterRenderer(bounds, _source);
				}
				else
				{					
 					var tmp:Object = graphicRenderer.newInstance();
 					plot = tmp as IGeometry;
 					Geometry(plot).preDraw();
 					if (plot is IBoundedRenderer)
 					{
 						(plot as IBoundedRenderer).bounds = bounds;
						addSVGData((plot as IBoundedRenderer).svgData);
 					} 
 				} 
				
				if(plot)
				{
					plot.fill = scaleResults[COLOR];
					plot.stroke = stroke;
					gg.geometryCollection.addItemAt(plot,0); 
				}
			}
		}

		// Be sure to remove all children in case an item renderer is used
		override public function clearAll():void
		{
			super.clearAll();
			if (_itemRenderer)
				for (var i:uint = 0; i<numChildren; )
					removeChild(getChildAt(0));
		}
	}
}