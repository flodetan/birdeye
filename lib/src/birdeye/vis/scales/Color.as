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
 
 package birdeye.vis.scales
{
	import birdeye.vis.elements.util.ColorUtil;
	
	import com.degrafa.paint.palette.PaletteUtils;
	
	[Exclude(name="scaleType", kind="property")]
	public class Color extends Linear
	{
		public static const INTERPOLATION_DEFAULT:String = "default";
		public static const INTERPOLATION_HUE:String = "hue";
		public static const INTERPOLAION_BRIGHTNESS:String = "brightness";
		public static const INTERPOLATION_SATURATION:String = "saturation";
		public static const INTERPOLATION_HSB:String = "hsb";
		
		private var generatedNumColors:uint = 48;
		
		private var colorPalette:Array = new Array();
		
		public function Color():void
		{
			scaleValues = [0x000000,0xffffff];

		}
		
		private var _scaleValuesChanged:Boolean = false;
		override public function set scaleValues(val:Array):void
		{
			super.scaleValues = val;
			
			_scaleValuesChanged = true;
			invalidate();

		}
		
		override public function commit():void
		{
			super.commit();
			
			if (_interPolationMethodChanged || _scaleValuesChanged)
			{
				_interPolationMethodChanged = false;
				_scaleValuesChanged = false;
				
							
				if (_interPolationMethod == INTERPOLATION_DEFAULT)
				{
					colorPalette = PaletteUtils.getInterpolatedPalette(generatedNumColors, _scaleValues[0], _scaleValues[1]);
				}
				else if (_interPolationMethod == INTERPOLATION_HUE)
				{				
					var hsb:Object = convertRGBuintToHSB(_scaleValues[0]);
					var hsb2:Object = convertRGBuintToHSB(_scaleValues[1]);
					
					colorPalette = ColorUtil.interpolateHSB(generatedNumColors, hsb.h, hsb.s, hsb.b, hsb2.h, hsb.s, hsb.b);
				}
				else if (_interPolationMethod == INTERPOLATION_SATURATION)
				{
					hsb = convertRGBuintToHSB(_scaleValues[0]);
					hsb2 = convertRGBuintToHSB(_scaleValues[1]);
					
					colorPalette = ColorUtil.interpolateHSB(generatedNumColors, hsb.h, hsb.s, hsb.b, hsb.h, hsb2.s, hsb.b);			
				}
				else if (_interPolationMethod == INTERPOLAION_BRIGHTNESS)
				{
					hsb = convertRGBuintToHSB(_scaleValues[0]);
					hsb2 = convertRGBuintToHSB(_scaleValues[1]);
					
					colorPalette = ColorUtil.interpolateHSB(generatedNumColors, hsb.h, hsb.s, hsb.b, hsb.h, hsb.s, hsb2.b);			
					
				}
				else if (_interPolationMethod == INTERPOLATION_HSB)
				{
					hsb = convertRGBuintToHSB(_scaleValues[0]);
					hsb2 = convertRGBuintToHSB(_scaleValues[1]);
					
					colorPalette = ColorUtil.interpolateHSB(generatedNumColors, hsb.h, hsb.s, hsb.b, hsb2.h, hsb2.s, hsb2.b);			
					
				}
			}
			
		}
		
		private function convertRGBuintToHSB(rgb:uint):Object
		{
			var red:uint = rgb>>16&0xFF;
			var green:uint = rgb>>8&0xFF;
			var blue:uint = rgb>>0&0xFF;
				
			return PaletteUtils.RGBtoHSB(red, green, blue);		
		}
		
		// other methods

		/** @Private
		 * Override the XYZAxis getPostion method based on the linear scaling.*/
		override public function getPosition(dataValue:*):*
		{
			_size = Math.abs(_scaleValues[1]-_scaleValues[0]);
			
			var color:Number = NaN;
			if (! (isNaN(max) || isNaN(min)))
			{
				
				var index:Number = Math.floor((Number(dataValue) - min) * generatedNumColors / max);
				
				return colorPalette[index];
			}
			return null;
		}
		
		private var _interPolationMethod:String = "default";
		private var _interPolationMethodChanged:Boolean = false;
		/**
		 * Set the method that is used to interpolate betweeen the two colors that are set</br>
		 * by scaleValues.</br>
		 * <code>default</code> mixes red,green,blue and alpha in a linear way</br>
		 * <code>brightness</code> changes the brightness of the colors. Brightness can be used to represent categorical dimension, but only with a few categories. <b>The hue and saturation of the FIRST color are used as base values</b></br>
		 * <code>hue</code> changes the hue of the colors. Hue is especially suited for categorical scales. <b>The brightness and saturation of the FIRST color are used as base values</b></br>
		 * <code>saturation</code> changes the saturation of the colors. Saturation is recommended for respresenting uncertainty in a grahpic. <b>The brightness and hue of the FIRST color are used as base values</b></br>
		 * <code>hsb</code> linearly interpolates between the hsb value of the given colors.</br>
		 */
		[Inspectable(enumeration="default,brightness,hue,saturation, hsb")]
		public function set interpolationMethod(val:String):void
		{
			_interPolationMethod = val;	
			_interPolationMethodChanged = true;
			
			invalidate();
		}
		
		public function get interpolationMethod():String
		{
			return _interPolationMethod;
		}
	}
}