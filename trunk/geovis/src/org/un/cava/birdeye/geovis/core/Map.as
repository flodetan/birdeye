package org.un.cava.birdeye.geovis.core
{
	import com.degrafa.Surface;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.controls.HSlider;
	import mx.controls.VSlider;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.events.MapEvent;

	public class Map extends Surface
	{
		// the surface of GeoFrame representing the map 
		// shall be a separate object with his own methods (zoomMap, center...) 
		// and properties (zoom, posX, currentCenterX...)
		
		// when clicking on toolBar buttons, the related map listeners will be triggered.
		// than, when clicking on the map, these listeners will trigger the related action
		// to be performed
		
		// the map surface, together with unscaledWidth and unscaledHeight of the canvas are passed to 
		// the MainViewToolbarPanel through the Canvas(event.target)
		public function Map()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, notifyMapReady);
		}
		
		private function notifyMapReady(e:Event):void
		{
			dispatchEvent(new MapEvent(MapEvent.MAP_INSTANTIATED));
		}
		
		private var _unscaledMapWidth:Number = 917.65; //1190.5511;
		private var _unscaledMapHeight:Number = 478.5; //841.8898;
		
		public function get unscaledMapWidth():Number
		{
				return _unscaledMapWidth;
		}

		public function get unscaledMapHeight():Number
		{
				return _unscaledMapHeight;
		}
			
		private var _zoomInSelected:Boolean = false;
		private var _zoomOutSelected:Boolean = false;
		private var _dragSelected:Boolean = false;
		private var _centeringMapSelected:Boolean = false; 
		private var _wheelZoomSelected:Boolean = false;
		private var _skewMapVerticallySelected:Boolean = false;
		private var _skewMapHorizontallySelected:Boolean = false;
		
		public function get zoomInSelected():Boolean
		{
			return _zoomInSelected;
		}
		
		public function get zoomOutSelected():Boolean
		{
			return _zoomOutSelected;
		}

		public function get dragSelected():Boolean
		{
			return _dragSelected;
		}
		
		public function get centeringMapSelected():Boolean
		{
			return _centeringMapSelected;
		}
		
		public function get wheelZoomSelected():Boolean
		{
			return _wheelZoomSelected;
		}
		
		public function get skewMapVerticallySelected():Boolean
		{
			return _skewMapVerticallySelected;
		}

		public function get skewMapHorizontallySelected():Boolean
		{
			return _skewMapHorizontallySelected;
		}

		public function set zoomInSelected(val:Boolean):void
		{
			_zoomInSelected = val;
			if (val)
			{
				zoomOutSelected = false;
				centeringMapSelected = false;
				addEventListener(MouseEvent.DOUBLE_CLICK, zoomDoubleClickMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.DOUBLE_CLICK, zoomDoubleClickMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}
		
		public function set zoomOutSelected(val:Boolean):void
		{
			_zoomOutSelected = val;
			if (val)
			{
				zoomInSelected = false;
				centeringMapSelected = false;
				addEventListener(MouseEvent.DOUBLE_CLICK, zoomDoubleClickMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.DOUBLE_CLICK, zoomDoubleClickMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		public function set dragSelected(val:Boolean):void
		{
			_dragSelected = val;
			if (val)
			{
				addEventListener(MouseEvent.MOUSE_DOWN, startMovingMap);
				addEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, startMovingMap);
				removeEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		public function set centeringMapSelected(val:Boolean):void
		{
			_centeringMapSelected = val;
			if (val)
			{
				zoomInSelected = false;
				zoomOutSelected = false;
				addEventListener(MouseEvent.DOUBLE_CLICK, centerMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.DOUBLE_CLICK, centerMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		public function set wheelZoomSelected(val:Boolean):void
		{
			_wheelZoomSelected = val;
			if (val)
			{
				skewMapVerticallySelected = false;
				skewMapHorizontallySelected = false;
				addEventListener(MouseEvent.MOUSE_WHEEL, zoomWheelMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_WHEEL, zoomWheelMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		public function set skewMapVerticallySelected(val:Boolean):void
		{
			_skewMapVerticallySelected = val;
			if (val)
			{
				wheelZoomSelected = false;
				skewMapHorizontallySelected = false;
				addEventListener(MouseEvent.MOUSE_WHEEL, skewMapVertically);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_WHEEL, skewMapVertically);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		public function set skewMapHorizontallySelected(val:Boolean):void
		{
			_skewMapHorizontallySelected = val;
			if (val)
			{
				wheelZoomSelected = false;
				skewMapVerticallySelected = false;
				addEventListener(MouseEvent.MOUSE_WHEEL, skewMapHorizontally);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_WHEEL, skewMapHorizontally);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		private var _zoom:Number=1;

		public function set zoom(value:Number):void
		{
			dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_CHANGED));
			_zoom=value;
		}
	
		public function get zoom():Number
		{
				return _zoom;
		}
	
	    override protected function createChildren():void
	    {
		    doubleClickEnabled = true;
		}
		
		override protected function measure():void
		{
			super.measure();
			minWidth = 150;
			minHeight = 100;
		}
		
	 	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
	
			if (isNaN(currentCenterX))
				currentCenterX = unscaledMapWidth/2; 
			if (isNaN(currentCenterY))
				currentCenterY = unscaledMapHeight/2;
		}
		
		private function skewMapVertically(e:MouseEvent):void
		{
			matr = transform.matrix;
			if (e.delta > 0)
				matr.b += .01;
			else 
				matr.b -= .01;
			
			transform.matrix = matr;
		}
		
		private function skewMapHorizontally(e:MouseEvent):void
		{
			matr = transform.matrix;
			if (e.delta > 0)
				matr.c += .01;
			else 
				matr.c -= .01;

			transform.matrix = matr;
		}
		
		private function zoomDoubleClickMap(e:MouseEvent):void
		{
			if (zoomOutSelected)
				zoomMap(.5, new Point(mouseX, mouseY));
			else if (zoomInSelected)
				zoomMap(2, new Point(mouseX, mouseY));
				
			dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_DOUBLECLICK));
		}
	    
	    private var currentCenterX:Number=NaN, currentCenterY:Number=NaN;
	    public function centerMap(e:MouseEvent):void
	    {
	    	currentCenterX = mouseX;
	    	currentCenterY = mouseY;
	    	x = (parent.width/2 - mouseX * _zoom);
	    	y = (parent.height/2 - mouseY * _zoom);
	    	dispatchEvent(new MapEvent(MapEvent.MAP_CENTERED));
	    }
	    
	    private var offsetX:Number, offsetY:Number;
	    public function startMovingMap(e:MouseEvent):void
	    {
	    	offsetX = e.stageX - x;
	    	offsetY = e.stageY - y;
	    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMap);
	    	parent.addEventListener(MouseEvent.ROLL_OUT, stopMovingMap);
	    	dispatchEvent(new MapEvent(MapEvent.MAP_DRAG_START));
	    }
	    
	    public function stopMovingMap(e:MouseEvent):void
	    {
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMap)
	  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
	    	parent.removeEventListener(MouseEvent.ROLL_OUT, stopMovingMap);
	    	dispatchEvent(new MapEvent(MapEvent.MAP_DRAG_COMPLETE));
	    }
	    
	    public function dragMap(e:MouseEvent):void
	    {
	    	x = e.stageX - offsetX;
	    	y = e.stageY - offsetY;
	    	e.updateAfterEvent();
	    }
	
		private var zoomSlider:VSlider;
		public function zoomingWithSlider(e:Event):void
		{
			var zoomValue:Number, sliderValue:Number;
			if (e.target is VSlider)
				sliderValue = Number(VSlider(e.target).value);
			else if (e.target is HSlider)
				{
					sliderValue = Number(HSlider(e.target).value);
				} else
					return

	trace (currentCenterX, currentCenterY);
			if (sliderValue > _zoom)
				zoomValue = 1 + (sliderValue - _zoom)/_zoom;
			else
				zoomValue = 1 - (_zoom - sliderValue )/_zoom;
	
			zoomMap(zoomValue, new Point(currentCenterX, currentCenterY));
			dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_SLIDER));
		}
		
	    public function zoomWheelMap(e:MouseEvent):void
	    {
	    	var value:Number;
	    	if (e.delta > 0)
	    		value = 1.1
	    	else
	    		value = .9
	
	    	zoomMap(value, new Point(mouseX, mouseY));
	    	dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_WHEEL));
	    }
	    
	    private var matr:Matrix = new Matrix();
	    public function zoomMap(zoomValue:Number, regPoint:Point):void
	    {
	    	// the absolute distance of the surface origins (0,0) from the the origins 
	    	// (0,0) of its parent canvas (i.e. this)  
	    	var globOrgPoint:Point = localToContent(new Point(x, y));
	    	
trace (regPoint, _zoom); 
	    	// regPoint*_zoom calculates the global absolute distance 
	    	// from the regPoint to the (0,0) of the surface
		    var moveX:int = regPoint.x * _zoom + globOrgPoint.x;
		    var moveY:int = regPoint.y * _zoom + globOrgPoint.y;
	
		    _zoom *= zoomValue;
	
	  		matr = transform.matrix; 
	  		// position the mouse point to the (0,0) of the canvas (this)
			matr.translate(-moveX, -moveY);
	    	// scale the surface to the new zoom value
	    	matr.scale(zoomValue, zoomValue);
	    	// add the moveX/Y values to the new surface position
		    matr.translate(moveX, moveY);
		    // apply matrix transformation
	 	    transform.matrix = matr;
	 	    
	 	    dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_COMPLETE));
	
		    // dispatch zoomed map event and differentiate between in/out
	     }
	}
}