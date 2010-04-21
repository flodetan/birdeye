package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	import mx.controls.Label;
	
	public class ElementToolTipManager extends DefaultToolTipManager
	{
		public function ElementToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		// 3 possibilities to set way same labels are shown
		// 1 : the same element
		// 2 : the same dimension
		// 3 : multiple same dimensions
		
		
		public static const GROUP_ELEMENT:String = "groupElement";
		public static const GROUP_DIMENSION:String = "groupDimension";
		
		
		protected var _groupType:String = GROUP_ELEMENT;
		protected var _groupDimensions:Array;
		
		
		public function setGroupType(type:String, dimensions:Array=null):void
		{
			if (dimensions != _groupDimensions || type != _groupType)
			{
				_groupDimensions = dimensions;
				_groupType = type;
				hideLabels();
			}
				
		}
		
		protected function hideLabels():void
		{
			for each (var t:Tooltip in _labels)
			{
				if (t.visible)
				{
					t.visible = false;
				}
			}
		}
		
		override protected function onMouseOver(event:InteractivityEvent):void
		{
			var geoms:Vector.<IInteractiveGeometry>;
			
			if (_groupType == GROUP_ELEMENT)
			{
				geoms = _coords.interactivityManager.getGeometriesForSpecificElement(event.geometry.element);
			}
			else if (_groupType == GROUP_DIMENSION)
			{
				var values:Array = [];
				
				for each (var dim:Object in _groupDimensions)
				{
					values.push(event.geometry.data[event.geometry.element[dim]]);
				}
				
				geoms = _coords.interactivityManager.getGeometriesForSpecificElementDimensions(_groupDimensions, values);
				
			}
			
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
								
				lbl.text = labelFunction(geom.data, geom.element[_labelDimension]);
				if (lbl.text != null && lbl.text != "null")
				{
					lbl.x = geom.preferredTooltipPoint.x - 25; // center tooltip
					lbl.y = geom.preferredTooltipPoint.y - 8;
					lbl.visible = true;
				}
			}
		}
		
		override protected function onMouseOut(event:InteractivityEvent):void
		{	
			var geoms:Vector.<IInteractiveGeometry>;

			if (_groupType == GROUP_ELEMENT)
			{
				geoms = _coords.interactivityManager.getGeometriesForSpecificElement(event.geometry.element);
			}
			else if (_groupType == GROUP_DIMENSION)
			{
				var values:Array = [];
				
				for each (var dim:Object in _groupDimensions)
				{
					values.push(event.geometry.data[event.geometry.element[dim]]);
				}
				
				geoms = _coords.interactivityManager.getGeometriesForSpecificElementDimensions(_groupDimensions, values);
								
			}	
			
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