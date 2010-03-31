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
	import birdeye.vis.data.UtilSVG;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.ArcPath;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Point;
	
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
		
		private var _showPercent:Boolean;
		[Inspectable(enumeration="true,false")]
		public function set showPercent(val:Boolean):void
		{
			_showPercent = val;
			invalidatingDisplay();
		}
		
		private var _labelFontWeight:String = "bold";
		[Inspectable(enumeration="bold,normal")]
		public function set labelFontWeight(lw:String):void
		{
			_labelFontWeight = lw;
			invalidatingDisplay();
		}
		
		public function get labelFontWeight():String
		{
			return _labelFontWeight;
		}
		
		public function WedgeElement()
		{
			super();
			labelCreationNotOverridden = false;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (_stackType != OVERLAID || _stackType != STACKED)
				_stackType = STACKED;

			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(CircleRenderer);
		}
		
		protected var _drawingData:Array;
		
		override public function preDraw() : Boolean
		{
			if (!(isReadyForLayout()) )
			{
				return false;
			}
			
			this.graphics.clear();
			
			_drawingData = new Array();		
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				var currentItem:Object = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				_drawingData.push(scaleResults);
				
			}
			
			if (scale2)
				radius = scale2.size;
			
			tmpRadius = radius;
			if (_total>0)
			{
				_innerRadius = radius/_total * _stackPosition; 
				tmpRadius = _innerRadius + radius/_total * visScene.thicknessRatio;
			}
			
			
			
			var arcCenterX:Number = 0; 
			var arcCenterY:Number = 0;
			
			if (visScene != null && visScene.origin != null)
			{
				arcCenterX = visScene.origin.x - radius;
				arcCenterY = visScene.origin.y - radius;
			}	
			var wSize:Number, hSize:Number;
			wSize = hSize = radius*2;
			
			var aAxis:IScale;
			if (scale1)
				aAxis = scale1;
			
			return true && super.preDraw();
		}
		
		protected var tmpRadius:Number;
		
		protected var angle:Number, radius:Number = NaN;
		
		protected var startAngle:Number = 0; 
		
		protected var arcSize:Number = NaN;
		
		protected var arc:ArcPath = new ArcPath(NaN,NaN,NaN,NaN,null);
		
		override public function drawDataItem() : Boolean
		{
			var d:Object = _drawingData[_currentItemIndex];
			if (isNaN(d[POS1])) return true && super.drawDataItem();
			
		
			if (d[SIZE] && !isNaN(d[SIZE]))
			{
				_graphicRendererSize = d[SIZE];
				tmpRadius = _innerRadius + radius/_total * visScene.thicknessRatio * _graphicRendererSize;
			}
			
			var xPos:Number = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius, visScene.origin);
			var yPos:Number = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius, visScene.origin); 

				
			if (_innerRadius > tmpRadius)
				_innerRadius = tmpRadius;
			
			arc.setArcData(Math.max(0, _innerRadius), tmpRadius, startAngle, d[POS1], visScene.origin);
			arc.fill = d[COLOR];
			arc.stroke = stroke;
			this.arc.draw(this.graphics, null);
				
			startAngle += d[POS1];
			
			return true && super.drawDataItem();
		}
		
		override public function endDraw() : void
		{
			
		}

		/* @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.
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
					case STACKED:
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
					tmpRadius = _innerRadius + radius/_total * visScene.thicknessRatio;
				}
	
				
				
				var arcCenterX:Number = 0; 
				var arcCenterY:Number = 0;
				
				if (visScene != null && visScene.origin != null)
				{
					arcCenterX = visScene.origin.x - radius;
					arcCenterY = visScene.origin.y - radius;
				}	
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
						
						if (isNaN(angle)) continue;
						
						if (sizeScale)
						{
							if (sizeField is Array)
							{
								_graphicRendererSize = sizeScale.getPosition(currentItem[sizeField[i]]);
								dataFields["sizeField"] = sizeField[i];
							} else
								_graphicRendererSize = sizeScale.getPosition(currentItem[sizeField]);
							tmpRadius = _innerRadius + radius/_total * visScene.thicknessRatio * _graphicRendererSize;
						}

						var xPos:Number = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius, visScene.origin);
						var yPos:Number = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius, visScene.origin); 
		
						dataFields["dim1"] = tmpDim1;

						createTTGG(currentItem, dataFields, xPos, yPos, NaN, _graphicRendererSize, i);
						
		 				if (ttGG && _extendMouseEvents)
		 				{
							gg = ttGG;
		 					gg.target = this;
		 				}
		 				
						var arc:IBoundedRenderer;
						
						if (_innerRadius > tmpRadius)
							_innerRadius = tmpRadius;
		
						arc = new ArcPath(Math.max(0, _innerRadius), tmpRadius, startAngle, angle, visScene.origin);
						
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
								rgbFill = UtilSVG.toHex(_colorsStart[c]);
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

						addSVGData(arc.svgData);
		
						arc.stroke = stroke;
		
						gg.geometryCollection.addItemAt(arc,0); 
						
						if (labelField || _showPercent || _showFieldName)
						{
							var xLlb:Number = xPos, yLlb:Number = yPos;
							if (!isNaN(_radiusLabelOffset))
							{
								xLlb = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius + _radiusLabelOffset, visScene.origin);
								yLlb = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius + _radiusLabelOffset, visScene.origin);
							}
							var labelTxt:String = "";
							if (_showFieldName)
							{
								labelTxt = tmpDim1;
							}
							
							if (labelField)
							{
								if (labelTxt != "") labelTxt += " ";
								labelTxt += currentItem[labelField];
							}
							
							if (_showPercent)
							{
								//TODO all percents can do 100.1% !!
								if (labelTxt != "") labelTxt += " ";
								
								var perc:Number = Math.round(angle * 1000 / scale1.size) / 10;
								
								if (perc > 0)
								{
									labelTxt += perc + "%"; 
								}
							}
							var label:TextRenderer = new TextRenderer(xLlb, yLlb, labelTxt, new SolidFill(colorLabel),
																	false, true, sizeLabel, fontLabel);
							
							var labelPoint:Point = PolarCoordinateTransform.getLabelXY(label.textWidth, label.fontSize, startAngle + angle / 2);
							
							label.x -= labelPoint.x;
							label.y -= labelPoint.y;
														
							label.fontWeight = _labelFontWeight;

							addSVGData(label.svgData);
							gg.geometryCollection.addItem(label); 
						}
						

								
						startAngle += angle;
					}
					c++;
				}
				
				if (displayName && aAxis && aAxis.size < 360)
				{
					label = new TextRenderer(PolarCoordinateTransform.getX(0, _innerRadius, visScene.origin), 
															PolarCoordinateTransform.getY(0, _innerRadius, visScene.origin), 
															displayName, new SolidFill(0x000000),
															false, false, 12, "verdana");
					label.fontWeight = "bold";
					gg.geometryCollection.addItem(label); 
				}
			}
			createSVG();
			_invalidatedElementGraphic = false;
		}*/
	}
}