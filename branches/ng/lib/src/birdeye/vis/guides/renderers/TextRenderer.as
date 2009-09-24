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
	import birdeye.vis.interfaces.data.IExportableSVG;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	
	import flash.text.TextFieldAutoSize;

	public class TextRenderer extends RasterText implements IExportableSVG
	{
		private var svgTextY:Number;
		
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
			else
				this.fontFamily = "arial";

			if (fill)
				this.fill = fill;
			else
				this.fill = new SolidFill(0x000000);

			if (alpha)
				this.alpha = alpha;
			else
				this.alpha = 1;

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
			
			svgTextY = y + fontSize;
		}
		
		public function get svgData():String
		{
			return '<text style="font-family: ' + fontFamily + 
								'; font-size: ' + fontSize + 
								'; stroke-width: 1' + ';"' +
					' x="' + x + '" y="' + svgTextY + '">' +
					text + '</text>';
		}
	}
}