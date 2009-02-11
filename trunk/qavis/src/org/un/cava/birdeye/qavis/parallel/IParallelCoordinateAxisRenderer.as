///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2009 Michael VanDaniker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////

package org.un.cava.birdeye.qavis.parallel
{
	import mx.core.IUIComponent;
	
	/**
	 * An interface to be implemented by components rendering parallel coordinate axes
	 */
	public interface IParallelCoordinateAxisRenderer extends IUIComponent
	{
		function get fieldName():String;
		function set fieldName(value:String):void;
		
		function get label():String;
		function set label(value:String):void;

		// In order to determine where the ParallelCoordinateItemRenderer should draw
		// lines, it needs to know the location of the actual axis within the axis renderer.
		// The following four getters allow the implementor to expose this information.
		
		/**
		 * The distance from the left side of the axis renderer to what 
		 * item renderer should consider the actual axis.
		 */
		function get axisOffsetLeft():Number;
		
		/**
		 * The distance from the right side of the axis renderer to what 
		 * item renderer should consider the actual axis.
		 */
		function get axisOffsetRight():Number;
		
		/**
		 * The distance from the top of the axis renderer to what 
		 * item renderer should consider the actual axis.
		 */
		function get axisOffsetTop():Number;
		
		/**
		 * The distance from the bottom of the axis renderer to what 
		 * item renderer should consider the actual axis.
		 */
		function get axisOffsetBottom():Number;
	}
}