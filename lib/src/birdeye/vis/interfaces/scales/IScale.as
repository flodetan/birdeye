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
 
package birdeye.vis.interfaces.scales
{
	import flash.geom.Point;
	import birdeye.vis.interfaces.validation.IValidatingScale;
	
	public interface IScale extends IValidatingScale
	{
		/** Calculates and returns the coordinate of a data value in the axis (depends on 
		 * scale type). */
		function getPosition(dataValue:*):*

		/** Set the data interval between scale data values (density, area, mortality...).*/
		function set dataInterval(val:Number):void
		function get dataInterval():Number

		/** Set the scale interval between scale values (pixels, colors, sizes...).*/
		function set scaleInterval(val:Number):void
		function get scaleInterval():Number

		/** Set-get the size of this axis.*/
		function set size(val:Number):void
		function get size():Number

		/** Set the function used by getPosition to calculate the position of the data value over the axis.*/
		function set f(val:Function):void

		/** Define the scale type (category, linear, log, date...)*/
		function set scaleType(val:String):void
		function get scaleType():String
		
		/** Reset the scale.*/
		function resetValues():void;
		
 		/** Define the range data values for the scale. If the scale is numeric than it represents the min and max data values
 		 * of the scale, for example [minLat, maxLat] or [minLong, maxLong]...
 		 * If the scale is categorical, than it represents the category strings that are passed directly to the 
 		 * scale. The values array has higher priority over the min, max and dataProvider properties.*/
		function set dataValues(val:Array):void
		function get dataValues():Array
		
		/**
		 * Returns all the data values</br>
		 * For a numeric scale this is min and max and everything in between.</br>
		 * For a category scale this is identical to dataValues.</br>
		 */
		function get completeDataValues():Array


		/**
		 * Set X|Y|Z based on
		 */ 
		function set dimension(dim:String):void
		function get dimension():String;

/*		/** Set the origin point of the scale.
		function set origin(val:Point):void
		function get origin():Point
		
		/** Set the angle of the scale.
		function set angle(val:Number):void
		function get angle():Number
 */	}
}