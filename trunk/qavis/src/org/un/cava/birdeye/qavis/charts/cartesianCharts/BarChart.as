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
	
	import org.un.cava.birdeye.qavis.charts.series.BarSeries;
	import org.un.cava.birdeye.qavis.charts.series.StackableSeries;

	public class BarChart extends CartesianChart
	{
		private var _type:String = StackableSeries.OVERLAID;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked100 if they appear staked one after the other (horizontally), or 
		 * stacked if the bars are stacked one after the other (vertically).*/
		[Inspectable(enumeration="overlaid,stacked,stacked100")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		private var _maxStacked100:Number = NaN;
		/** @Private
		 * The maximum value among all series stacked according to stacked100 type.
		 * This is needed to "enlarge" the related axis to include all the stacked values
		 * so that all stacked100 series fit into the chart.*/
		public function get maxStacked100():Number
		{
			return _maxStacked100;
		}

		public function BarChart()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// when series are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each BarSeries. The baseValues arrays will be used to know
			// the x0 starting point for each series values, which corresponds to 
			// the understair series highest x value;

			if (_series)
			{
				var _barSeries:Array = [];
			
				for (var i:Number = 0; i<_series.length; i++)
				{
					if (_series[i] is BarSeries)
					{
						BarSeries(_series[i]).stackType = _type;
						_barSeries.push(_series[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackableSeries.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_series}
					var allSeriesBaseValues:Array = []; 
					for (i=0;i<_barSeries.length;i++)
						allSeriesBaseValues[i] = {indexSeries: i, baseValues: []};
					
					var j:Number = 0;
					cursor.seek(CursorBookmark.FIRST);
					while (!cursor.afterLast)
					{
						for (var s:Number = 0; s<_barSeries.length; s++)
						{
							if (s>0)
								allSeriesBaseValues[s].baseValues[j] = 
									allSeriesBaseValues[s-1].baseValues[j] + 
									Math.max(0,cursor.current[BarSeries(_barSeries[s-1]).xField]);
							else 
								allSeriesBaseValues[s].baseValues[j] = 0;
							
							if (isNaN(_maxStacked100))
								_maxStacked100 = 
									allSeriesBaseValues[s].baseValues[j] + 
									Math.max(0,cursor.current[BarSeries(_barSeries[s]).xField]);
							else
								_maxStacked100 = Math.max(_maxStacked100,
									allSeriesBaseValues[s].baseValues[j] + 
									Math.max(0,cursor.current[BarSeries(_barSeries[s]).xField]));
						}
						j++;
						cursor.moveNext();
					}
					
					// set the baseValues array for each BarSeries
					// The baseValues array will be used to know
					// the x0 starting point for each series values, 
					// which corresponds to the understair series highest x value;
					for (s = 0; s<_barSeries.length; s++)
						BarSeries(_barSeries[s]).baseValues = allSeriesBaseValues[s].baseValues;
				}
			}
		}
		
	}
}