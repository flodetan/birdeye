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

	public class MollweideTransformation extends Transformation
	{
		protected var _xscaler:Number;
		private var _loopCounter:int=0;
		
		public function MollweideTransformation()
		{
			super();
		}
	
		private function approxNotGoodEnough(tP:Number, la:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			//diff = Left side - Right side = tP + sin(tP) - pi*sin(lat)
			var diff:Number = tP+Math.sin(tP) - Math.PI * Math.sin(la); 
			return (Math.abs(diff)>maxDiff); //Do not loop more than 100 times
		}
		
		private function newtonRaphson(tP:Number, la:Number):Number {
			return (Math.PI * Math.sin(la)-tP-Math.sin(tP))/(1 + Math.cos(tP));
		}

		private function approx_theta(la:Number):Number
		{
			var thetaPrim:Number = la;
			var _loopCounter:Number=0; //insurance against infinite looping
			while (approxNotGoodEnough(thetaPrim, la) && _loopCounter<100) {
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, la);
				_loopCounter++;
			}
			return thetaPrim/2;
		}

		public override function calcXY(latDeg:Number, longDeg:Number, zoom:Number):Point
		{
			const c:Number = 2*Math.sqrt(2)/Math.PI;
			var latRad:Number=convertDegToRad(latDeg);
			var longRad:Number=convertDegToRad(longDeg);
			var theta:Number=1;
			var xCentered:Number;
			var yCentered:Number;
			
			theta = approx_theta(latRad);
			
			xCentered = c * longRad * Math.cos(theta);
			xCentered = xCentered *_xscaler;
			
			yCentered = Math.sqrt(2) * Math.sin(theta);
									
			return createTranslatedXYPoint(xCentered, yCentered, zoom);						
		}
		
		//--------------------------------------------------------------------------
	    //
	    //  Setters and Getters
	    //
	    //--------------------------------------------------------------------------
		public function set xscaler(value:Number):void{
			_xscaler=value;
		}
		
		public function get xscaler():Number{
			return _xscaler;
		}
				
	}
}