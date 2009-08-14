package birdeye.util
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