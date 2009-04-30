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
	
	public class CategoryAngleAxis extends CategoryAxis
	{
		private var _angle:Number;
		
		private var _minAngle:Number = 0;
		/** Minimum angle for the angle axis.*/
		public function set minAngle(val:Number):void
		{
			_minAngle = val;
			if (elements && elements.length>0)
				_interval = (_maxAngle - _minAngle) / elements.length;
		}

		private var _maxAngle:Number = 360;
		/** Maximum angle for the angle axis.*/
		public function set maxAngle(val:Number):void
		{
			_maxAngle = val;
			if (elements && elements.length>0)
				_interval = (_maxAngle - _minAngle) / elements.length;
		}

		/** Elements defining the category angle axis.*/
		override public function set elements(val:Array):void
		{
			super.elements = val;
			if (elements && elements.length>0)
				interval = (_maxAngle - _minAngle) / elements.length;
		}
		
		public function CategoryAngleAxis():void
		{
			showAxis = false;
		}

		override public function getPosition(dataValue:*):*
		{
			if (! isNaN(_interval) && elements && elements.indexOf(dataValue) != -1)
			{
				if (_function == null)
					return elements.indexOf(dataValue) * _interval;
				else 
					return  _function(dataValue, _minAngle, _maxAngle, interval);
			}
		}
	}
}