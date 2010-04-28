package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	
	import flash.events.Event;
	
	import mx.controls.Label;

	public class FilterableToolTipManager extends BaseToolTipManager
	{
		public function FilterableToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		override protected function onTooltipLayerPlaced(ev:Event=null):void
		{
			super.onTooltipLayerPlaced(ev);
			placeTooltips();
		}
		
		override protected function onGeometryRegister(event:InteractivityEvent):void
		{
			filter(event.geometry);
			placeSelectedTooltips();
		}
		

		
		protected function placeTooltips():void
		{
			var geometries:Vector.<IInteractiveGeometry> = _coords.interactivityManager.allGeometries();
					
			for each (var geom:IInteractiveGeometry in geometries)
			{
				filter(geom);
			}
			
			placeSelectedTooltips();			
		}
		
		protected function filter(geom:IInteractiveGeometry):void
		{
			
		}
		
		protected var geoms:Vector.<IInteractiveGeometry> = new Vector.<IInteractiveGeometry>();
	
		protected function placeSelectedTooltips():void
		{
			changeAllLabels(false);
			
			if (geoms.length > 0)
			{
				changeLabels(geoms, true);
			}
		}
		
	}
}