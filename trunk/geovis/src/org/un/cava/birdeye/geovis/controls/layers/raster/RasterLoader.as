
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
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGraphic;
	import com.degrafa.Surface;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.BitmapFill;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	
	public class RasterLoader extends UIComponent implements IRaster
	{
		private var map:Map;
		
		private var bkSurface:Surface;
		private var _source:String = new String();
		private var original:BitmapData;
		
		private var _mask:IGraphic;
		private var _projection:String;
		
		[Inspectable(enumeration="Geographic,Lambert equal area,Mercator,Mollweide,WinkelTripel,Miller cylindrical,EckertIV,EckertVI,Goode,Sinsoidal,Robinson")]
		public function set projection(val:String):void
		{
			_projection = val;
		}

		public function set source(val:String):void
		{
			_source = val;
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
				try 
				{
					if (bkSurface != null)
					{
						bkSurface.transform.matrix = map.transform.matrix;
						bkSurface.visible = true;
					    dispatchEvent(new GeoCoreEvents(GeoCoreEvents.RASTER_COMPLETE));
					} else {
		 				var img:Loader = new Loader(); 
						img.contentLoaderInfo.addEventListener(Event.COMPLETE, imgHandler);
						img.load(new URLRequest(_source));  
					}
				} catch (e:Error)
				{
trace (e);
					dispatchEvent(new GeoCoreEvents(GeoCoreEvents.NO_RASTER));
				}
			} else {
				dispatchEvent(new GeoCoreEvents(GeoCoreEvents.NO_RASTER));
				if (bkSurface != null)
				{
					bkSurface.visible = false;
				}
			}
		}

		private function imgHandler(e:Event):void
		{
			try
			{
			 	var bmd:BitmapData = Bitmap(e.target.content).bitmapData; 
			 				
			 	var originalWidth:Number = bmd.width;
			 	var originalHeight:Number = bmd.height;
			 	var scaleX:Number = map.unscaledMapWidth/originalWidth;
			 	var scaleY:Number = map.unscaledMapHeight/originalHeight; 
			 	

			 	var m:Matrix = new Matrix();
			 	m = map.transform.matrix;
			 	m.scale(scaleX,scaleY);
			 	m.translate(0,-7);
				
				if (original != null)
					original.dispose();
			 	original = new BitmapData(map.unscaledMapWidth, map.unscaledMapHeight); 
			 	original.draw(bmd,m);
	
				var bmp:Bitmap = new Bitmap(original,PixelSnapping.ALWAYS,true);
			    var imgFill:BitmapFill = new BitmapFill(bmp);
	
				bkSurface = new Surface();
				var bkGeomGroup:GeometryGroup = new GeometryGroup();
				var bkPoly:RegularRectangle = 
			    	new RegularRectangle(0,0,map.unscaledMapWidth, map.unscaledMapHeight);
			    bkPoly.fill = imgFill;
			    bkGeomGroup.geometryCollection.addItem(bkPoly);
			    bkSurface.graphicsCollection.addItem(bkGeomGroup);
			    bkGeomGroup.target = bkSurface;
			    
			    addChild(bkSurface);
			    
			    bkSurface.mask = createMask(map.mask);

				map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, update);
				map.addEventListener(MapEvent.MAP_MOVING, update);
			    map.addEventListener(MapEvent.MAP_CENTERED, update);
			    dispatchEvent(new GeoCoreEvents(GeoCoreEvents.RASTER_COMPLETE));
			} catch (e:Error) {
trace (e);
				dispatchEvent(new GeoCoreEvents(GeoCoreEvents.NO_RASTER));
			}
		}
		
		public function createMask(geoMask:DisplayObject):DisplayObject
		{
			var msk:Shape;
			if (geoMask != null)
			{
			    msk = new Shape();
				msk.graphics.moveTo(0,0);
				msk.graphics.beginFill(0xffffff, 0);
				msk.graphics.drawRect(0,0,geoMask.width,geoMask.height);
				msk.graphics.endFill();

			    var mskCont:UIComponent = new UIComponent();
			    mskCont.addChild(msk);
				mskCont.setActualSize(geoMask.width, geoMask.height);
				mskCont.move(0,0);
			    this.addChildAt(mskCont,0);
			}
			return msk;
		}
		
		private function update(e:MapEvent):void
		{
			map = Map(e.target);
			if (_projection == map.projection)
			{
				bkSurface.transform.matrix = map.transform.matrix;
				if (map.zoom > 4)
					bkSurface.visible = false
				else
					bkSurface.visible = true;
			}
		}
	}
}