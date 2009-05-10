/* 
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package birdeye.vis.trans.projections
{
	import flash.geom.Point;
	
	import birdeye.vis.trans.projections.Transformation;

	import birdeye.vis.trans.projections.WorldGeographicTransformation;
	import birdeye.vis.trans.projections.LambertTransformation;
	import birdeye.vis.trans.projections.PlainMollweideTransformation;
	import birdeye.vis.trans.projections.WinkelTripelTransformation;
	import birdeye.vis.trans.projections.MillerTransformation;
	import birdeye.vis.trans.projections.EckertIVTransformation;
	import birdeye.vis.trans.projections.EckertVITransformation;
	import birdeye.vis.trans.projections.GoodeMollweideTransformation;
	import birdeye.vis.trans.projections.GoodeSinusoidalTransformation;
	import birdeye.vis.trans.projections.PlainSinusoidalTransformation;
	import birdeye.vis.trans.projections.RobinsonTransformation;

	//This class calculates latitude & longitude from x & y. And vice versa
	public class Projection
	{

		private var _proj:String;
		private static var _worldGeographic:WorldGeographicTransformation = null; //Singleton WorldGeographicTransformation
		private static var _lambert:LambertTransformation = null; //Singleton LambertTransformation
		private static var _mollweide:PlainMollweideTransformation = null; //Singleton PlainMollweideTransformation
		private static var _winkelTripel:WinkelTripelTransformation = null; //Singleton WinkelTripelTransformation
		private static var _miller:MillerTransformation = null; //Singleton MillerTransformation
		private static var _eckertIV:EckertIVTransformation = null; //Singleton EckertIVTransformation
		private static var _eckertVI:EckertVITransformation = null; //Singleton EckertVITransformation
		private static var _goodeMollweide:GoodeMollweideTransformation = null; //Singleton GoodeMollweideTransformation
		private static var _goodeSinusoidal:GoodeSinusoidalTransformation = null; //Singleton GoodeSinusoidalTransformation
		private static var _sinusoidal:PlainSinusoidalTransformation = null; //Singleton PlainSinusoidalTransformation
		private static var _robinson:RobinsonTransformation = null; //Singleton RobinsonTransformation

		public function projectArrayXs(coordArray:Array):void
		{
			var long:Number;
			var lat:Number;
			var xval:Number;
			for each (var coord:Array in coordArray) //a polygon has several points
			{
				xval = projectX(coord[1],coord[0],700,Number.NaN,Number.NaN,Number.NaN,Number.NaN);//-90,90,-180,180);//
				coord[0] = xval;
			} // end for each point
		}

		public function projectArrayYs(coordArray:Array):void
		{
			var long:Number;
			var lat:Number;
			var yval:Number;
			for each (var coord:Array in coordArray) //a polygon has several points
			{
				yval = projectY(coord[1],coord[0],500,Number.NaN,Number.NaN,Number.NaN,Number.NaN);//-90,90,-180,180);//
				coord[1] = yval;
			} // end for each point
		}

		public function projectX(lat:Number, long:Number, sizeX:Number, minLat:Number, maxLat:Number, minLong:Number, maxLong:Number):Number
		{
			var transformation: Transformation = selectTransformation(lat, long, _proj);
			var x:Number = transformation.projectX(lat, long, sizeX, minLat, maxLat, minLong, maxLong);
			return x;
		}

		public function projectY(lat:Number, long:Number, sizeY:Number, minLat:Number, maxLat:Number, minLong:Number, maxLong:Number):Number
		{
			var transformation: Transformation = selectTransformation(lat, long, _proj);
			var y:Number = transformation.projectY(lat, long, sizeY, minLat, maxLat, minLong, maxLong);
			return y;
		}
		
		private static function selectTransformation(lat:Number, long:Number, proj:String):Transformation
		{
			if (proj == "Geographic") {
				return worldGeographic;
			} else if (proj == "Lambert equal area") {
				return lambert;
			} else if (proj == "Mollweide") {
				return mollweide;
			} else if (proj == "WinkelTripel") {
				return winkelTripel;
			} else if (proj == "Miller cylindrical") {
				return miller;
			} else if (proj == "EckertIV") {
				return eckertIV;
			} else if (proj == "EckertVI") {
				return eckertVI;
			} else if (proj == "Goode") {
				if (Math.abs(lat) >= 40.73333403){
//					(t as MollweideTransformation).setGoodeConstants();
				return goodeMollweide;
				} else {
//					(t as SinusoidalTransformation).setGoodeConstants();
				return goodeSinusoidal;
				}
			} else if (proj == "Sinsoidal") {
				return sinusoidal;
			} else if (proj == "Robinson") {
				return robinson;
			} else {
				return null;
				//SASN: else throw an error with message "No such projection"
			}
		}
		
		
		
		//--------------------------------------------------------------------------
	    //
	    //  Setters and Getters for the Transformation singletons
	    //
	    //--------------------------------------------------------------------------
		public function get proj():String{
			return _proj;
		}	
		public function set proj(ref:String):void{
			_proj=ref;
		}

		public static function get worldGeographic():WorldGeographicTransformation{
			if (_worldGeographic == null) {
				_worldGeographic = new WorldGeographicTransformation();
			}
			return _worldGeographic;
		}	
		public static function set worldGeographic(ref:WorldGeographicTransformation):void{
			_worldGeographic=ref;
		}
		
		public static function get lambert():LambertTransformation{
			if (_lambert == null) {
				_lambert = new LambertTransformation();
			}
			return _lambert;
		}
		public static function set lambert(ref:LambertTransformation):void{
			_lambert=ref;
		}
		
		public static function get mollweide():PlainMollweideTransformation{
			if (_mollweide == null) {
				_mollweide = new PlainMollweideTransformation();
			}
			return _mollweide;
		}
		public static function set mollweide(ref:PlainMollweideTransformation):void{
			_mollweide=ref;
		}

		public static function get winkelTripel():WinkelTripelTransformation{
			if (_winkelTripel == null) {
				_winkelTripel = new WinkelTripelTransformation();
			}
			return _winkelTripel;
		}
		public static function set winkelTripel(ref:WinkelTripelTransformation):void{
			_winkelTripel=ref;
		}

		public static function get miller():MillerTransformation{
			if (_miller == null) {
				_miller = new MillerTransformation();
			}
			return _miller;
		}
		public static function set miller(ref:MillerTransformation):void{
			_miller=ref;
		}

		public static function get eckertIV():EckertIVTransformation{
			if (_eckertIV == null) {
				_eckertIV = new EckertIVTransformation();
			}
			return _eckertIV;
		}
		public static function set eckertIV(ref:EckertIVTransformation):void{
			_eckertIV=ref;
		}

		public static function get eckertVI():EckertVITransformation{
			if (_eckertVI == null) {
				_eckertVI = new EckertVITransformation();
			}
			return _eckertVI;
		}
		public static function set eckertVI(ref:EckertVITransformation):void{
			_eckertVI=ref;
		}

		public static function get goodeMollweide():GoodeMollweideTransformation{
			if (_goodeMollweide == null) {
				_goodeMollweide = new GoodeMollweideTransformation();
			}
			return _goodeMollweide;
		}
		public static function set goodeMollweide(ref:GoodeMollweideTransformation):void{
			_goodeMollweide=ref;
		}

		public static function get goodeSinusoidal():GoodeSinusoidalTransformation{
			if (_goodeSinusoidal == null) {
				_goodeSinusoidal = new GoodeSinusoidalTransformation();
			}
			return _goodeSinusoidal;
		}
		public static function set goodeSinusoidal(ref:GoodeSinusoidalTransformation):void{
			_goodeSinusoidal=ref;
		}

		public static function get sinusoidal():PlainSinusoidalTransformation{
			if (_sinusoidal == null) {
				_sinusoidal = new PlainSinusoidalTransformation();
			}
			return _sinusoidal;
		}
		public static function set sinusoidal(ref:PlainSinusoidalTransformation):void{
			_sinusoidal=ref;
		}

		public static function get robinson():RobinsonTransformation{
			if (_robinson == null) {
				_robinson = new RobinsonTransformation();
			}
			return _robinson;
		}
		public static function set robinson(ref:RobinsonTransformation):void{
			_robinson=ref;
		}
	
	}
}