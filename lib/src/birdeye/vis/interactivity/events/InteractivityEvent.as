package birdeye.vis.interactivity.events
{
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	import flash.events.Event;
	
	public class InteractivityEvent extends Event
	{
		public static const GEOMETRY_MOUSE_OVER:String = "geometryMouseOver";
		public static const GEOMETRY_MOUSE_CLICK:String = "geometryMouseClick";
		public static const GEOMETRY_MOUSE_OUT:String = "geometryMouseOut";
		
		public var geometry:IInteractiveGeometry;
		
		public function InteractivityEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}