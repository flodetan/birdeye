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
	import birdeye.vis.interfaces.IExportableSVG;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RasterText;
	
	import flash.text.TextFieldAutoSize;

	public class TextRenderer extends RasterText implements IExportableSVG
	{
		public function TextRenderer (xPos:Number = NaN, yPos:Number = NaN, text:String = null, fill:IGraphicsFill = null,
									 centerHorizontally:Boolean = false, centerVertically:Boolean = false,
									 fontSize:Number = 12, fontLabel:String = "tahoma") 
		{
			if (text)
				this.text = text;

			if (fontSize)
				this.fontSize = fontSize;

			if (fontFamily)
				this.fontFamily = fontLabel;

			if (fill)
				this.fill = fill;

			if (alpha)
				this.alpha = 1.0;

			this.autoSize = TextFieldAutoSize.LEFT;
			this.autoSizeField = true;
			if (centerHorizontally)
				x = xPos - (textWidth + 4)/2;
			else
				x = xPos;
			if (centerVertically)
				y = yPos - (fontSize + 4) /2;
			else
				y = yPos;
		}
		
		public function get svgData():String
		{
			return '<text x="' + bounds.width/2 + '" y="' + bounds.height + '">' +
					text + '</text>';
		}
	}
}