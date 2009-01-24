package org.un.cava.birdeye.geovis.core
{
	import com.degrafa.Surface;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.HSlider;
	import mx.controls.VSlider;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.locators.LatLong;

	 /**
	 * The Map class is responsible for managing the zooming and positioning 
	 * capabilities of the GeoFrame and provides methods (zoomMap, center...) 
	 * and properties (zoom, currentCenterX...) to perform different ways for zooming and positioning.
	 * Given the several possibilities offered by the map class for zooming and changing the position 
	 * of the map, it also controls the activation/deactivation of each feature.
	 * For example, similarly to a redlight, when selecting the ZOOM IN with a mouse double click, 
	 * if just before the double click was selected to perform a centering of the map, than the Map class 
	 * will switch off the double click listener for centering and will turn on the one for the zoom-in.
	 * Therefore when external viewers or toolbars select the feature ZOOM IN with double click, 
	 * the Map class will take care of resolving conflicts between the listeners.
	 * All actions performed using Map are notified through MapEvent events. External viewers can listen 
	 * to these events to update themselves.  
	*/
	public class Map extends Surface
	{
		public function Map()
		{
			super(); 
			Application.application.addEventListener(FlexEvent.APPLICATION_COMPLETE, notifyMapReady);
			
// to be changed in the future model
Application.application.addEventListener(GeoCoreEvents.RASTER_COMPLETE, raster, true);
Application.application.addEventListener(GeoCoreEvents.NO_RASTER, raster, true);
		}
		
		private var isMapReady:Boolean = false;
		private const no_raster:String = "no_raster"; 
		private const unknown:String = "unknown"; 
		private const raster_complete:String = "raster_complete";
		private var rasterFlag:String = unknown;
		private function raster(e:GeoCoreEvents):void
		{
			if (e.type == GeoCoreEvents.RASTER_COMPLETE)
				rasterFlag = raster_complete;
			else
				rasterFlag = no_raster;

			if (isMapReady)
				init(e);
		}
		
		private function notifyMapReady(e:Event):void
		{
			isMapReady = true;
			dispatchEvent(new MapEvent(MapEvent.MAP_INSTANTIATED));
			addEventListener(MapEvent.MAP_CHANGED, init);
			Application.application.removeEventListener(FlexEvent.APPLICATION_COMPLETE, notifyMapReady);
			
			
			if (rasterFlag != unknown)
				init(e);
		}
		
		private function init(e:Event):void
		{
			reset();
			rasterFlag = unknown;
			isMapReady = false;
		}
		
		private var _zoom:Number = CREATION_ZOOM;
		private var _defaultZoom:Number = 2;
		/**
		 * Used by all children of the GeoFrame to create themselves using a unique scaling reference,
		 * thus avoiding differences between them. Only used during the creation phase. It will be dismissed 
		 * with the new layered GeoFrame model
		*/
		public static const CREATION_ZOOM:Number = 1;

		private var _zoomInSelected:Boolean = false;
		private var _zoomOutSelected:Boolean = false;
		private var _dragSelected:Boolean = false;
		private var _centeringMapSelected:Boolean = false; 
		private var _wheelZoomSelected:Boolean = false;
		private var _skewMapVerticallySelected:Boolean = false;
		private var _skewMapHorizontallySelected:Boolean = false;
		private var _zoomRectangleSelected:Boolean = false;

		private var _projection:String;
		
		public function get zoom():Number
		{
				return _zoom;
		}

		/**
		 * This property updates the zoom value of the current map
		*/
		public function set zoom(value:Number):void
		{
			_zoom=value;
			dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_CHANGED));
		}
	
		/**
		 * This property sets the default zoom value that will be used each time the map is reset
		*/
		public function set defaultZoom(val:Number):void
		{
			_defaultZoom = val;
		}
		
		public function get projection():String
		{
			return _projection;
		}

		/**
		 * Set the name of the projection. When a new projection is set, the unscaled map sizes are recalculated
		*/
		public function set projection(val:String):void
		{
			_projection = val;
			updateUnscaledSize();
			dispatchEvent(new MapEvent(MapEvent.MAP_CHANGED));
		}
		
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

		public function get zoomRectangleSelected():Boolean
		{
			return _zoomRectangleSelected;
		}

		/**
		 * When this property is true, it activates the listeners for zooming in with a double click and remove
		 * the other double click listeners 
		*/
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
		
		/**
		 * When this property is true, it activates the listeners for zooming out with a double click and remove
		 * the other double click listeners 
		*/		
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

		/**
		 * When this property is true, it activates the listeners for dragging with a mouse down and remove
		 * the other mouse down listeners 
		*/		
		public function set dragSelected(val:Boolean):void
		{
			_dragSelected = val;
			if (val)
			{
				zoomRectangleSelected = false;
				addEventListener(MouseEvent.MOUSE_DOWN, startMovingMap);
				addEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, startMovingMap);
				removeEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		/**
		 * When this property is true, it activates the listeners for centering with a mouse double click and remove
		 * the other mouse double click listeners 
		*/		
		public function set centeringMapSelected(val:Boolean):void
		{
			_centeringMapSelected = val;
			if (val)
			{
				zoomInSelected = false;
				zoomOutSelected = false;
				addEventListener(MouseEvent.DOUBLE_CLICK, centerMapOnMouseEvent);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.DOUBLE_CLICK, centerMapOnMouseEvent);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		/**
		 * When this property is true, it activates the listeners for zooming in-out with the mouse wheeler 
		 * and remove the other mouse wheeler click listeners 
		*/		
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

		/**
		 * When this property is true, it activates the listeners for skewing vertically with the mouse wheeler 
		 * and remove the other mouse wheeler click listeners 
		*/		
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

		/**
		 * When this property is true, it activates the listeners for skewing horizontally with the mouse wheeler 
		 * and remove the other mouse wheeler click listeners 
		*/		
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
		
		/**
		 * When this property is true, it activates the listeners for zooming in with the mouse down
		 * and remove the other mouse down click listeners 
		*/		
		public function set zoomRectangleSelected(val:Boolean):void
		{
			_zoomRectangleSelected = val;
			if (val)
			{
				dragSelected = false;
				addEventListener(MouseEvent.MOUSE_DOWN, startRectangle);
				addEventListener(MouseEvent.MOUSE_UP, zoomOnRectangle);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_ON));
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, startRectangle);
				removeEventListener(MouseEvent.MOUSE_UP, zoomOnRectangle);
				dispatchEvent(new MapEvent(MapEvent.MAP_PROPERTY_OFF));
			}
		}

		/**
		 * @Private
		 * Enable double click
		*/		
	    override protected function createChildren():void
	    {
		    doubleClickEnabled = true;
		}
		
		/**
		 * @Private
		*/		
		override protected function measure():void
		{
			super.measure();
			minWidth = 150;
			minHeight = 100;
		}
		
		/**
		 * @Private
		*/
		private function updateUnscaledSize():void
		{ 
			var size:Rectangle = getBounds(this);
			width = size.width/_zoom;
			height = size.height/_zoom;
trace(size);
		}
		
		/**
		 * @Private
		 * Perform vertical skewing 
		*/
		private function skewMapVertically(e:MouseEvent):void
		{
			matr = transform.matrix;
			if (e.delta > 0)
				matr.b += .01;
			else 
				matr.b -= .01;
			
			transform.matrix = matr;
		}
		
		/**
		 * @Private
		 * Perform horizontal skewing 
		*/
		private function skewMapHorizontally(e:MouseEvent):void
		{
			matr = transform.matrix;
			if (e.delta > 0)
				matr.c += .01;
			else 
				matr.c -= .01;

			transform.matrix = matr;
		}
		
		/**
		 * @Private
		 * Perform zoom with double click 
		*/
		private function zoomDoubleClickMap(e:MouseEvent):void
		{
			if (zoomOutSelected)
				zoomMap(.5, new Point(mouseX, mouseY));
			else if (zoomInSelected)
				zoomMap(2, new Point(mouseX, mouseY));
				
			dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_DOUBLECLICK));
		}
	    
	    private var currentCenterX:Number=NaN, currentCenterY:Number=NaN;
	    private function centerMapOnMouseEvent(e:MouseEvent):void
	    {
	    	centerMap(new Point(mouseX, mouseY));
	    }
	    
		/**
		 * Center the map on a specific point 
		*/
	    public function centerMap(newCenter:Point):void
	    {
	    	x = (parent.width/2 - newCenter.x * _zoom);
	    	y = (parent.height/2 - newCenter.y * _zoom);
	    	currentCenterX = newCenter.x;
	    	currentCenterY = newCenter.y;
	    	dispatchEvent(new MapEvent(MapEvent.MAP_CENTERED));
	    }
	    
	    private var offsetX:Number, offsetY:Number;
		/**
		 * @Private 
		 * Starts map moving and trigger mouse move listener
		*/
	    private function startMovingMap(e:MouseEvent):void
	    {
	    	offsetX = e.stageX - x;
	    	offsetY = e.stageY - y;
	    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMap);
	    	parent.addEventListener(MouseEvent.ROLL_OUT, stopMovingMap);
	    	dispatchEvent(new MapEvent(MapEvent.MAP_DRAG_START));
	    }
	    
		/**
		 * @Private 
		 * Stop map moving 
		*/
	    private function stopMovingMap(e:MouseEvent):void
	    {
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMap)
	  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingMap);
	    	parent.removeEventListener(MouseEvent.ROLL_OUT, stopMovingMap);
	    	dispatchEvent(new MapEvent(MapEvent.MAP_DRAG_COMPLETE));
	    }
	    
		/**
		 * @Private 
		 * Move the map while the mouse moves 
		*/
	    private function dragMap(e:MouseEvent):void
	    {
	    	absoluteMoveMap(e.stageX - offsetX, e.stageY - offsetY);
	    	e.updateAfterEvent();
	    }
	    
		/**
		 * @Private 
		 * Move the origin point of the map to the specified x,y position
		*/
	    public function absoluteMoveMap(newX:Number, newY:Number):void
	    {
	    	x = newX;
	    	y = newY;
	    	dispatchEvent(new MapEvent(MapEvent.MAP_MOVING));
	    }
	
		/**
		 * @Private 
		 * Move the origin point of the map to the specified x,y position
		*/
	    public function relativeMoveMap(xMove:Number, yMove:Number):void
	    {
	    	x += xMove;
	    	y += yMove;
	    	dispatchEvent(new MapEvent(MapEvent.MAP_MOVING));
	    }

		private var zoomSlider:VSlider;
		/** 
		 * Zoom with sliders
		*/
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
		
		/**
		 * @Private 
		 * Zoom with the mouse wheeler
		*/
	    private function zoomWheelMap(e:MouseEvent):void
	    {
	    	var value:Number;
	    	if (e.delta > 0)
	    		value = 1.1
	    	else
	    		value = .9
	
	    	zoomMap(value, new Point(mouseX, mouseY));
	    	dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_WHEEL));
	    }
	    
	    private var rectLowerRightX:Number, rectLowerRightY:Number;
		/**
		 * @Private 
		 * Zoom in on a specified rectangle selected with the mouse
		*/
		private function zoomOnRectangle(e:MouseEvent):void
		{
			rectLowerRightX = this.mouseX;
			rectLowerRightY = this.mouseY;
			if (rectLowerRightX != rectUpperLeftX && rectLowerRightY != rectUpperLeftY)
				zoomMapRectangle(rectUpperLeftX, rectUpperLeftY, rectLowerRightX, rectLowerRightY);
			graphics.clear();
			removeEventListener(MouseEvent.MOUSE_MOVE, drawArea);
		}
		
	    private var rectUpperLeftX:Number, rectUpperLeftY:Number;
		/**
		 * @Private 
		 * Start the rectangle selection, used for the zoomOnRectangle
		*/
		private function startRectangle(e:MouseEvent):void
		{
			rectUpperLeftX = this.mouseX;
			rectUpperLeftY = this.mouseY;
			addEventListener(MouseEvent.MOUSE_MOVE, drawArea);
		}
		
		/**
		 * @Private 
		 * Draw the rectangle selection, used for the zoomOnRectangle
		*/
		private function drawArea(e:MouseEvent):void
		{
			graphics.clear();
			graphics.moveTo(rectUpperLeftX, rectUpperLeftY);
			graphics.beginFill(0xff0000, .3);
			graphics.drawRect(rectUpperLeftX, rectUpperLeftY, mouseX-rectUpperLeftX, mouseY - rectUpperLeftY);
			graphics.endFill();
		}
		
		/**
		 * Zoom on a specified lat-long rectangle
		*/
	    public function zoomMapLatLong(upperLeftLat:Number, upperLeftLong:Number, lowerRightLat:Number, lowerRightLong:Number):void
	    {
	    	var leftLatLong:LatLong = new LatLong();
	    	leftLatLong.lat = upperLeftLat;
	    	leftLatLong.long = upperLeftLong;
	    	leftLatLong.target = this.parent;
	    	
	    	var rightLatLong:LatLong = new LatLong();
	    	rightLatLong.lat = lowerRightLat;
	    	rightLatLong.long = lowerRightLong;
	    	rightLatLong.target = this.parent;
	    	
	    	leftLatLong.calculateXY();
	    	rightLatLong.calculateXY();
	    	
	    	zoomMapScaledRectangle(leftLatLong.xval, leftLatLong.yval, rightLatLong.xval, rightLatLong.yval);
	    }
	    
		/**
		 * @Private
		 * Zoom on a specified x,y rectangle (where x and y could be scaled)
		*/
	    private function zoomMapScaledRectangle(upperLeftX:Number, upperLeftY:Number, lowerRightX:Number, lowerRightY:Number):void
	    {
	    	// this has to be improved .....
	    	reset();
 	    	upperLeftX = upperLeftX / _zoom  * _defaultZoom;
	    	upperLeftY = upperLeftY / _zoom * _defaultZoom;
	    	lowerRightX = lowerRightX / _zoom * _defaultZoom;
	    	lowerRightY = lowerRightY / _zoom * _defaultZoom;

	    	zoomMapRectangle(upperLeftX, upperLeftY, lowerRightX, lowerRightY);
	    }
	    
		/**
		 * Zoom on a specified x,y based rectangle (where x and y are unscaled)
		*/
	    public function zoomMapRectangle(upperLeftX:Number, upperLeftY:Number, lowerRightX:Number, lowerRightY:Number):void
	    {
	    	var rect:Rectangle = new Rectangle(0, 0, Math.abs(upperLeftX-lowerRightX), Math.abs(upperLeftY-lowerRightY));
	    	var zoomValue:Number = Math.min(width/rect.width, height/rect.height);
	    	
	    	var centerPoint:Point = new Point(upperLeftX + (lowerRightX - upperLeftX)/2,
	    									upperLeftY + (lowerRightY - upperLeftY)/2);
	    	
		   	centerMap(centerPoint);
trace(centerPoint);
	    	zoomMap(1/_zoom,centerPoint); 
	    	zoomMap(zoomValue, centerPoint);
	    } 
	    
		/**
		 * Reset the map to the initial zooming and positioning, the zooming is based on defaultZoom
		 * and positioning is the center of the map
		*/
	    public function reset():void
	    {
	    	centerMap(new Point(width/2,height/2));
	    	zoomMap(1/_zoom * _defaultZoom, new Point(currentCenterX,currentCenterY));
	    }
	    
	    private var matr:Matrix = new Matrix();
		/**
		 * Zoom the map with a zoomValue on a specific point regPoint
		*/
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
	
		    zoom *= zoomValue;
	
	  		matr = transform.matrix; 
	  		// position the mouse point to the (0,0) of the canvas (this)
			matr.translate(-moveX, -moveY);
	    	// scale the surface to the new zoom value
	    	matr.scale(zoomValue, zoomValue);
	    	// add the moveX/Y values to the new surface position
		    matr.translate(moveX, moveY);
		    // apply matrix transformation
	 	    transform.matrix = matr;
	 	    
trace(matr.a, matr.d);
	 	    dispatchEvent(new MapEvent(MapEvent.MAP_ZOOM_COMPLETE));
	
		    // dispatch zoomed map event and differentiate between in/out
	     }
	}
}