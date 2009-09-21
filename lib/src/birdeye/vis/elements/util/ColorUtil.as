/* 
 * The MIT License
 *
 * Copyright (c) 2007 The SixDegrees Project Team
 * (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
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

package birdeye.vis.elements.util
{
	import com.degrafa.paint.palette.PaletteUtils;
	
	public class ColorUtil
	{
   
        /**
        * Util function that start at a given hue,sat and brightness and linearly interpolates to the endHue, endSaturation and endBrightness in numColors steps.
        */
        public static function interpolateHSB(numColors:int, initialHue:Number, initialSaturation:Number, initialBrightness:Number, endHue:Number, endSaturation:Number, endBrightness:Number):Array
        {
            var colors:Array = new Array(numColors);
            
            var diffHue:Number = endHue - initialHue;
            var diffSat:Number = endSaturation - initialSaturation;
            var diffBrightness:Number = endBrightness - initialBrightness;
			
			var hueOffset:Number = diffHue != 0 ? diffHue / numColors : 0;
			var satOffset:Number = diffSat != 0 ? diffSat / numColors : 0;
			var brightnessOffset:Number = diffBrightness != 0 ? diffBrightness / numColors : 0;
			
			var currentHue:Number = initialHue;
			var currentSaturation:Number = initialSaturation;
			var currentBrightness:Number = initialBrightness;
			
			for (var i:int = 0; i< numColors;i++)
			{
				colors[i] = PaletteUtils.HSBtoRGB(currentHue, currentSaturation, currentBrightness);
				
				currentHue += hueOffset;
				currentSaturation += satOffset;
				currentBrightness += brightnessOffset;
				
				if (hueOffset > 0 && currentHue > endHue) currentHue = endHue;
				if (hueOffset < 0 && currentHue < endHue) currentHue = endHue;
				if (satOffset > 0 && currentSaturation > endSaturation) currentSaturation = endSaturation;
				if (satOffset < 0 && currentSaturation < endSaturation) currentSaturation = endSaturation;
				if (brightnessOffset > 0 && currentBrightness > endBrightness) currentBrightness = endBrightness;
				if (brightnessOffset < 0 && currentBrightness < endBrightness) currentBrightness = endBrightness;

			}
			
			return colors;
	
        }
	}
}