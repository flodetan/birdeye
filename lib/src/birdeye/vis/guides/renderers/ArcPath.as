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
 
package birdeye.vis.guides.renderers
{
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.geometry.Path;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/** Not to be used as the other renderers, this allows to shape an arc with an inner radius.
	 * Used in PieChart, CoxCombo and other PolarCharts.*/
	public class ArcPath extends Path  implements IBoundedRenderer
	{
		public function ArcPath(r:Number, R:Number, startAngle:Number, arcAngle:Number, center:Point)
		{
			var data:String;
			
			// 1st and 2nd points of the inner radius arc
			var rP1:Point = PolarCoordinateTransform.getXY(startAngle, r, center);
			var rP2:Point = PolarCoordinateTransform.getXY(startAngle + arcAngle, r, center);

			// 1st and 2nd points of the outer radius arc
			var RP1:Point = PolarCoordinateTransform.getXY(startAngle, R, center);
			var RP2:Point = PolarCoordinateTransform.getXY(startAngle + arcAngle, R, center);

			var arcFlag:String = "0";
			if (arcAngle >= 180)
			{
				arcFlag = "1"
			}
			
			// move to 1st inner point
			data = "M" + String(rP1.x) + " " + String(rP1.y) + " ";

			// arc to 2nd inner point with radius = r
			data+= "A" + String(r) + " " + String(r) + " 0 " + arcFlag + " 0 " + String(rP2.x) + " " + String(rP2.y);

			// line to 2nd outer point
			data+= "L" + String(RP2.x) + " " + String(RP2.y) + " ";

			// arc to 1st outer point with radius = R and close the path
			data+= "A" + String(R) + " " + String(R) + " 0 " + arcFlag + " 1 " + String(RP1.x) + " " + String(RP1.y) + " z";
			
			super(data);
		}
		
		public function set bounds(bounds:Rectangle):void
		{
		}
		
		public function get svgData():String
		{
			return '<path d="' + data + '"/>';
		}
		
	}
}