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

	
	public class MillerTransformation extends Transformation
	{
				
		public function MillerTransformation()
		{
			super();
			this.xoffset=Math.PI;
			this.yoffset=2.303412543376390918432;
			this.worldUnscaledSizeX=Math.PI*2;
			this.worldUnscaledSizeY=4.606825086752782;
		}

		public override function calcX(latDeg:Number, longDeg:Number):Number
		{
			var longRad:Number=convertDegToRad(longDeg);
			var xCentered:Number;
			
			//x = long
			return longRad;			
		}

		public override function calcY(latDeg:Number, longDeg:Number):Number
		{
			var latRad:Number=convertDegToRad(latDeg);
			
			//y = 1.25 ln( tan(pi/4 + 0.4 lat) ) 
			return 1.25*Math.log( Math.tan(Math.PI/4 + 0.4*latRad) );
		}

	}
}