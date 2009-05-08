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
	import birdeye.vis.coords.Cartesian;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IScatter;
	import birdeye.vis.interfaces.ISizableItem;
	
	import mx.collections.CursorBookmark;


	/**
	 * The ScatterPlot is a CartesianChart that implement the ISizableIteme interface
	 * because its elements items layout don't only depend on the x-y-z fields but also 
	 * on the radiusField which is used to size each the element items.
	 * The ScatterPlot add the property maxRadius to the CartesianChart properties list.
	 * @see CartesianChart */
	public class ScatterPlot extends Cartesian implements ISizableItem
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

		private var _minRadius:Number = 10;
		/** @Private
		 * Set the minimum radius value for the scatter plot.*/
		public function set minRadius(val:Number):void
		{
			_minRadius = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get minRadius():Number
		{
			return _minRadius;
		}

		public function ScatterPlot()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			var scatterElements:Array = [];
			// load all scatter Elements (there might be Elements that are not IScatter 
			// in the ScatterPlot chart)
			for (var i:Number = 0; i<_elements.length; i++)
				if (_elements[i] is IScatter)
					scatterElements.push(_elements[i]);
			
			if (scatterElements.length > 0)
			{
				var maxRadiusValues:Array = [];
				var minRadiusValues:Array = [];
				
				for (i = 0; i<scatterElements.length; i++)
				{
					if (IElement(scatterElements[i]).cursor)
					{
						IElement(scatterElements[i]).cursor.seek(CursorBookmark.FIRST);
						while (! IElement(scatterElements[i]).cursor.afterLast)
						{
							if (maxRadiusValues[i] == null)
								maxRadiusValues[i] = IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								maxRadiusValues[i] = Math.max(maxRadiusValues[i],
															IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField]);
							if (minRadiusValues[i] == null)
								minRadiusValues[i] = IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								minRadiusValues[i] = Math.min(minRadiusValues[i],
															IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField]);
						
							IElement(scatterElements[i]).cursor.moveNext();
						}						
					} else if (cursor) {
						cursor.seek(CursorBookmark.FIRST);
						
						// calculate the min and max radius values for each scatter Elements
						while (! cursor.afterLast)
						{
							if (maxRadiusValues[i] == null)
								maxRadiusValues[i] = cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								maxRadiusValues[i] = Math.max(maxRadiusValues[i],
															cursor.current[IScatter(scatterElements[i]).radiusField]);
							if (minRadiusValues[i] == null)
								minRadiusValues[i] = cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								minRadiusValues[i] = Math.min(minRadiusValues[i],
															cursor.current[IScatter(scatterElements[i]).radiusField]);

							cursor.moveNext();
						}
					}
				}
				
				// set the min and max radius values for each scatter Elements
				// this will needed by the scatter Elements when calculating the
				// sizes for each data value
				for (i = 0; i<scatterElements.length; i++)
				{
					IScatter(scatterElements[i]).maxRadiusValue = maxRadiusValues[i];
					IScatter(scatterElements[i]).minRadiusValue = minRadiusValues[i];
				}
			}
		}
	}
}