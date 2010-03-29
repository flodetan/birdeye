package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	
	import flash.events.Event;
	
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class DefaultToolTipManager
	{
		private var _im:IInteractivityManager;
		
		private var _stage:UIComponent;
		
		private var _coords:ICoordinates;
		
		private var toolTipLabel:Label;
		
		public function DefaultToolTipManager(coords:ICoordinates)
		{
			if (!coords) 
			{
				throw new Error("DefaultTooTipManager can not work without an interactivity manager or stager.");
			}
			
			_coords = coords;
			
			_im = coords.interactivityManager;

			toolTipLabel = new Label();

			if (_coords.tooltipLayer)
			{
				_stage = _coords.tooltipLayer;
				
				_stage.addChild(toolTipLabel);

			}
			else
			{
				_coords.addEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			}
			
			
			_im.addEventListener(InteractivityEvent.GEOMETRY_MOUSE_OVER, onMouseOver);
			_im.addEventListener(InteractivityEvent.GEOMETRY_MOUSE_OUT, onMouseOut);
		}
		
		private function onTooltipLayerPlaced(ev:Event):void
		{
			_stage = _coords.tooltipLayer;
			_stage.addChild(toolTipLabel);
			
			_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
		}
		
		
		private function onMouseOver(event:InteractivityEvent):void
		{
			toolTipLabel.text = event.geometry.data[event.geometry.element.dim1] + " " + event.geometry.data[event.geometry.element.dim2]
			toolTipLabel.x = event.geometry.preferredTooltipPoint.x;
			toolTipLabel.y = event.geometry.preferredTooltipPoint.y;
		}
		
		private function onMouseOut(event:InteractivityEvent):void
		{
			trace("Mouse out of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
		}
	}
}