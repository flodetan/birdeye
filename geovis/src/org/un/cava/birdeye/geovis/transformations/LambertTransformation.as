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
		private var _latRad:Number;
		private var _longRad:Number;
		private const _lstart:Number=0;		
		private const _stdLat:Number=0;
		private var _kayPrim:Number;
		
		public function LambertTransformation(lat:Number,long:Number)
		{
			super();
			_latRad=convertDegToRad(lat);
			_longRad=convertDegToRad(long);

			_kayPrim = calc_kayPrim(_latRad,_longRad);
			this.scalefactor=152.2;
			this.xoffset=1.98;
			this.yoffset=1.94;
		}

		private function calc_kayPrim(la:Number, lo:Number):Number
		{
			//k'=sqrt(2/( 1+sin(_stdLat)sin(lat)+cos(_stdLat)cos(lat)cos(lambda-_lstart) )) 
			var denominator:Number = 1+Math.sin(_stdLat)*Math.sin(la)+Math.cos(_stdLat)*Math.cos(la)*Math.cos(lo-_lstart);
			return Math.sqrt(2/denominator);
		}
		
		public override function calculateX():Number
		{
			var xCentered:Number;

			//x	= k'*cos(lat)*sin(long-_lstart)
			xCentered = _kayPrim * Math.cos(_latRad)*Math.sin(_longRad-_lstart);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			//y	= k'[cos(_stdLat)sin(lat)-sin(_stdLat)cos(lat)cos(long-_lstart)]
			yCentered = _kayPrim * (Math.cos(_stdLat)*Math.sin(_latRad)-Math.sin(_stdLat)*Math.cos(_latRad)*Math.cos(_longRad-_lstart));
			return translateY(yCentered);
		}

	}
}