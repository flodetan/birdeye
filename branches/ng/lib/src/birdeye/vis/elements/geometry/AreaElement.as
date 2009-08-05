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
	import birdeye.vis.VisScene;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.splines.BezierSpline;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;

	public class AreaElement extends StackElement
	{
		/** It overrides the get elementType to force the result to be "area".
		 * elementType is used to provide the possibility of using stackable element
		 * within any type of chart instead of only using them inside their own 
		 * chart type.*/
		override public function get elementType():String
		{
			return "area";
		}

		private const CURVE:String = "curve";

		private var _form:String;
		/** The form defines the shape type of the element, ("curve", "line").*/
		[Inspectable(enumeration="curve,line")]
		public function set form(val:String):void
		{
			_form = val;
			invalidatingDisplay();
		}
		public function get form():String
		{
			return _form;
		}

		private var _tension:Number = 4;
		/** Set the tension of the curve form (values from 1 to 5). The higher, the closer to a line form. 
		 * The lower, the more curved the final shape. */
		public function set tension(val:Number):void
		{
			_tension = val;
			invalidatingDisplay();
		}
		
		public function AreaElement()
		{
			super();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			// select the item renderer (must be an IGeomentry)
			if (! itemRenderer)
				itemRenderer = new ClassFactory(UpTriangleRenderer);

			// doesn't need to call super.commitProperties(), since it doesn't need to listen
			// to axes interval changes 
			if (stackType == STACKED100 && chart)
			{
				if (scale2 is INumerableScale)
					INumerableScale(scale2).max = chart.maxStacked100;
			}
		}

		protected var poly:Polygon;
		private var bzSplines:BezierSpline;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace (getTimer(), "area ele");
				super.drawElement();
				removeAllElements();
				if (bzSplines)
					bzSplines.clearGraphicsTargets();
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number, zPos:Number;
				var j:Object;
				var t:Number = 0;
				
				var y0:Number = getYMinPosition();
				var y0Prev:Number;

				// shapes array defining the tooltip geometries
				var ttShapes:Array;
				// tooltip distance from the hitarea position
				var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
				
				poly = new Polygon();
				poly.data = "";
	
				var baseScale2:Number = getYMinPosition();

				ggIndex = 0;
				
				var points:Array = [];
				
				for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
				{
	 				if (graphicsCollection.items && graphicsCollection.items.length>ggIndex)
						gg = graphicsCollection.items[ggIndex];
					else
					{
						gg = new DataItemLayout();
						graphicsCollection.addItem(gg);
					}
					gg.target = this;
					ggIndex++;

					var currentItem:Object = _dataItems[cursorIndex];
					
					// if the Element has its own x axis, than get the x coordinate
					// position of the data value filtered by xField
					if (scale1)
						pos1 = scale1.getPosition(currentItem[dim1]);
					
					j = currentItem[dim1];
					// if the Element has its own y axis, than get the y coordinate
					// position of the data value filtered by yField
					if (scale2)
					{
						// if the stackType is stacked100, than the y0 coordinate of 
						// the current baseValue is added to the y coordinate of the current
						// data value filtered by yField
						if (_stackType == STACKED100)
						{
							y0 = scale2.getPosition(baseValues[j]);
							pos2 = scale2.getPosition(
								baseValues[j] + Math.max(0,currentItem[dim2]));
						} else 
							// if not stacked, than the y coordinate is given by the own y axis
							pos2 = scale2.getPosition(currentItem[dim2]);
					}
					
					// if stacked 100 than change the default tooltip shape to a line
					// that won't be covered by the children layering
					if (_stackType == STACKED100)
					{
							ttShapes = [];
							ttXoffset = -30;
							ttYoffset = 20;
							var line:Line = new Line(pos1, pos2, pos1 + + ttXoffset/3, pos2 + ttYoffset);
							line.stroke = stroke;
			 				ttShapes[0] = line;
					}
					
					var scale2RelativeValue:Number = NaN;
	
					if (scale3)
					{
						zPos = scale3.getPosition(currentItem[dim3]);
						// since there is no method yet to draw a real z axis 
						// we create an y axis and rotate it to properly visualize 
						// a 'fake' z axis. however zPos over this y axis corresponds to 
						// the axis height - zPos, because the y axis in Flex is 
						// up side down. this trick allows to visualize the y axis as
						// if it would be a z. when there will be a 3d line class, it will 
						// be replaced
						scale2RelativeValue = XYZ(scale3).height - zPos;
					}
	
					if (multiScale)
					{
						pos1 = multiScale.scale1.getPosition(currentItem[dim1]);
						pos2 = INumerableScale(multiScale.scales[
											currentItem[multiScale.dim1]
											]).getPosition(currentItem[dim2]);
					} else if (chart.multiScale) {
						pos1 = chart.multiScale.scale1.getPosition(currentItem[dim1]);
						pos2 = INumerableScale(chart.multiScale.scales[
											currentItem[chart.multiScale.dim1]
											]).getPosition(currentItem[dim2]);
					}
	
					if (colorScale)
					{
						var col:* = colorScale.getPosition(currentItem[colorField]);
						if (col is Number)
							fill = new SolidFill(col);
						else if (col is IGraphicsFill)
							fill = col;
					} 

					if (chart.coordType == VisScene.POLAR)
					{
	 					var xPos:Number = PolarCoordinateTransform.getX(pos1, pos2, chart.origin);
						var yPos:Number = PolarCoordinateTransform.getY(pos1, pos2, chart.origin);
	 					pos1 = xPos;
						pos2 = yPos; 
					}

					// create a separate GeometryGroup to manage interactivity and tooltips 
					createTTGG(currentItem, dataFields, pos1, pos2, scale2RelativeValue, 3);

					// in case the form is curve, it's used the BezeirSpline class to build the
					// element shape. the shape is not attached to the gg, the gg is only used to 
					// draw and manage the data items.
					if (_form == CURVE)
					{
						if (isNaN(xPrev) && isNaN(yPrev) && chart.coordType == VisScene.CARTESIAN)
						{
							// to bypass some limitation of the BezierSpline it's necessary
							// to create a double initial point. this allows the bezier line
							// to be drawn without risks of having a large initial curve
							points.push(new GraphicPoint(0, baseScale2));
							// the basescale2 is used to have a closure between points at the same height
							points.push(new GraphicPoint(0, baseScale2));
						}
						points.push(new GraphicPoint(pos1,pos2));
					} else {
						if (chart.coordType == VisScene.POLAR)
							poly.data += String(xPos) + "," + String(yPos) + " ";
		
						// create the polygon only if there is more than 1 data value
						// there cannot be an area with only the first data value 
						if (chart.coordType == VisScene.CARTESIAN)
							if (t++ > 0) 
							{
								poly = new Polygon()
								poly.data =  String(xPrev) + "," + String(y0Prev) + " " +
											String(xPrev) + "," + String(yPrev) + " " +
											String(pos1) + "," + String(pos2) + " " +
											String(pos1) + "," + String(y0);
								poly.fill = fill;
								poly.stroke = stroke;
								gg.geometryCollection.addItemAt(poly,0);
							}
					}
						
					if (_showItemRenderer)
					{
		 				var bounds:Rectangle = new Rectangle(pos1 - _rendererSize/2, pos2 - _rendererSize/2, _rendererSize, _rendererSize);
		 				
						var shape:IGeometry = itemRenderer.newInstance();
						if (shape is IBoundedRenderer) (shape as IBoundedRenderer).bounds = bounds; 

						shape.fill = fill;
						shape.stroke = stroke;
						gg.geometryCollection.addItem(shape);
					}
	
					// store previous data values coordinates, to rely them 
					// to the next data value coordinates
					y0Prev = y0;
					xPrev = pos1; yPrev = pos2;
					
					if (dim3)
					{
						gg.z = zPos;
						if (isNaN(zPos))
							zPos = 0;
					}
				}

				if (_form == CURVE)
				{
					bzSplines = new BezierSpline(points);
 					bzSplines.tension = _tension;
					bzSplines.stroke = stroke;
					bzSplines.fill = fill;
					bzSplines.graphicsTarget = [this];
					// if the coords are polar it's possible to autoclose the bezier shape
					if (chart.coordType == VisScene.POLAR)
						bzSplines.autoClose = true;

					// if the coords are cartesian we add a point with height resulted by baseScale2, in order 
					// to insure a proper closure with the 1st point inserted
					if (chart.coordType == VisScene.CARTESIAN)
					{
						points.push(new GraphicPoint(width, baseScale2));
						// the double point prevent from drawing a large final bezier curve
						points.push(new GraphicPoint(width, baseScale2-.0000000001));
					}
				} else if (chart.coordType == VisScene.POLAR && poly.data)
				{
					poly.fill = fill;
					poly.stroke = stroke;
					gg.geometryCollection.addItem(poly);
				}
	
				if (dim3)
					zSort();
				_invalidatedElementGraphic = false;
				
trace (getTimer(), "area ele");
			}
		}
		
		/** @Private 
		 * Get the x minimum position of the AreaElement (only used in case the AreaElement is drawn 
		 * vertically, i.e. the x axis is linear).*/ 
		private function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (scale1)
			{
				if (scale1 is INumerableScale)
					xPos = scale1.getPosition(minDim1Value);
			}
			
			return xPos;
		}
		
		/** @Private 
		 * Returns the y minimum position of the AreaElement.*/ 
		private function getYMinPosition():Number
		{
			var yPos:Number;
			if (scale2 && scale2 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					yPos = scale2.getPosition(_baseAt);
				else
					yPos = scale2.getPosition(minDim2Value);
			}
			return yPos;
		}
	}
}