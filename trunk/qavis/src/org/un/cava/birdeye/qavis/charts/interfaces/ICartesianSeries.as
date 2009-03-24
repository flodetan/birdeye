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
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.CartesianChart;
	
	public interface ICartesianSeries
	{
		/** Remove all elements from the series (Surface component).*/
		function removeAllElements():void;
		
		/** Set the data provider of a cartesian series, which must be a CartesianChart.*/
		function set dataProvider(val:CartesianChart):void;

		/** Set the yField to filter vertical data values.*/
		function set yField(val:String):void;

		/** Set the xField to filter horizontal data values.*/
		function set xField(val:String):void;

		/** Set the name to display (legends..).*/
		function set displayName(val:String):void;

		/** Set the fill color.*/
		function set fillColor(val:Number):void;

		/** Set the stroke color.*/
		function set strokeColor(val:Number):void;

		/** Set the itemRenderer used for the layout of data values.*/
		function set itemRenderer(val:Class):void;

		/** Set the horizontal axis.*/
		function set horizontalAxis(val:IAxisLayout):void;

		/** Set the vertical axis.*/
		function set verticalAxis(val:IAxisLayout):void;

		function get dataProvider():CartesianChart;
		function get yField():String;
		function get xField():String;
		function get displayName():String;
		function get fillColor():Number;
		function get strokeColor():Number;
		function get itemRenderer():Class;
		function get horizontalAxis():IAxisLayout;
		function get verticalAxis():IAxisLayout;
		function get maxVerticalValue():Number;
		function get maxHorizontalValue():Number;
		function get minVerticalValue():Number;
		function get minHorizontalValue():Number;
	}
}