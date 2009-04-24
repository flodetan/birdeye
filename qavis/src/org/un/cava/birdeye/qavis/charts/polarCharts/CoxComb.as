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

package org.un.cava.birdeye.qavis.charts.polarCharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAngleAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarColumnSeries;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarSeries;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarStackableSeries;
	
	public class CoxComb extends PolarChart
	{
		private const COLUMN:String = "column";
		private const RADAR:String = "radar";
		
		private var _type:String = PolarStackableSeries.STACKED100;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally), or 
		 * stacked100 if the columns are stacked one after the other (vertically).*/
		[Inspectable(enumeration="overlaid,stacked,stacked100")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		protected var _maxStacked100:Number = NaN;
		/** @Private
		 * The maximum value among all series stacked according to stacked100 type.
		 * This is needed to "enlarge" the related axis to include all the stacked values
		 * so that all stacked100 series fit into the chart.*/
		public function get maxStacked100():Number
		{
			return _maxStacked100;
		}
		
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

			if (_series)
			{
				var _columnSeries:Array = [];
			
				for (var i:Number = 0; i<_series.length; i++)
				{
					if (_series[i] is PolarColumnSeries)
					{
						PolarColumnSeries(_series[i]).stackType = _type;
						_columnSeries.push(_series[i])
					}
				}
			}

			// when series are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each üolarColumnSeries. The baseValues arrays will be used to know
			// the radius0 starting point for each series values, which corresponds to 
			// the understair series outer radius;
			if (_series && nCursors == _series.length)
			{
				_columnSeries = [];
			
				for (i = 0; i<_series.length; i++)
				{
					if (_series[i] is PolarColumnSeries)
					{
						PolarColumnSeries(_series[i]).stackType = _type;
						_columnSeries.push(_series[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==PolarStackableSeries.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_series}
					var allSeriesBaseValues:Array = []; 
					for (i=0;i < _columnSeries.length;i++)
						allSeriesBaseValues[i] = {indexSeries: i, baseValues: []};
					
					// keep index of last series been processed 
					// with the same angle field data value
					// k[xFieldDataValue] = last series processed
					var k:Array = [];
					
					// the baseValues are indexed with the angle field objects
					var j:Object;
					
					for (var s:Number = 0; s<_columnSeries.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (PolarColumnSeries(_columnSeries[s]).cursor &&
							PolarColumnSeries(_columnSeries[s]).cursor != cursor)
						{
							sCursor = PolarColumnSeries(_columnSeries[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							while (!sCursor.afterLast)
							{
								j = sCursor.current[PolarColumnSeries(_columnSeries[s]).angleField];

								if (s>0 && k[j]>=0)
									allSeriesBaseValues[s].baseValues[j] = 
										allSeriesBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[PolarColumnSeries(_columnSeries[k[j]]).radiusField]);
								else 
									allSeriesBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[PolarColumnSeries(_columnSeries[s]).radiusField]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[PolarColumnSeries(_columnSeries[s]).radiusField]));

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
							// index of last series without own cursor with the same xField data value 
							// (because they've already been processed in the previous loop)
							var t:Array = [];
							for (s = 0; s<_columnSeries.length; s++)
							{
								if (! (PolarColumnSeries(_columnSeries[s]).cursor &&
									PolarColumnSeries(_columnSeries[s]).cursor != cursor))
								{
									j = cursor.current[PolarColumnSeries(_columnSeries[s]).angleField];
							
									if (t[j]>=0)
										allSeriesBaseValues[s].baseValues[j] = 
											allSeriesBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[PolarColumnSeries(_columnSeries[t[j]]).radiusField]);
									else 
										allSeriesBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[PolarColumnSeries(_columnSeries[s]).radiusField]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[PolarColumnSeries(_columnSeries[s]).radiusField]));

									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each AreaSeries
					// The baseValues array will be used to know
					// the y0 starting point for each series values, 
					// which corresponds to the understair series highest y value;
					for (s = 0; s<_columnSeries.length; s++)
						PolarColumnSeries(_columnSeries[s]).baseValues = allSeriesBaseValues[s].baseValues;
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
 			if ((angleAxis && angleAxis is CategoryAngleAxis))
				drawLabels()
 		}
		
		private var elementsMinMax:Array;
		override protected function feedAxes():void
		{
			var elements:Array = [];
			var j:Number = 0;
			elementsMinMax = [];
			
			if (nCursors == series.length)
			{
				// check if a default y axis exists
				if (_radarAxis && _radarAxis.angleCategory && _radarAxis.angleAxis)
				{
					var angleCategory:String = radarAxis.angleCategory;
					for (var i:int = 0; i<nCursors; i++)
					{
						currentSeries = PolarSeries(_series[i]);
						// if the series has its own data provider but has not its own
						// angleAxis, than load their elements and add them to the elements
						// loaded by the chart data provider
						if (currentSeries.dataProvider 
							&& currentSeries.dataProvider != dataProvider)
						{
							currentSeries.cursor.seek(CursorBookmark.FIRST);
							while (!currentSeries.cursor.afterLast)
							{
								var category:String = currentSeries.cursor.current[angleCategory];
								if (elements.indexOf(category) == -1)
									elements[j++] = category;
								
								if (!elementsMinMax[category])
								{
									elementsMinMax[category] = {min: int.MAX_VALUE,
																	 max: int.MIN_VALUE};
								} 
								elementsMinMax[category].min = 
									Math.min(elementsMinMax[category].min, 
										currentSeries.cursor.current[currentSeries.radiusField]);

								elementsMinMax[category].max = 
									Math.max(elementsMinMax[category].max, 
										currentSeries.cursor.current[currentSeries.radiusField]);
								
								currentSeries.cursor.moveNext();
							}
						}
						
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								category = cursor.current[angleCategory]
								// if the category value already exists in the axis, than skip it
								if (elements.indexOf(category) == -1)
									elements[j++] = category;
								
								for (var t:int = 0; t<series.length; t++)
								{
									currentSeries = PolarSeries(_series[t]);
									if (!elementsMinMax[category])
									{
										elementsMinMax[category] = {min: int.MAX_VALUE,
																		 max: int.MIN_VALUE};
									} 
									elementsMinMax[category].min = 
										Math.min(elementsMinMax[category].min, 
											cursor.current[currentSeries.radiusField]);

									elementsMinMax[category].max = 
										Math.max(elementsMinMax[category].max, 
											cursor.current[currentSeries.radiusField]);
								}
								cursor.moveNext();
							}
						}
	
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							_radarAxis.angleAxis.elements = elements;
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
			var aAxis:CategoryAngleAxis;
			if (radarAxis)
				aAxis = radarAxis.angleAxis;
			else
				aAxis = CategoryAngleAxis(angleAxis);
			
			var ele:Array = aAxis.elements;
			var interval:int = aAxis.interval;
			var nEle:int = ele.length;
			var radius:int = Math.min(unscaledWidth, unscaledHeight)/2;

			if (aAxis && radius>0 && ele && nEle>0 && !isNaN(interval))
			{
				removeAllLabels();
				for (var i:int = 0; i<nEle; i++)
				{
					var angle:int = aAxis.getPosition(ele[i]);
					var position:Point = PolarCoordinateTransform.getXY(angle,radius,origin);
					
					var label:RasterText = new RasterText();
					label.text = String(ele[i]);
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