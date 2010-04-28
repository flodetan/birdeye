package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	public class AllToolTipManager extends FilterableToolTipManager
	{
		public function AllToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		override protected function onGeometryUnregister(event:InteractivityEvent):void
		{
			var index:int = geoms.indexOf(event.geometry);
			
			if (index > -1)
			{
				geoms.splice(index, 1);
			}
			
			placeSelectedTooltips();
		}
		
		override protected function filter(geom:IInteractiveGeometry):void
		{
			geoms.push(geom);
		}
	}
}