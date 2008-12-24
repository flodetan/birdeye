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
 
package org.un.cava.birdeye.geovis.views.toolbars
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;

	public class MainViewToolbarPanel extends Panel
	{
		private var myRestoreHeight:int;
		private var isMinimized:Boolean = false; 

		// Offset positions used when moving the toolbar on dragging/dropping
	    private var offsetX:Number, offsetY:Number;
	    // Keep the starting point position when dragging, if mouse goes out of the parents' view
	    // than the toolbar will be repositioned to this point
	    private var startDraggingPoint:Point;

		// Add the creationCOmplete event handler.
		public function MainViewToolbarPanel()
		{
			super();
		    isCenteringMap = new CheckBox();
		    isCenteringMap.label = CENTER;
		    isCenteringMap.blendMode = BlendMode.ADD;
		    isCenteringMap.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    isCenteringMap.y = 15;
		    addChild(isCenteringMap);
		    
		    zoomOut = new CheckBox();
		    zoomOut.label = ZOOM_OUT;
		    zoomOut.blendMode = BlendMode.ADD;
		    zoomOut.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    addChild(zoomOut);
	
		    zoomIn = new CheckBox();
		    zoomIn.label = ZOOM_IN;
		    zoomIn.blendMode = BlendMode.ADD;
		    zoomIn.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    addChild(zoomIn);
	
		    wheelZoom = new CheckBox();
		    wheelZoom.label = WHEEL_ZOOM;
		    wheelZoom.blendMode = BlendMode.ADD;
		    wheelZoom.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    addChild(wheelZoom);
	
		    dragBox = new CheckBox();
		    dragBox.label = DRAG_MAP;
		    dragBox.blendMode = BlendMode.ADD;
		    dragBox.addEventListener(Event.CHANGE, toolbarListenersHandler);
		    addChild(dragBox);
	
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		private var isCenteringMap:CheckBox;
		private var zoomOut:CheckBox;
		private var zoomIn:CheckBox;
		private var wheelZoom:CheckBox;
		private var dragBox:CheckBox;
		
		private function creationCompleteHandler(event:Event):void
		{
			// Add the resizing event handler.
 			this.doubleClickEnabled = true;
			titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, resizeToolbar);
			addEventListener(MouseEvent.MOUSE_DOWN, moveToolbar);
			map = Map(Canvas(parent).getChildByName("Surface")); 
			registerMapListeners();
			
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
				height = titleBar.height;
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
	  		addEventListener(MouseEvent.MOUSE_UP, stopMovingToolBar);
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
	    
	    private var map:Map;
		static private const CENTER:String = "center";
		static private const ZOOM_OUT:String = "zoom out";
		static private const ZOOM_IN:String = "zoom in";
		static private const WHEEL_ZOOM:String = "wheel";
		static private const DRAG_MAP:String = "drag map";
		private function toolbarListenersHandler(e:Event):void
		{
			var selectedTool:String = Button(e.target).label; 
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
		}
		
		private function registerMapListeners():void
		{
			map.addEventListener(MapEvent.MAP_PROPERTY_ON, updateBoxValue);
		}
	}
}