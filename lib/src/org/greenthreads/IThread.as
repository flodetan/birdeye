package org.greenthreads
{
	public interface IThread
	{
		/**
		 * Returns the priority of the thread.</br>
		 * Default priorities are defined in the ThreadProcessor class. </br>
		 */
		function get priority():int;
		
		function initializeDrawingData() : Boolean;
		
		function drawDataItem() : Boolean;
		
		
		
	
	}
	
}