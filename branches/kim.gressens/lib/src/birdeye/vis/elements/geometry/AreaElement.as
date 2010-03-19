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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.splines.BezierSpline;
	
	import flash.geom.Rectangle;
	
	import org.greenthreads.IThread;

	public class AreaElement extends StackElement implements IThread
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

		private var _form:String = "line" ;
		private var _formChanged:Boolean = true;
		/** The form defines the shape type of the element, ("curve", "line").*/
		[Inspectable(enumeration="curve,line")]
		public function set form(val:String):void
		{
			if (val != _form)
			{
				_form = val;
				_formChanged = true;
				
				invalidateProperties();
			}
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
			if (val != _tension)
			{
				_tension = val;
				_tensionChanged = true;
			
				invalidateProperties();
			}
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
				_tensionChanged = false;
				if (_form == CURVE)
				{
					_bezierSpline.tension = _tension;
					invalidatingDisplay();
				}
			}
			// doesn't need to call super.commitProperties(), since it doesn't need to listen
			// to axes interval changes 
			if (stackType == STACKED && visScene)
			{
				if (scale2 is INumerableScale)
					INumerableScale(scale2).max = Math.max(visScene.maxStacked100, INumerableScale(scale2).max);
			}
		}
		
		override protected function createDefaultGraphicsRenderer() : void
		{
			_graphicsRendererInst = new UpTriangleRenderer();
			(_graphicsRendererInst as UpTriangleRenderer).autoClearGraphicsTarget = false;
		}
		
		
		private var _drawingData:Array;
		
		public function initializeDrawingData():Boolean
		{
			if (!(isReadyForLayout()) )
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
		
		private var _bezierSpline:BezierSpline;
		private var _poly:Path;
		
		private var _dataItemIndex:uint = 0;
		private var xPrev:Number, yPrev:Number, y0Prev:Number;
		
		public function drawDataItem():Boolean
		{
			
			// draw the data item
			// if the form is a curve, we draw the curve in one piece
			// if the form is not a curve, we can split it up
			if (_dataItemIndex == 0 && _form == CURVE)
			{
				var points:Array = new Array();

				if (visScene.coordType == VisScene.CARTESIAN)
				{				
					points.push(new GraphicPoint(0, _drawingData[0][POS2+"base"]));
					points.push(new GraphicPoint(0, _drawingData[0][POS2+"base"]));
				}
				
				for each(var d:Object in _drawingData)
				{
					points.push(new GraphicPoint(d[POS1], d[POS2]));
				}
				
				if (visScene.coordType == VisScene.CARTESIAN)
				{
					// need to add double points at the end
					points.push(new GraphicPoint(width, _drawingData[0][POS2+"base"]));
					// the double point prevent from drawing a large final bezier curve
					points.push(new GraphicPoint(width, _drawingData[0][POS2+"base"]-.0000000001));	
				}
				
				
				_bezierSpline.points = points;
				_bezierSpline.fill = _drawingData[0][COLOR];
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
				_poly.fill = _drawingData[0][COLOR];
				_poly.stroke = stroke;
				_poly.draw(this.graphics, null);
			}
			
			if (_form != CURVE || _showGraphicRenderer)
			{
				if (_dataItemIndex < _drawingData.length)
				{
					var d:Object = _drawingData[_dataItemIndex];
					
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
							y0Prev = d[POS2+"base"];
							
						}
						else 
						{
		
							// create the polygon only if there is more than 1 data value
							// there cannot be an area with only the first data value 
							if (!isNaN(xPrev) && !isNaN(yPrev) && !isNaN(d[POS2+"base"]) 
								&& !isNaN(d[POS2]) && !isNaN(d[POS2]))
							{
								var data:String;
								data =  "M" + String(xPrev) + "," + String(y0Prev) + " " +
									"L" + String(xPrev) + "," + String(yPrev) + " " +
									"L" + String(d[POS1]) + "," + String(d[POS2]) + " " +
									"L" + String(d[POS1]) + "," + String(d[POS2+"base"]) + " z";
								
								_poly.data = data;
								_poly.fill = d[COLOR];
								_poly.stroke = stroke;
								
								_poly.draw(this.graphics, null);
		
							}
							
							xPrev = d[POS1];
							yPrev = d[POS2];	
							y0Prev = d[POS2+"base"];
		
							
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