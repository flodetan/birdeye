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
	import com.degrafa.geometry.RegularRectangle;
	
	[Exclude(name="scaleType", kind="property")]
	public class ConstantAxis extends NumericAxis 
	{
		/** @Private
		 * the scaleType cannot be changed, since it's inherently "constant".*/
		override public function set scaleType(val:String):void
		{}
		
		private var _constant:Number = NaN;
		public function set constant(val:Number):void
		{
			_constant = val;
		}
		 
		// UIComponent flow
		
		public function ConstantAxis()
		{
			super();
			_scaleType = BaseAxis.CONSTANT;
			showLabels = false;
			maxLblSize = 0;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
		}
		
		// other methods

		/** @Private
		 * Override the XYZAxis getPostion method based on the constant scaling. If a constant
		 * value is given, than it's returned no matter the input given to the function, 
		 * otherwise the mid size value is returned, since the constant axis 
		 * might simply the default chart axis, meaning that the chart has 1 axis only.
		 * The constant value is a position on the axis and not a constant data value.*/
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			if (!isNaN(_constant))
			{
				if (! (isNaN(max) || isNaN(min)))
					switch (placement)
					{
						case BOTTOM:
						case TOP:
						case HORIZONTAL_CENTER:
							pos = _constant;
							break;
						case LEFT:
						case RIGHT:
						case VERTICAL_CENTER:
							pos = size - _constant;
							break;
					}
			} else 
				pos = size * .5;
				
			return pos;
		}
	}
}