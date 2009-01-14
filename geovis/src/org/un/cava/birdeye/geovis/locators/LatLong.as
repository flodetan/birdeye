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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.locators.Projector;
	
	/**
	* Class for geographic location referencing via latitude and longitude
	**/

	[Inspectable("long")] 
	[Inspectable("lat")] 
	[Inspectable("xval")] 
	[Inspectable("yval")] 
	
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
		private var _isCalculationPending:Boolean=true; 
		private var _isBaseMapComplete:Boolean=false;
			            
		//--------------------------------------------------------------------------
    	//
    	//  Constructors
    	//
    	//--------------------------------------------------------------------------

		public function LatLong()
		{
			super(); 
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
//			Application.application.addEventListener(GeoProjEvents.PROJECTION_CHANGED, projectionChangedHandler,true);
		}
		
/* 		private function projectionChangedHandler(e:Event):void
		{
			_isCalculationPending = true;
			creationCompleteHandler(e);
		}
 */		
		//--------------------------------------------------------------------------
    	//
    	//  Functions for transforming lat and long to x and y
    	//
    	//--------------------------------------------------------------------------
		public function calculateXY():void
		{
			//if _target has not been set, try using parent
			if (_target == null ) {
				_target = this.parent;
			}
			
			if (_target != null ) {
				//retrieve projection from _target and create a transformation for the projection
				var dynamicClassName:String = getQualifiedClassName(_target);
				var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
				var proj:String = (_target as dynamicClassRef).projection;		
				//retrieve scale factors from _target and calculate x and y
				var zoom:Number = Map.CREATION_ZOOM;//Map((_target as DisplayObjectContainer).getChildByName("Surface")).zoom;
				
				var xyval:Point = Projector.calcXY(_lat, _long, proj, zoom);
				_xval = xyval.x;
				_yval = xyval.y;
						
				//Remember that x and y now are calculated.
				_isCalculationPending = false; 
			} //TODO: Else throw an error			 
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
			if (_isCalculationPending) {
				calculateXY();
			}
			return _xval;
		}
		
		public function set yval(value:Number):void{
			_yval=value;
		}

		public function get yval():Number{
			if (_isCalculationPending) {
				calculateXY();
			}
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
		private function creationCompleteHandler (event:Event):void {
			if (_isCalculationPending) {
				calculateXY();
			}
			this.x = _xval-childWidth/2;
			this.y = _yval-childHeight/2;
			Surface((_target as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
			Application.application.addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, baseMapComplete, true);		
		}
		
		/**
	     *  @private
	     */
		private function handleClickEvent(eventObj:MouseEvent):void {
			eventObj.stopPropagation()
		}
		
		private function baseMapComplete(e:GeoCoreEvents):void{
        	_isBaseMapComplete=true;
			invalidateDisplayList();
		}

		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
			super.updateDisplayList( unscaledWidth, unscaledHeight );            
			if(_isBaseMapComplete){
				calculateXY();
				this.x = _xval-childWidth/2;
				this.y = _yval-childHeight/2;
				Surface((_target as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
				_isBaseMapComplete=false;
			}
		}

		override public function addChild(child:DisplayObject):DisplayObject {
			_childWidth = child.width;
			_childHeight = child.height;
			return super.addChild(child);
		}
	}
}