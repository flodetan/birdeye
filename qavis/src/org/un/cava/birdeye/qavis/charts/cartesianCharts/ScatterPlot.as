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
	
	import org.un.cava.birdeye.qavis.charts.interfaces.IScatter;
	import org.un.cava.birdeye.qavis.charts.interfaces.ISizableItem;
	
	import org.un.cava.birdeye.qavis.charts.interfaces.ISizableItem;

	public class ScatterPlot extends CartesianChart implements ISizableItem
	{
		private var _maxRadius:Number = 10;
		/** @Private
		 * Set the maximum radius value for the scatter plot.*/
		public function set maxRadius(val:Number):void
		{
			_maxRadius = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get maxRadius():Number
		{
			return _maxRadius;
		}
		
		public function ScatterPlot()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			var scatterSeries:Array = [];
			// load all scatter series (there might be series that are not IScatter 
			// in the ScatterPlot chart)
			for (var i:Number = 0; i<_series.length; i++)
				if (_series[i] is IScatter)
					scatterSeries.push(_series[i]);
			
			if (scatterSeries.length > 0)
			{
				var maxRadiusValues:Array = [];
				var minRadiusValues:Array = [];
				cursor.seek(CursorBookmark.FIRST);
				
				// calculate the min and max radius values for each scatter series
				while (! cursor.afterLast)
				{
					for (i = 0; i<scatterSeries.length; i++)
					{
						if (maxRadiusValues[i] == null)
							maxRadiusValues[i] = cursor.current[IScatter(scatterSeries[i]).radiusField];
						else
							maxRadiusValues[i] = Math.max(maxRadiusValues[i],
														cursor.current[IScatter(scatterSeries[i]).radiusField]);
						if (minRadiusValues[i] == null)
							minRadiusValues[i] = cursor.current[IScatter(scatterSeries[i]).radiusField];
						else
							minRadiusValues[i] = Math.min(minRadiusValues[i],
														cursor.current[IScatter(scatterSeries[i]).radiusField]);
					}
						
					cursor.moveNext();
				}
				
				// set the min and max radius values for each scatter series
				// this will needed by the scatter series when calculating the
				// sizes for each data value
				for (i = 0; i<scatterSeries.length; i++)
				{
					IScatter(scatterSeries[i]).maxRadiusValue = maxRadiusValues[i];
					IScatter(scatterSeries[i]).minRadiusValue = minRadiusValues[i];
				}
			}
		}
	}
}