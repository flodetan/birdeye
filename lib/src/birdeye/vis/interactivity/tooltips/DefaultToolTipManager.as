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

			if (_coords.tooltipLayer)
			{
				_stage = _coords.tooltipLayer;

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
			_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
		}
		
		protected var _labels:Object = new Object();
		
		
		private function onMouseOver(event:InteractivityEvent):void
		{
			var lbl:Label = _labels[event.geometry];
			
			if (!lbl)
			{
				lbl = new Label();
				lbl.width = 50;
				lbl.height = 150;
				lbl.mouseEnabled = false;
				_labels[event.geometry] = lbl;
				
				_stage.addChild(lbl);
			}
			
			
//			trace("Mouse over of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
			lbl.text = event.geometry.data[event.geometry.element.dim1] + " " + event.geometry.data[event.geometry.element.dim2]
			lbl.x = event.geometry.preferredTooltipPoint.x;
			lbl.y = event.geometry.preferredTooltipPoint.y;
			lbl.visible = true;
		}
		
		private function onMouseOut(event:InteractivityEvent):void
		{
			var lbl:Label = _labels[event.geometry];
			
			if (lbl && lbl.visible)
			{
				lbl.visible = false;
			}
	
//			trace("Mouse out of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
		}
	}
}