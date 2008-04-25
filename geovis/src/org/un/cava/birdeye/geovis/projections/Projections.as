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

package org.un.cava.birdeye.geovis.projections
{
	import org.un.cava.birdeye.geovis.projections.world.*;
	import org.un.cava.birdeye.geovis.projections.usa.*;
	import mx.controls.Alert;
	[ExcludeClass]
	/**
	* A map projection is any method used in cartography to represent the two-dimensional 
	* curved surface of the earth or other body on a plane.  The Projection class selects the
	* geographic data set for computed coordinate models.
	**/
	public class Projections
	{
		public static function getData(proj:String, region:String):Object{
			var GeoData:Object;
			if(region=="World" || region=="Africa" || region=="NorthAmerica" || region=="SouthAmerica" || region=="Asia" || region=="Europe" || region=="Oceania" || region=="Antartica" || region=="CIS" || region=="NorthAfrica" || region=="SubSahara" || region=="EasternAsia" || region=="SouthernAsia" || region=="SouthEasternAsia" || region=="WesternAsia"){
				if(proj=="Geographic"){
					GeoData = new org.un.cava.birdeye.geovis.projections.world.Geographic();
				}else if(proj=="Lambert equal area"){
					GeoData = new LambertEqualArea();
				}else if(proj=="Mercator"){
					GeoData = new Mercator();
				}else if(proj=="Mollweide"){
					GeoData = new Mollweide();
				}else if(proj=="Miller cylindrical"){
					GeoData = new MillerCylindrical();
				}else if(proj=="WinkelTripel"){
					GeoData = new WinkelTripel();
				}else if(proj=="EckertIV"){
					GeoData = new EckertIV();
				}else if(proj=="EckertVI"){
					GeoData = new EckertVI();
				}else if(proj=="Goode"){
					GeoData = new Goode();
				}else if(proj=="Sinsoidal"){
					GeoData = new Sinsoidal();
				}else if(proj=="Robinson"){
					GeoData = new Robinson();
				//}else{
					//GeoData = new WorldCountriesData();
				}
			}else if(region=="USA"){
				
				if(proj=="Geographic"){
					GeoData = new org.un.cava.birdeye.geovis.projections.usa.Geographic();
				}
			
			}
			return GeoData;
		}

	}
}