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
		private var sincAlpha:Number;
		
		public function WinkelTripelTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;
			this.scalefactor=61;
			this.xoffset=6.14;
			this.yoffset=2.9;

			this.sincAlpha=calcSincAlpha(long, lat);
			trace ("sincAlpha: " + sincAlpha);
		}


		private function calcSincAlpha(long:Number,lat:Number):Number
		{
			var alpha:Number = Math.acos(Math.cos(lat)*Math.cos(long/2));
			trace ("alpha: " + alpha);
			if (alpha==0) {
				return 1;
			}else{
				return (Math.sin(alpha)/alpha);
			}
		}

		public override function calculateX():Number
		{
			//const cosEquirect:Number = 1;//2/Math.PI;
			var cosEquirect:Number = 1;
			var xCentered:Number;
			this.sincAlpha=calcSincAlpha(this.long, this.lat);
			trace ("sincAlpha: " + sincAlpha);
			
			xCentered = this.long*cosEquirect + 2*Math.cos(this.lat)*Math.sin(this.long/2)/this.sincAlpha;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			
			yCentered = this.lat + Math.sin(this.lat)/this.sincAlpha;

			return translateY(yCentered);
		}

	}
}