package org.un.cava.birdeye.geovis.locators
{
	public class LatLongMiller extends org.un.cava.birdeye.geovis.locators.LatLong
	{
		
		public function LatLongMiller(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.scalefactor=120;
			this.xoffset=3.16;
			this.yoffset=1.99;

			this.xval=calculateX();
			this.yval=calculateY();
		}

		public override function calculateX():Number
		{
			var xCentered:Number=this.long;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			//y = 1.25 ln( tan(pi/4 + 0.8 lat/2) ) 
			yCentered = 1.25*Math.log( Math.tan(Math.PI/4 + 0.4*this.lat) );
			return translateY(yCentered);
		}

	}
}