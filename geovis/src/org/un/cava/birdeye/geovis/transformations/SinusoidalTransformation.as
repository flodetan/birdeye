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
	public class SinusoidalTransformation extends Transformation
	{
		
		public function SinusoidalTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.xscaler=-0.05;
			this.scalefactor=137;
			this.xoffset=2.99;
			this.yoffset=1.45;
		}

		public override function calculateX():Number
		{
			//const lstart = 0;
			var lstart:Number = this.xscaler;
			var xCentered:Number;
			//x = (long-lstart)*cos(lat)
			xCentered=(this.long-lstart)*Math.cos(this.lat);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number = this.lat;
			return translateY(yCentered);
		}

	}
}