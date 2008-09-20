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
	public class MollweideTransformation extends Transformation
	{
		private var theta:Number=1;
		private var loopCounter:int=0;
		
		public function MollweideTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;
			this.scalefactor=152;
			this.xoffset=2.74;
			this.yoffset=1.35;
			this.xscaler=1;

			this.theta = approxTheta(lat);
		}
		
		private function approxIsGoodEnough(tP:Number, lat:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			loopCounter++;
			//diff = Left side - Right side = tP + sin(tP) - pi*sin(lat)
			var diff:Number = tP+Math.sin(tP) - Math.PI * Math.sin(lat); 
			return (Math.abs(diff)<maxDiff || loopCounter>=100); //Do not loop more than 100 times
		}
		
		private function newtonRaphson(tP:Number, lat:Number):Number {
			return (Math.PI * Math.sin(lat)-tP-Math.sin(tP))/(1 + Math.cos(tP));
		}

		private function approxTheta(lat:Number):Number
		{
			var thetaPrim:Number = lat;
			while (approxIsGoodEnough(thetaPrim, lat)==false) {
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, lat);
			}
			return thetaPrim/2;
		}

		public override function calculateX():Number
		{
			var xCentered:Number;
			const c:Number = 2*Math.sqrt(2)/Math.PI;
			
			xCentered = c * this.long * Math.cos(this.theta);
			xCentered = xCentered *this.xscaler;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			yCentered = Math.sqrt(2) * Math.sin(this.theta);
			return translateY(yCentered);
		}
				
	}
}