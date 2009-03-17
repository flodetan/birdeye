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
 
package org.un.cava.birdeye.qavis.charts.series
{
	import com.degrafa.geometry.Circle;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;

	public class PlotSeries extends CartesianSeries
	{
		public function PlotSeries()
		{
			super();
		}
		
		private var plot:Circle;
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			for (var i:Number = gg.geometryCollection.items.length; i>0; i--)
				gg.geometryCollection.removeItemAt(i-1);

			var xPos:Number, yPos:Number;
			
			dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!dataProvider.cursor.afterLast)
			{
				if (horizontalAxis)
				{
					if (horizontalAxis is NumericAxis)
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
					else if (horizontalAxis is CategoryAxis)
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
				} else {
					if (dataProvider.horizontalAxis is NumericAxis)
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
					else if (dataProvider.horizontalAxis is CategoryAxis)
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
				}
				
				if (verticalAxis)
				{
					if (verticalAxis is NumericAxis)
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);
					else if (verticalAxis is CategoryAxis)
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
				} else {
					if (dataProvider.verticalAxis is NumericAxis)
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[yField]);
					else if (dataProvider.verticalAxis is CategoryAxis)
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
				}
				
				plot = new Circle(xPos, yPos, 5);
				plot.fill = fill;
				plot.stroke = stroke;
				gg.geometryCollection.addItem(plot);
				dataProvider.cursor.moveNext();
			}
		}
	}
}