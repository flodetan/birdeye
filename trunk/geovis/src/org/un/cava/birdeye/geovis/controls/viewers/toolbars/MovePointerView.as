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
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;
	
	public class MovePointerView extends UIComponent
	{ 
	    private var map:Map;

		private var _scale:Number = 5;
		
		private var _relativeDistance:Number = 10;
		private var _space:Number = 10;
		private var _thick:Number = 10;
		private var _backgroundColor:Number = MoveUtils.BLACK;
		private var _borderColor:Number = MoveUtils.RED;
		private var _backgroundAlpha:Number = 0;
		private var _borderAlpha:Number = 0.5;
		private static const leftName:String = "left";
		private static const upLeftName:String = "up left";
		private static const lowLeftName:String = "low left";
		private static const rightName:String = "right";
		private static const upRightName:String = "up right";
		private static const lowRightName:String = "low right";
		private static const upName:String = "up";
		private static const downName:String = "down"; 
		
		public function set relativeDistance(val:Number):void
		{
			_relativeDistance = val;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set space(val:Number):void
		{
			_space = val;
		}
		
		public function set thick(val:Number):void
		{
			_thick = val;
		}
		
		public function set backgroundColor(val:Number):void
		{
			_backgroundColor = val;
		}
		
		public function set borderColor(val:Number):void
		{
			_borderColor = val;
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

		/**
		 * Set the scale value. The final size of this controller will be based on the map size
		 * reduced by this value  
		 */
		public function set scale(val:Number):void
		{
			if (val >= 0)
				_scale = val;
		}

		public function MovePointerView()
		{
			super(); 
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
		}
		
		/**
		 * @Private
		 * Register the map object and calculate this.sizes  
		 */
		private function init(event:Event):void
		{
			// Add the resizing event handler.

			map = Map(event.target);
			
			// calculate the this.width and this.height based on a scale of the original map size 
			drawAll();
		}
		
		/**
		 * @Private
		 * Draw all graphics 
		 */
		private function drawAll():void
		{
			clearAll();
			
			// get the map-mask sizes, needed to size the draggable rectangle 
			var tempMask:DisplayObject = DisplayObject(map.mask);
			var maskBounds:Rectangle;
			if (map.mask != null)
				maskBounds = map.mask.getBounds(map.mask);
			else if (map.parent != null)
				maskBounds = map.parent.getBounds(map.parent);
			
			var maskWidth:Number = (maskBounds.width == 0) ? NaN : maskBounds.width;
			var maskHeight:Number = (maskBounds.height == 0) ? NaN : maskBounds.height;
			
			width = maskWidth/scale-_thick;
			height = maskHeight/scale-_thick;
			x += _thick/2;
			y += _thick/2;
			
			var lineLenght:Number = Math.min(width, height)/3;
			
			var left:Sprite = new Sprite(); 
			left.buttonMode = true;
			left.name = leftName; 
			left.graphics.moveTo(0,lineLenght + _space);
			left.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			left.graphics.lineTo(0,height - lineLenght - _space);
			left.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			left.graphics.moveTo(_thick,height/2);
			left.graphics.beginFill(MoveUtils.BLACK,1);
			left.graphics.drawCircle(_thick,height/2,_thick);
			left.graphics.endFill();
			addChild(left);
			left.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var upLeftCorner:Sprite = new Sprite();
			upLeftCorner.buttonMode = true;
			upLeftCorner.name = upLeftName;
			upLeftCorner.graphics.moveTo(0,lineLenght - _space);
			upLeftCorner.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			upLeftCorner.graphics.lineTo(0,0);
			upLeftCorner.graphics.lineTo(lineLenght - _space,0);
			upLeftCorner.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			upLeftCorner.graphics.moveTo(_thick,_thick);
			upLeftCorner.graphics.beginFill(MoveUtils.BLACK,1);
			upLeftCorner.graphics.drawCircle(_thick,_thick,_thick);
			upLeftCorner.graphics.endFill();
			addChild(upLeftCorner);
			left.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);

			var lowLeftCorner:Sprite = new Sprite();
			lowLeftCorner.buttonMode = true;
			lowLeftCorner.name = lowLeftName;
			lowLeftCorner.graphics.moveTo(0,height - lineLenght + _space);
			lowLeftCorner.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			lowLeftCorner.graphics.lineTo(0,height);
			lowLeftCorner.graphics.lineTo(lineLenght - _space,height);
			lowLeftCorner.graphics.moveTo(_thick,height-_thick);
			lowLeftCorner.graphics.beginFill(MoveUtils.BLACK,1);
			lowLeftCorner.graphics.drawCircle(_thick,height-_thick,_thick);
			left.graphics.endFill();
			addChild(lowLeftCorner);
			lowLeftCorner.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var up:Sprite = new Sprite();
			up.buttonMode = true;
			up.name = upName;
			up.graphics.moveTo(lineLenght + _space, 0);
			up.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			up.graphics.lineTo(width - lineLenght - _space,0);
			up.graphics.moveTo(width/2,_thick);
			up.graphics.beginFill(MoveUtils.BLACK,1);
			up.graphics.drawCircle(width/2,_thick,_thick);
			up.graphics.endFill();
			addChild(up);
			up.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var right:Sprite = new Sprite();
			right.buttonMode = true;
			right.name = rightName;
			right.graphics.moveTo(width, lineLenght + _space);
			right.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			right.graphics.lineTo(width, height - lineLenght - _space);
			right.graphics.moveTo(width-_thick,height/2);
			right.graphics.beginFill(MoveUtils.BLACK,1);
			right.graphics.drawCircle(width-_thick,height/2,_thick);
			right.graphics.endFill();
			addChild(right);
			right.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var upRightCorner:Sprite = new Sprite();
			upRightCorner.buttonMode = true;
			upRightCorner.name = upRightName;
			upRightCorner.graphics.moveTo(width - lineLenght + _space, 0);
			upRightCorner.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			upRightCorner.graphics.lineTo(width, 0);
			upRightCorner.graphics.lineTo(width, lineLenght - _space);
			upRightCorner.graphics.moveTo(width-_thick,_thick);
			upRightCorner.graphics.beginFill(MoveUtils.BLACK,1);
			upRightCorner.graphics.drawCircle(width-_thick,_thick,_thick);
			upRightCorner.graphics.endFill();
			addChild(upRightCorner);
			upRightCorner.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var lowRightCorner:Sprite = new Sprite();
			lowRightCorner.buttonMode = true;
			lowRightCorner.name = lowRightName;
			lowRightCorner.graphics.moveTo(width, height - lineLenght + _space);
			lowRightCorner.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			lowRightCorner.graphics.lineTo(width,height);
			lowRightCorner.graphics.lineTo(width - lineLenght + _space, height);
			lowRightCorner.graphics.moveTo(width-_thick,height-_thick);
			lowRightCorner.graphics.beginFill(MoveUtils.BLACK,1);
			lowRightCorner.graphics.drawCircle(width-_thick,height-_thick,_thick);
			lowRightCorner.graphics.endFill();
			addChild(lowRightCorner);
			lowRightCorner.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			var down:Sprite = new Sprite();
			down.buttonMode = true;
			down.name = downName;
			down.graphics.moveTo(width - lineLenght - _space, height);
			down.graphics.lineStyle(_thick,_borderColor, _borderAlpha);
			down.graphics.lineTo(lineLenght + _space, height);
			down.graphics.moveTo(width/2,height-_thick);
			down.graphics.beginFill(MoveUtils.BLACK,1);
			down.graphics.drawCircle(width/2,height-_thick,_thick);
			down.graphics.endFill();
			addChild(down);
			down.addEventListener(MouseEvent.MOUSE_DOWN, moveHandler);
			
			// fill the rectangle 
			var bkg:Shape = new Shape();
			bkg.graphics.moveTo(0,0);
			bkg.graphics.beginFill(_backgroundColor,_backgroundAlpha);
			bkg.graphics.drawRect(0,0,width,height);
			bkg.graphics.endFill();

			// draws rectangle border  
			bkg.graphics.moveTo(0,0);
			bkg.graphics.lineStyle(2,_borderColor,_borderAlpha);
			bkg.graphics.lineTo(width,0);
			bkg.graphics.lineTo(width,height);
			bkg.graphics.lineTo(0,height);
			bkg.graphics.lineTo(0,0);
						
			// if parent is the worldmap itself, than put this on top, so that it's viewable
			if (parent is WorldMap)
				parent.setChildIndex(this, numChildren-1);
			else
				if (_backgroundAlpha > 0) 
					addChild(bkg);
 		}
 		
 		private function moveHandler(e:Event):void
 		{
 			switch (e.target.name)
 			{
 				case leftName:
 					map.relativeMoveMap(_relativeDistance,0);
 				break;
 				case upLeftName:
 					map.relativeMoveMap(_relativeDistance,_relativeDistance);
 				break;
 				case lowLeftName:
 					map.relativeMoveMap(_relativeDistance, -_relativeDistance);
 				break;
 				case rightName:
 					map.relativeMoveMap(-_relativeDistance, 0);
 				break;
 				case upRightName:
 					map.relativeMoveMap(-_relativeDistance, _relativeDistance);
 				break;
 				case lowRightName:
 					map.relativeMoveMap(-_relativeDistance, -_relativeDistance);
 				break;
 				case upName:
 					map.relativeMoveMap(0, _relativeDistance);
 				break;
 				case downName:
 					map.relativeMoveMap(0, -_relativeDistance);
 				break;
 			}
 			invalidateDisplayList();
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

class MoveUtils 
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
