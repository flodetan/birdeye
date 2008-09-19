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
		
 		private const arrProjDef:Object={
			00 : {'PLEN':1.0000, 'PDFE' :0.0000},
			05 : {'PLEN':0.9986, 'PDFE' :0.0620},
			10 : {'PLEN':0.9954, 'PDFE' :0.1240},
			15 : {'PLEN':0.9900, 'PDFE' :0.1860},
			20 : {'PLEN':0.9822, 'PDFE' :0.2480},
			25 : {'PLEN':0.9730, 'PDFE' :0.3100},
			30 : {'PLEN':0.9600, 'PDFE' :0.3720},
			35 : {'PLEN':0.9427, 'PDFE' :0.4340},
			40 : {'PLEN':0.9216, 'PDFE' :0.4958},
			45 : {'PLEN':0.8962, 'PDFE' :0.5571},
			50 : {'PLEN':0.8679, 'PDFE' :0.6176},
			55 : {'PLEN':0.8350, 'PDFE' :0.6769},
			60 : {'PLEN':0.7986, 'PDFE' :0.7346},
			65 : {'PLEN':0.7597, 'PDFE' :0.7903},
			70 : {'PLEN':0.7186, 'PDFE' :0.8435},
			75 : {'PLEN':0.6732, 'PDFE' :0.8936},
			80 : {'PLEN':0.6213, 'PDFE' :0.9394},
			85 : {'PLEN':0.5722, 'PDFE' :0.9761},
			90 : {'PLEN':0.5322, 'PDFE' :1.0000}
		};
		private var lowLat:int;
		private var highLat:int;
		private var ratio:Number;

		public function RobinsonTransformation(long:Number,lat:Number)
		{
			super();
			this.long=long*180/Math.PI;
			this.lat=lat*180/Math.PI;

			this.xscaler=0.1278;
			this.scalefactor=1530;
			this.xoffset=0.246;
			this.yoffset=0.122;
			lowLat = roundDownToFive(this.lat);
			highLat = roundUpToFive(this.lat);
			ratio = calcRatio(this.lat-lowLat, Math.abs(highLat-lowLat));
			trace ("lat: " + this.lat);
			trace ("lowLat: " + lowLat);
			trace ("highLat: " + highLat);
			trace ("ratio: " + ratio);
		}

		private function roundUpToFive(inVal:Number):int{
			var fiver:Number = inVal / 5;
			return 5*Math.ceil(fiver);
		}

		private function roundDownToFive(inVal:Number):int{
			var fiver:Number = inVal / 5;
			return 5*Math.floor(fiver);
		}

		private function calcRatio(numerator:Number, denominator:Number):Number{
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
			
			var lowX:Number = arrProjDef[Math.abs(this.lowLat)].PLEN*this.long/4/180;//Math.PI;
			var highX:Number = arrProjDef[Math.abs(this.highLat)].PLEN*this.long/4/180;//Math.PI;
			
			xCentered = lowX+ratio*(highX-lowX);

			trace ("xCentered: " + xCentered);
			trace ("lowX: " + lowX);
			trace ("highX: " + highX);
//			xCentered = interpolate(ratio, this.lowX, this.highX);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			var sign:int = sign(this.lat)
			trace ("sign: " + sign);
			var lowY:Number = arrProjDef[Math.abs(this.lowLat)].PDFE*sign*this.xscaler;
			var highY:Number = arrProjDef[Math.abs(this.highLat)].PDFE*sign*this.xscaler;

			yCentered = lowY+ratio*(highY-lowY);
			
			trace ("yCentered: " + yCentered);
			trace ("lowY: " + lowY);
			trace ("highY: " + highY);
//			yCentered = interpolate(ratio, this.lowY, this.highY);
			return translateY(yCentered);
		}

	}
}