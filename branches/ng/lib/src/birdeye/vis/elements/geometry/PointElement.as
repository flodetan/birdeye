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
	import __AS3__.vec.Vector;
	
	import birdeye.vis.VisScene;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.Position;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IPositionableElement;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;

	public class PointElement extends StackElement implements IPositionableElement, IDataRenderer
	{
		private var _data:Object;
		/**
		 *  @private
		 *  The data to render or edit.
		 */
		public function set data(value:Object):void
		{
			_data = value;
			invalidateDisplayList();
		}
		public function get data():Object
		{
			return _data;
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

		private var label:TextRenderer;
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
				var scaleResults:Object;

				y0 = getYMinPosition();
				x0 = getYMinPosition();
				
				var widthAutosize:Number = NaN;
				var heightAutosize:Number = NaN;
				if (scale1 && scale1 is IEnumerableScale && 
					scale2 && scale2 is IEnumerableScale)
				{
					widthAutosize = IEnumerableScale(scale1).size/IEnumerableScale(scale1).dataProvider.length;
					heightAutosize = IEnumerableScale(scale2).size/IEnumerableScale(scale2).dataProvider.length;
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

					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(currentItem, dataFields, scaleResults["pos1"], scaleResults["pos2"], scaleResults["pos3Relative"], scaleResults["size"]);
	
					if (itemRenderer != null)
					{
						var itmDisplay:DisplayObject = itemRenderer.newInstance();
						if (dataField && itmDisplay is IDataRenderer)
							(itmDisplay as IDataRenderer).data = currentItem[dataField];
						addChild(itmDisplay);

						if (sizeScale && sizeField && scaleResults["size"] > 0)
							DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = scaleResults["size"];
						else if (!isNaN(widthAutosize) && !isNaN(heightAutosize)) {
							DisplayObject(itmDisplay).width = widthAutosize;
							DisplayObject(itmDisplay).height = heightAutosize;
						} else if (sizeRenderer > 0)
							DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = sizeRenderer;
 						else {
							if (rendererWidth > 0)
								DisplayObject(itmDisplay).width = rendererWidth;
							if (rendererHeight > 0)
								DisplayObject(itmDisplay).height = rendererHeight;
						}
						
						itmDisplay.x = scaleResults["pos1"] - itmDisplay.width/2;
						itmDisplay.y = scaleResults["pos2"] - itmDisplay.height/2;
					}
					
					if (dim3)
					{
						if (!isNaN(scaleResults["pos3"]))
						{
							// why is this created again???
							// is just setting the z value not enough?
							gg = new DataItemLayout();
							gg.target = this;
							graphicsCollection.addItem(gg);
							ttGG.z = gg.z = scaleResults["pos3"];
						} else
							scaleResults["pos3"] = 0;
					}
					
					if (_extendMouseEvents)
					{
						gg = ttGG;
						gg.target = this;
					}


					createPlotItems(currentItem, scaleResults);

					if (dim3)
					{
						gg.z = scaleResults["pos3"];
						if (isNaN(scaleResults["pos3"]))
							scaleResults["pos3"] = 0;
					}
				}
				
				if (dim3)
					zSort();
	
				_invalidatedElementGraphic = false;
trace (getTimer(), "drawing point ele");
	
			}
		}

		private var y0:Number;
		private var x0:Number;		
		private function determinePositions(dim1:Object, dim2:Object, dim3:Object=null,color:Object=null, size:Object=null, currentItem:Object=null):Object
		{
			var scaleResults:Object = new Object();
			
			scaleResults["size"] = _size;
			scaleResults["color"] = fill;
			
			if (scale1)
			{
				if (scale1 is INumerableScale && _stackType == STACKED100)
				{
					x0 = scale1.getPosition(baseValues[dim2]);
					if (!isNaN(dim1 as Number))
					{
						scaleResults["pos1"] = scale1.getPosition(
							baseValues[dim2] + Math.max(0,Number(dim1 as Number)));
					}
					else
					{
						scaleResults["pos1"] = NaN;
					}
				} else {
					scaleResults["pos1"] = scale1.getPosition(dim1);
				}
			}
					
			if (scale1 is ISubScale && (scale1 as ISubScale).subScalesActive)
			{
				scaleResults["pos2"] = (scale1 as ISubScale).subScales[dim1].getPosition(dim2);
			} 

			if (scale2)
			{
				// if the stackType is stacked100, than the y0 coordinate of 
				// the current baseValue is added to the y coordinate of the current
				// data value filtered by yField
				if (scale2 is INumerableScale && _stackType == STACKED100)
				{
					y0 = scale2.getPosition(baseValues[dim1]);
					if (!isNaN(dim2 as Number))
					{
						scaleResults["pos2"] = scale2.getPosition(
							baseValues[dim1] + Math.max(0,dim2 as Number));
					}
					else
					{
						scaleResults["pos2"] = NaN;
					}
				} 
				else 
				{
					// if not stacked, than the y coordinate is given by the own y axis
					scaleResults["pos2"] = scale2.getPosition(dim2);
				}
			}
					
			var scale2RelativeValue:Number = NaN;

			if (scale3)
			{
				scaleResults["pos3"] = scale3.getPosition(dim3);
				scaleResults["pos3Relative"] = scale3.size - scaleResults["pos3"];
			} 
			
			if (colorScale)
			{
				var col:* = colorScale.getPosition(color);
				if (col is Number)
					scaleResults["color"] = new SolidFill(col);
				else if (col is IGraphicsFill)
					scaleResults["color"] = col;
			} 

			if (chart.coordType == VisScene.POLAR)
			{
				var xPos:Number = PolarCoordinateTransform.getX(scaleResults["pos1"], scaleResults["pos2"], chart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(scaleResults["pos1"], scaleResults["pos2"], chart.origin);
				scaleResults["pos1"] = xPos;
				scaleResults["pos2"] = yPos; 
			}

			if (sizeScale)
			{
				scaleResults["size"] = sizeScale.getPosition(size);
			}
			
			return scaleResults;
		}
		
		private function createPlotItems(currentItem:Object, scaleResults:Object):void
		{
			var bounds:Rectangle = new Rectangle(scaleResults["pos1"] - scaleResults["size"], scaleResults["pos2"] - scaleResults["size"], scaleResults["size"] * 2, scaleResults["size"] * 2);
	
			if (scaleResults["size"] > 0)
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
 					if (plot is IBoundedRenderer) (plot as IBoundedRenderer).bounds = bounds;
 				} 
				
				if(plot)
				{
					plot.fill = scaleResults["color"];
					plot.stroke = stroke;
					gg.geometryCollection.addItemAt(plot,0); 
				}
			}
			
			if (labelField)
			{
				label = new TextRenderer(null);
				if (currentItem[labelField])
					label.text = currentItem[labelField];
				else
					label.text = labelField;
					
				label.fill = scaleResults["color"];
				label.fontSize = sizeLabel;
				label.fontFamily = fontLabel;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.autoSizeField = true;
				label.x = scaleResults["pos1"] - label.displayObject.width/2;
				label.y = scaleResults["pos2"] - label.displayObject.height/2;
				ttGG.geometryCollection.addItemAt(label,0); 
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