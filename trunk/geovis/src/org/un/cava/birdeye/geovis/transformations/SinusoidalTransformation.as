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
	public class SinusoidalTransformation extends Transformation
	{
		private var _latRad:Number;
		private var _longRad:Number;
		
		public function SinusoidalTransformation(lat:Number,long:Number)
		{
			super();
			_latRad=convertDegToRad(lat);
			_longRad=convertDegToRad(long);

			this.scalefactor=139;
			this.xoffset=2.97;
			this.yoffset=1.45;
		}

		//When the Sinusoidal transformation is used for the peripheral parts of the Goode projection
		public function setGoodeConstants():void
		{
			this.scalefactor = 138.6;
			this.xoffset = 2.98;
			this.yoffset = 1.32;
		}

		public override function calculateX():Number
		{
			var xCentered:Number;
			//x = (long-lstart)*cos(lat)  //lstart=0
			xCentered=(_longRad)*Math.cos(_latRad);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number = _latRad;
			return translateY(yCentered);
		}

	}
}