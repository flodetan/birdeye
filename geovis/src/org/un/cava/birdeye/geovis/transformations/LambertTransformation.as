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
	public class LambertTransformation extends Transformation
	{
		private const lstart:Number=0;		
		private const stdLat:Number=0;
		private var kayPrim:Number;
		
		public function LambertTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;			

			kayPrim = calcKayPrim(this.long, this.lat);
			this.scalefactor=152.3;
			this.xoffset=1.94;
			this.yoffset=1.79;
		}

		private function calcKayPrim(lo:Number,la:Number):Number
		{
			//k'=sqrt(2/( 1+sin(stdLat)sin(lat)+cos(stdLat)cos(lat)cos(lambda-lstart) )) 
			var denominator:Number = 1+Math.sin(this.stdLat)*Math.sin(la)+Math.cos(this.stdLat)*Math.cos(la)*Math.cos(lo-this.lstart);
			return Math.sqrt(2/denominator);
		}
		
		public override function calculateX():Number
		{
			var xCentered:Number;

			//x	= k'*cos(lat)*sin(long-lstart)
			xCentered = this.kayPrim * Math.cos(this.lat)*Math.sin(this.long-this.lstart);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			//y	= k'[cos(stdLat)sin(lat)-sin(stdLat)cos(lat)cos(long-lstart)]
			yCentered = this.kayPrim * (Math.cos(this.stdLat)*Math.sin(this.lat)-Math.sin(this.stdLat)*Math.cos(this.lat)*Math.cos(this.long-this.lstart));
			return translateY(yCentered);
		}

	}
}