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
	import org.un.cava.birdeye.qavis.charts.axis.BaseAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.PercentAngleAxis;
	
	public class PieChart extends PolarChart
	{		
		public function PieChart()
		{
			super();
			angleAxis = new PercentAngleAxis();
			angleAxis.size = 360;
			radiusAxis = new NumericAxis();
			NumericAxis(radiusAxis).showAxis = false;
			radiusAxis.scaleType = BaseAxis.CONSTANT;
		}
	}
}