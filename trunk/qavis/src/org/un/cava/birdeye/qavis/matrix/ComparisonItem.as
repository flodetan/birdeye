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
	import mx.collections.ArrayCollection;
	
	[Bindable]
	/**
	 * A ComparisonItem shows the relationship between two attributes of the objects in a data set.
	 */
	public class ComparisonItem
	{
		/**
		 * One attribute of the data set captured by this ComparisonItem.
		 */
		public var xField:String;
		
		/**
		 * The other attribute of the data set captured by this ComparisonItem.
		 */
		public var yField:String;
		
		/**
		 * The numerical relationship between the xField and the yField. When used in the
		 * default implementation of the ComparisonMatrix, this value is the correlation
		 * coefficent.
		 */
		public var comparisonValue:Number;
		
		/**
		 * The dataProvider of the ComparisonMatrix that created this ComparisonItem.
		 */
		public var dataProvider:ArrayCollection;
		
		public function toString():String
		{
			return xField + ", " + yField + " : " + comparisonValue;
		}
	}
}