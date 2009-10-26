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
 
 package birdeye.vis.trans.modifiers
{
	import birdeye.vis.data.Pair;

	public class NoncontiguousCartogram extends Cartogram
	{
		public function NoncontiguousCartogram()
		{
			super();
		}
		
		public function resizeCountry(origPolygons:Array, baryCenter:Pair, sizeFactor:Number):Array { 
			var resizedPolygons:Array = new Array(origPolygons.length);
			if (sizeFactor > 1) {
				trace ("sizeFactor too big: " + sizeFactor);
			} else if (sizeFactor < 0 ) {
				trace ("sizeFactor negative: " + sizeFactor);				
			} else {
				for (var i:int=0; i<origPolygons.length; i++) //Loop over all polygons of the country
				{
					resizedPolygons[i] = resizePolygon(origPolygons[i], baryCenter, sizeFactor);
				} // end loop over polygons
			}
			return resizedPolygons;
		}
		
		private function resizePolygon(origPolygon:Vector.<Pair>, baryCenter:Pair, sizeFactor:Number):Vector.<Pair> {
			var baryX:Number=baryCenter.dim1;
			var baryY:Number=baryCenter.dim2;
			var origX:Number;
			var origY:Number;
			var resizedX:Number;
			var resizedY:Number;
			var resizedPair:Pair;
			var resizedPolygon:Vector.<Pair> = new Vector.<Pair>();
			
			for each (var origPair:Pair in origPolygon) {
				origX = origPair.dim1;
				origY = origPair.dim2;
				resizedX = baryX + sizeFactor*(origX-baryX);
				resizedY = baryY + sizeFactor*(origY-baryY);
				resizedPair = new Pair(resizedX,resizedY);
				resizedPolygon.push(resizedPair);
			}
			return resizedPolygon;
		} 
				
	}
}