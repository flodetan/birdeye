package org.un.cava.birdeye.geovis.locators
{
	public class LatLongMollweide extends LatLong
	{
		private var theta:Number=1;
		private var tmpCounter=0;
		
		public function LatLongMollweide(long:Number,lat:Number)
		{
			trace ("lat comig in: " + lat);
			super(long,lat);
			this.long=long;
			this.lat=lat;
			this.theta = approxTheta(lat);

			this.scalefactor=137;
			this.xoffset=2.73;
			this.yoffset=1.35;
		}
		
		private function approxIsGoodEnough(tP:Number, lat:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			tmpCounter++;
			//diff = Left side - Right side = tP + sin(tP) - pi*sin(lat)
			var diff:Number = tP+Math.sin(tP) - Math.PI * Math.sin(lat); 
			return (Math.abs(diff)<maxDiff || tmpCounter>=100);
		}
		
		private function newtonRaphson(tP:Number, lat:Number):Number {
			return (Math.PI * Math.sin(lat)-tP-Math.sin(tP))/(1 + Math.cos(tP));
		}

		private function approxTheta(lat:Number):Number
		{
			var thetaPrim:Number = lat;
			while (approxIsGoodEnough(thetaPrim, lat)==false) {
				trace ("tmpCounter: " + tmpCounter);
				trace ("thetaPrim: " + thetaPrim);
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, lat);
			}
			return thetaPrim/2;
		}

		public override function longToX(long:Number):Number
		{
			var xCentered:Number;
			const c:Number = 2*Math.sqrt(2)/Math.PI;
			
			xCentered = c * long * Math.cos(this.theta);
			return translateX(xCentered);
		}

		public override function latToY(lat:Number):Number
		{
			var yCentered:Number;
			yCentered = Math.sqrt(2) * Math.sin(this.theta);
			return translateY(yCentered);
		}
				
	}
}