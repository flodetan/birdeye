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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.RectangleRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.ClassFactory;
	
	public class BarElement extends StackElement 
	{
		override public function get elementType():String
		{
			return "bar";
		}
		
		private var _maxBarWidth:Number = NaN;
		
		/**
		 * Set/get the maximum width a bar can be.</br>
		 * @default to NaN which means unlimited.</br>
		 */
		public function set maxBarWidth(value:Number):void
		{
			_maxBarWidth = value;
		}
		
		public function get maxBarWidth():Number
		{
			return _maxBarWidth;	
		}
		
		private var _clusterPadding:Number = 0;
		
		/**
		 * Set/get the padding between the bars when they are clustered.
		 * @default Default is 0, which means no padding.
		 */
		public function set clusterPadding(value:Number):void
		{
			_clusterPadding = value;
		}
		
		public function get clusterPadding():Number
		{
			return _clusterPadding;
		}
		
		
		public function BarElement()
		{
			super();
			collisionScale = SCALE1;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (!graphicRenderer)
				graphicRenderer = new ClassFactory(RectangleRenderer);
			
			if (stackType == STACKED && visScene)
			{
				if (scale1 && scale1 is INumerableScale)
					INumerableScale(scale1).max = Math.max(INumerableScale(scale1).max, visScene.maxStacked100);
			}
		}
		
		
		
		private var poly:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
				trace(getTimer(), "drawing bar");
				super.drawElement();
				
				// create the poly
				if (_source)
				{
					poly = new RasterRenderer(null, _source);
				}
				else 
				{							
					poly = graphicRenderer.newInstance();
				}
				
				if (poly is Geometry)
				{
					(poly as Geometry).autoClearGraphicsTarget = false;
				}
				
				
				var drData:Array = createDrawingData();
				drawData(drData);
				
	
				createSVG();
				_invalidatedElementGraphic = false;

				trace(getTimer(), "END drawing bar");
			}
			
		}
		
		public function createDrawingData():Array
		{
			var drawingData:Array = new Array();

			var tmpDim1:String;
			var innerBase1:Number, innerBarWidth:Number;
			var xPos:Number, yPos:Number, zPos:Number = NaN;
			var j:Object;
			
			var x0:Number = getXMinPosition();
			var size:Number = NaN, barWidth:Number = 0; 
			
			if (scale2)
			{
				if (scale2 is IEnumerableScale)
					size = scale2.size/IEnumerableScale(scale2).dataProvider.length * visScene.thicknessRatio;
				else if (scale2 is INumerableScale)
					size = scale2.size / 
						(INumerableScale(scale2).max - INumerableScale(scale2).min) * visScene.thicknessRatio;
			} 
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
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
						{
							size = scale2.dataInterval * visScene.thicknessRatio;
						}
					} 
					
					if (!isNaN(maxBarWidth) && size > maxBarWidth)
					{
						size = maxBarWidth;
					}
					
					if (scale1)
					{
						if (_stackType == STACKED)
						{
							x0 = scale1.getPosition(baseValues[j] + innerBase1);
							xPos = scale1.getPosition(
								baseValues[j] + Math.max(0,currentItem[tmpDim1] + innerBase1));
						} else {
							xPos = scale1.getPosition(currentItem[tmpDim1] + innerBase1);
						}
						dataFields["dim1"] = tmpArray[i];
					}
					
					if (isNaN(yPos) || isNaN(xPos))
					{
						continue;	
					}
					
					switch (_stackType)
					{
						case OVERLAID:
							barWidth = size;
							yPos = yPos - size/2;
							break;
						case STACKED:
							barWidth  = size;
							yPos = yPos - size/2;
							break;
						case CLUSTER:
							yPos = yPos + size/2 - (size/_total + _clusterPadding) * (_stackPosition + 1);
							barWidth  = (size - (_total - 1)) / _total;
							break;
					}
					
					var innerBarWidth:Number;
					switch (_collisionType)
					{
						case OVERLAID:
							innerBarWidth = barWidth;
							break;
						case STACKED:
							innerBarWidth = barWidth;
							x0 = scale1.getPosition(innerBase1);
							innerBase1 += currentItem[tmpDim1];
							break;
						case CLUSTER:
							innerBarWidth = (barWidth - (tmpArray.length - 1) * 5)/tmpArray.length;
							yPos = yPos + (innerBarWidth + 5)* i;
							break;
					}
					
					var bounds:Rectangle = new Rectangle(x0, yPos, xPos -x0, innerBarWidth);
					
					var scale2RelativeValue:Number = NaN;
					
					// TODO: fix stacked100 on 3D
					if (scale3)
					{
						zPos = scale3.getPosition(currentItem[dim3]);
						scale2RelativeValue = scale3.size - zPos;
					}
					
					if (colorScale)
					{
						var col:* = colorScale.getPosition(currentItem[colorField]);
						if (col is Number)
							fill = new SolidFill(col);
						else if (col is IGraphicsFill)
							fill = col;
					} 
					
					var d:Object = new Object();
					d.bounds = bounds;
					d.fill = fill;
					d.stroke = stroke;
					
					drawingData.push(d);
					
				}
			}
			
			return drawingData;
		}
		
		
		
		public function drawData(data:Array):void
		{
			// this function assumes there is an element that can be used to draw everything
			// but first we clear everything
			this.graphics.clear();
			
			// draw everything
			
			for each (var d:Object in data)
			{
				// draw each data object
				if (poly is IBoundedRenderer)
				{
					(poly as IBoundedRenderer).bounds = d.bounds;
					addSVGData((poly as IBoundedRenderer).svgData);
					
					poly.fill = d.fill;
					poly.stroke = d.stroke;
					
					poly.draw(this.graphics, null);
					
				}
				
			}
			
		}
	}
}