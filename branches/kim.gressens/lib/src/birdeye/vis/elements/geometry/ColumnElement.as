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
	import birdeye.vis.guides.renderers.RectangleRenderer;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.*;
	
	import flash.geom.Rectangle;
	
	import org.greenthreads.IThread;

	public class ColumnElement extends StackElement implements IThread
	{
		private var _ggArray:Array;
		
		override public function get elementType():String
		{
			return "column";
		}
		
		private var _maxColumnWidth:Number = NaN;
		
		/**
		 * Set/get the maximum width a column can be.</br>
		 * @default to NaN which means unlimited.</br>
		 */
		public function set maxColumnWidth(value:Number):void
		{
			_maxColumnWidth = value;
		}
		
		public function get maxColumnWidth():Number
		{
			return _maxColumnWidth;	
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
		
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		public static const DIRECTION_VERTICAL:String = "vertical";
		public static const DIRECTION_AUTO:String = "auto";
		
		private var _direction:String = DIRECTION_VERTICAL;
		
		/**
		 * Indicate of this column/bar is drawn horizontically or vertically.</br>
		 * Automated is also a possibilit, and will determine the direction in an automated mode.</br>
		 * @default auto
		 */
		[Inspectable(enumeration="auto,horizontal,vertical")]
		public function set direction(d:String):void
		{
			_direction = d;
			
			if (_direction == DIRECTION_HORIZONTAL)
			{
				collisionScale = SCALE1;
			}
			else if (_direction == DIRECTION_VERTICAL)
			{
				collisionScale = SCALE2;
			}
		}
		
		public function get direction():String
		{
			return _direction;
		}
		
		
		public function ColumnElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (stackType == STACKED && visScene)
			{
				if (scale2 && scale2 is INumerableScale)
					INumerableScale(scale2).max = Math.max(INumerableScale(scale2).max, visScene.maxStacked100);
			}
		}
		
		
		override protected function createDefaultGraphicsRenderer() : void
		{
			_graphicsRendererInst = new RectangleRenderer();
		}
		
		
		private var _dataItemIndex:uint = 0;
		private var _drawingData:Array;
		
		private var colWidth:Number = NaN;
		private var innerColWidth:Number = NaN;

		
		public function initializeDrawingData():Boolean
		{
			if (!(isReadyForLayout() && _invalidatedElementGraphic) )
			{
				return false;
			}
			
			_dataItemIndex = 0;
			this.graphics.clear();
			
			_drawingData = new Array();
			
			/*if (direction == DIRECTION_AUTO)
			{
				// automated detection of direction
				if (scale1 && scale1 is IEnumerableScale && scale2 && scale2 is INumerableScale)
				{
					xDim = POS1;
					yDim = POS2;
				}
				else if (scale1 && scale1 is INumerableScale && scale2 && scale2 is IEnumerableScale)
				{
					xDim = POS2;
					yDim = POS1;
				}
				else
				{
					// defaults to vertical
					xDim = POS1;
					yDim = POS2;
				}
			}
			else if (direction == DIRECTION_VERTICAL)
			{
				xDim = POS1;
				yDim = POS2;
			}
			else if (direction == DIRECTION_HORIZONTAL)
			{
				xDim = POS2;
				yDim = POS1;
			}*/
			
			
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
					
				var currentItem:Object = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				_drawingData.push(scaleResults);
				
			}
			
			if (direction == DIRECTION_VERTICAL)
			{
				if (scale1)
				{
					if (scale1 is IEnumerableScale)
					{
						colWidth = scale1.size/IEnumerableScale(scale1).dataProvider.length * visScene.thicknessRatio;
					}
					else if (scale1 is INumerableScale)
					{
						colWidth = scale1.size / (INumerableScale(scale1).max - INumerableScale(scale1).min) * visScene.thicknessRatio;
					}
				}
			}
			else if (direction == DIRECTION_HORIZONTAL)
			{
				if (scale2)
				{
					if (scale2 is IEnumerableScale)
					{
						colWidth = scale2.size/IEnumerableScale(scale2).dataProvider.length * visScene.thicknessRatio;
					}
					else if (scale2 is INumerableScale)
					{
						colWidth = scale2.size / (INumerableScale(scale2).max - INumerableScale(scale2).min) * visScene.thicknessRatio;
					}
				}
			}
			
			if (!isNaN(_maxColumnWidth) && colWidth > _maxColumnWidth)
			{
				colWidth = _maxColumnWidth;
			}
			
			innerColWidth = colWidth;
			
			if (visScene.coordType == VisScene.CARTESIAN)
			{
				if (_stackType == CLUSTER)
				{
					innerColWidth = (colWidth - _clusterPadding*(_total) ) / _total;	
				}	
				
			}
			
			
			
			return true;
			
		}
		
		public function drawDataItem():Boolean
		{
			if (_dataItemIndex < _drawingData.length)
			{
				
				var d:Object = _drawingData[_dataItemIndex++];

				// save the tmp width
				var tmpWidth:Number = innerColWidth;
				
				// if a size from a scale is present, use that to change the width of column
				if (d[SIZE] && !isNaN(d[SIZE]))
				{
					tmpWidth = innerColWidth * d[SIZE];
				}
				
				
				// center the renderer using an offset
				var pos1:Number = d[POS1];
				var pos2:Number = d[POS2];
				var barWidth:Number;
				var barHeight:Number;
				
				switch(_stackType)
				{
					case OVERLAID:
					case STACKED:
						if (direction == DIRECTION_VERTICAL)
						{
							pos1 -= tmpWidth / 2;	
						}
						else if (direction == DIRECTION_HORIZONTAL)
						{
							pos2 -= tmpWidth / 2;
						}
						break;	
					case CLUSTER:
						if (direction == DIRECTION_VERTICAL)
						{
							pos1 += colWidth / 2 - (tmpWidth + clusterPadding) * (_stackPosition + 1);
						}
						else if (direction == DIRECTION_HORIZONTAL)
						{
							pos2 += colWidth / 2 - (tmpWidth + clusterPadding) * (_stackPosition + 1);
						}
						break;
				}
				
				if (direction == DIRECTION_VERTICAL)
				{
					barWidth = tmpWidth;
					barHeight = d[POS2+"base"] - d[POS2];
				}
				else if (direction == DIRECTION_HORIZONTAL)
				{
					barWidth = d[POS1+"base"] - d[POS1];
					barHeight = tmpWidth; 
				}
				
				if (_graphicsRendererInst)
				{
					if (_graphicsRendererInst is IBoundedRenderer)
					{
						(_graphicsRendererInst as IBoundedRenderer).bounds = new Rectangle(pos1, pos2, barWidth, barHeight);
					}
					
					_graphicsRendererInst.fill = d[COLOR];
					_graphicsRendererInst.stroke = stroke;
					
					_graphicsRendererInst.draw(this.graphics, null);
				}
				
				return true;
			}
			
			return false;
		}
	}
}