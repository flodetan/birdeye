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
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	
	public class NumericAxis implements INumerableAxis
	{
		public function NumericAxis()
		{
		}

		private var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
		}
		
		protected var _size:Number;
		public function set size(val:Number):void
		{
			_size = val;
		}
		public function get size():Number
		{
			return _size;
		}
	
		protected var _scaleType:String = BaseAxisUI.LINEAR;
		/** Set the scale type, LINEAR by default. */
		[Inspectable(enumeration="linear,constant,log")]
		public function set scaleType(val:String):void
		{
			_scaleType = val;
		}
		public function get scaleType():String
		{
			return _scaleType;
		}
		
		private var _interval:Number;
		public function set interval(val:Number):void
		{
			_interval = val;
		}
		public function get interval():Number
		{
			return _interval;
		}

		/** @Private
		 * Implement the IAxis getPostion method with a generic numeric function.
		 * This allows to define any type of scaling for a numeric axis.*/
		public function getPosition(dataValue:*):*
		{
			if (_function == null)
			{
				if (scaleType == BaseAxisUI.CONSTANT)
					return _size;
				else
					return _size * (Number(dataValue) - min)/(max - min);
			}
			else 
				return _function(dataValue, min, max, _baseAtZero, _size);
		}
	
		/** @Private
		 * The minimum data value of the axis, after that the min is formatted 
		 * by the formatMin methods.*/
		private var minFormatted:Boolean = false;
	
		protected var _min:Number = NaN;
		/** The minimum value of the axis (if the axis is shared among more series, than
		 * this is the minimun value among all series.*/
		public function set min(val:Number):void
		{
			_min = val;
			minFormatted = false;
			formatMin();
		}
		public function get min():Number
		{
			return _min;
		}
		
		/** @Private
		 * The maximum data value of the axis, after that max is formatted 
		 * by the formatMax methods.*/
		private var maxFormatted:Boolean = false;
	
		protected var _max:Number = NaN;
		/** The maximum value of the axis (if the axis is shared among more series, than
		 * this is the maximum value among all series. */
		public function set max(val:Number):void
		{
			_max = val;
			maxFormatted = false;
			formatMax();
		}
		public function get max():Number
		{
			return _max;
		}
		
		private var _baseAtZero:Boolean = false;
		/** Set the base of the axis at zero. If all values of the axis are positive (negative), 
		 * than the lowest base will be zero, even if the minimum value is higher (lower). */
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
		}
		public function get baseAtZero():Boolean
		{
			return _baseAtZero;
		}
	
		/** @Private
		 * Calculate the format of the axis values, in order to have 
		 * the more rounded values possible.*/ 
		private function formatMax():void
		{
			if (!maxFormatted && !isNaN(max))
			{
				var sign:Number = 1;
				var tempMax:Number = Math.ceil(max);
				if (max<0)
					sign = -1;
				var maxLenght:Number = String(Math.abs(tempMax)).length;
				tempMax /= Math.pow(10, maxLenght-1);
				tempMax = Math.ceil(tempMax);
				tempMax *= Math.pow(10, maxLenght-1);
				_max = tempMax * sign;
				maxFormatted = true; 
			}
		}
	
		/** @Private
		 * Calculate the format of the axis values, in order to have 
		 * the more rounded values possible.*/ 
		private function formatMin():void
		{
			if (!minFormatted && !isNaN(min))
			{
				var tempMin:Number;
				var minLenght:Number;
				tempMin = Math.floor(Math.abs(min));
				 
				if (min<0)
				{
					minLenght = String(tempMin).length;
					tempMin /= Math.pow(10, minLenght-1);
					tempMin = Math.ceil(tempMin);
					tempMin *= Math.pow(10, minLenght-1);
					_min = - tempMin;
					maxFormatted = true;
				} else {
					minLenght = String(tempMin).length;
					tempMin /= Math.pow(10, minLenght);
					tempMin = Math.floor(tempMin);
					tempMin *= Math.pow(10, minLenght);
					_min = tempMin;
					maxFormatted = true;
				} 
			}
		}
	}
}