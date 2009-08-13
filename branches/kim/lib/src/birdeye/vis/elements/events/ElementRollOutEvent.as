package birdeye.vis.elements.events
{
	import flash.events.Event;

	public class ElementRollOutEvent extends Event
	{
		public static const ELEMENT_ROLL_OUT:String="elementRollOut";
		
		public function ElementRollOutEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}