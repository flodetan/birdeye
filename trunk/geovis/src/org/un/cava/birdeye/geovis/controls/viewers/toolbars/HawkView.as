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
	import flash.display.Sprite;
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
	
	public class HawkView extends UIComponent
	{ 
	    private var map:Map;

		private var mapCopy:BitmapData;
		private var mapCopyCont:Bitmap;
		private var cont:Sprite; 
	    private var maskWidth:Number = NaN, maskHeight:Number = NaN;
		
		private var _zoom:Number = 5;
		
		private var _backgroundColor:Number = RectUtils.BLACK;
		private var _borderColor:Number = RectUtils.RED;
		private var _dragRectangleColor:Number = RectUtils.YELLOW;
		private var _backgroundAlpha:Number = 0.5;
		private var _borderAlpha:Number = 0.5;
		private var _dragRectangleAlpha:Number = 0.5;
		
		public function set zoom(val:Number):void
		{
			_zoom = val;
		}
		
		public function set backgroundColor(val:Number):void
		{
			_backgroundColor = val;
		}
		
		public function set borderColor(val:Number):void
		{
			_borderColor = val;
		}
		
		public function set dragRectangleColor(val:Number):void
		{
			_dragRectangleColor = val;
		}
		
		public function set backgroundAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_backgroundAlpha = val;
		}

		public function set borderAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_borderAlpha = val;
		}

		public function set dragRectangleAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_dragRectangleAlpha = val;
		}

		/**
		 * Set the scale value. The final size of this controller will be based on the map size
		 * reduced by this value  
		 */
		public function set scale(val:Number):void
		{
			if (val >= 0)
				_zoom = val;
		}

		public function HawkView()
		{
			super(); 
		    Application.application.addEventListener(MapEvent.MAP_CHANGED, init, true);
		}
		
		/**
		 * @Private
		 * Register the map object and calculate this.sizes  
		 */
		private function init(event:Event):void
		{
			// Add the resizing event handler.

			map = Map(event.target);
			
			Application.application.addEventListener(MouseEvent.CLICK, drawAll, true);
		}
	
		/**
		 * @Private
		 * Create draggableRect and its mask 
		 */
 		override protected function createChildren():void
		{
			super.createChildren();
			
		}
		
		/**
		 * @Private
		 * Draw all graphics 
		 */
		private function drawAll(e:MouseEvent):void
		{
			clearAll();
			
/*   			x = map.mouseX - width/2;
			y = map.mouseY - height/2;
 */			// get the map-mask sizes, needed to size the draggable rectangle 
			var tempMask:DisplayObject = DisplayObject(map.mask);
 			// map.mask must be temporarily set to null because otherwise the bitmapdata
 			// will cut the map on the top and left sides, probably because of a bug either 
 			// in the framework
 			map.mask = null;
 			
 			graphics.moveTo(0,0);
 			graphics.beginFill(_backgroundColor, _backgroundAlpha);
 			graphics.drawRect(0,0,width,height);
 			graphics.endFill();

	    	var globOrgPoint:Point = localToContent(new Point(map.mouseX, map.mouseY));
		    var moveX:int = map.mouseX;
		    var moveY:int = map.mouseY;

			// create the bitmap of the map and scale using the scale property value 
			var sourceRect:Rectangle = new Rectangle(0,0,width,height);
			if (mapCopy != null)
				mapCopy.dispose();
			mapCopy = new BitmapData(sourceRect.width, sourceRect.height,true,0x000000);
			var matr:Matrix = new Matrix();
trace (map.mouseX, map.mouseY);
 			matr.translate(-moveX, -moveY);
 			matr.scale(_zoom, _zoom);
 			matr.translate(width/2, height/2);
 			mapCopy.draw(map,matr,null,null,sourceRect,true);
			mapCopyCont = new Bitmap(mapCopy);
			addChild(mapCopyCont);
			map.mask = tempMask;

			// draws rectangle border  
			graphics.moveTo(0,0);
			graphics.lineStyle(2,_borderColor,_borderAlpha);
			graphics.lineTo(width,0);
			graphics.lineTo(width,height);
			graphics.lineTo(0,height);
			graphics.lineTo(0,0);
			
			// if parent is the worldmap itself, than put this on top, so that it's viewable
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
 		}
 		
		/**
		 * @Private
		 * Remove and clear everything
		 */
 		private function clearAll():void
 		{
			for (var childIndex:Number = 0; childIndex <= numChildren-1; childIndex++)
				removeChildAt(childIndex);
			
			graphics.clear();
			if (mapCopy != null)
				mapCopy.dispose();
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
