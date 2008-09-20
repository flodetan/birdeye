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
	public class EckertVITransformation extends Transformation
	{
		private var theta:Number=1;
		private var loopCounter:Number=0;

		public function EckertVITransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.scalefactor=156.5;
			this.xoffset=2.64;
			this.yoffset=1.36;
			
			this.theta = approxTheta(lat);
		}

		private function approxIsGoodEnough(tP:Number, lat:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			loopCounter++;
			//tP+sin(tP)=(1+pi/2)*sin(lat)
			//diff = Left side - Right side = tP + sin(tP)- (1+pi/2)*sin(lat)
			var diff:Number = tP+Math.sin(tP) - (1+Math.PI/2)*Math.sin(lat); 
			return (Math.abs(diff)<maxDiff || loopCounter>=100);
		}
		
		private function newtonRaphson(tP:Number, lat:Number):Number {
			//numerator: (1+pi/2)*sin(lat) - tP - sin(tP)
			//denominator: 1+cos(tP)
			return ((1+Math.PI/2)*Math.sin(lat) - tP - Math.sin(tP))/(1+Math.cos(tP));
		}

		private function approxTheta(lat:Number):Number
		{
			var thetaPrim:Number = lat;
			while (approxIsGoodEnough(thetaPrim, lat)==false) {
				trace ("loopCounter: " + loopCounter);
				trace ("thetaPrim: " + thetaPrim);
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, lat);
			}
			return thetaPrim;
		}

		public override function calculateX():Number
		{
			const lstart:Number = 0;
			var xCentered:Number;
			
			//x	=(long-lstart)*(1+cos(theta)/(sqrt(2+pi))
			xCentered = (this.long-lstart)*(1+Math.cos(this.theta))/Math.sqrt(2+Math.PI);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			const c:Number = 2*Math.sqrt(Math.PI/(4+Math.PI));
			var yCentered:Number;
			
			//y	= 2*theta/sqrt(2+pi)
			yCentered = 2*this.theta/Math.sqrt(2+Math.PI);
			return translateY(yCentered);
		}

	}
}