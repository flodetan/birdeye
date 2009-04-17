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
 
package org.un.cava.birdeye.qavis.charts.interfaces
{
	import org.un.cava.birdeye.qavis.charts.polarCharts.PolarChart;
	
	public interface IPolarSeries extends ISeries
	{
		/** Set the chart target. This allows to share axes and other properties
		 * of the chart among several series.*/
		function set polarChart(val:PolarChart):void;
		function get polarChart():PolarChart
		
		/** Set the angleField to filter vertical data values.*/
		function set angleField(val:String):void;
		function get angleField():String;

		/** Set the radiusField to filter horizontal data values.*/
		function set radiusField(val:String):void;
		function get radiusField():String;

		/** Set the angle axis.*/
		function set angleAxis(val:IAxis):void;
		function get angleAxis():IAxis;

		/** Set the radius axis.*/
		function set radiusAxis(val:IAxis):void;
		function get radiusAxis():IAxis;

		function get maxAngleValue():Number;
		function get minAngleValue():Number;

		function get maxRadiusValue():Number;
		function get minRadiusValue():Number;

		function get totalAnglePositiveValue():Number;
	}
}