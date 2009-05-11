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
	
	import birdeye.vis.elements.geometry.ColumnElement;
	import birdeye.vis.elements.collision.StackElement;

	/**
	 * The ColumnChart is a StackableChart providing a vertical layout
	 * @see StackableChart */
	public class ColumnChart extends StackableChart
	{
		public function ColumnChart()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// when elements are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each Column. The baseValues arrays will be used to know
			// the y0 starting point for each element values, which corresponds to 
			// the understair element highest y value;

			if (_elements && nCursors == _elements.length)
			{
				var _Column:Array = [];
			
				for (var i:Number = 0; i<_elements.length; i++)
				{
					if (_elements[i] is ColumnElement)
					{
						ColumnElement(_elements[i]).stackType = _type;
						_Column.push(_elements[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackElement.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_element}
					var allElementsBaseValues:Array = []; 
					for (i=0;i<_Column.length;i++)
						allElementsBaseValues[i] = {indexElements: i, baseValues: []};
					
					// keep index of last element been processed 
					// with the same xField data value
					// k[xFieldDataValue] = last Elements processed
					var k:Array = [];
					
					var j:Object;
					for (var s:Number = 0; s<_Column.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (ColumnElement(_Column[s]).cursor &&
							ColumnElement(_Column[s]).cursor != cursor)
						{
							sCursor = ColumnElement(_Column[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							
							while (!sCursor.afterLast)
							{
								j = sCursor.current[ColumnElement(_Column[s]).dim1];

								if (s>0 && k[j]>=0)
									allElementsBaseValues[s].baseValues[j] = 
										allElementsBaseValues[k[j]].baseValues[j] + 
										Math.max(0,sCursor.current[ColumnElement(_Column[k[j]]).dim2]);
								else 
									allElementsBaseValues[s].baseValues[j] = 0;

								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[ColumnElement(_Column[s]).dim2]);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,sCursor.current[ColumnElement(_Column[s]).dim2]));

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
							for (s = 0; s<_Column.length; s++)
							{
								if (! (ColumnElement(_Column[s]).cursor &&
									ColumnElement(_Column[s]).cursor != cursor))
								{
									j = cursor.current[ColumnElement(_Column[s]).dim1];
							
									if (t[j]>=0)
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[t[j]].baseValues[j] + 
											Math.max(0,cursor.current[ColumnElement(_Column[t[j]]).dim2]);
									else 
										allElementsBaseValues[s].baseValues[j] = 0;
									
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[ColumnElement(_Column[s]).dim2]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,cursor.current[ColumnElement(_Column[s]).dim2]));
	
									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each Column
					// The baseValues array will be used to know
					// the y0 starting point for each element values, 
					// which corresponds to the understair element highest y value;
					for (s = 0; s<_Column.length; s++)
						ColumnElement(_Column[s]).baseValues = allElementsBaseValues[s].baseValues;
				}
			}
		}
		
	}
}