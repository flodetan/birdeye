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
	import birdeye.vis.coords.Polar;
	
	public interface IPolarElement extends IElement
	{
		/** Set the chart target. This allows to share axes and other properties
		 * of the chart among several elements.*/
		function set polarChart(val:Polar):void;
		function get polarChart():Polar
		
		/** Set the dim1 (angle) to filter data values.*/
		function set dim1(val:String):void;
		function get dim1():String;

		/** Set the dim2 (radius) to filter data values.*/
		function set dim2(val:String):void;
		function get dim2():String;

		/** Set the scale1 (angle).*/
		function set scale1(val:IScale):void;
		function get scale1():IScale;

		/** Set the scale2 (radius).*/
		function set scale2(val:IScale):void;
		function get scale2():IScale;

		function get maxDim1Value():Number;
		function get minDim1Value():Number;

		function get maxDim2Value():Number;
		function get minDim2Value():Number;

		function get totalDim1PositiveValue():Number;
	}
}