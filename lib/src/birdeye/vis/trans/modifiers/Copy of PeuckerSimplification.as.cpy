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
	import birdeye.vis.data.PairPlus;

	/** This class applies the Ramer-Douglas-Peucker simplification algorithm to the polygons of a country. 
	 */
	public class PeuckerSimplification extends Simplification
	{

		public override function simplifyPolygon(polygon:Vector.<Pair>, epsilon:Number):Vector.<PairPlus>
		{
			return new Vector.<PairPlus>();
		}
		
		private function orthogonalDistance(polygon:Vector.<Pair>,i:int):Number {
			var p:Pair = polygon[i]; //cutIndex coordinate
			var p1:Pair = polygon[0]; //startIndex coordinate
			var p2:Pair = polygon[polygon.length-1]; //endIndex coordinate
			//The purpose is to find the distance between p
			//and the line connecting p1 with p2
			
			if (p1.dim1==p2.dim1 && p1.dim2==p2.dim2) { //If start and end in the same point, return the distance to the cutIndex point
				return Math.sqrt(Math.pow(p1.dim1-p.dim1,2)+Math.pow(p1.dim2-p.dim2,2));
			} else { //If start and end are different points, the three points form a triangle
			
				//Area = (1/2)(|x1y2 + x2y3 + x3y1 - x2y1 - x3y2 - x1y3|)	*Area of triangle
				//Base = sqrt((x1-x2)²+(y1-y2)²)							*Base of triangle
				//Area = Base*Height/2										*Solve for height
				//Height = Area/Base*2

				var area:Number = Math.abs(.5 * (p1.dim1*p2.dim2 + p2.dim1*p.dim2 + p.dim1*p1.dim2 - 
				p2.dim1*p1.dim2 - p.dim1*p2.dim2 - p1.dim1*p.dim2));
				var bottom:Number = Math.sqrt(Math.pow(p1.dim1-p2.dim1, 2) + 
				Math.pow(p1.dim2-p2.dim2, 2));
				var height:Number = area / bottom * 2;
				
				return height;
			}
		}

	}
}