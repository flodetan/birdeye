package styles.events
{
	import flash.events.Event;

	public class StyleLoaderEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		
		static public const STYLE_CHANGE:String 	= "styleChangeEvent";
		static public const LOAD_COMPLETE:String 	= "styleLoadCompleteEvent";
		static public const FAULT:String 			= "styleLoadFaultEvent";
		
		/*-.........................................Properties..........................................*/
		
		public var url:String = null;
		
		
		/*-.........................................Constructor..........................................*/
		
		public function StyleLoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}