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
	import birdeye.vis.guides.renderers.ArcPath;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.RectangleRenderer;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class ColumnElement extends StackElement 
	{
		override public function get elementType():String
		{
			return "column";
		}

		private var _form:String;
		public function set form(val:String):void
		{
			_form = val;
			invalidateDisplayList();
		}

		public function ColumnElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (!itemRenderer)
				itemRenderer = RectangleRenderer;

			if (stackType == STACKED100 && chart)
			{
				if (scale2 && scale2 is INumerableScale)
					INumerableScale(scale2).max = chart.maxStacked100;
			}
		}

		private var poly:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
//			var renderer:ISeriesDataRenderer = new itemRenderer();
			
			if (isReadyForLayout())
			{
				removeAllElements();
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim1;
				dataFields[1] = dim2;
				if (dim3) 
					dataFields[2] = dim3;
	
				var pos1:Number, pos2:Number, zPos:Number = NaN;
				var j:Object;
				
				var ttShapes:Array;
				var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
				
				var baseScale2:Number = getDim2MinPosition();
				var size:Number, colWidth:Number = 0; 
				if (scale1)
				{
					if (scale1 is IEnumerableScale)
						size = scale1.size/IEnumerableScale(scale1).dataProvider.length * deltaSize;
					else if (scale1 is IEnumerableScale)
						size = scale1.size / 
								(INumerableScale(scale1).max - INumerableScale(scale1).min) * deltaSize;
				}
	
				if (graphicsCollection.items && graphicsCollection.items.length>0)
					gg = graphicsCollection.items[0];
				else
				{
					gg = new DataItemLayout();
					graphicsCollection.addItem(gg);
				}
				gg.target = this;
				ggIndex = 1;
	
				if (chart.coordType == VisScene.POLAR)
				{
					var arcSize:Number = NaN;
			
					var angleInterval:Number;
					if (scale1) 
						angleInterval = scale1.interval * chart.columnWidthRate;
					else if (multiScale)
						angleInterval = multiScale.scale1.interval * chart.columnWidthRate;
					else if (chart.multiScale)
						angleInterval = chart.multiScale.scale1.interval * chart.columnWidthRate;
						
					switch (_stackType)
					{
						case STACKED:
							arcSize = angleInterval/_total;
							break;
						case OVERLAID:
						case STACKED100:
							arcSize = angleInterval;
							break;
					}
				}
				cursor.seek(CursorBookmark.FIRST);
	
				while (!cursor.afterLast)
				{
					if (scale1)
					{
						pos1 = scale1.getPosition(cursor.current[dim1]);
					}
					
					j = cursor.current[dim1];
					if (scale2)
					{
						
						if (_stackType == STACKED100)
						{
							baseScale2 = scale2.getPosition(baseValues[j]);
							pos2 = scale2.getPosition(
								baseValues[j] + Math.max(0,cursor.current[dim2]));
						} else {
							pos2 = scale2.getPosition(cursor.current[dim2]);
						}
					}
					
					var scale2RelativeValue:Number = NaN;
	
					// TODO: fix stacked100 on 3D
					if (scale3)
					{
						zPos = scale3.getPosition(cursor.current[dim3]);
						scale2RelativeValue = XYZ(scale3).height - zPos;
					}
	
					if (multiScale)
					{
						pos1 = multiScale.scale1.getPosition(cursor.current[dim1]);
						pos2 = INumerableScale(multiScale.scales[
											cursor.current[multiScale.dim1]
											]).getPosition(cursor.current[dim2]);
					} else if (chart.multiScale) {
						pos1 = chart.multiScale.scale1.getPosition(cursor.current[dim1]);
						pos2 = INumerableScale(chart.multiScale.scales[
											cursor.current[chart.multiScale.dim1]
											]).getPosition(cursor.current[dim2]);
					}
	
					if (chart.coordType == VisScene.CARTESIAN)
					{
						switch (_stackType)
						{
							case OVERLAID:
								colWidth = size;
								pos1 = pos1 - size/2;
								break;
							case STACKED100:
								colWidth = size;
								pos1 = pos1 - size/2;
								ttShapes = [];
								ttXoffset = -20;
								ttYoffset = 55;
								if (chart.customTooltTipFunction == null)
								{
									var line:Line = new Line(pos1+ colWidth/2, pos2, pos1 + colWidth/2 + ttXoffset/3, pos2 + ttYoffset);
									line.stroke = new SolidStroke(0xaaaaaa,1,2);
					 				ttShapes[0] = line;
								}
								break;
							case STACKED:
								pos1 = pos1 + size/2 - size/_total * _stackPosition;
								colWidth = size/_total;
								break;
						}
						
						if (colorScale)
						{
							var col:* = colorScale.getPosition(cursor.current[colorField]);
							if (col is Number)
								fill = new SolidFill(col);
							else if (col is IGraphicsFill)
								fill = col;
						} 
	
		 				var bounds:Rectangle = new Rectangle(pos1, pos2, colWidth, baseScale2 - pos2);
		
						// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
						// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
						createTTGG(cursor.current, dataFields, pos1 + colWidth/2, pos2, scale2RelativeValue, 3,ttShapes,ttXoffset,ttYoffset);
		
						if (dim3)
						{
							if (!isNaN(zPos))
							{
								gg = new DataItemLayout();
								gg.target = this;
								graphicsCollection.addItem(gg);
								ttGG.posZ = ttGG.z = gg.posZ = gg.z = zPos;
							} else
								zPos = 0;
						}
		
						if (ttGG && _extendMouseEvents)
							gg = ttGG;
						
		//				poly = renderer.getGeometry(bounds);
		
		 				if (_source)
							poly = new RasterRenderer(bounds, _source);
		 				else 
							poly = new itemRenderer(bounds);
		
						poly.fill = fill;
						poly.stroke = stroke;
						gg.geometryCollection.addItemAt(poly,0);
					} else if (chart.coordType == VisScene.POLAR)
					{
/* 						var arcCenterX:Number = chart.origin.x - pos2;
						var arcCenterY:Number = chart.origin.y - pos2;
 */
						var startAngle:Number; 
						switch (_stackType) 
						{
							case STACKED:
								startAngle = pos1 - angleInterval/2 +arcSize*_stackPosition;
								break;
							case OVERLAID:
							case STACKED100:
								startAngle = pos1 - angleInterval/2;
								break;
						}
						var wSize:Number, hSize:Number;
						wSize = hSize = pos2*2;
		
						var xPos:Number = PolarCoordinateTransform.getX(startAngle+arcSize/2, pos2, chart.origin);
						var yPos:Number = PolarCoordinateTransform.getY(startAngle+arcSize/2, pos2, chart.origin); 
	 	
						createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _size);
						
						if (ttGG && _extendMouseEvents)
							gg = ttGG;
							
						var arc:IGeometry;
						
						if (stackType == STACKED100)
							arc = 
								new ArcPath(Math.max(0, baseScale2), pos2, startAngle, arcSize, chart.origin);
						else
							arc = 
								new ArcPath(Math.max(0, baseScale2), pos2, startAngle, arcSize, chart.origin);
//								new EllipticalArc(arcCenterX, arcCenterY, wSize, hSize, startAngle, arcSize, "pie");
		
						arc.fill = fill;
						arc.stroke = stroke;
						gg.geometryCollection.addItemAt(arc,0); 
					}
	
					if (_showItemRenderer)
					{
						var shape:IGeometry = new itemRenderer(bounds);
						shape.fill = fill;
						shape.stroke = stroke;
						gg.geometryCollection.addItem(shape);
					}
	
					cursor.moveNext();
				}
	
				if (dim3)
					zSort();
			}
		}
		
/* 		private function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (xAxis)
			{
				if (xAxis is NumericAxis)
					xPos = xAxis.getPosition(minXValue);
			} else {
				if (chart.xAxis is NumericAxis)
					xPos = chart.xAxis.getPosition(minXValue);
			}
			
			return xPos;
		}
 */		
		private function getDim2MinPosition():Number
		{
			var pos2:Number;
			if (scale2 && scale2 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					pos2 = scale2.getPosition(_baseAt);
				else
					pos2 = scale2.getPosition(INumerableScale(scale2).min);
			}
			return pos2;
		}
	}
}