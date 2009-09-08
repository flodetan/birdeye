package birdeye.vis.interfaces
{
	import flash.geom.Rectangle;
	
	/**
	 * This interface defines the necessary setter </br>
	 * for a renderer that is bounded by a rectangle.
	 */
	public interface IBoundedRenderer
	{	
		function set bounds(bounds:Rectangle):void;
		function get data():Object;
	}
}