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
	import birdeye.vis.interfaces.INumerableAxis;
	import birdeye.vis.scales.BaseScale;
	
	public class PercentAxis extends NumericAxis
	{
		/** Set the scale type, LINEAR by default. */
		override public function set scaleType(val:String):void
		{
			_scaleType = BaseScale.PERCENT;
		}
		
		override public function set min(val:Number):void
		{
			_min = NaN;
		}

		override public function set max(val:Number):void
		{
			_max = NaN;
		}
		
		public function PercentAxis():void
		{
			showAxis = false;
		}

		override public function getPosition(dataValue:*):*
		{
			if (isNaN(_size))
				size = 100;
			return size * Number(dataValue) / _totalPositiveValue;
		} 
	}
}