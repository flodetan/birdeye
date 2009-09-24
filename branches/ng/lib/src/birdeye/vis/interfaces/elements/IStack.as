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
 
package birdeye.vis.interfaces.elements
{
	public interface IStack extends IElement
	{
		/** Set the position of the current component (element) inside a stack.*/
		function set stackPosition(val:Number):void;
		
		/** Set the total of clustered elements inside a cluster collision.*/
		function set total(val:Number):void;

		/** Set the element type (columns, area, bars).*/
		function get elementType():String;

		/** Set/Get the stack type (overlaid, stacked, stacked100).*/
		function set stackType(val:String):void;
		function get stackType():String;

		/** Set the baseValues for stacked 100 collisions (columns, area, bars).*/
		function set baseValues(val:Array):void;
		function get baseValues():Array;

		/** Set the topValues for stacked collisions.*/
		function set topValues(val:Array):void;
		function get topValues():Array;

		/** Set the maximum values for each category of the element. Used for stack100.*/
		function set maxCategoryValues(val:Array):void;
		function get maxCategoryValues():Array;

		/** Set the scale that defines the 'direction' of the stack. For ex. BarElements are stacked horizontally with 
		 * stack100 and vertically with normal stack. Columns (for both polar and cartesians)
		 * are stacked vertically with stack100, and horizontally for normal stack.*/
		function set collisionScale(val:String):void;
		function get collisionScale():String;
	}
}