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
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	
	import com.degrafa.geometry.Circle;
	
	import flash.geom.Rectangle;

	public class CircleRenderer extends Circle implements IBoundedRenderer
	{
		public function CircleRenderer(bounds:Rectangle=null)
		{
			super();
			
			if (bounds)	this.bounds = bounds;
		}
	
		public function set bounds(bounds:Rectangle):void
		{
			var xCenter:Number = bounds.x + bounds.width/2
			var yCenter:Number = bounds.y + bounds.height/2;
			var radius:Number = (bounds.width + bounds.height)/4;  
	
			this.centerX = xCenter;
			this.centerY = yCenter;
			this.radius = radius;
		}
		
		public function get svgData():String
		{
			return '<circle cx="' + String(centerX + bounds.width/2) + 
						'" cy="' + String(centerY + bounds.height/2) + 
						'" r="' + radius + '"/>';
		}
	}
}