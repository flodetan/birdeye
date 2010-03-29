package birdeye.vis.interactivity.geometry
{
	import birdeye.vis.interfaces.elements.IElement;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	import flash.geom.Point;
	
	public class BaseInteractiveGeometry implements IInteractiveGeometry
	{
				
		private var _data:Object;
		
		public function set data(d:Object):void
		{
			_data = d;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		private var _element:IElement;
		
		public function set element(el:IElement):void
		{
			_element = el;
		}
		
		public function get element():IElement
		{
			return _element;
		}
		
		private var _preferredPoint:Point;
		
		public function set preferredTooltipPoint(p:Point):void
		{
			_preferredPoint = p;
		}
		
		public function get preferredTooltipPoint():Point
		{
			return _preferredPoint;
		}
		
		
		public function contains(p:Point):Boolean
		{
			return false;
		}
	}
}