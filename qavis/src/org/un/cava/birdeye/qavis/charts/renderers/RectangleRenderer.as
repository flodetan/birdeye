package org.un.cava.birdeye.qavis.charts.renderers
{
	import com.degrafa.geometry.RegularRectangle;

	public class RectangleRenderer extends RegularRectangle
	{
		public function RectangleRenderer(bounds:RegularRectangle)
		{
			super(bounds.x, bounds.y, bounds.width, bounds.height);
		}
	}
}