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
 
package birdeye.vis.data
{
	/** This util class allows to easily generate an SVG text that includes one or more chart, each with its
	 * own x,y svg positions.*/
	public class UtilSVG
	{
		/**
		 * Method to create an SVG string containing the whole svg pattern, that may include several charts.
		 * The svgs array contains the list of svg data for each chart to be included in the whole svg string
		 * and can be composed by either Objects or Strings. 
		 * If they are objects, than they must have the following fields in order to work properly: 
		 * <p> data (representing svg data for the specidied chart);</p> 
		 * <p> x (to identify the x position for the specified chart);</p> 
		 * <p> y (to identify the y position for the specified chart).</p>
		 * <p> The width and height paramenter passed to createSVG, represent the whole size of the svg result.</p>*/ 
		public static function createSVG(svgs:Array, width:Number = 1000, height:Number = 1000):String
		{
			var header:String = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" ' + 
					' version="1.1" width="' + width + '" height="' + height + '">\n';
			var end:String = '</svg>\n';
			var body:String = "";
			for each (var svg:Object in svgs)
			{
				if (svg)
				{
					var bodySVGHeader:String = "";
					if (svg is String)
					{
						bodySVGHeader = '\n<svg>';
						body += bodySVGHeader + svg + "</svg>\n";
					} else if (svg is Object) {
						bodySVGHeader = '\n<svg x="' + svg.x + '" y="' + svg.y + '">';
						body += bodySVGHeader + svg.data + "</svg>\n";
					}
				}
			}
			
			return header + body + end;
		}
	}
}