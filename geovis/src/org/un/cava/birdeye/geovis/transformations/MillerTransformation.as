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
	public class MillerTransformation extends Transformation
	{
		
		public function MillerTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.scalefactor=120;
			this.xoffset=3.16;
			this.yoffset=1.99;
		}

		public override function calculateX():Number
		{
			var xCentered:Number=this.long;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			//y = 1.25 ln( tan(pi/4 + 0.8 lat/2) ) 
			yCentered = 1.25*Math.log( Math.tan(Math.PI/4 + 0.4*this.lat) );
			return translateY(yCentered);
		}

	}
}