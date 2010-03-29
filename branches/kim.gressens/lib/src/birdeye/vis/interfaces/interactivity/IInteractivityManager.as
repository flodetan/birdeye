package birdeye.vis.interfaces.interactivity
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	
	import flash.events.IEventDispatcher;

	public interface IInteractivityManager extends IEventDispatcher
	{
		
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
		
	}
}