package birdeye.vis.interfaces
{
	import birdeye.vis.scales.MultiScale;
	
	import flash.geom.Point;
	
	public interface ICoordinates
	{
		function set origin(val:Point):void;
		function get origin():Point;

		function set multiScale(val:MultiScale):void;
		function get multiScale():MultiScale;

		function set scale1(val:IScale):void; 
		function get scale1():IScale

 		function set scale2(val:IScale):void
		function get scale2():IScale

		function set scale3(val:IScale):void
		function get scale3():IScale

		function set colorAxis(val:INumerableScale):void
		function get colorAxis():INumerableScale
	}
}