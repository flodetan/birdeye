package org.un.cava.birdeye.geovis.locators
{
	public class LatLongWinkelTripel extends org.un.cava.birdeye.geovis.locators.LatLong
	{
		private var sincAlpha:Number;
		
		public function LatLongWinkelTripel(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;
			this.scalefactor=120;
			this.xoffset=3.15;
			this.yoffset=1.47;

			this.sincAlpha=calcSincAlpha(long, lat);

			this.xval=calculateX();
			this.yval=calculateY();
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

		public override function calculateX():Number
		{
			//const cosEquirect:Number = 1;//2/Math.PI;
			var cosEquirect:Number = this.xscaler;
			var xCentered:Number;
			
			xCentered = ( this.long*cosEquirect + 2*Math.cos(this.lat)*Math.sin(this.long/2)/this.sincAlpha )/2;
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			
			yCentered = (this.lat + Math.sin(this.lat)/this.sincAlpha)/2;
			return translateY(yCentered);
		}

	}
}