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
	
	/**
	* Superclass for transforming latitude and longitude coordinates into x and y for the maps of GeoVis
	**/

	//This class is intended to be overridden. Inheriting classes should implement the functions calculateX and calculateY
	public class Transformation
	{
		//These variables are supposed to be overridden
		protected var _minX:Number; //X value corresponding to minLong in the given latitude range
		protected var _maxY:Number; //Y value corresponding to maxLat in the given longitude range
		
		public function Transformation()
		{
		}

		//This function is supposed to be overridden
		public function calcX(lat:Number, long:Number):Number
		{
			return 0;
		}

		//This function is supposed to be overridden
		public function calcY(lat:Number, long:Number):Number
		{
			return 0;
		}
		
		public function projectX(lat:Number, long:Number, sizeX:Number, minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			var xCentered:Number = calcX(lat, long);
			var unscaledSizeX:Number = calcUnscaledSizeX(minLat, maxLat, minLong, maxLong);
			return translateX(xCentered, sizeX, unscaledSizeX);
		}

		public function projectY(lat:Number, long:Number, sizeY:Number, minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			var yCentered:Number = calcY(lat, long);
			var unscaledSizeY:Number = calcUnscaledSizeY(minLat, maxLat, minLong, maxLong);
			return translateY(yCentered, sizeY, unscaledSizeY);
		}

		protected function calcUnscaledSizeX(minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			const numberOfSteps:int = 4;
			var stepSize:Number = (maxLat - minLat)/numberOfSteps;
			_minX = calcX(minLat, minLong);
			var maxX:Number = calcX(maxLat, minLong);
			var lat:Number;
			var i:int;
			for (i = 1; i <= numberOfSteps; i++)
			{
				lat = minLat + i*stepSize;
				_minX = Math.min(_minX, calcX(lat,minLong));
				maxX = Math.max(maxX, calcX(lat,maxLong));
			}
			return maxX-_minX;
		}

		protected function calcUnscaledSizeY(minLat:Number=-90, maxLat:Number=90, minLong:Number=-180, maxLong:Number=180):Number
		{
			const numberOfSteps:int = 4;
			var stepSize:Number = (maxLong - minLong)/numberOfSteps;
			var minY:Number = calcY(minLat, minLong);
			_maxY = calcY(maxLat, minLong);
			var long:Number;
			var i:int;
			for (i = 1; i <= numberOfSteps; i++)
			{
				long = minLong + i*stepSize;
				minY = Math.min(minY, calcY(minLat,long));
				_maxY = Math.max(_maxY, calcY(maxLat,long));
			}
			return _maxY-minY;
		}

		protected function translateX(xCentered:Number, sizeX:Number, unscaledSizeX:Number):Number
		{
			var scalefactor:Number = sizeX/unscaledSizeX; //factor for zooming to match the size specified by minLat,maxLat,minLong and maxLong 
			return (xCentered-_minX)*scalefactor;
		}

		protected function translateY(yCentered:Number, sizeY:Number, unscaledSizeY:Number):Number
		{
			var scalefactor:Number = sizeY/unscaledSizeY;
			return (_maxY-yCentered)*scalefactor;
		}
		
		public static function convertDegToRad(deg:Number):Number {
			return deg * Math.PI / 180 ;
		}

	}
}