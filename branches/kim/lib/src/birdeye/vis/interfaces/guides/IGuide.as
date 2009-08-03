package birdeye.vis.interfaces.guides
{
	import birdeye.vis.interfaces.ICoordinates;
	
	import flash.geom.Rectangle;
	
	public interface IGuide
	{
		
		/** Draw the guide.*/
		function drawGuide():void
						
		/**
		 * The targets where the guide is drawn.
		 */
		function get targets():Array; 
		
		/**
		 * Set the coordinates system where this guide belongs too.
		 */
		function set coordinates(val:ICoordinates):void;
		function get coordinates():ICoordinates;
		
		/**
		 * This function needs to be implemented to allow the ICoordinates</br>
		 * interface to determine where this guide will draw itself.</br>
		 * <b>elements</b> : indicates that the guide will draw itself onto the elements
		 * <b>sides</b> : indicate that the guide will draw itself onto the side, subinterfaces will further determine the position
		 */
		function get position():String;	
	}
}