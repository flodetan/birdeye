package org.un.cava.birdeye.qavis.charts.renderers
{
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.RegularRectangle;

	public class CircleRenderer extends Circle
	{
		public function CircleRenderer(bounds:RegularRectangle)
		{
			var xCenter:Number = bounds.x + bounds.width/2
			var yCenter:Number = bounds.y + bounds.height/2;
			var radius:Number = (bounds.width + bounds.height)/4;  
			super(xCenter, yCenter, radius);
		}
	}
}