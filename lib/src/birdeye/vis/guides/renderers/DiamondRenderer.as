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
	
	import com.degrafa.geometry.Path;
	
	import flash.geom.Rectangle;

	public class DiamondRenderer extends Path implements IBoundedRenderer
	{
		public function DiamondRenderer(bounds:Rectangle=null)
		{
			if (bounds) this.bounds = bounds;

		}
		
		public function set bounds(bounds:Rectangle):void
		{
			data =  "M" + String(bounds.x) + " " + String(bounds.y + bounds.height/2) + " " +
					"L" + String(bounds.x + bounds.width/2) + " " + String(bounds.y) + " " +
					"L" + String(bounds.x + bounds.width) + " " + String(bounds.y + bounds.height/2) + " " +
					"L" + String(bounds.x + bounds.width/2) + " " + String(bounds.y + bounds.height) + " z";
		}

		public function get svgData():String
		{
			return '<path d="' + data + '"/>';
		}
	}
}