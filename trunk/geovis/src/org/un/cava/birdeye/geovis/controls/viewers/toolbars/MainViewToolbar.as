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
 
package org.un.cava.birdeye.geovis.controls.viewers.toolbars
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.CheckBox;
	import mx.core.Application;
	import mx.core.LayoutContainer;
	
	import org.un.cava.birdeye.geovis.controls.viewers.toolbars.icons.*;
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;

	public class MainViewToolbar extends LayoutContainer implements IMainViewToolbar
	{
	    private var map:Map;

	    // Keep the starting point position when dragging, if mouse goes out of the parents' view
	    // than the toolbar will be repositioned to this point
	    private var startDraggingPoint:Point;
		private var myRestoreHeight:int;
		private var isMinimized:Boolean = false; 
		// Offset positions used when moving the toolbar on dragging/dropping
	    private var offsetX:Number, offsetY:Number;

		private var isCenteringMap:CheckBox;
		private var zoomOut:CheckBox;
		private var zoomIn:CheckBox;
		private var wheelZoom:CheckBox;
		private var dragBox:CheckBox;
		private var wheelSkewVertically:CheckBox;
		private var wheelSkewHorizontally:CheckBox;
		private var zoomRect:CheckBox;
		private var resetMap:CheckBox;

		static private const CENTER:String = "center";
		static private const ZOOM_OUT:String = "zoom out";
		static private const ZOOM_IN:String = "zoom in";
		static private const WHEEL_ZOOM:String = "wheel zoom";
		static private const DRAG_MAP:String = "drag map";
		static private const WHEEL_SKEW_VERTICALLY:String = "skew map V";
		static private const WHEEL_SKEW_HORIZONTALLY:String = "skew map H";
		static private const ZOOM_RECTANGLE:String = "zoom rectangle";
		static private const RESET_MAP:String = "reset map";

		public static const GREY:Number = 0x777777;
		public static const WHITE:Number = 0xffffff;
		public static const YELLOW:Number = 0xffd800;
		public static const RED:Number = 0xff0000;
		public static const BLUE:Number = 0x009cff;
		public static const GREEN:Number = 0x00ff54;
		public static const BLACK:Number = 0x000000;
		
		public static const size:Number = 15;
		public static const thick:Number = 2;

		private var _upIconColor:Number = GREY;
		private var _overIconColor:Number = YELLOW;
		private var _downIconColor:Number = RED;
		private var _selectedUpIconColor:Number = GREEN;
		private var _selectedOverIconColor:Number = GREY;
		private var _selectedDownIconColor:Number = BLUE;
		
		public function get upIconColor():Number
		{
			return _upIconColor;
		}

		public function set upIconColor(val:Number):void
		{
			_upIconColor = val;
		}

		public function get overIconColor():Number
		{
			return _overIconColor;
		}

		public function set overIconColor(val:Number):void
		{
			_overIconColor = val;
		}

		public function get downIconColor():Number
		{
			return _downIconColor;
		}

		public function set downIconColor(val:Number):void
		{
			_downIconColor = val;
		}

		public function get selectedUpIconColor():Number
		{
			return _selectedUpIconColor;
		}

		public function set selectedUpIconColor(val:Number):void
		{
			_selectedUpIconColor = val;
		}

		public function get selectedOverIconColor():Number
		{
			return _selectedOverIconColor;
		}

		public function set selectedOverIconColor(val:Number):void
		{
			_selectedOverIconColor = val;
		}

		public function get selectedDownIconColor():Number
		{
			return _selectedDownIconColor;
		}

		public function set selectedDownIconColor(val:Number):void
		{
			_selectedDownIconColor = val;
		}

		private var _draggable:Boolean = false;
		
		[Inspectable(enumeration="true,false")]
		public function set draggable(val:Boolean):void
		{
			_draggable = val;
		}

		// Add the creationCOmplete event handler.
		public function MainViewToolbar()
		{
			super();
			
		    isCenteringMap = new CheckBox();
		    isCenteringMap.name = CENTER;
		    isCenteringMap.width = isCenteringMap.height = IconsUtils.size;
		    isCenteringMap.setStyle("upIcon", CenteringMapIcon);
		    isCenteringMap.setStyle("selectedUpIcon", CenteringMapIcon);
		    isCenteringMap.setStyle("overIcon", CenteringMapIcon);
		    isCenteringMap.setStyle("downIcon", CenteringMapIcon);
		    isCenteringMap.setStyle("selectedOverIcon", CenteringMapIcon);
		    isCenteringMap.setStyle("selectedDownIcon", CenteringMapIcon);
		    isCenteringMap.blendMode = BlendMode.ADD;
		    isCenteringMap.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    isCenteringMap.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(isCenteringMap);
		    
		    zoomOut = new CheckBox();
		    zoomOut.name = ZOOM_OUT
		    zoomOut.width = zoomOut.height = IconsUtils.size;
		    zoomOut.setStyle("upIcon", ZoomOutIcon);
		    zoomOut.setStyle("selectedUpIcon", ZoomOutIcon);
		    zoomOut.setStyle("overIcon", ZoomOutIcon);
		    zoomOut.setStyle("downIcon", ZoomOutIcon);
		    zoomOut.setStyle("selectedOverIcon", ZoomOutIcon);
		    zoomOut.setStyle("selectedDownIcon", ZoomOutIcon);
		    zoomOut.blendMode = BlendMode.ADD;
		    zoomOut.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    zoomOut.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(zoomOut);
	
		    zoomIn = new CheckBox();
		    zoomIn.name = ZOOM_IN;
		    zoomIn.width = zoomIn.height = IconsUtils.size;
		    zoomIn.setStyle("upIcon", ZoomInIcon);
		    zoomIn.setStyle("selectedUpIcon", ZoomInIcon);
		    zoomIn.setStyle("overIcon", ZoomInIcon);
		    zoomIn.setStyle("downIcon", ZoomInIcon);
		    zoomIn.setStyle("selectedOverIcon", ZoomInIcon);
		    zoomIn.setStyle("selectedDownIcon", ZoomInIcon);
		    zoomIn.blendMode = BlendMode.ADD;
		    zoomIn.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    zoomIn.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(zoomIn);
	
		    wheelZoom = new CheckBox();
		    wheelZoom.name = WHEEL_ZOOM;
		    wheelZoom.width = wheelZoom.height = IconsUtils.size;
		    wheelZoom.setStyle("upIcon", WheelZoomIcon);
		    wheelZoom.setStyle("selectedUpIcon", WheelZoomIcon);
		    wheelZoom.setStyle("overIcon", WheelZoomIcon);
		    wheelZoom.setStyle("downIcon", WheelZoomIcon);
		    wheelZoom.setStyle("selectedOverIcon", WheelZoomIcon);
		    wheelZoom.setStyle("selectedDownIcon", WheelZoomIcon);
		    wheelZoom.blendMode = BlendMode.ADD;
		    wheelZoom.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    wheelZoom.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(wheelZoom);
	
		    dragBox = new CheckBox();
		    dragBox.name = DRAG_MAP;
		    dragBox.width = dragBox.height = IconsUtils.size;
		    dragBox.setStyle("upIcon", DragBox);
		    dragBox.setStyle("selectedUpIcon", DragBox);
		    dragBox.setStyle("overIcon", DragBox);
		    dragBox.setStyle("downIcon", DragBox);
		    dragBox.setStyle("selectedOverIcon", DragBox);
		    dragBox.setStyle("selectedDownIcon", DragBox);
		    dragBox.blendMode = BlendMode.ADD;
		    dragBox.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    dragBox.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(dragBox); 
	
		    wheelSkewVertically = new CheckBox();
		    wheelSkewVertically.name = WHEEL_SKEW_VERTICALLY;
		    wheelSkewVertically.width = wheelSkewVertically.height = IconsUtils.size;
		    wheelSkewVertically.setStyle("upIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.setStyle("selectedUpIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.setStyle("overIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.setStyle("downIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.setStyle("selectedOverIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.setStyle("selectedDownIcon", WheelSkewVerticallyIcon);
		    wheelSkewVertically.blendMode = BlendMode.ADD;
/* 		    wheelSkewVertically.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    wheelSkewVertically.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(wheelSkewVertically);
 */
		    wheelSkewHorizontally = new CheckBox();
		    wheelSkewHorizontally.name = WHEEL_SKEW_HORIZONTALLY;
		    wheelSkewHorizontally.width = wheelSkewHorizontally.height = IconsUtils.size;
		    wheelSkewHorizontally.setStyle("upIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.setStyle("selectedUpIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.setStyle("overIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.setStyle("downIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.setStyle("selectedOverIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.setStyle("selectedDownIcon", WheelSkewHorizontallyIcon);
		    wheelSkewHorizontally.blendMode = BlendMode.ADD;
/* 		    wheelSkewHorizontally.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    wheelSkewHorizontally.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(wheelSkewHorizontally);
 */
		    zoomRect = new CheckBox();
		    zoomRect.name = ZOOM_RECTANGLE;
		    zoomRect.width = zoomRect.height = IconsUtils.size;
		    zoomRect.setStyle("upIcon", ZoomRectangle);
		    zoomRect.setStyle("selectedUpIcon", ZoomRectangle);
		    zoomRect.setStyle("overIcon", ZoomRectangle);
		    zoomRect.setStyle("downIcon", ZoomRectangle);
		    zoomRect.setStyle("selectedOverIcon", ZoomRectangle);
		    zoomRect.setStyle("selectedDownIcon", ZoomRectangle);
		    zoomRect.blendMode = BlendMode.ADD;
		    zoomRect.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    zoomRect.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(zoomRect);

		    resetMap = new CheckBox();
		    resetMap.name = RESET_MAP;
		    resetMap.width = resetMap.height = IconsUtils.size;
		    resetMap.setStyle("upIcon", ResetMap);
		    resetMap.setStyle("selectedUpIcon", ResetMap);
		    resetMap.setStyle("overIcon", ResetMap);
		    resetMap.setStyle("downIcon", ResetMap);
		    resetMap.setStyle("selectedOverIcon", ResetMap);
		    resetMap.setStyle("selectedDownIcon", ResetMap);
		    resetMap.blendMode = BlendMode.ADD;
		    resetMap.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    resetMap.addEventListener(MouseEvent.MOUSE_OVER, tooltipHandler);
		    addChild(resetMap);

		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true)
		}
		
		private function init(event:Event):void
		{
			// Add the resizing event handler.
			map = Map(event.target);
 			this.doubleClickEnabled = true;
//uncomment if Panel is used instead			titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, resizeToolbar);
			if (_draggable)
				addEventListener(MouseEvent.MOUSE_DOWN, moveToolbar);
			registerMapListeners();
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
 		}
 		
		override protected function measure():void
		{
			super.measure();
			minWidth = IconsUtils.size * numChildren + 40;
			minHeight = IconsUtils.size + 10;
		}

 		private function getMap(e:MapEvent):void
 		{
 			map = Map(e.target);
 		}
		
		private function resizeToolbar(e:Event):void
		{
			if (isMinimized)
				restorePanelSizeHandler(e);
			else
				minPanelSizeHandler(e);
		}

		// Minimize panel event handler.
		private function minPanelSizeHandler(event:Event):void
		{
			if (!isMinimized)
			{
				myRestoreHeight = height;	
//uncomment if Panel is used instead				height = titleBar.height;
				isMinimized = true;	
			}				
		}
		
		// Restore panel event handler.
		private function restorePanelSizeHandler(event:Event):void
		{
			if (isMinimized)
			{
				height = myRestoreHeight;
				isMinimized = false;	
			}
		}

		// Resize panel event handler.
		public  function moveToolbar(event:MouseEvent):void
		{
	  		startMovingToolBar(event);
	  		stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingToolBar);
		}
		
		// Start moving the toolbar
	    private function startMovingToolBar(e:MouseEvent):void
	    {
	    	this.parent.addEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    	startDraggingPoint = new Point(this.x, this.y);
	    	offsetX = e.stageX - this.x;
	    	offsetY = e.stageY - this.y;
	    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragToolBar);
	    }
	    
	    // Reset the toolbar position to the starting point
	    private function resetToolBarPosition(e:MouseEvent):void
	    {
	    	stopMovingToolBar(e);
	    	this.x = startDraggingPoint.x;
	    	this.y = startDraggingPoint.y;
	    	this.parent.removeEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    }
	    
	    // Stop moving the toolbar 
	    private function stopMovingToolBar(e:MouseEvent):void
	    {
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragToolBar)
	  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingToolBar);
	    	this.parent.removeEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    }
	    
	    // Moving the toolbar while MOUSE_MOVE event is on
	    private function dragToolBar(e:MouseEvent):void
	    {
	    	this.x = e.stageX - offsetX;
	    	this.y = e.stageY - offsetY;
	    	e.updateAfterEvent();
	    	// dispatch moved toolbar event
	    }
	    
		private function toolbarListenersHandler(e:Event):void
		{
			var selectedTool:String = CheckBox(e.target).name; 
			switch (selectedTool)
			{
				case CENTER:
		  			map.centeringMapSelected = isCenteringMap.selected;
		  		break;
	  			case ZOOM_OUT:
		  			map.zoomOutSelected = zoomOut.selected;
		   		break;
		   		case ZOOM_IN:
		   			map.zoomInSelected = zoomIn.selected; 
		   		break;
		   		case WHEEL_ZOOM:
		   			map.wheelZoomSelected = wheelZoom.selected;
		   		break;
		   		case DRAG_MAP:
		   			map.dragSelected = dragBox.selected;
			    break;
		   		case WHEEL_SKEW_VERTICALLY:
		   			map.skewMapVerticallySelected = wheelSkewVertically.selected;
		   		break;
		   		case WHEEL_SKEW_HORIZONTALLY:
		   			map.skewMapHorizontallySelected = wheelSkewHorizontally.selected;
		   		break;
		   		case ZOOM_RECTANGLE:
		   			map.zoomRectangleSelected = zoomRect.selected;
		   		break;
		   		case RESET_MAP:
		   			map.reset();
		   			resetMap.selected = false;
		   		break;
	  		} 
		}
		
		private function tooltipHandler(e:MouseEvent):void
		{
			var selectedTool:String = CheckBox(e.target).name; 
			switch (selectedTool)
			{
				case CENTER:
					toolTip = "Double click to center the mouse point"
		  		break;
	  			case ZOOM_OUT:
	  				toolTip = "Double click to zoom out from the mouse point"
		   		break;
		   		case ZOOM_IN:
	  				toolTip = "Double click to zoom the mouse point"
		   		break;
		   		case WHEEL_ZOOM:
	  				toolTip = "Use mouse wheel to zoom in/out the mouse point"
		   		break;
		   		case DRAG_MAP:
	  				toolTip = "Click and drag the map"
			    break;
		   		case WHEEL_SKEW_VERTICALLY:
	  				toolTip = "Use mouse wheel to skew the map vertically"
		   		break;
		   		case WHEEL_SKEW_HORIZONTALLY:
	  				toolTip = "Use mouse wheel to skew the map horizontally"
		   		break;
		   		case ZOOM_RECTANGLE:
	  				toolTip = "Select a map area to zoom it"
		   		break;
		   		case RESET_MAP:
	  				toolTip = "Reset map to its original position and scale"
		   		break;
	  		} 
		}

		private function updateBoxValue(e:MapEvent):void
		{
			map = Map(e.target);
			isCenteringMap.selected = map.centeringMapSelected;
			dragBox.selected = map.dragSelected;
			zoomIn.selected = map.zoomInSelected;
			zoomOut.selected = map.zoomOutSelected;
			wheelZoom.selected = map.wheelZoomSelected;
			wheelSkewVertically.selected = map.skewMapVerticallySelected;
			wheelSkewHorizontally.selected = map.skewMapHorizontallySelected;
			zoomRect.selected = map.zoomRectangleSelected;
		}
		
		private function registerMapListeners():void
		{
			map.addEventListener(MapEvent.MAP_PROPERTY_ON, updateBoxValue);
		}
	}
}