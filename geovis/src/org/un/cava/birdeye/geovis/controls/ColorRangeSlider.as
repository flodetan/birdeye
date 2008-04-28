package org.un.cava.birdeye.geovis.controls
{
	import mx.controls.sliderClasses.Slider;
	import mx.controls.sliderClasses.SliderThumb;
	
	public class ColorRangeSlider extends Slider
	{
		public var min:Number = -1;
    	public var max:Number = 101;
		
		public function ColorRangeSlider()
		{
			// Control to specify parameters for value based colorization of features.
			super();
      		// invertThumbDirection = true;
      		this.allowThumbOverlap = true;
      		this.direction = "horizontal";
			
			
		}

	}
}