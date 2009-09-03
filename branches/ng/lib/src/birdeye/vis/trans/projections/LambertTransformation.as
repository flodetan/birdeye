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

package birdeye.vis.trans.projections
{

	public class LambertTransformation extends Transformation
	{
		private const _lstart:Number=0;		
		private const _stdLat:Number=0;	
		
		public function LambertTransformation()
		{
			super();
		}

		private function calc_kayPrim(la:Number, lo:Number):Number
		{
			//k'=sqrt(2/( 1+sin(_stdLat)sin(lat)+cos(_stdLat)cos(lat)cos(lambda-_lstart) )) 
			var denominator:Number = 1+Math.sin(_stdLat)*Math.sin(la)+Math.cos(_stdLat)*Math.cos(la)*Math.cos(lo-_lstart);
			return Math.sqrt(2/denominator);
		}
		
/*		public override function calcXY(latDeg:Number, longDeg:Number, sizeX:Number, sizeY:Number):Point
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
						
			return createTranslatedXYPoint(xCentered, yCentered);
		}
*/		
		public override function calcX(latDeg:Number, longDeg:Number):Number
		{
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var kayPrim:Number = calc_kayPrim(latRad,longRad);
			
			if (isFinite(kayPrim)) {
				//x	= k'*cos(lat)*sin(long-_lstart)
				return kayPrim * Math.cos(latRad)*Math.sin(longRad-_lstart);
			} else {	
				//When longRad-lstart is pi and lat is 0, kayPrim becomes infinite and x goes towards the square root of 2
				if (longRad >= 0) {
					return 2;
				} else {
					return -2;	
				}
			}
		}

		public override function calcY(latDeg:Number, longDeg:Number):Number
		{
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var kayPrim:Number = calc_kayPrim(latRad,longRad);
			
			if (isFinite(kayPrim)) {
				//y	= k'[cos(stdLat)sin(lat)-sin(_stdLat)cos(lat)cos(long-_lstart)]
				return kayPrim * (Math.cos(_stdLat)*Math.sin(latRad)-Math.sin(_stdLat)*Math.cos(latRad)*Math.cos(longRad-_lstart));
			} else {	
				//When longRad-lstart is pi and lat is 0, kayPrim becomes infinite and y goes towards 2
				if (latRad >= 0) {
					return 2;			
				} else {
					return -2;
				}
			}
		}
		
		protected override function calcUnscaledSizeX(minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			if (minLat<=0 && maxLat>=0) {
				var degLStart:Number=convertRadToDeg(_lstart);
				_minX = calcX(0, minLong+degLStart);
				var maxX:Number = calcX(0, maxLong+degLStart);
				return Math.abs(maxX-_minX);
			} else {
				return super.calcUnscaledSizeX(minLat,maxLat,minLong,maxLong);
			}
		}

		private function convertRadToDeg(rad:Number):Number {
			return rad * 180 / Math.PI ;
		}

	}
}