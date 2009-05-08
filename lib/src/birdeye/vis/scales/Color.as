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
	import com.degrafa.geometry.RegularRectangle;
	
	[Exclude(name="scaleType", kind="property")]
	public class Color extends Linear
	{
		public function Color():void
		{
			showAxis = false;
			_range = [0x000000,0xffffff];
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			// no need to draw
		}
		
		// other methods

		/** @Private
		 * Override the XYZAxis getPostion method based on the linear scaling.*/
		override public function getPosition(dataValue:*):*
		{
			size = Math.abs(_range[1]-_range[0]);
			
			var color:Number = NaN;
			if (! (isNaN(max) || isNaN(min)))
				color = size * (Number(dataValue) - min)/(max - min);
				
			return isNaN(color) ? color: decimalToHex(Math.min(_range[1], _range[0]) + color);
		}

		private function decimalToHex(value:uint):String
		{
			var hexDigits:String = "0123456789ABCDEF";
			var hex:String = '';
			
			while (value > 0)
			{
				//get the next hex digit by masking everything except the last 4 bits (a single hex digit)
				var next:uint = value & 0xF;
				//shift number by 4 bits (the value in 'next')
				value >>= 4;
				//add the hex value of 'next' to the string
				hex = hexDigits.charAt(next) + hex;
			}
			//ensure there's at least one digit
			if (hex.length == 0)
				hex = '0'
			
			//add the hexadecimal prefix
			return '0x'+hex;
		}
	}
}