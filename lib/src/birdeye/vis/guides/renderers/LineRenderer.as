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
	
	import com.degrafa.geometry.Line;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class LineRenderer extends Line implements IBoundedRenderer, IEdgeRenderer
	{
		public function LineRenderer(bounds:Rectangle=null)
		{
			super();
			if (bounds) this.bounds = bounds;
		}
		
		public function set bounds(bounds:Rectangle):void
		{
			this.x = bounds.x;
			this.y = bounds.y;
			this.x1 = bounds.width;
			this.y1 = bounds.height;	
		}

		public function set startX(value:Number):void {
			x = value;
		}

		public function get startX():Number {
			return x;
		}
		
		public function set endX(value:Number):void {
			x1 = value;
		}

		public function get endX():Number {
			return x1;
		}

		public function set startY(value:Number):void {
			y = value;
		}

		public function get startY():Number {
			return y;
		}
		
		public function set endY(value:Number):void {
			y1 = value;
		}

		public function get endY():Number {
			return y1;
		}

	}
}