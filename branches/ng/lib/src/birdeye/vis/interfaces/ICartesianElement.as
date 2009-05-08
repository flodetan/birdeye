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
 
package birdeye.vis.interfaces
{
	import birdeye.vis.coords.Cartesian;
	
	public interface ICartesianElement extends IElement
	{
		/** Set the chart target. This allows to share axes and other properties
		 * of the chart among several elements.*/
		function set chart(val:Cartesian):void;
		function get chart():Cartesian;
		
		/** Set the yField to filter vertical data values.*/
		function set yField(val:String):void;

		/** Set the xField to filter horizontal data values.*/
		function set xField(val:String):void;

		/** Set the x axis.*/
		function set xAxis(val:IAxisUI):void;

		/** Set the y axis.*/
		function set yAxis(val:IAxisUI):void;

		/** Set the z axis.*/
		function set zAxis(val:IAxisUI):void;

		function get yField():String;
		function get xField():String;
		function get xAxis():IAxisUI;
		function get yAxis():IAxisUI;
		function get zAxis():IAxisUI;

		function get maxZValue():Number;
		function get minZValue():Number;

		function get maxYValue():Number;
		function get minYValue():Number;

		function get maxXValue():Number;
		function get minXValue():Number;
	}
}