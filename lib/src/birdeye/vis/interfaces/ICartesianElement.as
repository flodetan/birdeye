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
		
		/** Set the dim1 to filter horizontal data values.*/
		function set dim1(val:String):void;
		function get dim1():String;

		/** Set the dim2 to filter vertical data values.*/
		function set dim2(val:String):void;
		function get dim2():String;

		/** Set the dim3 to filter vertical data values.*/
		function set dim3(val:String):void;
		function get dim3():String;

		/** Set the scale for dim1.*/
		function set scale1(val:IScaleUI):void;
		function get scale1():IScaleUI;

		/** Set the scale for dim2.*/
		function set scale2(val:IScaleUI):void;
		function get scale2():IScaleUI;

		/** Set the scale for dim3.*/
		function set scale3(val:IScaleUI):void;
		function get scale3():IScaleUI;

		function get maxDim1Value():Number;
		function get minDim1Value():Number;

		function get maxDim2Value():Number;
		function get minDim2Value():Number;

		function get maxDim3Value():Number;
		function get minDim3Value():Number;
	}
}