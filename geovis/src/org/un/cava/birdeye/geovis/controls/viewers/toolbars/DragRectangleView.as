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
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;

	public class DragRectangleView extends UIComponent
	{
		private var rect:RectangleView;
		
		override public function set width(value:Number):void
		{
			super.width = value;
			invalidateProperties();
		}

		override public function set height(value:Number):void
		{
			super.height = value;
			invalidateProperties();
		}

		// Add the creationCOmplete event handler.
		public function DragRectangleView()
		{
			super();
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			rect = new RectangleView();
			
			var mask:Shape = new Shape();
			mask.graphics.moveTo(0,0);
			mask.graphics.beginFill(0xffffff,0);
			mask.graphics.drawRect(0,0,width,height);
			mask.graphics.endFill();
			
			addChild(mask);
			
			rect.mask = mask;

			addChild(rect);
			rect.addEventListener(RectangleView.DRAGGING, moveMap);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			rect.draw(width,height);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.moveTo(0,0);
			graphics.beginFill(RectUtils.RED,.2);
			graphics.drawRect(0,0,width,height);
			graphics.endFill();

			graphics.moveTo(2,2);
			graphics.beginFill(RectUtils.BLACK,.1);
			graphics.drawRect(2,2,width-4,height-4);
			graphics.endFill();
		}
		
		private function init(event:Event):void
		{
			// Add the resizing event handler.
			map = Map(event.target);
			rect.width = width/map.zoom;
			rect.height = height/map.zoom;
			var prop:Number = map.unscaledMapWidth / width;
			rect.x = Math.max(0,-map.x/map.zoom)/prop;
			rect.y = Math.max(0,-map.y/map.zoom)/prop;
			registerMapListeners();
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
 		}
 		
	    private var map:Map;
	    private function moveMap(e:Event):void
	    {
	    	var xPos:Number, yPos:Number;
	    	xPos = RectangleView(e.target).x;
	    	yPos = RectangleView(e.target).y;
	    	
			var prop:Number = map.unscaledMapWidth / width;

	    	map.x = -xPos*prop*map.zoom;
	    	map.y = -yPos*prop*map.zoom;
	    }
		
		private function updateValuesOnZoom(e:MapEvent):void
		{
			map = Map(e.target);
			rect.width = Math.min(width,width/map.zoom);
			rect.height = Math.min(height,height/map.zoom);
			var prop:Number = map.unscaledMapWidth / width;
			rect.x = Math.max(0,-map.x/map.zoom)/prop;
			rect.y = Math.max(0,-map.y/map.zoom)/prop;
		}
		
		private function updateValuesOnDrag(e:MapEvent):void
		{
			map = Map(e.target);
			var prop:Number = map.unscaledMapWidth / width;
			if (map.zoom>1)
				rect.x = -map.x/map.zoom/prop;
			else 
				rect.x = map.x/map.zoom/prop;
				
			if (map.zoom>1)
				rect.y = -map.y/map.zoom/prop;
			else
				rect.y = map.y/map.zoom/prop;
		}

		private function registerMapListeners():void
		{
			map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, updateValuesOnZoom);
			map.addEventListener(MapEvent.MAP_MOVING, updateValuesOnDrag);
		}
	}
}


import mx.core.UIComponent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.Sprite;
import flash.events.Event;

class RectangleView extends Sprite
{
	// Offset positions used when moving the rectanlge inside the container on dragging/dropping
    private var offsetX:Number, offsetY:Number;
    // Keep the starting point position when dragging, if mouse goes out of the parents' view
    // than the toolbar will be repositioned to this point
    private var startDraggingPoint:Point;
    
    public static const DRAG_COMPLETE:String = "Rectangle drag completed"; 
    public static const DRAGGING:String = "Rectangle being dragged"; 

	public function RectangleView():void
	{
		super();
		addEventListener(MouseEvent.MOUSE_DOWN, moveRectangle);
	}
	
	internal function draw(w:Number,h:Number):void
	{
		graphics.moveTo(0,0);
		graphics.beginFill(RectUtils.BLACK,.3);
		graphics.drawRect(0,0,w,h);
		graphics.endFill();
	}
	
	// Resize panel event handler.
	public  function moveRectangle(event:MouseEvent):void
	{
  		startMovingRectangle(event);
  		stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingRectangle);
	}
	
	// Start moving the toolbar
    private function startMovingRectangle(e:MouseEvent):void
    {
    	startDraggingPoint = new Point(this.x, this.y);
    	offsetX = e.stageX - this.x;
    	offsetY = e.stageY - this.y;
    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragRectangle);
    }
    
    // Stop moving the toolbar 
    private function stopMovingRectangle(e:MouseEvent):void
    {
    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragRectangle)
  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingRectangle);
  		dispatchEvent(new Event(RectangleView.DRAG_COMPLETE));
    }
    
    // Moving the toolbar while MOUSE_MOVE event is on
    private function dragRectangle(e:MouseEvent):void
    {
    	this.x = Math.max(e.stageX - offsetX,0);
    	this.y = Math.max(e.stageY - offsetY,0);
     	e.updateAfterEvent();
    	// dispatch moved toolbar event
  		dispatchEvent(new Event(RectangleView.DRAGGING));
    }
}

class RectUtils 
{
	public static const GREY:Number = 0x777777;
	public static const WHITE:Number = 0xffffff;
	public static const YELLOW:Number = 0xffd800;
	public static const RED:Number = 0xff0000;
	public static const BLUE:Number = 0x009cff;
	public static const GREEN:Number = 0x00ff54;
	public static const BLACK:Number = 0x000000;
	
	public static const size:Number = 40;
	public static const thick:Number = 2;
}
