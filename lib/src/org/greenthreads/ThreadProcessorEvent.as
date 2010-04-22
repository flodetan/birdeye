package org.greenthreads
{
	import flash.events.Event;
	
	public class ThreadProcessorEvent extends Event
	{
		public static const THREAD_PROCESSOR_FINSIHED:String = "threadProcessorFinished";
		
		public function ThreadProcessorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}