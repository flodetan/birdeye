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

	public class EckertVITransformation extends Transformation
	{

		public function EckertVITransformation()
		{
			super();
		}

		private function approxNotGoodEnough(tP:Number, la:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			//tP+sin(tP)=(1+pi/2)*sin(lat)
			//diff = Left side - Right side = tP + sin(tP)- (1+pi/2)*sin(lat)
			var diff:Number = tP+Math.sin(tP) - (1+Math.PI/2)*Math.sin(la); 
			return (Math.abs(diff)>maxDiff);
		}
		
		private function newtonRaphson(tP:Number, la:Number):Number {
			//numerator: (1+pi/2)*sin(lat) - tP - sin(tP)
			//denominator: 1+cos(tP)
			return ((1+Math.PI/2)*Math.sin(la) - tP - Math.sin(tP))/(1+Math.cos(tP));
		}

		private function approx_theta(la:Number):Number
		{
			var thetaPrim:Number = la;
			var _loopCounter:Number=0; //insurance against infinite looping
			while (approxNotGoodEnough(thetaPrim, la)==false && _loopCounter<100) {
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, la);
				_loopCounter++;
			}
			return thetaPrim;
		}

		public override function calcX(latDeg:Number, longDeg:Number):Number
		{
			const lstart:Number = 0;
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var theta:Number;
			
			theta = approx_theta(latRad);
			//x	=(long-lstart)*(1+cos(theta)/(sqrt(2+pi))
			return (longRad-lstart)*(1+Math.cos(theta))/Math.sqrt(2+Math.PI);						
		}

		public override function calcY(latDeg:Number, longDeg:Number):Number
		{
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var theta:Number;
			
			theta = approx_theta(latRad);
			//y	= 2*theta/sqrt(2+pi)
			return 2*theta/Math.sqrt(2+Math.PI);
		}
	}
}