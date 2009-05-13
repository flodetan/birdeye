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
	import birdeye.vis.coords.Polar;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IStack;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	
	
	public class CoxComb extends Polar
	{
		private const COLUMN:String = "column";
		private const RADAR:String = "radar";
		
		public function CoxComb()
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
			
			if (!contains(labels))
				addChild(labels);

			if (_elements)
			{
				var _stackElements:Array = [];
			
				for (var i:Number = 0; i<_elements.length; i++)
				{
					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_stackElements.push(_elements[i])
					}
				}
			}

			// when elements are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each üolarColumnElements. The baseValues arrays will be used to know
			// the radius0 starting point for each elements values, which corresponds to 
			// the understair elements outer radius;
			if (_elements && nCursors == _elements.length)
			{
				_stackElements = [];
			
				for (i = 0; i<_elements.length; i++)
				{
					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_stackElements.push(_elements[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==PolarStackElement.STACKED100)
				{
					// {indexElements: i, baseValues: Array_for_each_Elements}
					var allElementsBaseValues:Array = []; 
					for (i=0;i < _stackElements.length;i++)
						allElementsBaseValues[i] = {indexElements: i, baseValues: []};
					
					// keep index of last element been processed 
					// with the same angle field data value
					// k[xFieldDataValue] = last element processed
					var k:Array = [];
					
					// the baseValues are indexed with the angle field objects
					var j:Object;
					
					for (var s:Number = 0; s<_stackElements.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (IElement(_stackElements[s]).cursor &&
							IElement(_stackElements[s]).cursor != cursor)
						{
							sCursor = IElement(_stackElements[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							while (!sCursor.afterLast)
							{
								j = sCursor.current[IElement(_stackElements[s]).dim1];

								if (s>0 && k[j]>=0)
									allElementsBaseValues[s].baseValues[j] = 
										allElementsBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[IElement(_stackElements[k[j]]).dim2]);
								else 
									allElementsBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[IElement(_stackElements[s]).dim2]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[IElement(_stackElements[s]).dim2]));

								sCursor.moveNext();
								k[j] = s;
							}
						}
					}
					
					if (cursor)
					
					{
						cursor.seek(CursorBookmark.FIRST);
						while (!cursor.afterLast)
						{
							// index of last element without own cursor with the same xField data value 
							// (because they've already been processed in the previous loop)
							var t:Array = [];
							for (s = 0; s<_stackElements.length; s++)
							{
								if (! (IElement(_stackElements[s]).cursor &&
									IElement(_stackElements[s]).cursor != cursor))
								{
									j = cursor.current[IElement(_stackElements[s]).dim1];
							
									if (t[j]>=0)
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[IElement(_stackElements[t[j]]).dim2]);
									else 
										allElementsBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[IElement(_stackElements[s]).dim2]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[IElement(_stackElements[s]).dim2]));

									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each AreaElement
					// The baseValues array will be used to know
					// the y0 starting point for each element values, 
					// which corresponds to the understair element highest y value;
					for (s = 0; s<_stackElements.length; s++)
						IStack(_stackElements[s]).baseValues = allElementsBaseValues[s].baseValues;
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
 			if ((scale1 && scale1 is CategoryAngle))
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
				if (_multiScale && _multiScale.dim1 && _multiScale.scale1)
				{
					var angleCategory:String = multiScale.dim1;
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
						}
						
						if (cursor)
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
								cursor.moveNext();
							}
						}
	
						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							_multiScale.scale1.dataProvider = catElements;
					} 
					
					_multiScale.feedRadiusAxes(elementsMinMax);
				}
			}
			super.feedAxes();
		}
		
		private var labels:Surface;
		private var gg:GeometryGroup;
		private function drawLabels():void
		{
			var aAxis:CategoryAngle;
			if (multiScale)
				aAxis = multiScale.scale1;
			else
				aAxis = CategoryAngle(scale1);
			
			var catElements:Array = aAxis.dataProvider;
			var interval:int = aAxis.interval;
			var nEle:int = catElements.length;
			var radius:int = Math.min(unscaledWidth, unscaledHeight);

			if (aAxis && radius>0 && catElements && nEle>0 && !isNaN(interval))
			{
				removeAllLabels();
				for (var i:int = 0; i<nEle; i++)
				{
					var angle:int = aAxis.getPosition(catElements[i]);
					var position:Point = PolarCoordinateTransform.getXY(angle,radius,origin);
					
					var label:RasterText = new RasterText();
					label.text = String(catElements[i]);
 					label.fontFamily = "verdana";
 					label.fontSize = _fontSize;
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(0x000000);

					label.x = position.x;
					label.y = position.y;
					
					gg.geometryCollection.addItem(label);
				}
 			}
		}
		
		private function removeAllLabels():void
		{
			if (gg)
				gg.geometryCollection.items = [];
		}
	}
}