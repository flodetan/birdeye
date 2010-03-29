package birdeye.vis.interfaces.interactivity
{
	import birdeye.vis.interfaces.elements.IElement;
	
	import flash.geom.Point;

	public interface IInteractiveGeometry
	{
		/**
		 * Get the preferred point where the tooltip can be shown.
		 */
		function set preferredTooltipPoint(p:Point):void;
		function get preferredTooltipPoint():Point;
		
		/**
		 * Get the element that owns this geometry.
		 */
		function set element(el:IElement):void;
		function get element():IElement;
		
		/**
		 * Set/get the data for this geometry.
		 */
		function set data(d:Object):void;
		function get data():Object;
		
		/**
		 * Check if the given point is contained in this geometry.
		 * @return true if the given point is contained.
		 */
		function contains(p:Point):Boolean;

		
	}
}