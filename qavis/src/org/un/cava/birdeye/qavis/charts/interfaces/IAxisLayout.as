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
	import com.degrafa.geometry.Line;
	
	public interface IAxisLayout
	{
		/** Define the scale type (category, linear, log, date...)*/
		function set scaleType(val:String):void
		function get scaleType():String

		/** Set the interval between axis labels.*/
		function set interval(val:Number):void
		function get interval():Number

		/** Set the axis placement.*/
		function set placement(val:String):void
		function get placement():String

		/** Calculates and returns the coordinate of a data value in the axis (depends on 
		 * scale type). */
		function getPosition(dataValue:*):*
		
		/** Position the axis pointer on the specific Y coordinate value. */ 
		function set pointerY(val:Number):void;

		/** Position the axis pointer on the specific X coordinate value. */ 
		function set pointerX(val:Number):void;
		
		/** Get the axis pointer. Can be used to change colors, stroke, visibility...*/
		function get pointer():Line;
	}
}