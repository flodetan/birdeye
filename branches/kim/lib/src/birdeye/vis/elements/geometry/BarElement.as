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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.RectangleRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	
	import mx.core.ClassFactory;

	public class BarElement extends StackElement 
	{
		override public function get elementType():String
		{
			return "bar";
		}

		public function BarElement()
		{
			super();
			collisionScale = HORIZONTAL;
		}
	
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (!itemRenderer)
				itemRenderer = new ClassFactory(RectangleRenderer);

			if (stackType == STACKED100 && chart)
			{
				if (scale1 && scale1 is INumerableScale)
					INumerableScale(scale1).max = chart.maxStacked100;
			}
		}

		private var poly:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
				super.drawElement();
				removeAllElements();
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim2;
				dataFields[1] = dim1;
				if (dim3) 
					dataFields[2] = dim3;
	
				var xPos:Number, yPos:Number, zPos:Number = NaN;
				var j:Object;
	
				var ttShapes:Array;
				var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
			
				var x0:Number = getXMinPosition();
				var size:Number = NaN, barWidth:Number = 0; 
				if (scale2)
				{
					if (scale2 is IEnumerableScale)
						size = scale2.size/IEnumerableScale(scale2).dataProvider.length * chart.columnWidthRate;
					else if (scale2 is IEnumerableScale)
						size = scale2.size / 
								(INumerableScale(scale1).max - INumerableScale(scale2).min) * chart.columnWidthRate;
				} 
	
				ggIndex = 0;
	
				var tmpDim1:String;
				var innerBase1:Number;

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
					
					var tmpArray:Array = (dim1 is Array) ? dim1 as Array : [String(dim1)];
					
					innerBase1 = 0;
					j = currentItem[dim2];

					for (var i:Number = 0; i<tmpArray.length; i++)
					{
						tmpDim1 = tmpArray[i];
						if (scale2)
						{
							yPos = scale2.getPosition(currentItem[dim2]);
		
							if (isNaN(size))
		 						size = scale2.dataInterval * chart.columnWidthRate;
						} 
						
						if (scale1)
						{
							if (_stackType == STACKED100)
							{
								x0 = scale1.getPosition(baseValues[j] + innerBase1);
								xPos = scale1.getPosition(
									baseValues[j] + Math.max(0,currentItem[tmpDim1] + innerBase1));
							} else {
								xPos = scale1.getPosition(currentItem[tmpDim1] + innerBase1);
							}
							dataFields[1] = dim1;
						}
						
						switch (_stackType)
						{
							case OVERLAID:
								barWidth = size;
								yPos = yPos - size/2;
								break;
							case STACKED100:
								barWidth  = size;
								yPos = yPos - size/2;
								ttShapes = [];
								ttXoffset = -20;
								ttYoffset = 50;
								var line:Line = new Line(xPos, yPos + barWidth/2, xPos + ttXoffset/3, yPos + barWidth/2 + ttYoffset);
								line.stroke = stroke;
				 				ttShapes[0] = line;
								break;
							case STACKED:
								yPos = yPos + size/2 - size/_total * _stackPosition;
								barWidth  = size/_total;
								break;
						}
						
						var innerBarWidth:Number;
						switch (_collisionType)
						{
							case OVERLAID:
								innerBarWidth = barWidth;
								break;
							case STACKED100:
								innerBarWidth = barWidth;
								x0 = scale1.getPosition(innerBase1);
								innerBase1 += currentItem[tmpDim1];
								break;
							case STACKED:
								innerBarWidth = barWidth/tmpArray.length;
								yPos = yPos + innerBarWidth * i;
								if (ttShapes && ttShapes[0] is Line)
								{
 					 				Line(ttShapes[0]).y = yPos + innerBarWidth/2;
					 				Line(ttShapes[0]).y1 = yPos + innerBarWidth/2 + ttYoffset;
 								}
								break;
						}
							
						var bounds:Rectangle = new Rectangle(x0, yPos, xPos -x0, innerBarWidth);
		
						var scale2RelativeValue:Number = NaN;
		
						// TODO: fix stacked100 on 3D
						if (scale3)
						{
							zPos = scale3.getPosition(currentItem[dim3]);
							scale2RelativeValue = XYZ(scale3).height - zPos;
						}
		
						if (colorScale)
						{
							var col:* = colorScale.getPosition(currentItem[colorField]);
							if (col is Number)
								fill = new SolidFill(col);
							else if (col is IGraphicsFill)
								fill = col;
						} 
		
						// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
						// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
						createTTGG(currentItem, dataFields, xPos, yPos+innerBarWidth/2, scale2RelativeValue, 3,ttShapes,ttXoffset,ttYoffset);
		
						if (dim3)
						{
							if (!isNaN(zPos))
							{
								gg = new DataItemLayout();
								gg.target = this;
								graphicsCollection.addItem(gg);
								ttGG.z = gg.z = zPos;
							} else
								zPos = 0;
						}
						
						if (_extendMouseEvents)
							gg = ttGG;
		
		 				if (_source)
		 				{
							poly = new RasterRenderer(bounds, _source);
		 				}
		 				else 
						{							
							poly = itemRenderer.newInstance();
							if (poly is IBoundedRenderer) (poly as IBoundedRenderer).bounds = bounds;
		
						}
							
						if (_showItemRenderer)
						{

							var shape:IGeometry = itemRenderer.newInstance();
							if (shape is IBoundedRenderer) (shape as IBoundedRenderer).bounds = bounds;
							shape.fill = fill;
							shape.stroke = stroke;
							gg.geometryCollection.addItem(shape);
						}
		
						poly.fill = fill;
						poly.stroke = stroke;
						gg.geometryCollection.addItemAt(poly,0);
					}
		
					if (dim3)
						zSort();
					_invalidatedElementGraphic = false;
				}
			}
		}
		
		private function getXMinPosition():Number
		{
			var xPos:Number;
			if (scale1 && scale1 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					xPos = scale1.getPosition(_baseAt);
				else
					xPos = scale1.getPosition(INumerableScale(scale1).min);
			}
			return xPos;
		}
	}
}