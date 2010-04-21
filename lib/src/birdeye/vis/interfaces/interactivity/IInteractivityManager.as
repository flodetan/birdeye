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
		 * Unregister all geometries.
		 */
		function unregisterAll():void;
		
		
		/**
		 * Unregister a given geometry.
		 */
		function unregisterGeometry(geom:IInteractiveGeometry):void;
		
		/**
		 * Register the coordinates where the elements are drawn.
		 */
		function registerCoordinates(coords:ICoordinates):void;
		
		/**
		 * Unregister the coordinates where the elements are drawn.
		 */
		function unregisterCoordinates():void;
		
		/**
		 * Get the interactive geometries for a specific dimension
		 */
		function getGeometriesForSpecificDimensions(dims:Array, dimValues:Array):Vector.<IInteractiveGeometry>;


		/**
		 * Get the interactive geometries for a specific element dimension
		 */
		function getGeometriesForSpecificElementDimensions(dims:Array, dimValues:Array):Vector.<IInteractiveGeometry>;
		
		/**
		 * Get the interactive geometries for a specific element.
		 */
		function getGeometriesForSpecificElement(el:IElement):Vector.<IInteractiveGeometry>;

	}
}