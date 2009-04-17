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
 
 package org.un.cava.birdeye.qavis.charts.axis
{
	import org.un.cava.birdeye.qavis.charts.interfaces.IEnumerableAxis;
	
	public class CategoryAxis implements IEnumerableAxis
	{
		protected var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
		}
		
		private var _size:Number;
		public function set size(val:Number):void
		{
			_size = val;
		}
		public function get size():Number
		{
			return _size;
		}
		
		/** @Private
		 * The scale type cannot be changed, since it's already "category".*/
		public function set scaleType(val:String):void
		{}
		public function get scaleType():String
		{return null}

		protected var _interval:Number = NaN;
		public function set interval(val:Number):void
		{
			_interval = val;
		}
		public function get interval():Number
		{
			return _interval;
		}

		/** Elements defining the category angle axis.*/
		private var _elements:Array = [];
		public function set elements(val:Array):void
		{
			_elements = val;
			if (elements && elements.length>0 && !isNaN(_size))
				interval = size / elements.length;
		}
		public function get elements():Array
		{
			return _elements;
		}
		
		private var _categoryField:String;
		/** Category field that will filter the category values from the 
		 * dataprovider.*/
		public function set categoryField(val:String):void
		{
			_categoryField = val;
		}
		public function get categoryField():String
		{
			return _categoryField;
		}

		public function CategoryAxis()
		{
			scaleType = BaseAxisUI.CATEGORY;
		}
		
		public function getPosition(dataValue:*):*
		{
			if (! isNaN(_interval) && _elements && _elements.indexOf(dataValue) != -1)
			{
				if (_function == null)
					return _elements.indexOf(dataValue) * _interval;
				else 
					return  _function(dataValue, size, interval);
			}
		}
	}
}