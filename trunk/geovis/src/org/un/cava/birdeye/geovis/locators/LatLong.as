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
//	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
//	import flash.utils.getDefinitionByName;
//	import flash.utils.getQualifiedClassName;
	
//	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.containers.Canvas;
	
//	import org.un.cava.birdeye.geovis.projections.Projections;
//	import org.un.cava.birdeye.qavis.sparklines.*;

	/**
	* Class for geographic location referencing via latitude and longitude
	**/
	 
	public class LatLong extends Canvas//UIComponent
	{
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */

		private var _long:Number=0;
		private var _lat:Number=0;
		private var _xval:Number=0;
		private var _yval:Number=0;
		private var _scalefactor:Number=1;
		private var _xscaler:Number=1;
		private var _xoffset:Number=0;
		private var _yoffset:Number=0;
		
		/**
	     *  @private
	     */
//		private var _isRemove:Boolean=false;
		
		/**
	     *  @private
	     */
//		private var geom:GeometryGroup;
		
		/**
	     *  @private
	     */
//		private var objToDel:DisplayObject;
		            
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------
		public function LatLong(long:Number,lat:Number)
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		public function longToX(long:Number):Number
		{
			return 0;
		}

		public function latToY(lat:Number):Number
		{
			return 0;
		}
		
		public function translateX(xCentered:Number):Number
		{
			trace("_scalefactor: " + _scalefactor);
			return (_xoffset+xCentered)*_scalefactor;
		}

		public function translateY(yCentered:Number):Number
		{
			return (_yoffset-yCentered)*_scalefactor;
		}

    	//----------------------------------
	    //  long and lat define the position of the child of LatLong
	    //----------------------------------

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
		
		protected function set xval(value:Number):void{
			_xval=value;
		}

		protected function get xval():Number{
			return _xval;
		}
		
		protected function set yval(value:Number):void{
			_yval=value;
		}

		protected function get yval():Number{
			return _yval;
		}

		public function set scalefactor(value:Number):void{
			_scalefactor=value;
			trace ("_scalefactor set to value: " + value);
		}
		
		public function get scalefactor():Number{
			return _scalefactor;
		}
		
		public function set xscaler(value:Number):void{
			_xscaler=value;
		}
		
		public function get xscaler():Number{
			return _xscaler;
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
		
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		
		/**
	     *  @private
	     */
		private function creationCompleteHandler (event:FlexEvent):void{
		
			this.x=longToX(this.long);
			this.y=latToY(this.lat);		
					
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