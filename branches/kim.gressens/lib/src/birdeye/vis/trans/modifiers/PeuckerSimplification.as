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

	/** This class applies the Ramer-Douglas-Peucker simplification algorithm to the polygons of a country. 
	 */
	public class PeuckerSimplification extends Simplification
	{

		public override function simplifyPolygon(polygon:Vector.<Pair>, epsilon:Number):Vector.<Pair>
		{
			if (polygon.length == 0) { //Safeguard against infinite recursion
				return polygon;
			}
			
			var dmax:Number = 0
			var cutIndex:int = 0
			var d:Number;
			var recResults1:Vector.<Pair>;
			var recResults2:Vector.<Pair>;
			var maxDist:Number = Math.pow(10,(100-epsilon)/10-8); //Normalize epsilon, so that it ranges from 0(no simplification) to 100 (max simplification)
			//Find the point with maximum distance
			for (var i:int=1; i<polygon.length-2; i++) { 
 				d = orthogonalDistance(polygon, i);
				if (d > dmax) {
					cutIndex = i
					dmax = d
				}
			}

 			if (dmax >= maxDist) {
				//Recursive call
				recResults1 = simplifyPolygon(polygon.slice(0,cutIndex),epsilon); //copy the simplified 1st part of polygon into a new array recResults1
				recResults2 = simplifyPolygon(polygon.slice(cutIndex,polygon.length-1),epsilon); //copy the simplified 2nd part of polygon into a new array recResults2 				

				// Build the result list
				return recResults1.concat(recResults2);
			} else {
				return polygon;
			}
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