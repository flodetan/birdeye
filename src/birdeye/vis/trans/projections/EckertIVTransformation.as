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

	public class EckertIVTransformation extends Transformation
	{

		public function EckertIVTransformation()
		{
			super();
			this.scalefactor=163.6;
			this.xoffset=2.524;
			this.yoffset=1.31;
		}

		private function approxNotGoodEnough(tP:Number, la:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			//diff = Left side - Right side = tP + sin(tP)cos(tP) + 2sin(tP) - (2 + pi/2)*sin(lat)
			var diff:Number = tP+Math.sin(tP)*Math.cos(tP)+2*Math.sin(tP) - (2+Math.PI/2) * Math.sin(la); 
			return (Math.abs(diff)>maxDiff);
		}
		
		private function newtonRaphson(tP:Number, la:Number):Number {
			//numerator: (2+pi/2)*sin(lat) - tP - sin(tP)cos(tP) - 2sin(tP)
			//denominator: 2cos(tP)*(1+cos(tP))
			return ((2+Math.PI/2)*Math.sin(la) - tP - Math.sin(tP)*Math.cos(tP) - 2*Math.sin(tP))/(2*Math.cos(tP)*(1+Math.cos(tP)));
		}

		private function approx_theta(la:Number):Number
		{
			var _thetaPrim:Number = la/2;
			var _loopCounter:Number=0; //insurance against infinite looping
			while (approxNotGoodEnough(_thetaPrim, la) && _loopCounter<100) {
				_thetaPrim = _thetaPrim + newtonRaphson(_thetaPrim, la);
				_loopCounter++;
			}
			return _thetaPrim;
		}

		public override function calcXY(latDeg:Number, longDeg:Number, zoom:Number):Point
		{
			const lstart:Number = 0;
			const c:Number = 2/Math.sqrt(4+Math.PI);
			const sqrtPi:Number = Math.sqrt(Math.PI);
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var theta:Number;
			var xCentered:Number;
			var yCentered:Number;
			
			theta = approx_theta(latRad);
			//x = 2/sqrt(pi*(4+pi)) * (long-lstart)*( 1+cos(theta) )
			xCentered = c/sqrtPi *(longRad-lstart)*(1+Math.cos(theta));
			//y = 2*sqrt(pi/(4+pi)) * sin(theta)
			yCentered = c*sqrtPi * Math.sin(theta);
						
			var xval:Number=translateX(xCentered)*zoom;
			var yval:Number=translateY(yCentered)*zoom;
			return new Point(xval,yval);
		}

	}
}