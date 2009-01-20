package org.un.cava.birdeye.geovis.controls.layers.raster
{
	import com.degrafa.GeometryGroup;
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
						visible = true;
					} else {
		 				var img:Loader = new Loader(); 
						img.contentLoaderInfo.addEventListener(Event.COMPLETE, imgHandler);
						img.load(new URLRequest(_source));  
					}
				} catch (e:Error)
				{
trace (e);
				}
			} else {
				if (bkSurface != null)
				{
					visible = false;
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
			    
			    var mapMask:DisplayObject = DisplayObject(map.mask);
			    var msk:Shape = new Shape();
				msk.graphics.moveTo(0,0);
				msk.graphics.beginFill(0xffffff, 0);
				msk.graphics.drawRect(0,0,mapMask.width,mapMask.height);
				msk.graphics.endFill();

			    var mskCont:UIComponent = new UIComponent();
			    mskCont.addChild(msk);
				mskCont.setActualSize(mapMask.width, mapMask.height);
				mskCont.move(0,0);
			    this.addChildAt(mskCont,0);
			    bkSurface.mask = msk;

				map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, update);
				map.addEventListener(MapEvent.MAP_MOVING, update);
			    map.addEventListener(MapEvent.MAP_CENTERED, update);
			    dispatchEvent(new GeoCoreEvents(GeoCoreEvents.RASTER_COMPLETE));
			} catch (e:Error) {
trace (e);
			}
		}
		
		private function update(e:MapEvent):void
		{
			map = Map(e.target);
			if (_projection == map.projection)
			{
				bkSurface.transform.matrix = map.transform.matrix;
				if (map.zoom > 4)
					visible = false
				else
					visible = true;
			}
		}
	}
}