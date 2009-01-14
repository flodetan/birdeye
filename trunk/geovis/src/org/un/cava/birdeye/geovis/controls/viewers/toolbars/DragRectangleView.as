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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;
	
	public class DragRectangleView extends UIComponent
	{ 
		private var draggableRect:RectangleView;
		private var mapCopy:BitmapData;
		private var mapCopyCont:Bitmap;
		private var msk:Shape;
	    private var maskWidth:Number, maskHeight:Number;
		
		private var _scale:Number = 5;
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scale(val:Number):void
		{
			if (val >= 0)
				_scale = val;
		}

		// Add the creationCOmplete event handler.
		public function DragRectangleView()
		{
			super(); 
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
		    Application.application.addEventListener(MapEvent.MAP_CHANGED, init, true);
		}
		
 		override protected function createChildren():void
		{
			super.createChildren();
			draggableRect = new RectangleView();
			
			msk = new Shape();
			
			draggableRect.mask = msk;
		}
		
		private function init(event:Event):void
		{
			// Add the resizing event handler.

			map = Map(event.target); 
			width = map.unscaledMapWidth / scale;
			height = map.unscaledMapHeight / scale;
			drawAll();
		}
	
		private function drawAll():void
		{
			for (var childIndex:Number = 0; childIndex <= numChildren-1; childIndex++)
				removeChildAt(childIndex);
			
			clearAll();

			msk.graphics.moveTo(0,0);
			msk.graphics.beginFill(0xffffff,0);
			msk.graphics.drawRect(0,0,width,height);
			msk.graphics.endFill();
			addChild(msk);

			graphics.moveTo(0,0);
			graphics.beginFill(RectUtils.BLACK,.4);
			graphics.drawRect(0,0,width,height);
			graphics.endFill();

			var tempMask:DisplayObject = DisplayObject(map.mask);
			var maskBounds:Rectangle;
			if (map.mask != null)
				maskBounds = map.mask.getBounds(map.mask);
			else
				maskBounds = map.parent.getBounds(map.parent);
			maskWidth = maskBounds.width;
			maskHeight = maskBounds.height;
 			// map.mask must be temporarily set to null because otherwise the bitmapdata
 			// will cut the map on the top and left sides, probably because of a bug either 
 			// in the framework
 			map.mask = null;

			var sourceRect:Rectangle = new Rectangle(0,0,width,height);
			if (mapCopy != null)
				mapCopy.dispose();
			mapCopy = new BitmapData(sourceRect.width, sourceRect.height,true,0x000000);
			var matr:Matrix = new Matrix(1/scale,0,0,1/scale,0,0); 
			mapCopy.draw(map,matr,null,null,sourceRect,true);
			mapCopyCont = new Bitmap(mapCopy);
			addChild(mapCopyCont);
			map.mask = tempMask;

			graphics.moveTo(0,0);
			graphics.lineStyle(2,RectUtils.RED,.4);
			graphics.lineTo(width,0);
			graphics.lineTo(width,height);
			graphics.lineTo(0,height);
			graphics.lineTo(0,0);
			
			draggableRect = new RectangleView();
			draggableRect.mask = msk;
			var w:Number = maskWidth/map.zoom/scale;
			var h:Number = maskHeight/map.zoom/scale;
			draggableRect.draw(w,h);
			draggableRect.width = w;
			draggableRect.height = h;
			draggableRect.x = Math.max(0,-map.x/map.zoom)/scale;
			draggableRect.y = Math.max(0,-map.y/map.zoom)/scale;
			draggableRect.addEventListener(RectangleView.DRAGGING, moveMap);
			addChild(draggableRect);

			registerMapListeners();
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
 		}
 		
 		private function clearAll():void
 		{
			if (msk != null)
				msk.graphics.clear();
			graphics.clear();
			if (mapCopy != null)
				mapCopy.dispose();
			if (draggableRect != null)
				draggableRect.graphics.clear();
 		}

	    private var map:Map;
	    private function moveMap(e:Event):void
	    {
	    	var xPos:Number, yPos:Number;
	    	xPos = RectangleView(e.target).x;
	    	yPos = RectangleView(e.target).y;
	    	
	    	map.x = -xPos*scale*map.zoom;
	    	map.y = -yPos*scale*map.zoom;
	    }
		
		private function updateValuesOnZoom(e:MapEvent):void
		{
			map = Map(e.target);
			draggableRect.width = maskWidth/map.zoom/scale;//map.parent.width/map.zoom/scale;
			draggableRect.height = maskHeight/map.zoom/scale;//map.parent.height/map.zoom/scale;
			draggableRect.x = -map.x/map.zoom/scale;
			draggableRect.y = -map.y/map.zoom/scale;
trace (map.zoom, draggableRect.width, draggableRect.height);
		}
		
		private function updateValuesOnDragOrCentering(e:MapEvent):void
		{
			map = Map(e.target);
trace (map.zoom, draggableRect.width, draggableRect.height, map.parent.width, map.parent.height);
			draggableRect.x = -map.x/map.zoom/scale;
			draggableRect.y = -map.y/map.zoom/scale;
		}

		private function registerMapListeners():void
		{
			draggableRect.addEventListener(RectangleView.DRAGGING, moveMap);
			map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, updateValuesOnZoom);
			map.addEventListener(MapEvent.MAP_MOVING, updateValuesOnDragOrCentering);
		    map.addEventListener(MapEvent.MAP_CENTERED, updateValuesOnDragOrCentering);
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
		graphics.beginFill(RectUtils.WHITE,.7);
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
    	this.x = e.stageX - offsetX;
    	this.y = e.stageY - offsetY;
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
