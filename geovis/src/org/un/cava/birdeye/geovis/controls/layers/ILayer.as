package org.un.cava.birdeye.geovis.controls.layers
{
	import flash.display.DisplayObject;
	
	public interface ILayer
	{
		// sets the projection layer property. this should usually trigger 
		// an invalidateDisplasList or the redraw of the layer with the new projection
		function set projection(val:String):void;
	}
}