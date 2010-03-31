package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	import flash.events.Event;
	
	import mx.controls.Label;

	public class FilterableToolTipManager
	{
		private var _coords:ICoordinates;
		
		public function FilterableToolTipManager(coords:ICoordinates)
		{
			if (!coords || !coords.interactivityManager) 
			{
				throw new Error("DefaultTooTipManager can not work without an interactivity manager or stager.");
			}
			
			_coords = coords;
			
			_coords.interactivityManager.addEventListener(InteractivityEvent.GEOMETRY_REGISTERED, onGeometryRegister);
			_coords.interactivityManager.addEventListener(InteractivityEvent.GEOMETRY_UNREGISTERED, onGeometryUnregister);

			if (!_coords.tooltipLayer)
			{
				_coords.addEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			}
			else
			{
				placeTooltips();
			}
		}
		
		
		
		
		private function onTooltipLayerPlaced(ev:Event):void
		{		
			_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			placeTooltips();
		}
		
		private function onGeometryRegister(event:InteractivityEvent):void
		{
			filter(event.geometry);
			placeMinAndMaxTooltip();
		}
		
		private function onGeometryUnregister(event:InteractivityEvent):void
		{
			
		}

		private var min:Number = Number.MAX_VALUE;
		private var max:Number = Number.MIN_VALUE;
		private var minGeom:IInteractiveGeometry;
		private var maxGeom:IInteractiveGeometry;
		private var minLbl:Label;
		private var maxLbl:Label;
		
		protected function placeTooltips():void
		{
			var geometries:Vector.<IInteractiveGeometry> = _coords.interactivityManager.allGeometries();
			
			
			for each (var geom:IInteractiveGeometry in geometries)
			{
				filter(geom);
			}
			
			placeMinAndMaxTooltip();			
		}
		
		protected function filter(geom:IInteractiveGeometry):void
		{
			var nbr:Number = Number(geom.data[geom.element.dim2]);
			trace("Filtering ", nbr);
			
			if (nbr < min)
			{
				min = nbr;
				minGeom = geom;
			}
			
			if (nbr > max)
			{
				max = nbr;
				maxGeom = geom;
			}
			
		}
	
		protected function placeMinAndMaxTooltip():void
		{
			if (minGeom)
			{
				if (!minLbl)
				{
					minLbl = new Label();
					minLbl.width = 150;
					minLbl.height = 50;
					_coords.tooltipLayer.addChild(minLbl);
				}
				
				minLbl.x = minGeom.preferredTooltipPoint.x;
				minLbl.y = minGeom.preferredTooltipPoint.y;
				minLbl.text = minGeom.data[minGeom.element.dim1] + " " + minGeom.data[minGeom.element.dim2]
			}
			
			if (maxGeom)
			{
				if (!maxLbl)
				{
					maxLbl = new Label();
					maxLbl.width = 150;
					maxLbl.height = 50;
					_coords.tooltipLayer.addChild(maxLbl);
				}
				
				maxLbl.x = maxGeom.preferredTooltipPoint.x;
				maxLbl.y = maxGeom.preferredTooltipPoint.y;
				maxLbl.text = maxGeom.data[maxGeom.element.dim1] + " " + maxGeom.data[maxGeom.element.dim2]
			}

		}
		
	}
}