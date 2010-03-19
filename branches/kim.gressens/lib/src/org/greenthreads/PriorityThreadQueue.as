package org.greenthreads
{
	public dynamic class PriorityThreadQueue extends Array
	{
		public function PriorityThreadQueue(...parameters)
		{
			//super(...parameters);
		}
		
		AS3 override function push(...args):uint
		{
			var ret:uint = super.push(args[0]);
			this.sort(compare);
			return ret;
		}
		
		public function front():IThread
		{
			return this[0];
		}
		
		
		public function contains(thread:IThread):Boolean
		{
			var index:int = this.indexOf(thread);
			
			return index >= 0;
		}
		
		public function remove(thread:IThread):void
		{
			var index:int = this.indexOf(thread);
				
			if (index >= 0)
			{
				this.splice(index, 1);
			}
		}
		
		private function compare(threadA:IThread, threadB:IThread):int
		{
			if (threadA.priority < threadB.priority)
			{
				return -1;
			}
			else if (threadA.priority > threadB.priority)
			{
				return 1;
			}
			
			return 0;
		}
	}
}