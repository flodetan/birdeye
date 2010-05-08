package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;

	public class VisualGraphEvent extends Event
	{
		public static const BACKGROUND_DRAG_END:String = "backgroundDragEnd";
        public static const BEGIN_ANIMATION:String = "beginAnimation";
        public static const END_ANIMATION:String = "endAnimation";
        public static const GRAPH_UPDATED:String = "graphUpdated";
		
		public function VisualGraphEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}