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
 
package birdeye.vis.scales
{
	import flash.geom.Point;
	
	public class PolarCoordinateTransform
	{
		public function PolarCoordinateTransform()
		{
		}
		
		/** Return the x,y point corresponding to a polar coordinate point.*/
		public static function getXY(angle:Number /* degrees */, radius:Number, origin:Point = null):Point
		{
			var x1:Number, y1:Number;
			
			x1 = Math.sin(angle * Math.PI / 180) * radius;
			y1 = -Math.cos(angle * Math.PI / 180) * radius;

			if (origin)
			{
				x1 += origin.x;
				y1 += origin.y;
			}

			return new Point(x1,y1);
		}

		/** Return the x value of a polar coordinate point.*/
		public static function getX(angle:Number /* degrees */, radius:Number, origin:Point = null):Number
		{
			var x1:Number;
			
			x1 = Math.sin(angle * Math.PI / 180) * radius;

			if (origin)
				x1 += origin.x;

			return x1;
		}

		/** Return the y value of a polar coordinate point.*/
		public static function getY(angle:Number /* degrees */, radius:Number, origin:Point = null):Number
		{
			var y1:Number;
			
			y1 = -Math.cos(angle * Math.PI / 180) * radius;

			if (origin)
				y1 += origin.y;

			return y1;
		}

		/** Return the x,y point corresponding to a polar label coordinate point.*/
		public static function getLabelXY(labelWidth:Number, labelHeight:Number, angle:Number):Point {
			
			var x:Number, y:Number;
			
			if( angle < 90 ) {
				x = 0;
				y = 0;//labelHeight;
			} else if( angle >= 90 && angle < 180 ) {
				x = labelWidth;
				y = 0;//labelHeight;
			} else if( angle >= 180 && angle < 270 ) {
				x = labelWidth;
				y = 0;//-labelHeight;
			} else {
				x = 0;
				y = 0;//-labelHeight;
			} 
			
			return new Point(x, y);
		}
	}
}