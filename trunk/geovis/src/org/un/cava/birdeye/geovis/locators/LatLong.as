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
	import org.un.cava.birdeye.geovis.transformations.Transformation;
	import org.un.cava.birdeye.geovis.transformations.USGeographicTransformation;
	import org.un.cava.birdeye.geovis.transformations.WorldGeographicTransformation;
	import org.un.cava.birdeye.geovis.transformations.MollweideTransformation;
	import org.un.cava.birdeye.geovis.transformations.WinkelTripelTransformation;
	import org.un.cava.birdeye.geovis.transformations.MillerTransformation;
	import org.un.cava.birdeye.geovis.transformations.EckertIVTransformation;
	import org.un.cava.birdeye.geovis.transformations.EckertVITransformation;
	import org.un.cava.birdeye.geovis.transformations.RobinsonTransformation;
	import org.un.cava.birdeye.geovis.transformations.SinusoidalTransformation;
	import org.un.cava.birdeye.geovis.transformations.LambertTransformation;

	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import mx.events.FlexEvent;
	import mx.containers.Canvas;
	
	/**
	* Class for geographic location referencing via latitude and longitude
	**/

	[Inspectable("long")] 
	[Inspectable("lat")] 
	[Inspectable("xval")] 
	[Inspectable("yval")] 
	//This class is intended to be overridden. Inheriting classes should implement the functions calculateX and calculateY
	public class LatLong extends Canvas//UIComponent
	{
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------

		private var _long:Number=0; //longitude in radians
		private var _lat:Number=0;	//latitude in radians
		private var _xval:Number=0;	//x value calculated from long and lat
		private var _yval:Number=0; //y value calculated from long and lat
			            
		//--------------------------------------------------------------------------
    	//
    	//  Constructors
    	//
    	//--------------------------------------------------------------------------

		public function LatLong(lat:Number, long:Number, target:Object)
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.long = long;
			this.lat = lat;
			
			var dynamicClassName:String = getQualifiedClassName(target);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			var proj:String = (target as dynamicClassRef).projection;			
			trace ("proj: " + proj);
			var transf:Transformation = initTransformation(lat, long, proj);
			
			transf.scaleX = (target as dynamicClassRef).scaleX;
			transf.scaleY = (target as dynamicClassRef).scaleY;
			trace ("scaleX: " + (target as dynamicClassRef).scaleX);
			trace ("scaleY: " + (target as dynamicClassRef).scaleY);

			this.xval = transf.calculateX();
			this.yval = transf.calculateY();
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Functions for transforming lat and long to x and y
    	//
    	//--------------------------------------------------------------------------
		public function initTransformation(lat:Number, long:Number, projection:String):Transformation
		{
			var t:Transformation;
			if (projection == "Geographic") {
				t = new WorldGeographicTransformation(long,lat);
			} else if (projection == "Mollweide") {
				t = new MollweideTransformation(long,lat);
			} else if (projection == "WinkelTripel") {
				t = new WinkelTripelTransformation(long,lat);
			} else if (projection == "Miller cylindrical") {
				t = new MillerTransformation(long,lat);
			} else if (projection == "EckertIV") {
				t = new EckertIVTransformation(long,lat);
			} else if (projection == "EckertVI") {
				t = new EckertVITransformation(long,lat);
			} else if (projection == "Robinson") {
				t = new RobinsonTransformation(long,lat);
			} else if (projection == "Sinsoidal") {
				t = new SinusoidalTransformation(long,lat);
			} else if (projection == "Lambert equal area") {
				t = new LambertTransformation(long,lat);
			} else if (projection == "Goode") {
				if (Math.abs(lat) >= 0.710930782){
					t = new MollweideTransformation(long, lat);
					t.scalefactor = 131;
					t.xscaler = 1.05;
					t.xoffset = 3.16;
					t.yoffset = 1.36;
				} else {
					t = new SinusoidalTransformation(long, lat);
					t.scalefactor = 138;
					t.xscaler = 0;
					t.xoffset = 3;
					t.yoffset = 1.31;
				}
			}
			return t;
		}

		//--------------------------------------------------------------------------
    	//
    	//  Setters and getters
    	//
    	//--------------------------------------------------------------------------

		protected function set long(value:Number):void{
			_long=value;
		}
		
		protected function get long():Number{
			return _long;
		}
		
		protected function set lat(value:Number):void{
			_lat=value;
		}

		protected function get lat():Number{
			return _lat;
		}
		
		public function set xval(value:Number):void{
			_xval=value;
		}

		public function get xval():Number{
			return _xval;
		}
		
		public function set yval(value:Number):void{
			_yval=value;
		}

		public function get yval():Number{
			return _yval;
		}

		//--------------------------------------------------------------------------
    	//
    	//  Functions for this canvas
    	//
    	//--------------------------------------------------------------------------
		
		/**
	     *  @private
	     */
		private function creationCompleteHandler (event:FlexEvent):void {
		
			this.x=this.xval;
			this.y=this.yval;		
					
			Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
		}	
		
		
		/**
	     *  @private
	     */
		private function handleClickEvent(eventObj:MouseEvent):void {
			eventObj.stopPropagation()
		}
	}
}