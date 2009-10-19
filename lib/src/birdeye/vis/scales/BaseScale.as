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
	import birdeye.vis.interfaces.validation.IValidatingParent;
	import birdeye.vis.interfaces.validation.IValidatingScale;
	


	public class BaseScale implements IValidatingScale
	{
		/** Scale type: Linear */
		public static const LINEAR:String = "linear";
		/** Scale type: Percent */
		public static const PERCENT:String = "percent";
		/** Scale type: CONSTANT */
		public static const CONSTANT:String = "constant";
		/** Scale type: Numeric (general numeric scale that could be used for custom numeric axes)*/
		public static const NUMERIC:String = "linear";
		/** Scale type: Category */
		public static const CATEGORY:String = "category";
		/** Scale type: Logaritmic */
		public static const LOG:String = "log";
		/** Scale type: DateTime */
		public static const DATE_TIME:String = "date_time";
		
		
		/** Constant describing dimension X */
		public static const DIMENSION_1:String = "dim1";
		/** Constant describing dimension Y */
		public static const DIMENSION_2:String = "dim2";
		/** Constant describing dimension Z */
		public static const DIMENSION_3:String = "dim3";
		
		
		/*
		* INTERFACE IVALIDATINGCHILD IMPLEMENTATION
		*/
		// TODO create a separate namespace for these functions and share them?
		
		protected var toBeInvalidated:Boolean = false;
		private var _valParent:IValidatingParent;
		public function set parent(val:IValidatingParent):void
		{
			_valParent = val;	
			if (toBeInvalidated)
			{
				invalidate();
				toBeInvalidated = false;
			}
		}
		public function get parent():IValidatingParent
		{
			return _valParent;
		}
		
		private var invalidated:Boolean = false;
		public function invalidate():void
		{
			if (!_valParent)
				toBeInvalidated = true;

			if (!invalidated && _valParent)
			{
				_valParent.invalidate(this);
				invalidated = true;
			}
		}
		
		public function get isInvalidated():Boolean
		{
			return invalidated;
		}
		
		
		/**
		 * This is an implementation of the IValidatingChild interface.</br>
		 * Do not call this method. </br>
		 * <b>Call super() when overriding this method!</b>
		 * @see birdeye.vis.interfaces.IValidatingChild
		 * @see birdeye.vis.interfaces.IValidatingParent
		 */
		public function commit():void
		{
			invalidated = false;
			// override this by childs
		}
		
		// END INTERFACE IMPLEMENTATION
		
		protected var _scaleValues:Array; /* of numerals  for numeric scales and strings for category scales*/
 		/** Define the min max values for numeric scales ([minColor, maxColor] or [minRadius, maxRadius])
 		 * and category strings for category scales.*/
 		/** Define the min max scale values for numeric scales ([minColor, maxColor] or [minRadius, maxRadius]). Here values
 		 * refer to scale values, depending on the scale they can be pixels, colors ranges, size ranges, etc.*/
		public function set scaleValues(val:Array):void
		{
			_scaleValues = val;
			_scaleValues.sort(Array.NUMERIC);
			size = _scaleValues[1] - _scaleValues[0];
		}
		public function get scaleValues():Array
		{
			return _scaleValues;
		}

		public static const POSITIVE:String = "positive";
		public static const NEGATIVE:String = "negative";
		private var _direction:String = POSITIVE;
		/** Set the direction of the scale. A positive direction refers to left->right for
		 * x axes, or down->up for y axes. Negative refers to right->left for x axes and 
		 * up->down for y axes.*/
		 [Inspectable(enumeration="positive,negative")]
		public function set direction(val:String):void
		{
			_direction = val;
			invalidate();
		}
		public function get direction():String
		{
			return _direction;
		}

		protected var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;

			//invalidate();
		}
		
		protected var _scaleType:String = LINEAR;
		/** Set the scale type, LINEAR by default. */
		public function set scaleType(val:String):void
		{
			_scaleType = val;
			
			//invalidate();
		}
		public function get scaleType():String
		{
			return _scaleType;
		}
		
		protected var _dataInterval:Number = NaN;
		
		/** @Private
		 * Set to true if the user has specified an interval for the axis.
		 * Otherwise, the interval will be calculated automatically.
		 */
		protected var isGivenInterval:Boolean = false;
		
		/** Set the interval between axis values. */
		public function set dataInterval(val:Number):void
		{
			_dataInterval = val;
			isGivenInterval = !isNaN(_dataInterval);
			
			//invalidate();
		}
		
		public function get dataInterval():Number
		{
			return _dataInterval;
		}

		protected var _scaleInterval:Number = NaN;
		/** Set the scale interval between scale values (pixels, colors..). */
		public function set scaleInterval(val:Number):void
		{
			_scaleInterval = val;
			isGivenInterval = !isNaN(_scaleInterval);
			//invalidate();
		}
		public function get scaleInterval():Number
		{
			return _scaleInterval;
		}
		
		
		protected var _numberOfIntervals:Number = NaN;
		/** Set the number of intervals in the scale. For ex. 5 intervals, will define
		 * 5 labels and ticks on the scale. This can be used as alternative to scaleInterval and
		 * dataInterval. If dataInterval and scaleInterval are not defined than numberOfIntervals
		 * is used. If numberOfIntervals is not set the scale will create the best possible scale.*/
		public function set numberOfIntervals(val:Number):void
		{
			_numberOfIntervals = val;
			
			//invalidate();
		}
		public function get numberOfIntervals():Number
		{
			return _numberOfIntervals;
		}
		
		protected var _dataValues:Array; /* of numerals  for numeric scales and strings for category scales*/
 		/** Define the min and max data values for numeric scales ([minLat, maxLong], [minAreaDensity, maxAreaDensity])
 		 * and category strings for category scales. The data values property has higher priority compared to min, max and 
 		 * dataProvider. It also avoids the algorithmic calculation of min, max for Numeric scales and dataProvider for 
 		 * Category scales.*/
		public function set dataValues(val:Array):void
		{
			// to be overridden
		}
		public function get dataValues():Array
		{
			return _dataValues;
		}

/*		/** Set the origin point of the scale.*
		public function set origin(val:Point):void
		public function get origin():Point
		
		/** Set the angle of the scale.*
		public function set angle(val:Number):void
		public function get angle():Number */
		



		
		protected var _size:Number;
		public function set size(val:Number):void
		{
			_size = val;
			
			//invalidate();
		}
		
		
		public function get size():Number
		{
			return _size;
		}
		
		protected var _dimension:String;
		/**
		 * Set the dimension of this scale.</br>
		 * <b>This is called by the framework</b>
		 */
		public function set dimension(dim:String):void
		{
			_dimension = dim;
			
			//invalidate();
			
		}
		
		public function get dimension():String
		{
			return _dimension;
		}		

		/** @Private
		 * Given a data value, it returns the position of the data value on the current axis.
		 * Override this method depending on the axis scaling (linear, log, category, etc).
		 */
		public function getPosition(dataValue:*):*
		{
			// abstract method to be overridden by implementing class (Category, Numeric, DateTime..)
			throw new Error("abstract method that must be overridden");
			return null;
		}
		
		public function resetValues():void
		{
			// override
		}
	}
}