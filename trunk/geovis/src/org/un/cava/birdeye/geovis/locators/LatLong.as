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
	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.transformations.EckertIVTransformation;
	import org.un.cava.birdeye.geovis.transformations.EckertVITransformation;
	import org.un.cava.birdeye.geovis.transformations.LambertTransformation;
	import org.un.cava.birdeye.geovis.transformations.MillerTransformation;
	import org.un.cava.birdeye.geovis.transformations.MollweideTransformation;
	import org.un.cava.birdeye.geovis.transformations.RobinsonTransformation;
	import org.un.cava.birdeye.geovis.transformations.SinusoidalTransformation;
	import org.un.cava.birdeye.geovis.transformations.Transformation;
	import org.un.cava.birdeye.geovis.transformations.WinkelTripelTransformation;
	import org.un.cava.birdeye.geovis.transformations.WorldGeographicTransformation;
	
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
		private var _long:Number=0; //longitude in degrees
		private var _lat:Number=0;	//latitude in degrees
		private var _xval:Number=0;	//x value calculated from long and lat
		private var _yval:Number=0; //y value calculated from long and lat
		private var _target:Object; //myMap. Used for retrieving projection, scaleX and scaleY
		private var _childWidth:Number=0; //Optional. If set, the child UIComponent will be moved so that it's centered x-wise over the spot given by lat and long
		private var _childHeight:Number=0; //Optional. If set, the child UIComponent will be moved so that it's centered y-wise over the spot given by lat and long
			            
		//--------------------------------------------------------------------------
    	//
    	//  Constructors
    	//
    	//--------------------------------------------------------------------------

		public function LatLong()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Functions for transforming lat and long to x and y
    	//
    	//--------------------------------------------------------------------------
		public function calculateXY():void
		{
			//if _target has not been set, try using mom
			if (_target == null ) {
				_target = this.parent;
			}
			
			//retrieve projection from _target and create a transformation for the projection
			var dynamicClassName:String = getQualifiedClassName(_target);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			var proj:String = (_target as dynamicClassRef).projection;
			var transf:Transformation = createTransformation(_lat, _long, proj);
			
			//retrieve scale factors from _target and calculate x and y
			transf.scaleX = (_target as dynamicClassRef).scaleX;
			transf.scaleY = (_target as dynamicClassRef).scaleY;
			_xval = transf.calculateX();
			_yval = transf.calculateY();
		}

		public function createTransformation(lat:Number, long:Number, projection:String):Transformation
		{
			var t:Transformation;
			if (projection == "Geographic") {
				t = new WorldGeographicTransformation(lat,long);
			} else if (projection == "Mollweide") {
				t = new MollweideTransformation(lat,long);
			} else if (projection == "WinkelTripel") {
				t = new WinkelTripelTransformation(lat,long);
			} else if (projection == "Miller cylindrical") {
				t = new MillerTransformation(lat,long);
			} else if (projection == "EckertIV") {
				t = new EckertIVTransformation(lat,long);
			} else if (projection == "EckertVI") {
				t = new EckertVITransformation(lat,long);
			} else if (projection == "Robinson") {
				t = new RobinsonTransformation(lat,long);
			} else if (projection == "Sinsoidal") {
				t = new SinusoidalTransformation(lat,long);
			} else if (projection == "Lambert equal area") {
				t = new LambertTransformation(lat,long);
			} else if (projection == "Goode") {
				if (Math.abs(lat) >= 40.73333403){
					t = new MollweideTransformation(lat,long);
					(t as MollweideTransformation).setGoodeConstants();
				} else {
					t = new SinusoidalTransformation(lat,long);
					(t as SinusoidalTransformation).setGoodeConstants();
				}
			}
			return t;
		}

		//--------------------------------------------------------------------------
    	//
    	//  Setters and getters
    	//
    	//--------------------------------------------------------------------------

		public function set long(value:Number):void{
			_long=value;
		}
		
		public function get long():Number{
			return _long;
		}
		
		public function set lat(value:Number):void{
			_lat=value;
		}

		public function get lat():Number{
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
		
		public function set target(value:Object):void{
			_target=value;
		}

		public function get target():Object{
			return _target;
		}		

		public function set childWidth(value:Number):void{
			_childWidth=value;
		}

		public function get childWidth():Number{
			return _childWidth;
		}

		public function set childHeight(value:Number):void{
			_childHeight=value;
		}

		public function get childHeight():Number{
			return _childHeight;
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
			calculateXY();
			this.x=this.xval-childWidth/2;
			this.y=this.yval-childHeight/2;
				
			Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
		}
		
		/**
	     *  @private
	     */
		private function handleClickEvent(eventObj:MouseEvent):void {
			eventObj.stopPropagation()
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			_childWidth = child.width;
			_childHeight = child.height;
			return super.addChild(child);
		}
	}
}