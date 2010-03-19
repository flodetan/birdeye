package org.greenthreads
{
	import birdeye.vis.interfaces.guides.IGuide;
	
	import flash.geom.Rectangle;
	
	public interface IGuideThread extends IThread, IGuide
	{
		function set bounds(b:Rectangle):void;
	}
}