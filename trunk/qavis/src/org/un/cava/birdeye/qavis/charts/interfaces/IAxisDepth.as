package org.un.cava.birdeye.qavis.charts.interfaces
{
	public interface IAxisDepth extends IAxisLayout
	{
		/** It defines the 3d depth, corresponding to the z axis size. */
		function set depth(val:Number):void;
		
		/** It defines the layer position for the z axis. If there are more than 1 
		 * z axis, they will be layered according to their layer.*/
		function set layer(val:Number):void;

		/** Set the distance between multiple layers (z axis).*/		
		function set layerDistance(val:Number):void;
	}
}