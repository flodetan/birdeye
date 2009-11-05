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
 
package birdeye.vis.elements.geometry
{
	import __AS3__.vec.Vector;
	
	import birdeye.vis.data.Pair;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.scales.*;
	import birdeye.vis.trans.projections.Projection;
	
	import flash.display.GraphicsPathCommand;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	
	public class PolygonElement extends BaseElement
	{
		private var _polyDim:String;
		/** The polyDim is the dimension field that specify the coordinates 
		 * to define the whole polygon. For the geo map, this is expected to be
		 * an array (countries) of possible arrays (islands) of latitude-longitude coordinates.*/
		public function set polyDim(val:String):void
		{
			_polyDim = val;
			invalidatingDisplay();
		}

		private var _targetLatProjection:Projection;
		public function set targetLatProjection(val:Projection):void {
			_targetLatProjection = val;
			invalidatingDisplay();
		}
		public function get targetLatProjection():Projection {
			return _targetLatProjection;
			invalidatingDisplay();
		}

		private var _targetLongProjection:Projection;
		public function set targetLongProjection(val:Projection):void {
			_targetLongProjection = val;
			invalidatingDisplay();
		}
		public function get targetLongProjection():Projection {
			return _targetLongProjection;
			invalidatingDisplay();
		}

		public function PolygonElement()
		{
			super();
		}

		private var isListeningMouseMove:Boolean = false;
		override protected function commitProperties():void
		{
			super.commitProperties();
		}

		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace(getTimer(), "drawing BEST");
var numCoords:Number = 0;
				super.drawElement();
				clearAll();
				
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number;
				var t:uint = 0;
				
				var fullPoly:Array;
				var initiated:Boolean = false;
				var data:String;
				
				var pathCommands:Vector.<int>;
				var pathPoints:Vector.<Point>;
				
				for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
				{
					var currentItem:Object = _dataItems[cursorIndex];

					fullPoly = currentItem[_polyDim] as Array;

					if (fullPoly && fullPoly.length > 0)
					{
						// we could achieve the following with a recursive function but it slows down 
						// significantly the process.
						for each (var item:Vector.<Pair> in fullPoly)
						{
							if (item[0] is Number)
							{
								initiated = true;
								
								// data is composed by a set of arrays (Maps)
								if (scale1)
									pos1 = scale1.getPosition(item);
								
								// data is composed by a set of arrays (Maps)
								if (scale2)
									pos2 = scale2.getPosition(item);
								
								data = "M" + String(pos1) + "," + String(pos2) + " ";
								pathCommands.push(GraphicsPathCommand.MOVE_TO);
								pathPoints.push(new Point(pos1, pos2));
							} else if (item[0] is Pair) {
								var i:uint = 0;
	
								if (initiated)
								{
									data += "z";
									svgData += data;
								}
								initiated = false;
								
								data = " ";
								var vertices:Vector.<Number>;
								for each (var pairs:Pair in item)
								{
									// data is composed by a set of arrays (Maps)
									if (scale1)
										pos1 = scale1.getPosition(pairs);
									
									// data is composed by a set of arrays (Maps)
									if (scale2)
										pos2 = scale2.getPosition(pairs);
									
									if (i++ == 0)
									{
										pathCommands = new Vector.<int>();
										vertices = new Vector.<Number>;
										pathCommands.push(GraphicsPathCommand.MOVE_TO);
										data = "M" + String(pos1) + "," + String(pos2) + " ";
									} else {
										pathCommands.push(GraphicsPathCommand.LINE_TO);
										data += "L" + String(pos1) + "," + String(pos2) + " ";
									}

									vertices.push(pos1)
									vertices.push(pos2);
								}
								data += "z";
								addSVGData('\n<path d="' + data + '"/>');

								var sp:ExtendedSprite = new ExtendedSprite();
								if (visScene.showDataTips)
								{
									sp.item = currentItem;
									sp.addEventListener(MouseEvent.ROLL_OVER, createTip);
									sp.addEventListener(MouseEvent.ROLL_OUT, destroyTip);
								}

								if (draggableItems)
									sp.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);

								if (colorScale)
									colorFill = colorScale.getPosition(currentItem[colorField]);

								sp.graphics.lineStyle(alphaStroke, colorStroke, weightStroke);
								sp.graphics.beginFill(colorFill, alphaFill);
								sp.graphics.drawPath(pathCommands, vertices);
								sp.graphics.endFill();
								addChild(sp);
//we must convert the array of points to a vertices vector
 							}
						}
					}
				}

				createSVG();
				_invalidatedElementGraphic = false;
trace(getTimer(), "end drawing BEST");
			}
		}
		
		private var tip:ToolTip;
		private function createTip(e:MouseEvent):void
		{
			var globalPosition:Point = localToGlobal(new Point(mouseX, mouseY)); 
			if (visScene.customTooltTipFunction != null)
			{
				myTT = visScene.customTooltTipFunction(ExtendedSprite(e.target).item);
				toolTip = myTT.text;
trace ("created TIP", toolTip)
			} else {
				tip = ToolTipManager.createToolTip(visScene.dataTipFunction(ExtendedSprite(e.target).item, null), 
													globalPosition.x, globalPosition.y) as ToolTip;
			}
		}

		private function destroyTip(e:MouseEvent):void
		{
			if (visScene.customTooltTipFunction)
 			{
				toolTip = null;
trace ("destroyed TIP", toolTip)
			} else 
 				ToolTipManager.destroyToolTip(tip);
		}

		/** Implement function to manage mouse click events.*/
		override public function onMouseClick(e:MouseEvent):void
		{
			if (isDraggingNow) return;

			if (e.target is ExtendedSprite)
				mouseDoubleClickFunction(ExtendedSprite(e.target).item);
		}

		/** Implement function to manage mouse double click events.*/
		override public function onMouseDoubleClick(e:MouseEvent):void
		{
			if (isDraggingNow) return;

			if (e.target is ExtendedSprite)
				mouseDoubleClickFunction(ExtendedSprite(e.target).item);
		}

		private var draggedPoly:ExtendedSprite;
		override protected function startDragging(e:MouseEvent):void
		{
			if (e.target is ExtendedSprite)
			{
				draggedPoly = ExtendedSprite(e.target);
				var itemX:Number = draggedPoly.x, itemY:Number = draggedPoly.y;
				isDraggingNow = true;
		    	offsetX = e.stageX - itemX;
		    	offsetY = e.stageY - itemY;
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragDataItem);
		    	dispatchEvent(new Event("DraggingStarted")); // TODO: create specific event 
			}
		}
		
		/**
		 * @Private 
		 * Move the data item while the mouse moves 
		*/
	    override protected function dragDataItem(e:MouseEvent):void
	    {
	    	draggedPoly.x = e.stageX - offsetX;
	    	draggedPoly.y = e.stageY - offsetY;
trace (draggedPoly.x, draggedPoly.y);
	    	dispatchEvent(new Event("ItemMoving"));
	    	e.updateAfterEvent();
	    }
	    
		/**
		 * @Private 
		 * Stop data item moving 
		*/
	    private function stopDragging(e:MouseEvent):void
	    {
	    	if (isDraggingNow)
		    	isDraggingNow = false;

	  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragDataItem)
	    	dispatchEvent(new Event("DragComplete"));
	    }

		override public function clearAll():void
		{
			for (var i:Number = numChildren-1; i>0; i--)
				if (getChildAt(i) is ExtendedSprite)
				{
					ExtendedSprite(getChildAt(i)).graphics.clear(); 
					if (visScene.showDataTips)
					{
						ExtendedSprite(getChildAt(i)).removeEventListener(MouseEvent.ROLL_OVER, createTip);
						ExtendedSprite(getChildAt(i)).removeEventListener(MouseEvent.ROLL_OUT, destroyTip);
					}
						
					removeChildAt(i);
				}
		}
		// fieldID is the field that can be used to uniquely identify 
		// adata item in the polygon (for ex. if the polygon is a country, 
		// than it's ISO code, or country name)
		override public function refresh(updatedDataItems:Vector.<Object>, field:Object = null, colorFieldValues:Array = null, fieldID:Object = null):void
		{
		}
	}
}
	import flash.display.Sprite;
	import birdeye.vis.elements.BaseElement;
	

class ExtendedSprite extends Sprite
{
	public var item:Object;
}