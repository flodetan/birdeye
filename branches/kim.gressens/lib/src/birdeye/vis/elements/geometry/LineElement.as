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
	import birdeye.vis.interactivity.geometry.InteractivePath;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.splines.BezierSpline;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
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
		
		private var _drawingData:Array;
		
		override public function preDraw():Boolean
		{
			if (!(isReadyForLayout() && _invalidatedElementGraphic) )
			{
				return false;
			}

			this.graphics.clear();
			
			_drawingData = new Array();			
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				var currentItem:Object = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				if (visScene.coordType == VisScene.POLAR)
				{
					var xPos:Number = PolarCoordinateTransform.getX(scaleResults[POS1], scaleResults[POS2], visScene.origin);
					var yPos:Number = PolarCoordinateTransform.getY(scaleResults[POS1], scaleResults[POS2], visScene.origin);
					scaleResults[POS1] = xPos;
					scaleResults[POS2] = yPos; 
				}
				
				_drawingData.push(scaleResults);
				
			}
			
			if (_form == CURVE)
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
			
			upperPoints = new Vector.<Point>();
			lowerPoints = new Vector.<Point>();
			geomIndex = 0;
			
			
			return true && super.preDraw();
		}
		
		private var xPrev:Number, yPrev:Number;
	
		override public function drawDataItem():Boolean
		{				
			var d:Object = _drawingData[_currentItemIndex];

			if (_form != CURVE && visScene.coordType == VisScene.POLAR && _currentItemIndex == 0)
			{
				// add a point previous, because we're closing the line
				var dt:Object = _drawingData[_drawingData.length - 1];
				addPoint(dt);
			}
			
			addPoint(d);
			initInteractivePath();
				
			if (_form != CURVE || _showGraphicRenderer)
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
					
					if (_currentItemIndex == 0)
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
					
					return true && super.drawDataItem();
				}
				
			}
			
			return false;
			
		}
		
		private var upperPoints:Vector.<Point>;
		private var lowerPoints:Vector.<Point>;
		protected var geometries:Vector.<InteractivePath> = new Vector.<InteractivePath>;
		protected var geomIndex:int = 0;
		
		protected function addPoint(scaleResult:Object):void
		{
			upperPoints.push(new Point(scaleResult[POS1] , scaleResult[POS2]));
			lowerPoints.splice(0, 0, new Point(scaleResult[POS1], scaleResult[POS2]));
			
			if (upperPoints.length > 3)
			{
				upperPoints.shift();
			}
			
			if (lowerPoints.length > 3)
			{
				lowerPoints.pop();
			}
			
		}
		
		protected function initInteractivePath(isEnd:Boolean=false):void
		{
			if (upperPoints.length < 2) return;
			if (upperPoints.length == 2 && (_form != CURVE && visScene.coordType == VisScene.POLAR && !isEnd)) return;
			
			var geom:InteractivePath;
			
			var isNew:Boolean = false;
			
			if (geomIndex < geometries.length)
			{
				geom = geometries[geomIndex];
				geom.reset();
			}
			else
			{
				// add a new one
				geom = new InteractivePath();
				geom.element = this;
				geometries.push(geom);
				isNew = true;
			}
			
			var highestIndex:int = -1;
			var lowestY:Number = Number.MAX_VALUE;
			var i:uint = 0;
			for each (var p:Point in upperPoints)
			{
				var p2:Point = new Point(p.x, p.y - 50);
				if (p.y < lowestY)
				{
					lowestY = p.y;
					highestIndex = i;
				}
				
				geom.addPoint(p2);
				i++;
			}
			
			for each (p in lowerPoints)
			{
				var p2:Point = new Point(p.x, p.y + 50);
				geom.addPoint(p2);
			}
			
			var up:Point = new Point(upperPoints[0].x, upperPoints[0].y - 50);
			geom.addPoint(up);
			
			if (upperPoints.length == 2)
			{
				if (!isEnd)
				{
					geom.preferredTooltipPoint = upperPoints[0];
					
					if (highestIndex == 0)
					{
						geom.preferredTooltipPoint.y -= 10;
					}
					else if (highestIndex == 1)
					{
						geom.preferredTooltipPoint.y += 10;
					}
				}
				else
				{
					geom.preferredTooltipPoint = upperPoints[1];
					
					if (highestIndex == 0)
					{
						geom.preferredTooltipPoint.y += 10;
					}
					else if (highestIndex == 1)
					{
						geom.preferredTooltipPoint.y -= 10;
					}
					
				}
			}
			else if (upperPoints.length == 3)
			{
				
				geom.preferredTooltipPoint = upperPoints[1];
				
				if (highestIndex == 1)
				{
					geom.preferredTooltipPoint.y -= 10;
				}
				else if (highestIndex == 0 || highestIndex == 2)
				{
					geom.preferredTooltipPoint.y += 10;
				}
			}
			
			geom.data = _dataItems[geomIndex];
			
			//if (isNew)
			//{						
			this.visScene.interactivityManager.registerGeometry(geom);
			//}
			
			
			geomIndex++;
		}
		
		override public function endDraw():void
		{
			super.endDraw();
			
			if (_form != CURVE && visScene.coordType == VisScene.POLAR)
			{
				// build the area in one go, it's one path
				
				var data:String = "M" + String(_drawingData[0][POS1]) + "," + String(_drawingData[0][POS2]) + " ";
				data += "L" + String(xPrev) + "," + String(yPrev) + " ";	
				data += "z";
				_poly.data = data;
				_poly.stroke = stroke;
				_poly.draw(this.graphics, null);
				
				addPoint(_drawingData[0]);
			} 
			else if (upperPoints.length > 2)
			{
				upperPoints.shift();
				lowerPoints.pop();
			}			
			
			initInteractivePath(true);
			
			// check if there are geometries which are unnecessary
			if (geometries.length > _dataItems.length)
			{
				// to many geometries, unregister some
				while (geometries.length > _dataItems.length)
				{
					this.visScene.interactivityManager.unregisterGeometry(geometries.pop());
				}
			}
		}
		
 	}
}