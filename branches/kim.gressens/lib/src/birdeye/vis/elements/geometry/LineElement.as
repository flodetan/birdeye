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
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.guides.renderers.LineRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.splines.BezierSpline;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	
	import org.greenthreads.IThread;

	public class LineElement extends StackElement implements IThread
	{
		private const CURVE:String = "curve";
		
		private var _form:String;
		private var _formChanged:Boolean = true;
		/** The form defines the shape type of the element, ("curve", "line").*/
		[Inspectable(enumeration="curve,line")]
		public function set form(val:String):void
		{
			_form = val;
			_formChanged = true;
			
			invalidateProperties();
		}
		public function get form():String
		{
			return _form;
		}
		
		private var _tension:Number = 4;
		private var _tensionChanged:Boolean = false;
		/** Set the tension of the curve form (values from 1 to 5). The higher, the closer to a line form. 
		 * The lower, the more curved the final shape. */
		public function set tension(val:Number):void
		{
			_tension = val;
			_tensionChanged = true;
			
			invalidateProperties();
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

			if (_formChanged)
			{
				_formChanged = false;
				if (_form == CURVE)
				{
					_poly = null;
					_bezierSpline = new BezierSpline();
					_bezierSpline.tension = _tension;
					_bezierSpline.autoClearGraphicsTarget = false;
					
					if (visScene && visScene.coordType == VisScene.POLAR)
					{
						_bezierSpline.autoClose = true;
					}
					else
					{
						_bezierSpline.autoClose = false;
					}
				}
				else
				{
					_bezierSpline = null;
					_poly = new Path();
					_poly.autoClearGraphicsTarget = false;
				}
				
				invalidatingDisplay();
			}
			
			if (_tensionChanged)
			{
				if (_form == CURVE)
				{
					_bezierSpline.tension = _tension;
					invalidatingDisplay();
				}
			}
		}
		
		override protected function createDefaultGraphicsRenderer() : void
		{
			_graphicsRendererInst = new LineRenderer();
		}
		
		private var _bezierSpline:BezierSpline;
		private var _poly:Path;
		
		private var _dataItemIndex:uint = 0;
		private var _drawingData:Array;
		
		public function initializeDrawingData():Boolean
		{
			if (!(isReadyForLayout() && _invalidatedElementGraphic) )
			{
				return false;
			}
			
			_dataItemIndex = 0;
			this.graphics.clear();
			
			_drawingData = new Array();			
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				var currentItem:Object = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				_drawingData.push(scaleResults);
				
			}
			
			return true;
		}
		
		private var xPrev:Number, yPrev:Number;
	
		public function drawDataItem():Boolean
		{
			if (_dataItemIndex == 0 && _form == CURVE)
			{
				var points:Array = new Array();
				
				if (visScene.coordType == VisScene.CARTESIAN)
				{
					points.push(new GraphicPoint(_drawingData[0][POS1], _drawingData[0][POS2]));
				}
				
				for each (var d:Object in _drawingData)
				{
					if (d[SIZE] && !isNaN(d[SIZE]))
					{
						stroke = new SolidStroke(colorStroke, alphaStroke, d[SIZE]);
					}
					
					if (d[COLOR] && d[COLOR] is SolidFill)
					{
						var fi:SolidFill = d[COLOR] as SolidFill;
						
						if (d[SIZE] && !isNaN(d[SIZE]))
						{
							stroke = new SolidStroke(fi.color, alphaStroke, d[SIZE]);
						}
						else
						{
							stroke = new SolidStroke(fi.color, alphaStroke, weightStroke);
						}
					}
					
					points.push(new GraphicPoint(d[POS1], d[POS2]));
				}

				if (visScene.coordType == VisScene.CARTESIAN)
				{
					points.push(new GraphicPoint(_drawingData[_drawingData.length - 1][POS1]+.0000001, _drawingData[_drawingData.length - 1][POS2]));
				}

				_bezierSpline.points = points;
				_bezierSpline.stroke = stroke;
				_bezierSpline.preDraw();
				_bezierSpline.draw(this.graphics, null);

				
			}
			
			if (_dataItemIndex == 0 &&  _form != CURVE && visScene.coordType == VisScene.POLAR)
			{
				// build the area in one go, it's one path
				
				var data:String;
				
				for each (var d:Object in _drawingData)
				{
					if (!data)
					{
						data = "M" + String(d[POS1]) + "," + String(d[POS2]) + " ";
					}
					else
					{
						data += "L" + String(d[POS1]) + "," + String(d[POS2]) + " ";	
					}
				}
				
				data += "z";
				_poly.data = data;
				_poly.stroke = stroke;
				_poly.draw(this.graphics, null);
			}
			
			if (_form != CURVE || _showGraphicRenderer)
			{
				if (_dataItemIndex < _drawingData.length)
				{
					var d:Object = _drawingData[_dataItemIndex];
					
					if (d[SIZE] && !isNaN(d[SIZE]))
					{
						stroke = new SolidStroke(colorStroke, alphaStroke, d[SIZE]);
					}
					
					if (d[COLOR] && d[COLOR] is SolidFill)
					{
						var fi:SolidFill = d[COLOR] as SolidFill;
						
						if (d[SIZE] && !isNaN(d[SIZE]))
						{
							stroke = new SolidStroke(fi.color, alphaStroke, d[SIZE]);
						}
						else
						{
							stroke = new SolidStroke(fi.color, alphaStroke, weightStroke);
						}
					}
					
					if (_showGraphicRenderer && _graphicsRendererInst)
					{
						if (_graphicsRendererInst is IBoundedRenderer)
						{
							(_graphicsRendererInst as IBoundedRenderer).bounds = new Rectangle(d[POS1] - _rendererSize/2, d[POS2] - _rendererSize/2, _rendererSize, _rendererSize);;
							
						}
						_graphicsRendererInst.fill = d.fill;
						_graphicsRendererInst.stroke = stroke;
						_graphicsRendererInst.draw(this.graphics, null);
						
					}
					
					if (_form != CURVE)
					{
						
						if (_dataItemIndex == 0)
						{
							xPrev = d[POS1];
							yPrev = d[POS2];
							
						}
						else 
						{
							
							// create the polygon only if there is more than 1 data value
							// there cannot be an area with only the first data value 
							if (!isNaN(xPrev) && !isNaN(yPrev)
								&& !isNaN(d[POS2]) && !isNaN(d[POS1]))
							{
								var data:String;
								data =  "M" + String(xPrev) + "," + String(yPrev) + " " +
									"L" + String(d[POS1]) + "," + String(d[POS2]) + " ";
								
								_poly.data = data;
								_poly.stroke = stroke;
								
								
								_poly.draw(this.graphics, null);
								
							}
							
							xPrev = d[POS1];
							yPrev = d[POS2];	
							
							
						}
					}
					
					
					_dataItemIndex++;
					
					return true;
				}
				
				
				
			}
			
			return false;
			
		}
		
 	}
}