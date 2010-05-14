/**
   Copyright 2009 Charles E Hubbard

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */ 
package org.greenthreads {
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mx.core.Application;
	import mx.managers.CursorManager;
	
	public class ThreadProcessor {
		
		public static const PRIORITY_GUIDE:int = 3;
		public static const PRIORITY_ELEMENT:int = 2;
		
		
		private static var _instance : ThreadProcessor;
		private static const EPSILON : int = 1;
		
		private var frameRate : int;
		private var _share : Number;
		
		private var newThreads:PriorityThreadQueue;
		private var initedThreads:PriorityThreadQueue;
		
		private var consolidatedStatistics:ThreadStatistics;
		
		
		protected var baseThread:GreenThread;
		
		private var errorTerm:int;
		
		public function ThreadProcessor( share : Number = 0.9 ) {
			if( !_instance ) {
				this.frameRate = 20; // we want to render at a framerate of 20 frames / second
				this.share = share;
				this.newThreads = new PriorityThreadQueue();
				this.initedThreads = new PriorityThreadQueue();
				this.baseThread = new GreenThread(true);
				this.consolidatedStatistics = new ThreadStatistics();
				_instance = this;
			} else {
				throw new Error("Error: Instantiation failed: Use ThreadProcessor.getInstance() instead of new.");
			}
		}
		
		public static function getInstance( share : Number = 0.9 ) : ThreadProcessor {
			if( !_instance ) {
				_instance = new ThreadProcessor( share );
			}
			return _instance;
		}
		
		public function addThread( thread : IThread ) : void 
		{
			if (!newThreads.contains(thread))
			{
				newThreads.push(thread);
			}
			
			start();
		}
		
		private var _isRunning:Boolean = false;
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		private function start() : void {
			if (!_isRunning)
			{	
				CursorManager.setBusyCursor();
				this.consolidatedStatistics = new ThreadStatistics();
				_isRunning = true;
				Application.application.addEventListener( Event.ENTER_FRAME, doCycle );
			}
		}
		
		public function stop( thread : IThread ) : void 
		{			
			var index:int = initedThreads.indexOf(thread);
			if (index >= 0)
			{
				initedThreads.splice(index, 1);
			}
			
			if (newThreads.length == 0 && initedThreads.length == 0)
			{
				stopAll();
			}
		}
		
		public function stopAll() : void {
			newThreads.splice(0);
			initedThreads.splice(0);
			_isRunning = false;
			Application.application.removeEventListener( Event.ENTER_FRAME, doCycle );
			
			CursorManager.removeBusyCursor();
			
			// debug
			trace(this.consolidatedStatistics.print());
			
			if (this.consolidatedStatistics.numCycles > 0)
			{
				Application.application.dispatchEvent(new ThreadProcessorEvent(ThreadProcessorEvent.THREAD_PROCESSOR_FINSIHED));
			}
		}
		
		private function doCycle( event : Event ) : void {
			var timeAllocation : int = share < 1.0 ? timerDelay * share + 1 : frameRate - share;
			
			// not needed, only run one thread at a time
			//timeAllocation = Math.max(timeAllocation, EPSILON * activeThreads.length);

			//if the error term is too large, skip a cycle
			if( errorTerm > timeAllocation - 1 ) {
				errorTerm = 0;
				return;
			}
						
			var cycleStart:int = getTimer();	
			var cycleAllocation:int = timeAllocation - errorTerm;
	

			var remainingTime:int = cycleAllocation;
			var cycleTime:int = 0;
			
			while (remainingTime > 0)
			{
				var isNew:Boolean = getThread();

				if (!baseThread.innerThread) break;
				
				if (isNew)
				{
					var isOK:Boolean = baseThread.start();
					isNew = false;
					
					if (!isOK)
					{
						// thread can not start, remove it from queue
						stop(baseThread.innerThread);
					}
				}
				else if (!baseThread.execute(remainingTime) )
				{
					// done, next process
					// print statistics
					printDebug();
				}
				
				// calculate the remainingTime
				cycleTime = getTimer() - cycleStart;
				remainingTime = remainingTime - cycleTime;
			}
		
			//update the error term
			errorTerm = ( errorTerm + remainingTime ) >> 1;
		}
		
		/**
		 * Set the new thread in the basethread</br>
		 * Return true if it is a new thread, false otherwise</br>
		 */
		protected function getThread() : Boolean
		{
			if (initedThreads.length > 0)
			{
				baseThread.innerThread = initedThreads.front();
				return false;
			}
			
			if (newThreads.length == 0)
			{
				baseThread.innerThread = null;
				stopAll();
				return false;
			}
			
			baseThread.innerThread = newThreads.pop();
			initedThreads.push(baseThread.innerThread);
			return true;
		}

		private function printDebug():void
		{
			consolidatedStatistics.addStatistics(baseThread.statistics);
		}

		public function get timerDelay() : Number {
			return 1000 / frameRate;
		}
		
		public function get share() : Number {
			return _share;
		}
		
		public function set share( percent : Number ) : void {
			_share = percent;
		}
	}
}