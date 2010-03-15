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
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	
	[Event( name='complete', type='flash.events.Event' )]
	[Event( name='timeout', type='org.greenthreads.ThreadEvent')]
	[Event( name='progress', type='mx.events.ProgressEvent')]
	public class GreenThread extends EventDispatcher {
		private var _maximum : Number = NaN;
		private var _progress : Number = NaN;
		private var _debug : Boolean;
		private var _statistics : ThreadStatistics;
		
		public function GreenThread( debug : Boolean = true ) {
			_debug = debug;
		}
		
		public final function start( share : Number = 0.99 ) : void {
			ThreadProcessor.getInstance(share).addThread( this );
			if( debug ) {
				_statistics = new ThreadStatistics();
			}
			initialize();
		}

		public final function stop() : void {
			ThreadProcessor.getInstance().stop( this );
		}
		
		protected function initialize() : void {
		}
		
		protected function run() : Boolean {
			return false;
		}
		
		public final function execute( processAllocation : Number ) : Boolean {
			if( debug ) statistics.startCycle();
			
			try {
				var processStart:int = getTimer();
				
			    var loop : Boolean = true;
				while( getTimer() - processStart < processAllocation && loop ) {
					loop = run();
				} 
			} catch( error:ScriptTimeoutError ) {
				if( debug ) statistics.recordTimeout();
				dispatchEvent( new ThreadEvent( ThreadEvent.TIMEOUT ) );
			}
			
			//record post process time
			if( debug ) statistics.endCycle( processAllocation );
		
			if( !loop ) {
				dispatchProgress();
				dispatchEvent( new Event( Event.COMPLETE ) );
				//do any cleanup
				stop();
				return false;
			} else {
				dispatchProgress();
			}
			return true;
		}
		
		private function dispatchProgress() : void {
			if( isNaN(maximum) == false ) {
				var evt : ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS );
				evt.bytesLoaded = progress;
				evt.bytesTotal = maximum;
				dispatchEvent( evt );
			}
		}
		
		public function get progress() : Number {
			return _progress;
		}
		
		public function get maximum() : Number {
			return _maximum;
		}
		
		public function set maximum( value : Number ) : void {
			_maximum = value;
		}
		
		public function set progress( value : Number ) : void {
			_progress = value;
		}
		
		public function get debug() : Boolean {
			return _debug;
		}
		
		public function set debug( value : Boolean ) : void {
			_debug = value;
		}
		
		public function get statistics() : ThreadStatistics {
			return _statistics;
		}
		
	}
}