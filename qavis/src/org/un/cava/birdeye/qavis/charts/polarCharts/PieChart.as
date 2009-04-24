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
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarPieSeries;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarStackableSeries;
	
	public class PieChart extends PolarChart
	{
		private var _type:String = PolarStackableSeries.OVERLAID;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally).*/
		[Inspectable(enumeration="stacked")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function PieChart()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (_series)
			{
				var _pieSeries:Array = [];
			
				for (var i:Number = 0; i<_series.length; i++)
				{
					if (_series[i] is PolarPieSeries)
					{
						PolarPieSeries(_series[i]).stackType = _type;
						_pieSeries.push(_series[i]);
					}
				}
				
				for (i = 0; i<_pieSeries.length; i++)
				{
					PolarPieSeries(_pieSeries[i]).stackPosition = i;
					PolarPieSeries(_pieSeries[i]).total = _pieSeries.length;
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}