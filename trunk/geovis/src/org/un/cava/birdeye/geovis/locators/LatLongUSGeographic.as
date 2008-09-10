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

package org.un.cava.birdeye.geovis.locators
{

	/**
	* Class for geographic location referencing via latitude and longitude
	**/	 
	public class LatLongUSGeographic extends LatLong//UIComponent
	{
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------
		public function LatLongUSGeographic(long:Number,lat:Number)
		{
			super(long, lat);
			this.long=long;
			this.lat=lat;

			this.scalefactor=740;
			this.xoffset=2.19;
			this.yoffset=0.858
		}

		public override function longToX(long:Number):Number
		{
			var xCentered:Number;
			var stdParallell:Number = 0;
			
			xCentered = long * Math.cos(stdParallell);
			trace ("xCentered: " + xCentered);
			return translateX(xCentered);
		}

		public override function latToY(lat:Number):Number
		{
			var yCentered:Number;
			var scaleY:Number = 100;
			yCentered = lat;
			trace ("yCentered: " + yCentered);
			return translateY(yCentered);
		}
		
	}
}