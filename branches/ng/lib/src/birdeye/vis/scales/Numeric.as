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
 
package birdeye.vis.scales
{
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.util.NumericScaleDefinition;
	import birdeye.vis.scales.util.NumericUtil;

	public class Numeric extends BaseScale  implements INumerableScale
	{
 		/** Define the min max data values for numeric scales [100, 200] where the values refer to data values, number of
 		 * inhabitants, rain falls, etc.*/
		override public function set dataValues(val:Array):void
		{
			_dataValues = val;
			_dataValues.sort(Array.NUMERIC);
			_min = dataValues[0];
			_max = dataValues[1];
			
			invalidate();
		}
		
		/**
		 * Returns all the data values</br>
		 * For a numeric scale this is min and max and everything in between.</br>
		 * For a category scale this is identical to dataValues.</br>
		 */
		public function get completeDataValues():Array
		{
			var toReturn:Array = new Array();
			
			if (min == max) 
			{
				toReturn.push(min);
				return toReturn;
			}
			
			for (var snap:Number = min; snap<=max; snap += dataInterval)
			{
				toReturn.push(snap);
			}
			
			return toReturn;
		}
		
		/** @Private
		 * Decide whether to format or not, the min and max values of the scale.*/
		private var _format:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set format(val:Boolean):void
		{
			_format = val;
		}

		/** @Private
		 * The minimum data value of the axis, after that the min is formatted 
		 * by the formatMin methods.*/
		private var minFormatted:Boolean = false;

		protected var _totalPositiveValue:Number = NaN;
		/** The total sum of positive values of the axis.*/
		public function set totalPositiveValue(val:Number):void
		{
			_totalPositiveValue = val;
		}
		public function get totalPositiveValue():Number
		{
			return _totalPositiveValue;
		}
		
		protected var _min:Number = NaN;
		/** The minimum value of the axis (if the axis is shared among more series, than
		 * this is the minimun value among all series.*/
		public function set min(val:Number):void
		{
			_min = val;

			invalidate();
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
			
			invalidate();
		}
		public function get max():Number
		{
			return _max;
		}
		
		private var _baseAtZero:Boolean = true;
		/** Set the base of the axis at zero. If all values of the axis are positive (negative), 
		 * than the lowest base will be zero, even if the minimum value is higher (lower). */
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidate();
		}
		public function get baseAtZero():Boolean
		{
			return _baseAtZero;
		}

		// UIComponent flow
		
		public function Numeric()
		{
			super();
			scaleType = BaseScale.LINEAR;
		}
		
		override public function commit():void
		{
			
			super.commit();

			if (isNaN(_min) && _dataValues)
				_min = _dataValues[0];
			if (isNaN(_max) && _dataValues) 
				_max = _dataValues[1];

			// if no interval is specified by the user, than divide the axis in 5 parts
			if (!isNaN(max) && !isNaN(min))
			{
				if (min == max)
				{
					if (!isGivenInterval) 
						_dataInterval = 10;
					_max = min + dataInterval;
				} else if (!isGivenInterval) {
					var def:NumericScaleDefinition = NumericUtil.calculateIdealScale(min, max, baseAtZero);
					
					
					if(!def)
					{
						trace("Could not calculate ideal scale for min",min,"max",max, "baseAtZero", baseAtZero);
						createFixedScale();
					}
					else
					{
						if (!isNaN(_numberOfIntervals) && (_numberOfIntervals == def.numberOfIntervals) || isNaN(_numberOfIntervals))
						{
							_min = def.min;
							_max = def.max;
							_dataInterval = def.diff;
						}
						else
						{
							createFixedScale();
						}
					}
				}
			}
		}
		
		// other methods
		
		private function createFixedScale():void
		{
			minFormatted =false;
			maxFormatted = false;
			formatMin();
			formatMax();
			
			if (baseAtZero)
			{
				if (max > 0)
				{
					if (max < numberOfIntervals)
						_dataInterval = max;
					else
						_dataInterval = max / numberOfIntervals;
				} else
					_dataInterval = -min / numberOfIntervals;
			} else {
				if (Math.abs(max - min) < numberOfIntervals)
					dataInterval = Math.abs(max - min);
				else 
					dataInterval = Math.abs((max - min) / numberOfIntervals)
				isGivenInterval = false;
			}
		}


		/** @Private
		 * Calculate the format of the axis values, in order to have 
		 * the more rounded values possible.*/ 
		private function formatMax():void
		{
			if (!maxFormatted && !isNaN(max))
			{
				var sign:Number = 1;
				
				var tempMax:Number = Math.ceil(max - 0.0000001);
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
					minFormatted = true;
				} else {
					minLenght = String(tempMin).length;
					tempMin /= Math.pow(10, minLenght);
					tempMin = Math.floor(tempMin);
					tempMin *= Math.pow(10, minLenght);
					_min = tempMin;
					minFormatted = true;
				} 
			}
		}

		/** @Private
		 * Override the XYZAxis getPostion method with a generic numeric function.
		 * This allows to define any type of scaling for a numeric axis.*/
		override public function getPosition(dataValue:*):*
		{
			if (_function == null)
			{
				if (scaleType == BaseScale.CONSTANT)
					return _size;
				else
					return _size * (Number(dataValue) - min)/(max - min);
			}
			else 
				return _function(dataValue, min, max, _size);
		}
		
		override public function resetValues():void
		{
			super.resetValues();
			if (!dataValues)
				min = max = NaN; 
			totalPositiveValue = NaN;

		} 
		
		
		

		
		
	}
}