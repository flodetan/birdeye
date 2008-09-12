package org.un.cava.birdeye.geovis.locators
{
	public class LatLongWorldGeographic extends LatLong
	{
		public function LatLongWorldGeographic(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.scalefactor=121;
			this.xscaler=0.99;
			this.xoffset=3.13;
			this.yoffset=1.44;

			this.xval=calculateX();
			this.yval=calculateY();
		}
		
		public override function calculateX():Number
		{
			var xCentered:Number;
			var stdParallell:Number = Math.PI / 8;
			
			xCentered = this.long * this.xscaler;//Math.cos(stdParallell);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			var scaleY:Number = 100;
			yCentered = this.lat;
			return translateY(yCentered);
		}
		
	}
}