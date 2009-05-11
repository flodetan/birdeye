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
			
			// when elements are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each Bar. The baseValues arrays will be used to know
			// the x0 starting point for each element values, which corresponds to 
			// the understair element highest x value;

			if (_elements && nCursors == _elements.length)
			{
				var _Bar:Array = [];
			
				for (var i:Number = 0; i<_elements.length; i++)
				{
					if (_elements[i] is BarElement)
					{
						BarElement(_elements[i]).stackType = _type;
						_Bar.push(_elements[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackElement.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_series}
					var allElementsBaseValues:Array = []; 
					for (i=0;i<_Bar.length;i++)
						allElementsBaseValues[i] = {indexElements: i, baseValues: []};
					
					// keep index of last element been processed 
					// with the same xField data value
					// k[xFieldDataValue] = last element processed
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
								j = sCursor.current[BarElement(_Bar[s]).dim2];
								if (s>0 && k[j]>=0)
									allElementsBaseValues[s].baseValues[j] = 
										allElementsBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[k[j]]).dim1]);
								else 
									allElementsBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[s]).dim1]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[BarElement(_Bar[s]).dim1]));

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
							// index of last Elements without own cursor with the same xField data value 
							// (because they've already been processed in the previous loop)
							var t:Array = [];
							for (s = 0; s<_Bar.length; s++)
							{
								if (! (BarElement(_Bar[s]).cursor &&
									BarElement(_Bar[s]).cursor != cursor))
								{
									j = cursor.current[BarElement(_Bar[s]).dim2];
	
									if (t[j]>=0)
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[t[j]]).dim1]);
									else 
										allElementsBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[s]).dim1]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[BarElement(_Bar[s]).dim1]));
	
									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each Bar
					// The baseValues array will be used to know
					// the x0 starting point for each element values, 
					// which corresponds to the understair element highest x value;
					for (s = 0; s<_Bar.length; s++)
						BarElement(_Bar[s]).baseValues = allElementsBaseValues[s].baseValues;
				}
			}
		}
		
		/** @Private */
		override protected function createScale2():void
		{
			// must be defined by the user since it's probably a category axis
			// and need the category field to be defined
			throw new Error("No yAxis defined for the Bar char. Please make sure that an yAxis is created in the chart declaration.");
		}
		/** @Private */
		override protected function createScale1():void
		{
			scale1 = new Linear();
			scale1.placement = BaseScale.BOTTOM;
		}
	}
}