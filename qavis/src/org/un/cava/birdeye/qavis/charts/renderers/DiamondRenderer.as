package org.un.cava.birdeye.qavis.charts.renderers
{
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RegularRectangle;

	public class DiamondRenderer extends Polygon
	{
		public function DiamondRenderer(bounds:RegularRectangle)
		{
			data =  String(bounds.x) + "," + String(bounds.y + bounds.height/2) + " " +
					String(bounds.x + bounds.width/2) + "," + String(bounds.y) + " " +
					String(bounds.x + bounds.width) + "," + String(bounds.y + bounds.height/2) + " " +
					String(bounds.x + bounds.width/2) + "," + String(bounds.y + bounds.height);
		}
	}
}