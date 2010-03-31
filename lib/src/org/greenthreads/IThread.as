package org.greenthreads
{
	public interface IThread
	{
		/**
		 * Returns the priority of the thread.</br>
		 * Default priorities are defined in the ThreadProcessor class. </br>
		 */
		function get priority():int;
		
		function preDraw() : Boolean;
		
		function drawDataItem() : Boolean;
		
		function endDraw() : void;
		
		
		
	
	}
	
}