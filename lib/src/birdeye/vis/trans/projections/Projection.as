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
	import birdeye.vis.data.Pair;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.transforms.IProjection;
	
	//This class calculates latitude & longitude from x & y. And vice versa
	public class Projection implements IProjection
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

		private var _minLat:Number;
		public function set minLat(val:Number):void
		{
			_minLat = val;
		}
		
		private var _maxLat:Number;
		public function set maxLat(val:Number):void
		{
			_maxLat = val;
		}

		private var _minLong:Number;
		public function set minLong(val:Number):void
		{
			_minLong = val;
		}

		private var _maxLong:Number;
		public function set maxLong(val:Number):void
		{
			_maxLong = val;
		}
		
		private var _latScale:IScale;
		public function set latScale(val:IScale):void
		{
			_latScale = val;
			if (_latScale.dataValues)
			{
				minLat = _latScale.dataValues[0];
				maxLat = _latScale.dataValues[1];
			}
			_latScale.f = funcDim2;
		}

		private var _longScale:IScale;
		public function set longScale(val:IScale):void
		{
			_longScale = val;
			if (_longScale.dataValues)
			{
				minLong = _longScale.dataValues[0];
				maxLong = _longScale.dataValues[1];
			}
			_longScale.f = funcDim1;
		}
		
		public function Projection():void
		{

		}

		public function funcDim1(latLon:*, minLong:Number, maxLong:Number, sizeX:Number):Number
		{
			if (latLon is Number)
				return projectX(_minLat, latLon, sizeX, _minLat, _maxLat, minLong, maxLong);
			else if (latLon is String)
				return projectX(_minLat, Number(latLon), sizeX, _minLat, _maxLat, minLong, maxLong);
			else if (latLon is Pair)
				return projectX(latLon.dim2, latLon.dim1, sizeX, _minLat, _maxLat, minLong, maxLong);
			else 
				return projectX(latLon[1], latLon[0], sizeX, _minLat, _maxLat, minLong, maxLong);
		}

		public function funcDim2(latLon:*, minLat:Number, maxLat:Number, sizeY:Number):Number
		{
			if (latLon is Number)
				return projectY(latLon, _minLong, sizeY, minLat, maxLat, _minLong, _maxLong);
			else if (latLon is String)
				return projectY(Number(latLon), _minLong, sizeY, minLat, maxLat, _minLong, _maxLong);
			else if (latLon is Pair)
				return projectY(latLon.dim2, latLon.dim1, sizeY, minLat, maxLat, _minLong, _maxLong);
			else 
				return projectY(latLon[1], latLon[0], sizeY, minLat, maxLat, _minLong, _maxLong);
		}

		public function funcDim3(dataValue:*, min3:Number, max3:Number, size3:Number):Number {return NaN}

		public function projectArrayXs(coordArray:Array, sizeX:Number):void
		{
			var long:Number;
			var lat:Number;
			var xval:Number;
			for each (var coord:Array in coordArray) //a polygon has several points
			{
				xval = projectX(coord[1],coord[0],sizeX);//-90,90,-180,180);//
				coord[0] = xval;
			} // end for each point
		}

		public function projectArrayYs(coordArray:Array, sizeY:Number):void
		{
			var long:Number;
			var lat:Number;
			var yval:Number;
			for each (var coord:Array in coordArray) //a polygon has several points
			{
				yval = projectY(coord[1],coord[0],sizeY);//-90,90,-180,180);//
				coord[1] = yval;
			} // end for each point
		}

		public function projectX(lat:Number, long:Number, sizeX:Number, minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			if (isNaN(minLat))
				minLat=-90;
			if (isNaN(maxLat))
				maxLat=90;
			if (isNaN(minLong))
				minLong=-180;
			if (isNaN(maxLong))
				maxLong=180;

			var transformation: Transformation = selectTransformation(lat, long, _proj);
			var x:Number = transformation.projectX(lat, long, sizeX, minLat, maxLat, minLong, maxLong);
			return x;
		}

		public function projY(latLon:Array, minLat:Number, maxLat:Number, sizeY:Number):Number
		{
			return projectY(latLon[1], latLon[0], sizeY, minLat, maxLat, _minLong, _maxLong);
			
		}

		public function projectY(lat:Number, long:Number, sizeY:Number, minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			if (isNaN(minLat))
				minLat=-90;
			if (isNaN(maxLat))
				maxLat=90;
			if (isNaN(minLong))
				minLong=-180;
			if (isNaN(maxLong))
				maxLong=180;

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
		[Inspectable(enumeration="Geographic,Lambert equal area,Mollweide,WinkelTripel,Miller cylindrical,EckertIV,EckertVI,Goode,Sinsoidal,Robinson")]
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