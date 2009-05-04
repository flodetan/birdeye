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
 
package birdeye.vis.recipes.cartesianCharts
{
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	
	import birdeye.vis.scales.BaseScale;
	import birdeye.vis.scales.*;
	import birdeye.vis.elements.geometry.BarElement;
	import birdeye.vis.elements.collision.StackElement;

	/**
	 * The BarChart is a CartesianChart that provides the type property
	 * that can be used by the Bar to define their stackable type.
	 * Besides it provides some further control over the Bar layout
	 * to insure the proper stack layout, particularly for the stacked100 type.
	 * @see CartesianChart */
	public class BarChart extends StackableChart
	{
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
			// arrays for each Bar. The baseValues arrays will be used to know
			// the x0 starting point for each series values, which corresponds to 
			// the understair series highest x value;

			if (_series && nCursors == _series.length)
			{
				var _Bar:Array = [];
			
				for (var i:Number = 0; i<_series.length; i++)
				{
					if (_series[i] is BarElement)
					{
						BarElement(_series[i]).stackType = _type;
						_Bar.push(_series[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackElement.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_series}
					var allSeriesBaseValues:Array = []; 
					for (i=0;i<_Bar.length;i++)
						allSeriesBaseValues[i] = {indexSeries: i, baseValues: []};
					
					// keep index of last series been processed 
					// with the same xField data value
					// k[xFieldDataValue] = last series processed
					var k:Array = [];
					
					var j:Object;
					for (var s:Number = 0; s<_Bar.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (BarElement(_Bar[s]).cursor &&
							BarElement(_Bar[s]).cursor != cursor)
						{
							sCursor = BarElement(_Bar[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							while (!sCursor.afterLast)
							{
								j = sCursor.current[BarElement(_Bar[s]).yField];
								if (s>0 && k[j]>=0)
									allSeriesBaseValues[s].baseValues[j] = 
										allSeriesBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[k[j]]).xField]);
								else 
									allSeriesBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[s]).xField]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allSeriesBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[s]).xField]));

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
							for (s = 0; s<_Bar.length; s++)
							{
								if (! (BarElement(_Bar[s]).cursor &&
									BarElement(_Bar[s]).cursor != cursor))
								{
									j = cursor.current[BarElement(_Bar[s]).yField];
	
									if (t[j]>=0)
										allSeriesBaseValues[s].baseValues[j] = 
											allSeriesBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[t[j]]).xField]);
									else 
										allSeriesBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[s]).xField]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allSeriesBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[s]).xField]));
	
									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each Bar
					// The baseValues array will be used to know
					// the x0 starting point for each series values, 
					// which corresponds to the understair series highest x value;
					for (s = 0; s<_Bar.length; s++)
						BarElement(_Bar[s]).baseValues = allSeriesBaseValues[s].baseValues;
				}
			}
		}
		
		/** @Private */
		override protected function createYAxis():void
		{
			// must be defined by the user since it's probably a category axis
			// and need the category field to be defined
			throw new Error("No yAxis defined for the Bar char. Please make sure that an yAxis is created in the chart declaration.");
		}
		/** @Private */
		override protected function createXAxis():void
		{
			xAxis = new LinearAxis();
			xAxis.placement = BaseScale.BOTTOM;
		}
	}
}