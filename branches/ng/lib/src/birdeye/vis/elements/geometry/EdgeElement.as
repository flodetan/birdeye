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
package birdeye.vis.elements.geometry {

	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.Position;
	import birdeye.vis.guides.renderers.IEdgeRenderer;
	import birdeye.vis.guides.renderers.LineRenderer;
	import birdeye.vis.interfaces.IEdgeElement;
	import birdeye.vis.interfaces.IPositionableElement;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class EdgeElement extends BaseElement implements IEdgeElement {

		public function EdgeElement() {
			super();
		}

		private var _dimStart:String;
		
		public function set dimStart(val:String):void {
			_dimStart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get dimStart():String {
			return _dimStart;
		}

		private var _dimEnd:String;
		
		public function set dimEnd(val:String):void	{
			_dimEnd = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get dimEnd():String {
			return _dimEnd;
		}
		
		override protected function createGlobalGeometryGroup():void {
			// do nothing: no need to create the global group 
	    }

		private var _node:IPositionableElement;

		public function set node(val:IPositionableElement):void {
			_node = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get node():IPositionableElement {
			return _node;
		}

		protected function createItemRenderer(edgeItemId:String, x1:Number, y1:Number, x2:Number, y2:Number):IEdgeRenderer {
			var edgeRenderer:IEdgeRenderer;
 			if (itemRenderer) {
				edgeRenderer = itemRenderer.newInstance();
				if (!(edgeRenderer is IEdgeRenderer)) {
					throw new Error("EdgeElement renderer factory produced not an IEdgeRenderer");
				}
				edgeRenderer.startX = x1;
				edgeRenderer.startY = y1;
				edgeRenderer.endX = x2;
				edgeRenderer.endY = y2;
 			} else {
				edgeRenderer = new LineRenderer(new Rectangle(x1, y1, x2, y2));
			}	
			edgeRenderer.fill = fill;
			edgeRenderer.stroke = stroke;
			_edgeRenderers[edgeItemId] = edgeRenderer;
			return edgeRenderer;
		}

		public function edgeItemId(itemIndex:int, item:Object):String {
			return String(itemIndex);
		}
		
		private var _edgeRenderers:Dictionary;
		
		public function setEdgePosition(edgeItemId:String, x1:Number, y1:Number, x2:Number, y2:Number):void {
			var edgeRenderer:IEdgeRenderer = _edgeRenderers[edgeItemId];
			if (edgeRenderer != null) {
				edgeRenderer.startX = x1;
				edgeRenderer.startY = y1;
				edgeRenderer.endX = x2;
				edgeRenderer.endY = y2;
			}
		}

		override protected function prepareForItemDisplayObjectsCreation():void {
			super.prepareForItemDisplayObjectsCreation();
			_edgeRenderers = new Dictionary();
		}

		override public function drawElement():void {
			super.drawElement();
			
			prepareForItemDisplayObjectsCreation();
			
			const items:Vector.<Object> = dataItems;
			var dataFields:Array = [];
			if (dimStart)
				dataFields["dimStart"] = dimStart;
			if (dimEnd)
				dataFields["dimEnd"] = dimEnd;
				
			if (items){
				items.forEach(function(item:Object, itemIndex:int, items:Vector.<Object>):void {
					var pos1:Number = NaN, pos2:Number = NaN, pos3:Number = NaN;
	
					const startItemId:Object = item[_dimStart];
					const endItemId:Object = item[_dimEnd];

					if (_node.isItemVisible(startItemId)  &&  _node.isItemVisible(endItemId)) {
						var start:Position = _node.getItemPosition(startItemId);
						var end:Position = _node.getItemPosition(endItemId);
/* 						var middle:Position = new Position((start.pos1 + end.pos1)/2, (start.pos2 + end.pos2)/2);
						
						var relativeStart:Position = new Position(start.pos1 - middle.pos1, start.pos2 - middle.pos2);
						var relativeEnd:Position = new Position(end.pos1 - middle.pos1, end.pos2 - middle.pos2); */

						if (start && end) {
							const itemId:String = edgeItemId(itemIndex, item);
							// The display object is always positioned at (0, 0) and
							// the edge renderers are passed in the start/end coordinates
							// and position and draw the edges accordingly.   
							createItemDisplayObject(
								item, dataFields, Position.ZERO, itemId,
								[ createItemRenderer(itemId, start.pos1, start.pos2, end.pos1, end.pos2)
//								  TextRenderer.createTextLabel(
//								  (start.pos1 + end.pos1)/2, (start.pos2 + end.pos2)/2,
//								  itemId + ": " + startItemId + "-" + endItemId, new SolidFill(0xffffff), 
//								  true, true)
								 ]
							);
						}
					}
				});
			}
		}
		
		// we need to override to avoid the cretion of tooltips whose position
		// is not yet clear with the current implementation
		override protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, collisionIndex:Number = NaN, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN, showGeometry:Boolean = true):void
		{
			if (graphicsCollection.items && graphicsCollection.items.length > ggIndex)
				ttGG = graphicsCollection.items[ggIndex];
			else {
				ttGG = new DataItemLayout();
				graphicsCollection.addItem(ttGG);
			}
			ggIndex++;
			ttGG.target = chart.elementsContainer;

			if (mouseClickFunction!=null || mouseDoubleClickFunction!=null || mouseOverFunction != null)
			{
				// if no tips but interactivity is required than add mouse events and pass
				// data and positioning information about the current data item 
				ttGG.create(item, dataFields, xPos, yPos, zPos, NaN,collisionIndex,  null, NaN, NaN, false);
				if (mouseClickFunction != null)
					ttGG.addEventListener(MouseEvent.CLICK, onMouseClick);
	
				if (mouseDoubleClickFunction != null)
					ttGG.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			}
		}
	}
}
