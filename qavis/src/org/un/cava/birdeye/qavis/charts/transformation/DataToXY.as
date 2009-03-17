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
 
package org.un.cava.birdeye.qavis.charts.transformation
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYAxis;
	
	public class DataToXY
	{
		private var xAxis:XYAxis, yAxis:XYAxis;

		private var _bounds:Rectangle;
		public function set bounds(val:Rectangle):void
		{
			_bounds = val;
			validateElements();
		}
		
		public function DataToXY(xAxis:XYAxis, yAxis:XYAxis, bounds:Rectangle = null)
		{
			if (bounds) 
				this.bounds = bounds;
			this.xAxis = xAxis;
			this.yAxis = yAxis;
		}
		
		public function getXY(horizontalValue:Object, verticalValue:Object):Point
		{
			var p:Point = new Point();
			return p;
		}
		
		public function getData(xPos:Number, yPos:Number):Object
		{
			return new Object();
		}
		
		private function validateElements():void
		{
			
		}
	}
}