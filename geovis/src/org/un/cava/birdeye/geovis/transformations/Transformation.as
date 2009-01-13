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

package org.un.cava.birdeye.geovis.transformations
{
	import flash.geom.Point;
	
	/**
	* Superclass for transforming latitude and longitude coordinates into x and y for the maps of GeoVis
	**/

	//This class is intended to be overridden. Inheriting classes should implement the functions calculateX and calculateY
	public class Transformation
	{
		//These variables are supposed to be overridden
		protected var _scalefactor:Number; //Projection-specific scaling factor for zooming in to match the size of the map polygon
		protected var _xoffset:Number; //Projection-specific x-wise translation so that x=0 becomes the left border of the map
		protected var _yoffset:Number; //Projection-specific y-wise translation so that y=0 becomes the top of the map

		public function Transformation()
		{
		}
		
		//This function is supposed to be overridden
		public function calcXY(lat:Number, long:Number, zoom:Number):Point
		{
			return null;
		}

		//This function is supposed to be overridden
		public function calculateX():Number
		{
			return 0;
		}

		//This function is supposed to be overridden
		public function calculateY():Number
		{
			return 0;
		}
			
		protected function createTranslatedXYPoint(xCentered:Number,yCentered:Number,zoom:Number):Point
		{
			var xval:Number=translateX(xCentered)*zoom;
			var yval:Number=translateY(yCentered)*zoom;
			return new Point(xval,yval);
		}

		protected function translateX(xCentered:Number):Number
		{
			return (_xoffset+xCentered)*_scalefactor;
		}

		protected function translateY(yCentered:Number):Number
		{
			return (_yoffset-yCentered)*_scalefactor;
		}
		
		public static function convertDegToRad(deg:Number):Number {
			return deg * Math.PI / 180 ;
		}

		//--------------------------------------------------------------------------
	    //
	    //  Setters and Getters
	    //
	    //--------------------------------------------------------------------------

		public function set scalefactor(value:Number):void{
			_scalefactor=value;
		}
		
		public function get scalefactor():Number{
			return _scalefactor;
		}
		
		public function set xoffset(value:Number):void{
			_xoffset=value;
		}
		
		public function get xoffset():Number{
			return _xoffset;
		}

		public function set yoffset(value:Number):void{
			_yoffset=value;
		}
		
		public function get yoffset():Number{
			return _yoffset;
		}

	}
}