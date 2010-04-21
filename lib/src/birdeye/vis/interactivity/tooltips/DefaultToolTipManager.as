package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.InteractivityManager;
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	
	import flash.events.Event;
	
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class DefaultToolTipManager
	{
		private var _im:IInteractivityManager;
		
		protected var _stage:UIComponent;
		
		protected var _coords:ICoordinates;
		
		private var toolTipLabel:Label;
		
		public function DefaultToolTipManager(coords:ICoordinates)
		{
			if (!coords) 
			{
				throw new Error("DefaultTooTipManager can not work without a coordinates system.");
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
		
		public function release():void
		{
			if (_im)
			{
				_im.removeEventListener(InteractivityEvent.GEOMETRY_MOUSE_OVER, onMouseOver);
				_im.removeEventListener(InteractivityEvent.GEOMETRY_MOUSE_OUT, onMouseOut);
			}
			
			if (_coords)
			{
				_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			}
		}
		
		protected var _labels:Object = new Object();
		
		protected var _labelDimension:Object = "dim2";
		
		public function set labelDimension(dim:Object):void
		{
			_labelDimension = dim;
		}
		
		public function get labelDimension():Object
		{
			return _labelDimension;
		}
		
		protected function labelFunction(o:Object, dim:Object):String
		{
			return String(o[dim]);
		}
		
		protected function onMouseOver(event:InteractivityEvent):void
		{
			var lbl:Tooltip = _labels[event.geometry];
			
			if (!lbl)
			{
				lbl = new Tooltip();
				lbl.mouseEnabled = false;
				lbl.mouseChildren = false;
				_labels[event.geometry] = lbl;
				
				_stage.addChild(lbl);
			}
			
			
//			trace("Mouse over of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
			lbl.text = labelFunction(event.geometry.data, event.geometry.element[_labelDimension]);
			lbl.x = event.geometry.preferredTooltipPoint.x - 25; // center tooltip
			lbl.y = event.geometry.preferredTooltipPoint.y - 8;
			lbl.visible = true;
		}
		
		protected function onMouseOut(event:InteractivityEvent):void
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