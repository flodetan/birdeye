package org.un.cava.birdeye.geovis.locators
{
	public class LatLongEckertIV extends org.un.cava.birdeye.geovis.locators.LatLong
	{
		private var theta:Number=1;
		private var tmpCounter=0;

		public function LatLongEckertIV(long:Number,lat:Number)
		{
			super();
			this.long=long;
			this.lat=lat;

			this.scalefactor=145;
			this.xoffset=2.6;
			this.yoffset=1.3;
			
			this.theta = approxTheta(lat);

			this.xval=calculateX();
			this.yval=calculateY();
		}

		private function approxIsGoodEnough(tP:Number, lat:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			tmpCounter++;
			//diff = Left side - Right side = tP + sin(tP)cos(tP) + 2sin(tP) - (2 + pi/2)*sin(lat)
			var diff:Number = tP+Math.sin(tP)*Math.cos(tP)+2*Math.sin(tP) - (2+Math.PI/2) * Math.sin(lat); 
			return (Math.abs(diff)<maxDiff || tmpCounter>=100);
		}
		
		private function newtonRaphson(tP:Number, lat:Number):Number {
			//numerator: (2+pi/2)*sin(lat) - tP - sin(tP)cos(tP) - 2sin(tP)
			//denominator: 2cos(tP)*(1+cos(tP))
			return ((2+Math.PI/2)*Math.sin(lat) - tP - Math.sin(tP)*Math.cos(tP) - 2*Math.sin(tP))/(2*Math.cos(tP)*(1+Math.cos(tP)));
		}

		private function approxTheta(lat:Number):Number
		{
			var thetaPrim:Number = lat/2;
			while (approxIsGoodEnough(thetaPrim, lat)==false) {
				trace ("tmpCounter: " + tmpCounter);
				trace ("thetaPrim: " + thetaPrim);
				thetaPrim = thetaPrim + newtonRaphson(thetaPrim, lat);
			}
			return thetaPrim;
		}

		public override function calculateX():Number
		{
			const lstart:Number = 0;
			const c:Number = 2/Math.sqrt(Math.PI*(4+Math.PI));
			var xCentered:Number;
			
			xCentered = c *(this.long-lstart)*(1+Math.cos(this.theta));
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			const c:Number = 2*Math.sqrt(Math.PI/(4+Math.PI));
			var yCentered:Number;
			
			yCentered = c * Math.sin(this.theta);
			return translateY(yCentered);
		}

	}
}