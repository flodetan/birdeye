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

package org.un.cava.birdeye.qavis.matrix
{
	import mx.core.IUIComponent;
	
	/**
	 * A class must implement this interface in order to be used as a
	 * comparisonRenderer in a ComparisonMatrix.
	 */
	public interface IComparisonRenderer extends IUIComponent
	{
		/**
		 * The comparisonItem this IComparisonRenderer should render.
		 */
		function get comparisonItem():ComparisonItem;
		function set comparisonItem(value:ComparisonItem):void;
		
		/**
		 * The function used to determine what text should be shown in the cell.
		 * 
		 * The function should take a comparisonItem as an argument and return a String.
		 * If a function is not applied, no label is shown.
		 */
		function get labelFunction():Function;
		function set labelFunction(value:Function):void;
		
		/**
		 * A function used to determine the color of this interior of this ComparisonMatrixCell.
		 * 
		 * The function should take a comparisonItem as an argument and return a uint.
		 *  
		 * The default behavior is to use red (0xff0000) for comparisonValues less than 0
		 * and blue (0xff) for all other values.
		 */
		function get colorFunction():Function;
		function set colorFunction(value:Function):void;
		
		/**
		 * A function used to determine the alpha value of this interior of this ComparisonMatrixCell.
		 * 
		 * The function should take a comparisonItem as an argument and return a Number.
		 *  
		 * The default behavior is to use the absolute value of the comparisonItem's comparisonValue.
		 */
		function get alphaFunction():Function;
		function set alphaFunction(value:Function):void;
		
		/**
		 * Whether or not this ComparisonMatrixCell should appear selected.
		 */
		function get selected():Boolean;
		function set selected(value:Boolean):void;	
	}
}