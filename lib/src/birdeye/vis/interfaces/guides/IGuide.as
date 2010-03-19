package birdeye.vis.interfaces.guides
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	
	import flash.geom.Rectangle;
	
	public interface IGuide
	{	
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
		
		
		/** The axis must provide the clear all graphics items when refreshed, thus insuring
		 * both display refresh and memory clearing.*/
		function clearAll():void

		/** Return the svg data corresponding to this guide.*/
		function get svgData():String;

		/** Return the parent container of this guide.*/
		function get parentContainer():Object;

		/** Return the x position of this guide.*/
		function get x():Number;
		/** Return the y position of this guide.*/
		function get y():Number;
	}
}