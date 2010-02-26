package birdeye.vis.elements.events
{
	import birdeye.vis.interfaces.scales.IScale;
	
	import flash.events.Event;

	public class ElementRollOverEvent extends Event
	{
		public static const ELEMENT_ROLL_OVER:String = "elementRollOver";
		
		public var dim1:Object;
		public var dim2:Object;
		public var dim3:Object;
		
		public var pos1:Object;
		public var pos2:Object;
		public var pos3:Object;
		
		public var scale1:IScale;
		public var scale2:IScale;
		public var scale3:IScale;
		
		public function ElementRollOverEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}