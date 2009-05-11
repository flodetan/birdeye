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

package birdeye.vis.recipes.polarCharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;
	
	import birdeye.vis.coords.Polar;
	import birdeye.vis.scales.*;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.elements.collision.*;
	
	public class RadarChart extends Polar
	{
		private const COLUMN:String = "column";
		private const RADAR:String = "radar";
				
		private var _layout:String;
		[Inspectable(enumeration="column,radar")]
		public function set layout(val:String):void
		{
			_layout = val;
			invalidateDisplayList();
		}
		
		public function RadarChart()
		{
			super();
			addChild(labels = new Surface());

			gg = new GeometryGroup();
			gg.target = labels;
			labels.addChild(gg);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (radarAxis && !contains(radarAxis))
				addChild(radarAxis);
				
			if (!contains(labels))
				addChild(labels);

			if (_elements)
			{
				var _columnElements:Array = [];
			
				for (var i:Number = 0; i<_elements.length; i++)
				{
					if (_elements[i] is PolarColumnElement)
					{
						PolarColumnElement(_elements[i]).stackType = _type;
						_columnElements.push(_elements[i])
					}
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ((radarAxis && radarAxis.angleAxis) ||
				(scale1 && scale1 is CategoryAngle))
				drawLabels()
		}
		
		private var elementsMinMax:Array;
		override protected function feedAxes():void
		{
			var catElements:Array = [];
			var j:Number = 0;
			elementsMinMax = [];
			
			if (nCursors == elements.length)
			{
				// check if a default y axis exists
				if (_radarAxis && _radarAxis.angleCategory && _radarAxis.angleAxis)
				{
					var angleCategory:String = radarAxis.angleCategory;
					for (var i:int = 0; i<nCursors; i++)
					{
						currentElement = PolarElement(_elements[i]);
						// if the element has its own data provider but has not its own
						// angleAxis, than load their elements and add them to the elements
						// loaded by the chart data provider
						if (currentElement.dataProvider 
							&& currentElement.dataProvider != dataProvider)
						{
							currentElement.cursor.seek(CursorBookmark.FIRST);
							while (!currentElement.cursor.afterLast)
							{
								var category:String = currentElement.cursor.current[angleCategory];
								if (catElements.indexOf(category) == -1)
									catElements[j++] = category;
								
								if (!elementsMinMax[category])
								{
									elementsMinMax[category] = {min: int.MAX_VALUE,
																	 max: int.MIN_VALUE};
								} 
								elementsMinMax[category].min = 
									Math.min(elementsMinMax[category].min, 
										currentElement.cursor.current[currentElement.dim2]);

								elementsMinMax[category].max = 
									Math.max(elementsMinMax[category].max, 
										currentElement.cursor.current[currentElement.dim2]);
								
								currentElement.cursor.moveNext();
							}
						} else if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								category = cursor.current[angleCategory]
								// if the category value already exists in the axis, than skip it
								if (catElements.indexOf(category) == -1)
									catElements[j++] = category;
								
								for (var t:int = 0; t<elements.length; t++)
								{
									currentElement = PolarElement(_elements[t]);
									if (!(currentElement.dataProvider 
										&& currentElement.dataProvider != dataProvider))
									{
										if (!elementsMinMax[category])
										{
											elementsMinMax[category] = {min: int.MAX_VALUE,
																			 max: int.MIN_VALUE};
										} 
										elementsMinMax[category].min = 
											Math.min(elementsMinMax[category].min, 
												cursor.current[currentElement.dim2]);
	
										elementsMinMax[category].max = 
											Math.max(elementsMinMax[category].max, 
												cursor.current[currentElement.dim2]);
									}
								}
								cursor.moveNext();
							}
						}
	
						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							_radarAxis.angleAxis.dataProvider = catElements;
					} 
					
					_radarAxis.feedRadiusAxes(elementsMinMax);
				}
			}
			super.feedAxes();
		}
		
		private var labels:Surface;
		private var gg:GeometryGroup;
		private function drawLabels():void
		{
			var aAxis:CategoryAngle;
			if (radarAxis)
				aAxis = radarAxis.angleAxis;
			else
				aAxis = CategoryAngle(scale1);
			
			var catElements:Array = aAxis.dataProvider;
			var interval:int = aAxis.interval;
			var nEle:int = catElements.length;
			var radius:int = Math.min(unscaledWidth, unscaledHeight)/2;

			if (aAxis && radius>0 && catElements && nEle>0 && !isNaN(interval))
			{
				removeAllLabels();
				for (var i:int = 0; i<nEle; i++)
				{
					var angle:int = aAxis.getPosition(catElements[i]);
					var position:Point = PolarCoordinateTransform.getXY(angle,radius,origin);
					
					var label:RasterTextPlus = new RasterTextPlus();
					label.text = String(catElements[i]);
 					label.fontFamily = "verdana";
 					label.fontSize = _fontSize;
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(0x000000);

					label.x = position.x - label.displayObject.width/2;
					label.y = position.y - label.displayObject.height/2;
					
					gg.geometryCollection.addItem(label);
				}

				switch (_layout)
				{
					case RADAR: 
						if (radarAxis)
							createRadarLayout1();
						else
							createRadarLayout2();
						break;
					case COLUMN:
						createColumnLayout()
						break;
				}
			}
		}
		
		private function removeAllLabels():void
		{
			if (gg)
				gg.geometryCollection.items = [];
		}
		
		private function createRadarLayout1():void
		{
			var aAxis:CategoryAngle = radarAxis.angleAxis;
			var catElements:Array = aAxis.dataProvider;
			var rAxis:Numeric = radarAxis.radiusAxes[catElements[0]];
			
			if (aAxis && rAxis && !isNaN(rAxis.interval))
			{
				var interval:int = aAxis.interval;
				var nEle:int = catElements.length;
	
				var rMin:Number = rAxis.min;
				var rMax:Number = rAxis.max;
				
				var angle:int;
				var radius:int;
				var position:Point;
	
				for (radius = rMin + rAxis.interval; radius<rMax; radius += rAxis.interval)
				{
					var poly:Polygon = new Polygon();
					poly.data = "";
	
					for (var j:int = 0; j<nEle; j++)
					{
						angle = aAxis.getPosition(catElements[j]);
						position = PolarCoordinateTransform.getXY(angle, rAxis.getPosition(radius), origin)
						poly.data += String(position.x) + "," + String(position.y) + " ";
					}
					poly.stroke = new SolidStroke(0x000000,.15);
					gg.geometryCollection.addItem(poly);
				}
			}
		}

		private function createRadarLayout2():void
		{
			var aAxis:CategoryAngle = CategoryAngle(scale1);
			var catElements:Array = aAxis.dataProvider;
			var interval:int = aAxis.interval;
			var nEle:int = catElements.length;
			
			if (scale2 is Numeric && !isNaN(Numeric(scale2).interval))
			{
				var rAxis:Numeric = Numeric(scale2);
				var rMin:Number = rAxis.min;
				var rMax:Number = rAxis.max;
				
				var angle:int;
				var radius:int;
				var position:Point = PolarCoordinateTransform.getXY(angle,radius-10,origin);

				for (radius = rMin + rAxis.interval; radius<rMax; radius += rAxis.interval)
				{
					var poly:Polygon = new Polygon();
					poly.data = "";

					for (var j:int = 0; j<nEle; j++)
					{
						angle = aAxis.getPosition(catElements[j]);
						position = PolarCoordinateTransform.getXY(angle, rAxis.getPosition(radius), origin)
						poly.data += String(position.x) + "," + String(position.y) + " ";
					}
					poly.stroke = new SolidStroke(0x000000,.15);
					gg.geometryCollection.addItem(poly);
				}
			}
			
		}
		
		private function createColumnLayout():void
		{
			var rad:int = Math.min(unscaledWidth, unscaledHeight)/2;
			var circle:Circle = new Circle(origin.x, origin.y, rad-20);
			circle.stroke = new SolidStroke(0x000000);

			gg.geometryCollection.addItem(circle);
		}
	}
}