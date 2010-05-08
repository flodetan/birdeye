package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;

	public class VisualGraphEvent extends Event
	{
		public static const BACKGROUND_DRAG_END:String = "backgroundDragEnd";
		
		public function VisualGraphEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}