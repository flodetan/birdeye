package org.un.cava.birdeye.ravis.utils.logging
{
	import mx.logging.Log;
	import mx.logging.targets.TraceTarget;

	//A simple LogTarget for use in RaVis examples
	public class RavisLogTarget extends TraceTarget
	{
		public function RavisLogTarget()
		{
			super();
			includeCategory = true
			includeLevel = true
			includeTime = true
			filters = ["org.un.cava.birdeye.ravis.*"]
			Log.addTarget(this)
		}
	}
}