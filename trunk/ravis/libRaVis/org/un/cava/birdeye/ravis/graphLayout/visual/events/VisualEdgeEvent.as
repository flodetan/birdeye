package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public class VisualEdgeEvent extends Event
	{
		public static const CLICK:String = "edgeClick";
		public static const ROLL_OVER:String = "edgeRollOver";
		public static const ROLL_OUT:String = "edgeRollOut";
		
		public var edge:IEdge;
        public var ctrlKey:Boolean;
		
		public function VisualEdgeEvent(type:String, edge:IEdge, ctrlKey:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.edge = edge;
            this.ctrlKey = ctrlKey;
		}
		
		public override function clone():Event
		{
			return new VisualEdgeEvent(type,edge,ctrlKey, bubbles,cancelable);
		}
		
	}
}