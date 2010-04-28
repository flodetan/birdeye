package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interactivity.events.InteractivityEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	import mx.controls.Label;
	
	public class ElementToolTipManager extends BaseToolTipManager
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
				changeAllLabels(false);
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
			
			changeLabels(geoms, true);
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
			
			changeLabels(geoms, false);
	
			//			trace("Mouse out of ", event.geometry.data[event.geometry.element.dim1], event.geometry.data[event.geometry.element.dim2]);
		}
		
		
	}
}