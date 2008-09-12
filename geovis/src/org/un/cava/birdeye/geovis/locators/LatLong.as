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

	import mx.events.FlexEvent;
	import mx.containers.Canvas;
	
	/**
	* Class for geographic location referencing via latitude and longitude
	**/

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
		private var _scalefactor:Number=1; //for zooming in to match the size of the map polygon
		private var _xscaler:Number=1; //temporary calibration variable, will be removed after calibration is done
		private var _xoffset:Number=0; //x-wise translation so that x=0 becomes the left end of the map
		private var _yoffset:Number=0; //y-wise translation so that y=0 becomes the upper end of the map
			            
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------
		public function LatLong()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		//--------------------------------------------------------------------------
	    //
	    //  Functions for transformation from lat and long to x and y
	    //
	    //--------------------------------------------------------------------------
	    
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
		
		protected function translateX(xCentered:Number):Number
		{
			return (_xoffset+xCentered)*_scalefactor;
		}

		protected function translateY(yCentered:Number):Number
		{
			return (_yoffset-yCentered)*_scalefactor;
		}

		//--------------------------------------------------------------------------
	    //
	    //  Setters and Getters
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

		public function set scalefactor(value:Number):void{
			_scalefactor=value;
		}
		
		public function get scalefactor():Number{
			return _scalefactor;
		}
		
		//xscaler is a temporary calibration variable, will be removed once calibration is done
		public function set xscaler(value:Number):void{
			_xscaler=value;
		}
		
		//xscaler is a temporary calibration variable, will be removed once calibration is done
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
    	//  Functions for this canvas
    	//
    	//--------------------------------------------------------------------------
		
		/**
	     *  @private
	     */
		private function creationCompleteHandler (event:FlexEvent):void{
		
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