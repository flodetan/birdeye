package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.InteractivityManager;
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interactivity.geometry.InteractiveArcPath;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	public class BaseToolTipManager
	{
		private var _im:IInteractivityManager;
		
		protected var _stage:UIComponent;
		
		protected var _coords:ICoordinates;
		
		private var toolTipLabel:Label;
		
		public function BaseToolTipManager(coords:ICoordinates)
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
				onTooltipLayerPlaced();
				
			}
			else
			{
				_coords.addEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			}
			
			_im.addEventListener(InteractivityEvent.GEOMETRY_REGISTERED, onGeometryRegister);
			_im.addEventListener(InteractivityEvent.GEOMETRY_UNREGISTERED, onGeometryUnregister);
			_im.addEventListener(InteractivityEvent.GEOMETRY_MOUSE_CLICK, onMouseClick);
			_im.addEventListener(InteractivityEvent.GEOMETRY_MOUSE_OVER, onMouseOver);
			_im.addEventListener(InteractivityEvent.GEOMETRY_MOUSE_OUT, onMouseOut);
		}
		
		protected function onTooltipLayerPlaced(ev:Event=null):void
		{
			_stage = _coords.tooltipLayer;			
			_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
		}
		
		public function release():void
		{
			if (_im)
			{
				_im.removeEventListener(InteractivityEvent.GEOMETRY_REGISTERED, onGeometryRegister);
				_im.removeEventListener(InteractivityEvent.GEOMETRY_UNREGISTERED, onGeometryUnregister);
				_im.removeEventListener(InteractivityEvent.GEOMETRY_MOUSE_CLICK, onMouseClick);
				_im.removeEventListener(InteractivityEvent.GEOMETRY_MOUSE_OVER, onMouseOver);
				_im.removeEventListener(InteractivityEvent.GEOMETRY_MOUSE_OUT, onMouseOut);
			}
			
			if (_coords)
			{
				_coords.removeEventListener("tooltipLayerPlaced", onTooltipLayerPlaced);
			}
			
			for each (var lbl:DisplayObject in _labels)
			{
				if (_coords.tooltipLayer.contains(lbl))
				{
					_coords.tooltipLayer.removeChild(lbl);
				}
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
		
		protected var _labelFunction:Function;
		
		public function set labelFunction(f:Function):void
		{
			_labelFunction = f;
		}
		
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		protected function createLabel(o:Object, dim:Object):String
		{
			if (_labelFunction)
			{
				return _labelFunction.call(null, o, dim);
			}
			
			return String(o[dim]);
		}
		
		protected function onMouseOver(event:InteractivityEvent):void
		{
			
		}
		
		protected function onMouseOut(event:InteractivityEvent):void
		{

		}
		
		protected function onMouseClick(event:InteractivityEvent):void
		{
			
		}
		
		protected function onGeometryRegister(event:InteractivityEvent):void
		{
			
		}
		
		protected function onGeometryUnregister(event:InteractivityEvent):void
		{
			
		}
		
		protected function changeLabels(geoms:Vector.<IInteractiveGeometry>, visible:Boolean):void
		{
			for each (var geom:IInteractiveGeometry in geoms)
			{
				if (geom == null) continue;
				
				var lbl:Tooltip = _labels[geom];
				
				if (!visible && lbl)
				{
					lbl.visible = false;
				}
				else
				{
					
					if (!lbl && visible)
					{
						lbl = new Tooltip();
						lbl.mouseEnabled = false;
						lbl.mouseChildren = false;
						_labels[geom] = lbl;
						
						_stage.addChild(lbl);
					}
					
					
					
					
					lbl.text = createLabel(geom.data, geom.element[_labelDimension]);
					if (lbl.text != null && lbl.text != "null")
					{
						lbl.x = geom.preferredTooltipPoint.x - 25; // center tooltip
						lbl.y = geom.preferredTooltipPoint.y - 8;
						lbl.visible = true;
					}
				}
			}
		}
		
		protected function changeAllLabels(visible:Boolean):void
		{
			for each (var t:Tooltip in _labels)
			{
				if (t.visible)
				{
					t.visible = false;
				}
			}
		}
	}
}