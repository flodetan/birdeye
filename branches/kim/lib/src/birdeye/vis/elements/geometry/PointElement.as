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
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.facets.FacetContainer;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;

	public class PointElement extends BaseElement
	{
		public function PointElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = new ClassFactory(CircleRenderer);
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
				removeAllElements();
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim1;
				dataFields[1] = dim2;
				dataFields[2] = sizeField;
				if (dim3) 
					dataFields[3] = dim3;
				
				if (!itemRenderer)
					itemRenderer = new ClassFactory(CircleRenderer);
				
				ggIndex = 0;
				
				if (scale1 is IEnumerableScale && scale2 is IEnumerableScale)
				{
					// ok two categories, we need to loop categories
					// to avoid the issue where there are more subdata
					var enumScale1:IEnumerableScale = scale1 as IEnumerableScale;
					var enumScale2:IEnumerableScale = scale2 as IEnumerableScale;
					
					var enumLength1:Number = enumScale1.dataProvider.length;
					var enumLength2:Number = enumScale2.dataProvider.length;
					
					for (var i:uint=0;i<enumLength1;i++)
					{
						for (var j:uint=0;j<enumLength2;j++)
						{
							var filteredData:Object = filterData(enumScale1.dataProvider[i], enumScale2.dataProvider[j], enumScale1.categoryField, enumScale2.categoryField);
							
							var currentItem:Object = _dataItems[cursorIndex];
						
							var scaleResults:Object = determinePositions(enumScale1.dataProvider[i], enumScale2.dataProvider[j], null, null, null, null);
																							
							var bounds:Rectangle = new Rectangle(scaleResults["pos1"] - enumScale1.size/2/enumLength1 + 5, scaleResults["pos2"] - enumScale2.size/2/enumLength2 + 5, enumScale1.size/enumLength1 - 10, enumScale2.size/enumLength2 - 10);


							
							var tmp:Object = itemRenderer.newInstance();
 						
		 					if (tmp is FacetContainer)	
		 					{
		 						var subco:FacetContainer = tmp as FacetContainer;
		 						
		 						var coord:Object = subco.coord.clone();
		 						
		 						
		 						coord.scales = subco.scales;
		 						
		 						var el:Array = new Array();
		 						for each (var baseEl:BaseElement in subco.elements)
		 						{
		 							el.push(baseEl.clone());
		 						}
		 						coord.elements = el;
		 						
		 						coord.width = bounds.width;
		 						coord.height = bounds.height;
		 						coord.x = bounds.x;
		 						coord.y = bounds.y;
		 						coord.dataProvider = filteredData;

								this.addChild(coord as DisplayObject);
		 					}
						}
					}
				}
				else
				{		
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
							
							var currentItem:Object = _dataItems[cursorIndex];
							
							var scaleResults:Object = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
																	currentItem[colorField], currentItem[sizeField], currentItem);
		
							// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
							// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
							createTTGG(currentItem, dataFields, scaleResults["pos1"], scaleResults["pos2"], scaleResults["pos3Relative"], scaleResults["size"]);
			
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
								gg = ttGG;
		
		
							createPlotItems(currentItem, scaleResults);
		
							if (dim3)
							{
								gg.z = scaleResults["pos3"];
								if (isNaN(scaleResults["pos3"]))
									scaleResults["pos3"] = 0;
							}
					}
				}
				
				
				if (dim3)
					zSort();
	
					_invalidatedElementGraphic = false;
trace (getTimer(), "drawing point ele");
	
			}
		}
		
		private function determinePositions(dim1:Object, dim2:Object, dim3:Object=null,color:Object=null, size:Object=null, currentItem:Object=null):Object
		{
			var scaleResults:Object = new Object();
			
			scaleResults["size"] = _size;
			scaleResults["color"] = fill;
			
			if (scale1)
			{
				scaleResults["pos1"] = scale1.getPosition(dim1);
			} 
			
			if (scale2)
			{
				scaleResults["pos2"] = scale2.getPosition(dim2);
			} 

			var scale2RelativeValue:Number = NaN;

			if (scale3)
			{
				scaleResults["pos3"] = scale3.getPosition(dim3);
				scaleResults["pos3Relative"] = XYZ(scale3).height - scaleResults["pos3"];
			} 
			
			if (currentItem)
			{
				if (multiScale)
				{
					scaleResults["pos1"] = multiScale.scale1.getPosition(dim1);
					scaleResults["pos2"] = INumerableScale(multiScale.scales[
										currentItem[multiScale.dim1]
										]).getPosition(dim2);
				} else if (chart.multiScale) {
					scaleResults["pos1"] = chart.multiScale.scale1.getPosition(dim1);
					scaleResults["pos2"] = INumerableScale(chart.multiScale.scales[
										currentItem[chart.multiScale.dim1]
										]).getPosition(dim2);
				}
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
				var xPos:Number = PolarCoordinateTransform.getX(scaleResults[0], scaleResults[1], chart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(scaleResults[0], scaleResults[1], chart.origin);
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
 					var tmp:Object = itemRenderer.newInstance();
 						
 					if (tmp is DisplayObject)	
 					{
 						tmp.width = bounds.width;
 						tmp.height = bounds.height;
 						tmp.x = bounds.x;
 						tmp.y = bounds.y;
 						trace("ADDING CHILD ON x:" + bounds.x + " y:"+ bounds.y + " and w:"+bounds.width + " and h:"+bounds.height); 
 						this.addChild(tmp as DisplayObject);
 					}
 					else
 					{
 						plot = tmp as IGeometry;
 						if (plot is IBoundedRenderer) (plot as IBoundedRenderer).bounds = bounds;
 					}
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
		
		private function filterData(scale1Value:Object, scale2Value:Object, scale1CategoryField:Object, scale2CategoryField:Object):Vector.<Object>
		{
			var filteredDataItems:Vector.<Object> = new Vector.<Object>();
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				var currentItem:Object = _dataItems[cursorIndex];
				
				if (currentItem[scale1CategoryField] == scale1Value && currentItem[scale2CategoryField] == scale2Value)
				{
					filteredDataItems.push(currentItem);
				}
			}
			
			return filteredDataItems;
		}
		
		private var _testje:Array;
		public function set testje(t:Array):void
		{
			_testje = t;	
		}
		
		 
	}
}