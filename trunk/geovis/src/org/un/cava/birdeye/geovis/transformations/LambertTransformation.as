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
	import flash.geom.Point;

	public class LambertTransformation extends Transformation
	{
		private const _lstart:Number=0;		
		private const _stdLat:Number=0;
		
		public function LambertTransformation()
		{
			super();
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
		
		public override function calcXY(latDeg:Number, longDeg:Number, zoom:Number):Point
		{
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var kayPrim:Number;
			var xCentered:Number;
			var yCentered:Number;
			
			kayPrim = calc_kayPrim(latRad,longRad);
			//x	= k'*cos(lat)*sin(long-_lstart)
			xCentered = kayPrim * Math.cos(latRad)*Math.sin(longRad-_lstart);
			//y	= k'[cos(stdLat)sin(lat)-sin(_stdLat)cos(lat)cos(long-_lstart)]
			yCentered = kayPrim * (Math.cos(_stdLat)*Math.sin(latRad)-Math.sin(_stdLat)*Math.cos(latRad)*Math.cos(longRad-_lstart));
						
			return createTranslatedXYPoint(xCentered, yCentered, zoom);						
		}

	}
}