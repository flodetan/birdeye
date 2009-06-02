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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.interfaces.IScaleUI;
	import birdeye.vis.scales.*;
	import birdeye.vis.trans.projections.Projection;
	
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.CursorBookmark;

	public class PolygonElement extends BaseElement
	{
		private var _polyDim:String;
		public function set polyDim(val:String):void
		{
			_polyDim = val;
		}

		private var _targetLatProjection:Projection;
		public function set targetLatProjection(val:Projection):void {
			_targetLatProjection = val;
		}
		public function get targetLatProjection():Projection {
			return _targetLatProjection;
		}

		private var _targetLongProjection:Projection;
		public function set targetLongProjection(val:Projection):void {
			_targetLongProjection = val;
		}
		public function get targetLongProjection():Projection {
			return _targetLongProjection;
		}

		public function PolygonElement()
		{
			super();
		}

		private var isListeningMouseMove:Boolean = false;
		override protected function commitProperties():void
		{
			super.commitProperties();
			// select the item renderer (must be an IGeomentry)
			if (! itemRenderer)
				itemRenderer = UpTriangleRenderer;

			if (!isListeningMouseMove)
			{
				chart.elementsContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				isListeningMouseMove = true;
			}
		}

		protected var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout())
			{
				removeAllElements();
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number;
				var t:uint = 0;
				
				// move data provider cursor at the beginning
				cursor.seek(CursorBookmark.FIRST);
				var fullPoly:Array;
				var initiated:Boolean = false;
				
				poly = new Polygon();
				poly.data = " ";

				while (!cursor.afterLast)
				{
					fullPoly = cursor.current[_polyDim] as Array;

					if (colorScale)
					{
						colorFill = colorScale.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					} 

					createTTGG(cursor.current, [_polyDim], NaN, NaN, NaN, NaN, null, NaN, NaN, false);

					if (fullPoly && fullPoly.length > 0)
					{
						// we could achieve the following with a recursive function but it slows down 
						// significantly the process.
						for each (var item:Array in fullPoly)
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
								
								poly.data += String(pos1) + "," + String(pos2) + " ";
							} else if (item[0] is Array) {
								if (initiated)
								{
									poly.fill = fill;
									poly.stroke = stroke;
									ttGG.geometryCollection.addItemAt(poly,0);
								}
								initiated = false;
								
								poly = new Polygon();
								poly.data = " ";
	
								for each (var pairs:Array in item)
								{
									// data is composed by a set of arrays (Maps)
									if (scale1)
										pos1 = scale1.getPosition(pairs);
									
									// data is composed by a set of arrays (Maps)
									if (scale2)
										pos2 = scale2.getPosition(pairs);
									
									poly.data += String(pos1) + "," + String(pos2) + " ";
								}
								poly.fill = fill;
								poly.stroke = stroke;
								ttGG.geometryCollection.addItemAt(poly,0);
							}
						}
					}
					cursor.moveNext();
				}
			}
		}

		override protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:DataItemLayout = DataItemLayout(e.target);

			if (chart.showDataTips) {
				if (chart.customTooltTipFunction != null)
				{
					myTT = chart.customTooltTipFunction(extGG);
		 			toolTip = myTT.text;
				} else {
					extGG.posX = extGG.mouseX;
					extGG.posY = extGG.mouseY;
					extGG.showToolTip();
				}
			}
		}

		private function onMouseMove(e:MouseEvent):void 
		{
			var localPoint:Point, posX:Number, posY:Number;
			
			localPoint = new Point(chart.elementsContainer.mouseX, chart.elementsContainer.mouseY);
			posY = localPoint.y;
			posX = localPoint.x;

			if (scale2 && scale2 is IScaleUI && IScaleUI(scale2).pointer)
			{
				IScaleUI(scale2).pointerY = posY;
				IScaleUI(scale2).pointer.visible = true;
			} 

			if (scale1 && scale1 is IScaleUI && IScaleUI(scale1).pointer)
			{
				IScaleUI(scale1).pointerX = posX;
				IScaleUI(scale1).pointer.visible = true;
			}
		}
	}
}