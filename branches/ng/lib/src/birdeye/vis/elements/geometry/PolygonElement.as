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
	import birdeye.vis.data.Pair;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.scales.*;
	import birdeye.vis.trans.projections.Projection;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;

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
			// select the item renderer (must be an IGeomentry)
			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(UpTriangleRenderer);

			if (!isListeningMouseMove && chart)
			{
				chart.elementsContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				isListeningMouseMove = true;
			}
		}

		protected var poly:Path;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace(getTimer(), "drawing polygon ele");
var numCoords:Number = 0;
				super.drawElement();
				clearAll();

				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number;
				var t:uint = 0;
				
				var fullPoly:Array;
				var initiated:Boolean = false;
				
				dataFields["polyDim"] = _polyDim;
				
				var data:String;

				for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
				{
					var currentItem:Object = _dataItems[cursorIndex];

					fullPoly = currentItem[_polyDim] as Array;

					if (colorScale)
					{
						var col:* = colorScale.getPosition(currentItem[colorField]);
						if (col is Number)
							fill = new SolidFill(col);
						else if (col is IGraphicsFill)
							fill = col;
					} 

					createTTGG(currentItem, dataFields, NaN, NaN, NaN, NaN, NaN, null, NaN, NaN, false);
					ttGG.target = this;

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
							} else if (item[0] is Pair) {
								if (initiated)
								{
									data += "z";
									poly = new Path(data);
									poly.fill = fill;
									poly.stroke = stroke;
									ttGG.geometryCollection.addItemAt(poly,0);
									svgData += data;
								}
								initiated = false;
								
								data = " ";
								
								var i:uint = 0;
	
								for each (var pairs:Pair in item)
								{
									// data is composed by a set of arrays (Maps)
									if (scale1)
										pos1 = scale1.getPosition(pairs);
									
									// data is composed by a set of arrays (Maps)
									if (scale2)
										pos2 = scale2.getPosition(pairs);
									
									if (i++ == 0)
										data = "M" + String(pos1) + "," + String(pos2) + " ";
									else
										data += "L" + String(pos1) + "," + String(pos2) + " ";
								}
								data += "z";
								poly = new Path(data);
								poly.fill = fill;
								poly.stroke = stroke; 
								ttGG.geometryCollection.addItemAt(poly,0); 
								
								addSVGData(data);
							}
						}
					}
				}

				createSVG();
				_invalidatedElementGraphic = false;
trace(getTimer(), "drawing polygon ele Num coords ", numCoords);
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

			/*if (scale2 && scale2 is IAxis && IAxis(scale2).pointer)
			{
				IAxis(scale2).pointerY = posY;
				IAxis(scale2).pointer.visible = true;
			} 

			if (scale1 && scale1 is IAxis && IAxis(scale1).pointer)
			{
				IAxis(scale1).pointerX = posX;
				IAxis(scale1).pointer.visible = true;
			}*/
		}

		override public function refresh():void
		{
			// in the future this will reflect a more proper dataItems structure
			var nGG:Number = (graphicsCollection.items) ? graphicsCollection.items.length : 0;
			var tmpGG:DataItemLayout;
			var tmpColor:Object;
			var dataValue:Object;
			var tmpGeometry:IGeometry;
			
			for (var i:Number = 0; i<nGG; i++)
			{
				if ((tmpGG = graphicsCollection.items[i]) is DataItemLayout && tmpGG.currentItem)
				{
					if (colorScale && colorField)
					{
						dataValue = tmpGG.currentItem[colorField];
						tmpColor = colorScale.getPosition(dataValue); 

						for (var j:uint = 0; j<tmpGG.geometryCollection.items.length; j++)
						{
							tmpGeometry = tmpGG.geometryCollection.items[j];
							if (tmpGeometry is Polygon)
							{
								if (tmpColor is Number)
									tmpGeometry.fill = new SolidFill(tmpColor);
								else if (tmpColor is IGraphicsFill)
									tmpGeometry.fill = IGraphicsFill(tmpColor);
							}
						}
					}
				}
			}
		}
	}
}