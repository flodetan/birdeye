package org.un.cava.birdeye.geovis.locators
{
	public class LatLongMollweide extends org.un.cava.birdeye.geovis.locators.LatLong
	{
		private var theta:Number=1;
		private var loopCounter:int=0;
		
		public function LatLongMollweide(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;
			this.scalefactor=137;
			this.xoffset=2.73;
			this.yoffset=1.35;

			this.theta = approxTheta(lat);

			this.xval=calculateX();
			this.yval=calculateY();
		}
		
		private function approxIsGoodEnough(tP:Number, lat:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			loopCounter++;
			//diff = Left side - Right side = tP + sin(tP) - pi*sin(lat)
			var diff:Number = tP+Math.sin(tP) - Math.PI * Math.sin(lat); 
			return (Math.abs(diff)<maxDiff || loopCounter>=100); //Do not loop more than 100 times
		}
		
		private function newtonRaphson(tP:Number, lat:Number):Number {
			return (Math.PI * Math.sin(lat)-tP-Math.sin(tP))/(1 + Math.cos(tP));
		}

		private function approxTheta(lat:Number):Number
		{
			var thetaPrim:Number = lat;
			while (approxIsGoodEnough(thetaPrim, lat)==false) {
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, lat);
			}
			return thetaPrim/2;
		}

		public override function calculateX():Number
		{
			var xCentered:Number;
			const c:Number = 2*Math.sqrt(2)/Math.PI;
			
			xCentered = c * this.long * Math.cos(this.theta);
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			var yCentered:Number;
			yCentered = Math.sqrt(2) * Math.sin(this.theta);
			return translateY(yCentered);
		}
				
	}
}