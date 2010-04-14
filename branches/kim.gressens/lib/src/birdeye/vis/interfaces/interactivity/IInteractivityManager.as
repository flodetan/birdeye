package birdeye.vis.interfaces.interactivity
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.elements.IElement;
	
	import flash.events.IEventDispatcher;

	public interface IInteractivityManager extends IEventDispatcher
	{
		
		/**
		 * Get all interactive geometries.
		 */
		function allGeometries():Vector.<IInteractiveGeometry>;
		
		/**
		 * Register an interactive geometry.
		 */
		function registerGeometry(geom:IInteractiveGeometry):void;
		
		
		/**
		 * Unregister a given geometry.
		 */
		function unregisterGeometry(geom:IInteractiveGeometry):void;
		
		/**
		 * Register the coordinates where the elements are drawn.
		 */
		function registerCoordinates(coords:ICoordinates):void;
		
		/**
		 * Get the interactive geometries for a specific dimension
		 */
		function getGeometriesForSpecificDimension(dim:Object, dimValue:Object):Vector.<IInteractiveGeometry>;

		/**
		 * Get the interactive geometries for a specific element.
		 */
		function getGeometriesForSpecificElement(el:IElement):Vector.<IInteractiveGeometry>;

	}
}