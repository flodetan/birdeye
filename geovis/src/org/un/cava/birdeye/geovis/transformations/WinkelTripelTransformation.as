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

package org.un.cava.birdeye.geovis.transformations
{
	public class WinkelTripelTransformation extends Transformation
	{
		private var _latRad:Number;
		private var _longRad:Number;
		private var _sincAlpha:Number;
		
		public function WinkelTripelTransformation(lat:Number,long:Number)
		{
			super();
			_latRad=convertDegToRad(lat);
			_longRad=convertDegToRad(long);
			this.scalefactor=68;
			this.xoffset=6.13;
			this.yoffset=2.88;

			_sincAlpha=calcSincAlpha(_latRad,_longRad);
		}

		private function calcSincAlpha(la:Number,lo:Number):Number
		{
			var alpha:Number = Math.acos(Math.cos(la)*Math.cos(lo/2));
			if (alpha==0) {
				return 1;
			}else{
				return (Math.sin(alpha)/alpha);
			}
		}

		public override function calculateX():Number
		{
			const cosEquirect:Number = 1;
			var xCentered:Number;
			//x = long*cosEquirect + 2cos(lat)*sin(long/2)/sincAlpha
			xCentered = _longRad*cosEquirect + 2*Math.cos(_latRad)*Math.sin(_longRad/2)/_sincAlpha;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			//y = lat + sin(lat)/sincAlpha
			yCentered = _latRad + Math.sin(_latRad)/_sincAlpha;
			return translateY(yCentered);
		}

	}
}