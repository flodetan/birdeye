package org.un.cava.birdeye.geovis.locators
{
	public class LatLongWinkelTripel extends LatLong
	{
		private var sincAlpha:Number;
		
		public function LatLongWinkelTripel(long:Number,lat:Number)
		{
			trace ("lat comig in: " + lat);
			super(long,lat);
			this.long=long;
			this.lat=lat;
			this.sincAlpha=calcSincAlpha(long, lat);
			this.scalefactor=120;
			this.xoffset=3.15;
			this.yoffset=1.47;
		}


		private function calcSincAlpha(long:Number,lat:Number):Number
		{
			var alpha:Number = Math.acos(Math.cos(lat)*Math.cos(long/2));
			trace ("alpha: " + alpha);
			if (alpha==0) {
				return 1;
				trace ("sincAlpha: " + sincAlpha);
			}else{
				return (Math.sin(alpha)/alpha);
			}
		}

		public override function longToX(long:Number):Number
		{
			//const cosEquirect:Number = 1;//2/Math.PI;
			var cosEquirect = this.xscaler;
			var xCentered:Number;
			
			xCentered = ( long*cosEquirect + 2*Math.cos(lat)*Math.sin(long/2)/this.sincAlpha )/2;
			return translateX(xCentered);
		}

		public override function latToY(lat:Number):Number
		{
			var yCentered:Number;
			
			yCentered = (lat + Math.sin(lat)/this.sincAlpha)/2;
			return translateY(yCentered);
		}

	}
}