package org.un.cava.birdeye.geovis.locators
{
	public class LatLongMiller extends LatLong
	{
		
		public function LatLongMiller(long:Number,lat:Number)
		{
			trace ("lat comig in: " + lat);
			super(long,lat);
			this.long=long;
			this.lat=lat;

			this.scalefactor=120;
			this.xoffset=3.16;
			this.yoffset=1.99;
		}

		public override function longToX(long:Number):Number
		{
			var xCentered:Number=long;
			return translateX(xCentered);
		}

		public override function latToY(lat:Number):Number
		{
			var yCentered:Number;
			//y = 1.25 ln( tan(pi/4 + 0.8 lat/2) ) 
			yCentered = 1.25*Math.log( Math.tan(Math.PI/4 + 0.4*lat) );
			return translateY(yCentered);
		}

	}
}