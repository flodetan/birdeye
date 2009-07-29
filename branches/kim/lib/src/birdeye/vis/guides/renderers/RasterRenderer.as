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
	import birdeye.vis.interfaces.IRasterRenderer;
	
	import com.degrafa.geometry.RasterImage;
	
	import flash.geom.Rectangle;
	
	public class RasterRenderer extends RasterImage implements IRasterRenderer, IBoundedRenderer
	{
		private var _s:Object;
		public function get source():Object
		{
			return _s;
		}
		
		public function RasterRenderer(bounds:Rectangle=null, _source:Object = null)
		{
			super();
			
			if (bounds) this.bounds = bounds;
			
			if (_source)
				source = _source;
		}
		
		public function set bounds(bounds:Rectangle):void
		{
			width = bounds.width;
			height = bounds.height;
			x = bounds.x;
			y = bounds.y;
		}
	}
}