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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.ArcPath;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	
	import flash.text.TextFieldAutoSize;
	
	import mx.core.ClassFactory;

	public class WedgeElement extends StackElement
	{
		private var _innerRadius:Number;
		public function set innerRadius(val:Number):void
		{
			_innerRadius = val;
			invalidatingDisplay();
		}
		
		private var _radiusLabelOffset:Number;
		public function set radiusLabelOffset(val:Number):void
		{
			_radiusLabelOffset = val;
			invalidatingDisplay();
		}		

		public function WedgeElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (_stackType != OVERLAID || _stackType != STACKED100)
				_stackType = STACKED100;

			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(CircleRenderer);
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
				super.drawElement();
				clearAll();
				var c:uint = 0;
				
				var angle:Number, radius:Number = NaN;
				
				var startAngle:Number = 0; 
				
				var arcSize:Number = NaN;
				
				switch (_stackType)
				{
					case STACKED100:
						break;
					case OVERLAID:
						break;
				}
					
				if (graphicsCollection.items && graphicsCollection.items.length>0)
					gg = graphicsCollection.items[0];
				else
				{
					gg = new DataItemLayout();
					graphicsCollection.addItem(gg);
				}
				gg.target = this;
				ggIndex = 1;
	
				if (scale2)
					radius = scale2.size;
				
				var tmpRadius:Number = radius;
				if (_total>0)
				{
					_innerRadius = radius/_total * _stackPosition; 
					tmpRadius = _innerRadius + radius/_total * chart.columnWidthRate;
				}
	
				var arcCenterX:Number = chart.origin.x - radius;
				var arcCenterY:Number = chart.origin.y - radius;
	
				var wSize:Number, hSize:Number;
				wSize = hSize = radius*2;
	
				var aAxis:IScale;
				if (scale1)
					aAxis = scale1;
	
				var i:Number = 0;
				var tmpDim1:String;
				
				ggIndex = 0;

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

					var tmpArray:Array = (dim1 is Array) ? dim1 as Array : [String(dim1)];
					
					for (i = 0; i<tmpArray.length; i++)
					{
						tmpDim1 = tmpArray[i];
						angle = aAxis.getPosition(currentItem[tmpDim1]);
						
						if (sizeScale)
						{
							if (sizeField is Array)
							{
								_size = sizeScale.getPosition(currentItem[sizeField[i]]);
								dataFields["sizeField"] = sizeField[i];
							} else
								_size = sizeScale.getPosition(currentItem[sizeField]);
							tmpRadius = _innerRadius + radius/_total * chart.columnWidthRate * _size;
						}

						var xPos:Number = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius, chart.origin);
						var yPos:Number = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius, chart.origin); 
		
						dataFields["dim1"] = tmpDim1;

						createTTGG(currentItem, dataFields, xPos, yPos, NaN, _size, i);
						
		 				if (ttGG && _extendMouseEvents)
		 				{
							gg = ttGG;
		 					gg.target = this;
		 				}
		 				
						var arc:IGeometry;
						
						if (_innerRadius > tmpRadius)
							_innerRadius = tmpRadius;
		
						arc = new ArcPath(Math.max(0, _innerRadius), tmpRadius, startAngle, angle, chart.origin);
			
						var tempColor:int;
						
						if (colorField)
						{
							if (colorScale)
							{
								var col:* = colorScale.getPosition(currentItem[colorField]);
								if (col is Number)
									fill = new SolidFill(col);
								else if (col is IGraphicsFill)
									fill = col;
							} 
						} else if (_colorsStart && _colorsStop)
						{
							if (c < _colorsStart.length)
							{
								fill = new LinearGradientFill();
								var grStop:GradientStop = new GradientStop(_colorsStart[c])
								grStop.alpha = alpha;
								var g:Array = new Array();
								g.push(grStop);
				
								grStop = new GradientStop(_colorsStop[c]);
								grStop.alpha = alpha;
								g.push(grStop);
				
								LinearGradientFill(fill).gradientStops = g;
							}
						}  else if (_colors)
						{
							if (c < _colors.length)
								fill = new SolidFill(_colors[c]);
							else
								fill = new SolidFill(_colors[_colors.length]);
						} else if (randomColors)
						{
							tempColor = Math.random() * 255 * 255 * 255;
							fill = new SolidFill(tempColor);
						}
						
						if (fill)
						{
							arc.fill = fill;
						}
		
						arc.stroke = stroke;
		
						gg.geometryCollection.addItemAt(arc,0); 
						
						if (labelField)
						{
							var xLlb:Number = xPos, yLlb:Number = yPos;
							if (!isNaN(_radiusLabelOffset))
							{
								xLlb = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius + _radiusLabelOffset, chart.origin);
								yLlb = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius + _radiusLabelOffset, chart.origin);
							}
							var label:RasterText = new RasterText();
							label.fontFamily = fontLabel;
							label.fontWeight = "bold";
							label.fontSize = sizeLabel;
							label.autoSize = TextFieldAutoSize.LEFT;
							label.text = currentItem[labelField];
							label.fill = new SolidFill(colorLabel);
							label.x = xLlb- (label.textWidth + 4)/2;
							label.y = yLlb - (label.fontSize + 4)/2;
							gg.geometryCollection.addItem(label); 
						} else if (_showFieldName)
						{
							xLlb = xPos, yLlb = yPos;
							if (!isNaN(_radiusLabelOffset))
							{
								xLlb = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius + _radiusLabelOffset, chart.origin);
								yLlb = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius + _radiusLabelOffset, chart.origin);
							}
							label 	= new RasterText();
							label.text = tmpDim1;
							label.fontFamily = fontLabel;
							label.fontWeight = "bold";
							label.fontSize = sizeLabel;
							label.autoSize = TextFieldAutoSize.LEFT;
							label.fill = new SolidFill(colorLabel);
							label.x = xLlb- (label.textWidth + 4)/2;
							label.y = yLlb - (label.fontSize + 4)/2;
							gg.geometryCollection.addItem(label); 
						}
		
						startAngle += angle;
					}
					c++;
				}
				
				if (displayName && aAxis && aAxis.size < 360)
				{
					label = new RasterText();
					label.text = displayName;
					label.fontFamily = "verdana";
					label.fontWeight = "bold";
					label.autoSize = TextFieldAutoSize.LEFT;
					label.fill = new SolidFill(0x000000);
					label.x = PolarCoordinateTransform.getX(0, _innerRadius, chart.origin);
					label.y = PolarCoordinateTransform.getY(0, _innerRadius, chart.origin);
					gg.geometryCollection.addItem(label); 
				}
			}
			_invalidatedElementGraphic = false;
		}
	}
}