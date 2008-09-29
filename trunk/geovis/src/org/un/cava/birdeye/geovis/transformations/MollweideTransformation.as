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
		private var _latRad:Number;
		private var _longRad:Number;
		private var _theta:Number=1;
		private var _loopCounter:int=0;
		
		public function MollweideTransformation(lat:Number,long:Number)
		{
			super();
			_latRad=convertDegToRad(lat);
			_longRad=convertDegToRad(long);
			this.scalefactor=151.5;
			this.xoffset=2.75;
			this.yoffset=1.37;
			this.xscaler=1;

			this._theta = approx_theta(_latRad);
		}

		//When the Mollweide transformation is used for the central part of the Goode projection
		public function setGoodeConstants():void
		{
			this.scalefactor = 131;
			this.xscaler = 1.05;
			this.xoffset = 3.16;
			this.yoffset = 1.36;
		}
		
		private function approxIsGoodEnough(tP:Number, la:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			_loopCounter++;
			//diff = Left side - Right side = tP + sin(tP) - pi*sin(lat)
			var diff:Number = tP+Math.sin(tP) - Math.PI * Math.sin(la); 
			return (Math.abs(diff)<maxDiff || _loopCounter>=100); //Do not loop more than 100 times
		}
		
		private function newtonRaphson(tP:Number, la:Number):Number {
			return (Math.PI * Math.sin(la)-tP-Math.sin(tP))/(1 + Math.cos(tP));
		}

		private function approx_theta(la:Number):Number
		{
			var thetaPrim:Number = la;
			while (approxIsGoodEnough(thetaPrim, la)==false) {
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, la);
			}
			return thetaPrim/2;
		}

		public override function calculateX():Number
		{
			var xCentered:Number;
			const c:Number = 2*Math.sqrt(2)/Math.PI;
			
			xCentered = c * _longRad * Math.cos(this._theta);
			xCentered = xCentered *this.xscaler;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			yCentered = Math.sqrt(2) * Math.sin(this._theta);
			return translateY(yCentered);
		}
				
	}
}