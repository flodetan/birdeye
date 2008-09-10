package org.un.cava.birdeye.geovis.locators
{
	public class LatLongWorldGeographic extends LatLong
	{
		public function LatLongWorldGeographic(long:Number,lat:Number)
		{
			super(long,lat);
			this.long=long;
			this.lat=lat;

			this.scalefactor=121;
			this.xscaler=0.99;
			this.xoffset=3.13;
			this.yoffset=1.44;
		}
		
		public override function longToX(long:Number):Number
		{
			var xCentered:Number;
			var stdParallell:Number = Math.PI / 8;
			
			xCentered = long * this.xscaler;//Math.cos(stdParallell);
			trace ("xscaler: " + this.xscaler);
			trace ("xCentered: " + xCentered);
			return translateX(xCentered);
		}

		public override function latToY(lat:Number):Number
		{
			var yCentered:Number;
			var scaleY:Number = 100;
			yCentered = lat;
			trace ("yCentered: " + yCentered);
			return translateY(yCentered);
		}
		
	}
}