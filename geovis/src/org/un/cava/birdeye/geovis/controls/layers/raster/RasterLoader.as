
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
package org.un.cava.birdeye.geovis.controls.layers.raster
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	
	import mx.controls.Image;
	import mx.core.Application;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	
	public class RasterLoader extends Image implements IRaster
	{
		private var map:Map;
		
		private var _projection:String;
		private var _memVisibility:Boolean = true;
		
		[Inspectable(enumeration="Geographic,Lambert equal area,Mercator,Mollweide,WinkelTripel,Miller cylindrical,EckertIV,EckertVI,Goode,Sinsoidal,Robinson")]
		public function set projection(val:String):void
		{
			_projection = val;
		}
		
		override public function set visible(value:Boolean):void
		{
			_memVisibility = value;
			if (map != null && map.projection == _projection)
				super.visible = value;
		}

		public function RasterLoader()
		{
			Application.application.addEventListener(MapEvent.MAP_CHANGED,init,true);
		}
		
		private function init(e:MapEvent):void
		{
			map = Map(e.target); 
			if (map.projection == _projection)
			{
				if (source.toString().search("embed") == -1)
				{
					addEventListener(Event.COMPLETE, imgHandler);
					try {
						load(source);
					} catch (e:Error) {
						trace(e.message, e.getStackTrace());
						dispatchEvent(new GeoCoreEvents(GeoCoreEvents.NO_RASTER));
					}
					
				} else {
					imgHandler(e);
				}
				super.visible = _memVisibility; 
			} else {
				super.visible = false;
				dispatchEvent(new GeoCoreEvents(GeoCoreEvents.NO_RASTER));
			}
		}
		
		private var rappX:Number, rappY:Number;
		private function imgHandler(e:Event):void
		{
			removeEventListener(Event.COMPLETE, imgHandler);
		 	var originalWidth:Number = contentWidth;
		 	var originalHeight:Number = contentHeight;
		 	rappX = map.unscaledMapWidth/originalWidth;
		 	rappY = map.unscaledMapHeight/originalHeight; 
		 	
			updateSizeAndPosition();
			
			map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, update);
			map.addEventListener(MapEvent.MAP_MOVING, update);
		    map.addEventListener(MapEvent.MAP_CENTERED, update);
		    
		    dispatchEvent(new GeoCoreEvents(GeoCoreEvents.RASTER_COMPLETE));
		}
		
		private function update(e:MapEvent):void
		{
			map = Map(e.target);
			if (_projection == map.projection)
			{
				updateSizeAndPosition();
			}
		}
		
		private function updateSizeAndPosition():void
		{
		 	var m:Matrix = 	map.transform.matrix;

			scaleX = m.a*rappX;
			scaleY = m.d*rappY;
			x = map.x;
			y = map.y;
		}
	}
}