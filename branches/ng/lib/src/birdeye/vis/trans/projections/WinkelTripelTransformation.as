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
	import flash.geom.Point;

	public class WinkelTripelTransformation extends Transformation
	{
		
		public function WinkelTripelTransformation()
		{
			super();
			this.xoffset=6.283185307;
			this.yoffset=3.141592654;
			this.worldUnscaledSizeX=12;
			this.worldUnscaledSizeY=6;
		}

		private function calcSincAlpha(lat:Number,long:Number):Number
		{
			var alpha:Number = Math.acos(Math.cos(lat)*Math.cos(long/2));
			if (alpha==0) {
				return 1;
			}else{
				return (Math.sin(alpha)/alpha);
			}
		}

/*		public override function calcXY(lat:Number, long:Number, sizeX:Number, sizeY:Number):Point
		{
			const cosEquirect:Number = 1;
			var latRad:Number=convertDegToRad(lat);
			var longRad:Number=convertDegToRad(long);
			var sincAlpha:Number;
			var xCentered:Number;
			var yCentered:Number;
			
			sincAlpha=calcSincAlpha(latRad,longRad);

			//x = long*cosEquirect + 2cos(lat)*sin(long/2)/sincAlpha
			xCentered = longRad*cosEquirect + 2*Math.cos(latRad)*Math.sin(longRad/2)/sincAlpha;

			//y = lat + sin(lat)/sincAlpha
			yCentered = latRad + Math.sin(latRad)/sincAlpha;
									
			return createTranslatedXYPoint(xCentered, yCentered);
		}
*/

		public override function calcX(latDeg:Number, longDeg:Number):Number
		{
			const cosEquirect:Number = 1;
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var sincAlpha:Number;
	
			sincAlpha=calcSincAlpha(latRad,longRad);
			//x = long*cosEquirect + 2cos(lat)*sin(long/2)/sincAlpha
			return longRad*cosEquirect + 2*Math.cos(latRad)*Math.sin(longRad/2)/sincAlpha;
		}
		
		public override function calcY(latDeg:Number, longDeg:Number):Number
		{
			const cosEquirect:Number = 1;
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var sincAlpha:Number;
			
			sincAlpha=calcSincAlpha(latRad,longRad);
			//y = lat + sin(lat)/sincAlpha
			return latRad + Math.sin(latRad)/sincAlpha;
		}

	}
}