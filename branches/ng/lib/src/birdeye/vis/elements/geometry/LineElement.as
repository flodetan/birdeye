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
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.LineRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.splines.BezierSpline;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;

	public class LineElement extends StackElement
	{
		private const CURVE:String = "curve";
		
		private var _form:String;
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
		
		private var _tension:Number = 2;
		/** Set the tension of the curve form (values from 1 to 5). The higher, the closer to a line form. 
		 * The lower, the more curved the final shape. */
		public function set tension(val:Number):void
		{
			_tension = val;
			invalidatingDisplay();
		}
		
		
		
		private var _autoClose:Boolean = true;
		/**
		 * Set if the line needs to be autoclosed in a polar chart.
		 * Defaults to true.
		 */
		[Inspectable(enumeration="true,false")]
		public function set autoClose(a:Boolean):void
		{
			if (a != _autoClose)
			{
				_autoClose = a;
				invalidatingDisplay();
			}
		}
		
		public function get autoClose():Boolean
		{
			return _autoClose;
		}
		
		public function LineElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(LineRenderer);
		}

		private var bzSplines:BezierSpline;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace (getTimer(), "drawing line ele");
				super.drawElement();
				clearAll();
				
				if (bzSplines)
					bzSplines.clearGraphicsTargets();
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number, zPos:Number;
				var j:Number = 0;
				
				var y0:Number = getYMinPosition();
				var x0:Number = getXMinPosition();

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
					
					if (isNaN(scaleResults[POS1]) || isNaN(scaleResults[POS2]))
					{
						continue;
					}
	
					if (visScene.coordType == VisScene.POLAR)
					{
						if (j == 0)
						{
							var firstX:Number = scaleResults[POS1], firstY:Number = scaleResults[POS2];
						}
					}

					if (sizeScale)
					{
						 var weight:Number = scaleResults[SIZE];
						stroke = new SolidStroke(colorStroke, alphaStroke, weight);
					}

					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(currentItem, dataFields, scaleResults[POS1], scaleResults[POS2], scaleResults[POS3relative], 3);
   	 
					if (dim3)
					{
						if (!isNaN(scaleResults[POS3]))
						{
							gg = new DataItemLayout();
							gg.target = this;
							graphicsCollection.addItem(gg);
							ttGG.z = gg.z = zPos;
						} else
							zPos = 0;
					}
					
					if (_form == CURVE)
					{
						points.push(new GraphicPoint(scaleResults[POS1],scaleResults[POS2]));
						if (isNaN(xPrev) && isNaN(yPrev) && visScene.coordType != VisScene.POLAR)
							points.push(new GraphicPoint(scaleResults[POS1],scaleResults[POS2]));
					} else if (j++ > 0)
					{
						if (!isNaN(xPrev) && !isNaN(yPrev) && !isNaN(scaleResults[POS1]) && !isNaN(scaleResults[POS2]))
						{
							var data:String = "M" + String(xPrev) + "," + String(yPrev) + " " +
											"L" + String(scaleResults[POS1]) + "," + String(scaleResults[POS2]);
							var line:Path= new Path(data);
							addSVGData('\n<path d="' + data + '"/>');
							line.fill = fill;
							line.stroke = stroke;
							gg.geometryCollection.addItemAt(line,0);
							line = null;     
						}
					}
	
					if (_showGraphicRenderer)
					{
		 				var bounds:Rectangle = new Rectangle(scaleResults[POS1] - _rendererSize/2, scaleResults[POS2] - _rendererSize/2, _rendererSize, _rendererSize);
						
						var shape:IGeometry = graphicRenderer.newInstance();
						if (shape is IBoundedRenderer)
						{
							(shape as IBoundedRenderer).bounds = bounds; 
							addSVGData(IBoundedRenderer(shape).svgData);
						}
						shape.fill = fill;
						shape.stroke = stroke;
						gg.geometryCollection.addItem(shape);
					}
	
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
					points.push(new GraphicPoint(scaleResults[POS1]+.0000001,scaleResults[POS2]));
						
					bzSplines = new BezierSpline(points);
 					bzSplines.tension = _tension;
					bzSplines.stroke = stroke;
					bzSplines.graphicsTarget = [this];
					if (visScene.coordType == VisScene.POLAR && autoClose)
						bzSplines.autoClose = true;
				}
				
				if (visScene.coordType == VisScene.POLAR && autoClose && !isNaN(firstX) && !isNaN(firstY) 
					&& !isNaN(scaleResults[POS1]) && !isNaN(scaleResults[POS2]))
				{
						data = "M" + String(scaleResults[POS1]) + "," + String(scaleResults[POS2]) + " " +
								"L" + String(firstX) + "," + String(firstY);
						line = new Path(data);
						addSVGData('\n<path d="' + data + '"/>');
						line.fill = fill;
						line.stroke = stroke;
						gg.geometryCollection.addItemAt(line,0);
						line = null;
				}
	
				if (dim3)
					zSort();

				createSVG();
				_invalidatedElementGraphic = false;
trace (getTimer(), "drawing line ele");
			}
		}
 	}
}