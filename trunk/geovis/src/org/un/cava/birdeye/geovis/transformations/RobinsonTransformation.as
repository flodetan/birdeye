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
	public class RobinsonTransformation extends Transformation
	{
		private var _lat:Number;
		private var _long:Number;
		private var _lowLat:int;
		private var _highLat:int;
		private var _ratio:Number;
		
 		private const arrProjDef:Object={
			00 : {'PLEN':1.0000, 'PDFE' :0.0000},
			05 : {'PLEN':0.9986, 'PDFE' :0.007874},
			10 : {'PLEN':0.9954, 'PDFE' :0.015748},
			15 : {'PLEN':0.9900, 'PDFE' :0.023622},
			20 : {'PLEN':0.9822, 'PDFE' :0.031496},
			25 : {'PLEN':0.9730, 'PDFE' :0.03937},
			30 : {'PLEN':0.9600, 'PDFE' :0.047244},
			35 : {'PLEN':0.9427, 'PDFE' :0.055118},
			40 : {'PLEN':0.9216, 'PDFE' :0.0629666},
			45 : {'PLEN':0.8962, 'PDFE' :0.0707517},
			50 : {'PLEN':0.8679, 'PDFE' :0.0784352},
			55 : {'PLEN':0.8350, 'PDFE' :0.0859663},
			60 : {'PLEN':0.7986, 'PDFE' :0.0932942},
			65 : {'PLEN':0.7597, 'PDFE' :0.1003681},
			70 : {'PLEN':0.7186, 'PDFE' :0.1071245},
			75 : {'PLEN':0.6732, 'PDFE' :0.1134872},
			80 : {'PLEN':0.6213, 'PDFE' :0.1193038},
			85 : {'PLEN':0.5722, 'PDFE' :0.1239647},
			90 : {'PLEN':0.5322, 'PDFE' :0.127}
		};

		public function RobinsonTransformation(lat:Number,long:Number)
		{
			super();
			_lat=lat;
			_long=long;

			this.scalefactor=1729;
			this.xoffset=0.239;
			this.yoffset=0.1224;

			_lowLat = roundDownToFive(_lat);
			_highLat = roundUpToFive(_lat);
			_ratio = calc_ratio(_lat-_lowLat, Math.abs(_highLat-_lowLat));
		}

		private function roundUpToFive(inVal:Number):int{
			var fiver:Number = inVal / 5;
			return 5*Math.ceil(fiver);
		}

		private function roundDownToFive(inVal:Number):int{
			var fiver:Number = inVal / 5;
			return 5*Math.floor(fiver);
		}

		private function calc_ratio(numerator:Number, denominator:Number):Number{
			if (denominator==0) {
				return 0;
			} else {
				return numerator/denominator;
			}
		}

		private function sign(inVal:Number):int{
			if (inVal >= 0) {
				return 1;
			}else{
				return -1;
			}
		}
		
		public override function calculateX():Number
		{
			var xCentered:Number;		
			var lowX:Number = arrProjDef[Math.abs(_lowLat)].PLEN*_long/4/180;//Math.PI;
			var highX:Number = arrProjDef[Math.abs(_highLat)].PLEN*_long/4/180;//Math.PI;
			
//			xCentered = interpolate(_ratio, lowX, highX);
			xCentered = lowX+_ratio*(highX-lowX);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			var sign:int = sign(_lat)
			var lowY:Number = sign*arrProjDef[Math.abs(_lowLat)].PDFE;
			var highY:Number = sign*arrProjDef[Math.abs(_highLat)].PDFE;

//			yCentered = interpolate(_ratio, lowY, highY);
			yCentered = lowY+_ratio*(highY-lowY);			
			return translateY(yCentered);
		}

	}
}