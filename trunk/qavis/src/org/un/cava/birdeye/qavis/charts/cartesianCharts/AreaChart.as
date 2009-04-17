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
 
package org.un.cava.birdeye.qavis.charts.cartesianCharts
{
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	
	import org.un.cava.birdeye.qavis.charts.cartesianSeries.AreaSeries;
	import org.un.cava.birdeye.qavis.charts.cartesianSeries.StackableSeries;
	
	/**
	 * The AreaChart is a CartesianChart that provides the type property
	 * that can be used by the AreaSeries to define their stackable type.
	 * Besides it provides some further control over the AreaSeries layout
	 * to insure the proper stack layout, particularly for the stacked100 type.
	 * @see CartesianChart */
	public class AreaChart extends StackableChart
	{
		public function AreaChart()
		{
			super();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// when series are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each AreaSeries. The baseValues arrays will be used to know
			// the y0 starting point for each series values, which corresponds to 
			// the understair series highest y value;
			if (_series && nCursors == _series.length)
			{
				var _areaSeries:Array = [];
			
				for (var i:Number = 0; i<_series.length; i++)
				{
					if (_series[i] is AreaSeries)
					{
						AreaSeries(_series[i]).stackType = _type;
						_areaSeries.push(_series[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackableSeries.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_series}
					var allSeriesBaseValues:Array = []; 
					for (i=0;i < _areaSeries.length;i++)
						allSeriesBaseValues[i] = {indexSeries: i, baseValues: []};
					
					// keep index of last series been processed 
					// with the same xField data value
					// k[xFieldDataValue] = last series processed
					var k:Array = [];
					
					// the baseValues are indexed with the xField objects
					var j:Object;
					
					for (var s:Number = 0; s<_areaSeries.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (AreaSeries(_areaSeries[s]).cursor &&
							AreaSeries(_areaSeries[s]).cursor != cursor)
						{
							sCursor = AreaSeries(_areaSeries[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							while (!sCursor.afterLast)
							{
								j = sCursor.current[AreaSeries(_areaSeries[s]).xField];

								if (s>0 && k[j]>=0)
									allSeriesBaseValues[s].baseValues[j] = 
										allSeriesBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[AreaSeries(_areaSeries[k[j]]).yField]);
								else 
									allSeriesBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[AreaSeries(_areaSeries[s]).yField]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[AreaSeries(_areaSeries[s]).yField]));

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
							for (s = 0; s<_areaSeries.length; s++)
							{
								if (! (AreaSeries(_areaSeries[s]).cursor &&
									AreaSeries(_areaSeries[s]).cursor != cursor))
								{
									j = cursor.current[AreaSeries(_areaSeries[s]).xField];
							
									if (t[j]>=0)
										allSeriesBaseValues[s].baseValues[j] = 
											allSeriesBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[AreaSeries(_areaSeries[t[j]]).yField]);
									else 
										allSeriesBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[AreaSeries(_areaSeries[s]).yField]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[AreaSeries(_areaSeries[s]).yField]));

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
					for (s = 0; s<_areaSeries.length; s++)
						AreaSeries(_areaSeries[s]).baseValues = allSeriesBaseValues[s].baseValues;
				}
			}
		}
	}
}