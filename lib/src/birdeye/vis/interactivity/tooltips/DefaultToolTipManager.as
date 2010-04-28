package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.InteractivityManager;
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	
	import flash.events.Event;
	
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class DefaultToolTipManager extends BaseToolTipManager
	{
		public function DefaultToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		override protected function onMouseOver(event:InteractivityEvent):void
		{
			var geoms:Vector.<IInteractiveGeometry> = new Vector.<IInteractiveGeometry>();
			geoms.push(event.geometry);
			
			changeLabels(geoms, true);
			
		}
		
		override protected function onMouseOut(event:InteractivityEvent):void
		{
			var lbl:Tooltip = _labels[event.geometry];
			
			if (lbl && lbl.visible)
			{
				lbl.visible = false;
			}
	
//			trace("Mouse out of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
		}
		

	}
}