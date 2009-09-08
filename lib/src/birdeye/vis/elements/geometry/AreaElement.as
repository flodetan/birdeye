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
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.splines.BezierSpline;
	
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
			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(UpTriangleRenderer);

			// doesn't need to call super.commitProperties(), since it doesn't need to listen
			// to axes interval changes 
			if (stackType == STACKED && chart)
			{
				if (scale2 is INumerableScale)
					INumerableScale(scale2).max = chart.maxStacked100;
			}
		}

		protected var poly:Path;
		private var bzSplines:BezierSpline;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace (getTimer(), "area ele");
				super.drawElement();
				clearAll();
				svgData = "";
				if (bzSplines)
					bzSplines.clearGraphicsTargets();
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number, zPos:Number;
				var j:Object;
				
				y0 = getYMinPosition();
				var y0Prev:Number;

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
					
					scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
															currentItem[colorField], currentItem[sizeField], currentItem);
					
					j = currentItem[dim1];
					
					// create a separate GeometryGroup to manage interactivity and tooltips 
					createTTGG(currentItem, dataFields, scaleResults[POS1], scaleResults[POS2], scaleResults[POS3relative], 3);

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
							points.push(new GraphicPoint(0, y0));
							// the basescale2 is used to have a closure between points at the same height
							points.push(new GraphicPoint(0, y0));
						}
						points.push(new GraphicPoint(scaleResults[POS1],scaleResults[POS2]));
					} else {
						if (chart.coordType == VisScene.POLAR)
							if (!data)
								data = "M" + String(scaleResults[POS1]) + "," + String(scaleResults[POS2]) + " ";
							else
								data += "L" + String(scaleResults[POS1]) + "," + String(scaleResults[POS2]) + " ";
		
						// create the polygon only if there is more than 1 data value
						// there cannot be an area with only the first data value 
						if (chart.coordType == VisScene.CARTESIAN && !isNaN(xPrev) && !isNaN(yPrev) && !isNaN(y0Prev) 
							&& !isNaN(scaleResults[POS1]) && !isNaN(scaleResults[POS2]))
						{
							var data:String;
							data =  "M" + String(xPrev) + "," + String(y0Prev) + " " +
									"L" + String(xPrev) + "," + String(yPrev) + " " +
									"L" + String(scaleResults[POS1]) + "," + String(scaleResults[POS2]) + " " +
									"L" + String(scaleResults[POS1]) + "," + String(y0) + " z";
							svgData += data;
							poly = new Path(data);
							poly.fill = fill;
							poly.stroke = stroke;
							gg.geometryCollection.addItemAt(poly,0);
						}
					}
						
					if (_showGraphicRenderer)
					{
		 				var bounds:Rectangle = new Rectangle(scaleResults[POS1] - _rendererSize/2, scaleResults[POS2] - _rendererSize/2, _rendererSize, _rendererSize);
		 				
						var shape:IGeometry = graphicRenderer.newInstance();
						if (shape is IBoundedRenderer) (shape as IBoundedRenderer).bounds = bounds; 

						shape.fill = fill;
						shape.stroke = stroke;
						gg.geometryCollection.addItem(shape);
					}
	
					// store previous data values coordinates, to rely them 
					// to the next data value coordinates
					y0Prev = y0;
					xPrev = scaleResults[POS1]; yPrev = scaleResults[POS2];
					
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
						points.push(new GraphicPoint(width, y0));
						// the double point prevent from drawing a large final bezier curve
						points.push(new GraphicPoint(width, y0-.0000000001));
					}
				} else if (chart.coordType == VisScene.POLAR && data)
				{
					data += "z";
					svgData += data;
					poly = new Path(data);
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
	}
}