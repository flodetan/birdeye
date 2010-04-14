package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	public class ElementToolTipManager extends DefaultToolTipManager
	{
		public function ElementToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		override protected function onMouseOver(event:InteractivityEvent):void
		{
			var geoms:Vector.<IInteractiveGeometry> = _coords.interactivityManager.getGeometriesForSpecificElement(event.geometry.element);
			
			for each (var geom:IInteractiveGeometry in geoms)
			{
				var lbl:Tooltip = _labels[geom];
				
				if (!lbl)
				{
					lbl = new Tooltip();
					lbl.mouseEnabled = false;
					lbl.mouseChildren = false;
					_labels[geom] = lbl;
					
					_stage.addChild(lbl);
				}
								
				lbl.text = labelFunction(geom.data[geom.element.dim2]);
				lbl.x = geom.preferredTooltipPoint.x - 25; // center tooltip
				lbl.y = geom.preferredTooltipPoint.y - 8;
				lbl.visible = true;
			}
		}
		
		override protected function onMouseOut(event:InteractivityEvent):void
		{			
			var geoms:Vector.<IInteractiveGeometry> = _coords.interactivityManager.getGeometriesForSpecificElement(event.geometry.element);
			
			for each (var geom:IInteractiveGeometry in geoms)
			{

				var lbl:Tooltip = _labels[geom];
			
				if (lbl && lbl.visible)
				{
					lbl.visible = false;
				}
			}	
			//			trace("Mouse out of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
		}
		
		
	}
}