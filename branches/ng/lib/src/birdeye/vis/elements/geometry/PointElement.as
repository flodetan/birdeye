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
	import birdeye.vis.elements.Position;
	import birdeye.vis.elements.RenderableElement;
	import birdeye.vis.facets.FacetContainer;
	import birdeye.vis.guides.axis.Axis;
	import birdeye.vis.guides.axis.MultiAxis;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IPositionableElement;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
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

	public class PointElement extends RenderableElement implements IPositionableElement
	{
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
				
				if (graphicRenderer is FacetContainer) 
				{
					// ok two categories, we need to loop categories
					// to avoid the issue where there are more subdata
					var enumScale1:IEnumerableScale = scale1 as IEnumerableScale;
					var enumScale2:IEnumerableScale = scale2 as IEnumerableScale;
					
					var enumLength1:Number = 1;
					var enumLength2:Number = 1;
					if (enumScale1)
					{
						enumLength1 = enumScale1.dataProvider.length;
					}
					
					if (enumScale2)
					{
						enumLength2 = enumScale2.dataProvider.length;
					}
					
					for (var i:uint=0;i<enumLength1;i++)
					{
						for (var j:uint=0;j<enumLength2;j++)
						{
							var currentItem:Object = _dataItems[cursorIndex];

							if (enumScale1 && enumScale2)
							{
								var filteredData:Object = filterData(enumScale1.dataProvider[i], enumScale1.categoryField, enumScale2.dataProvider[j],  enumScale2.categoryField);		
		
								var scaleResults:Object = determinePositions(enumScale1.dataProvider[i], enumScale2.dataProvider[j], null, null, null, null);
																								
								var bounds:Rectangle = new Rectangle(scaleResults["pos1"] - enumScale1.size/2/enumLength1 + 5, scaleResults["pos2"] - enumScale2.size/2/enumLength2 + 5, enumScale1.size/enumLength1 - 10, enumScale2.size/enumLength2 - 10);
							}
							else if (enumScale1 && !enumScale2)
							{
								filteredData = filterData(enumScale1.dataProvider[i], enumScale1.categoryField);
								
								scaleResults = determinePositions(enumScale1.dataProvider[i], null);
								
								bounds = new Rectangle(scaleResults["pos1"] - enumScale1.size/2/enumLength1 + 5, 0, enumScale1.size/enumLength1 - 10,height);

							}
							else if (!enumScale1 && enumScale2)
							{
								filteredData = filterData(enumScale2.dataProvider[j], enumScale2.categoryField);
								
								scaleResults = determinePositions(null,enumScale2.dataProvider[j]);
								
								bounds = new Rectangle(0, scaleResults["pos2"] - enumScale2.size/2/enumLength2 + 5, width,enumScale2.size/enumLength2 - 10);
							}

	 						var subco:FacetContainer = graphicRenderer.newInstance() as FacetContainer;
	 						
	 						var coord:Object = subco.coord.clone();
	 						
	 						var sc:Array = new Array();
	 						for each (var scale:IScale in subco.scales)
	 						{
	 							// percents need to have locally min and max
	 							if (scale is Percent)
	 							{
	 								sc.push((scale as Percent).clone());
	 							}
	 							else
	 							{
	 								sc.push(scale);
	 							}
	 						}
	 						coord.scales = sc;
	 						
	 						var el:Array = new Array();
	 						for each (var baseEl:BaseElement in subco.elements)
	 						{
	 							var elem:IElement = baseEl.clone();
	 							
	 							if (elem.scale1 is Percent)
	 							{
	 								var k:uint = subco.scales.indexOf(elem.scale1);
	 								
	 								if (k > -1)
	 								{
	 									elem.scale1 = sc[k];
	 								}
	 								
	 							}
	 							
	 							if (elem.scale2 is Percent)
	 							{
	 								k = subco.scales.indexOf(elem.scale2);
	 								
	 								if (k > -1)
	 								{
	 									elem.scale2 = sc[k];
	 								}
	
	 							}
	 							
	 							el.push(elem);
	 						}
	 						
	 						coord.elements = el;
	 						
	 						var gu:Array = new Array();
	 						for each (var g:Object in subco.guides)
	 						{
	 							if (g is Axis)
	 							{
	 								var ta:Axis = (g as Axis).clone();
	 								
	 								if (ta.scale is Percent)
	 								{
	 									k= subco.scales.indexOf(ta.scale);
	 									if (k > -1)
	 									{
	 										ta.scale = sc[k];
	 									}
	 								}
	 								
	 								gu.push(ta);
	 							}
	 							else if (g is MultiAxis)
	 							{
	 								gu.push((g as MultiAxis).clone());
	 							}
	 						}
	 						coord.guides = gu;
	 						
	 						
	 						coord.width = bounds.width;
	 						coord.height = bounds.height;
	 						coord.x = bounds.x;
	 						coord.y = bounds.y;
	 						coord.dataProvider = filteredData;

							this.addChild(coord as DisplayObject);
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
							
							currentItem = _dataItems[cursorIndex];
							
							scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
																	currentItem[colorField], currentItem[sizeField], currentItem);
		
							// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
							// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
							createTTGG(currentItem, dataFields, scaleResults["pos1"], scaleResults["pos2"], scaleResults["pos3Relative"], scaleResults["size"]);
			
							if (itemRenderer != null)
							{
								var itmDisplay:DisplayObject = new itemRenderer();
								if (dataField && itmDisplay is IDataRenderer)
									(itmDisplay as IDataRenderer).data = currentItem[dataField];
								addChild(itmDisplay);

								if (sizeScale && sizeField && scaleResults["size"] > 0)
									DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = scaleResults["size"];
								else if (sizeRenderer > 0)
									DisplayObject(itmDisplay).width = DisplayObject(itmDisplay).height = sizeRenderer;
									
								
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
			
			if (scale1 is ISubScale && (scale1 as ISubScale).subScalesActive)
			{
				scaleResults["pos2"] = (scale1 as ISubScale).subScales[dim1].getPosition(dim2);
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
		
		private function filterData(scale1Value:Object, scale1CategoryField:Object, scale2Value:Object=null, scale2CategoryField:Object=null):Vector.<Object>
		{
			var filteredDataItems:Vector.<Object> = new Vector.<Object>();
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				var currentItem:Object = _dataItems[cursorIndex];
				

				if ( ( (!scale1Value || !scale1CategoryField) || (currentItem[scale1CategoryField] == scale1Value) ) && 
					 ( (!scale2Value || !scale2CategoryField) || (currentItem[scale2CategoryField] == scale2Value) )
				   )
				{
					filteredDataItems.push(currentItem);
				}
			}
			
			return filteredDataItems;
		}
	}
}