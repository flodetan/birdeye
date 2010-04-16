package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public class VisualNodeEvent extends Event
	{
		public static const CLICK:String = "nodeClick";
		public static const DRAG_START:String = "nodeDragStart";
		public static const DRAG_END:String = "nodeDragEnd";
		
		public var node:INode;
		
		public function VisualNodeEvent(type:String, node:INode, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.node = node;
		}
		
		public override function clone():Event
		{
			return new VisualNodeEvent(type,node,bubbles,cancelable);
		}
		
	}
}