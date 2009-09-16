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
	import birdeye.vis.guides.renderers.RectangleRenderer;
	import birdeye.vis.interfaces.IExportableSVG;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import mx.containers.Canvas;
	import mx.core.ClassFactory;
	import mx.core.IFactory;

	public class IsotypeElement extends StackElement
	{
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		
		private var _direction:String = HORIZONTAL;
		[Inspectable(enumeration="horizontal,vertical")]
		public function set direction(val:String):void
		{
			_direction = val;
			if (direction == VERTICAL)
				collisionScale = SCALE2;
			else 
				collisionScale = SCALE1;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get direction():String
		{
			return _direction;
		}
		
		private var _itemRenderer:IFactory;
		/** Set the item renderer following the standard Flex approach. The item renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set itemRenderer(val:IFactory):void
		{
			_itemRenderer = val;
			invalidatingDisplay();
		}
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		override public function get svgData():String
		{
			_svgData = "";
			var child:Object;
			var localOriginPoint:Point = localToGlobal(new Point(x, y)); 
			for (var i:uint = 0; i<numChildren; i++)
			{
				child = getChildAt(i);
				if (child is Canvas)
				{
					var canvasPosition:Point = localToGlobal(new Point((child as Canvas).x, (child as Canvas).y));
					if (direction == VERTICAL)
						_svgData += '<svg x="' + String(canvasPosition.x -localOriginPoint.x) + 
									'" y="' + String(canvasPosition.y - localOriginPoint.y) + 
									'" width="' + (child as Canvas).width + 
									'">';
					else
						_svgData += '<svg x="' + String(canvasPosition.x -localOriginPoint.x) + 
									'" y="' + String(canvasPosition.y - localOriginPoint.y) + 
									'" height="' + (child as Canvas).height +
									'">';

 					var canvasChildren:Array = child.getChildren();
					for each (var isotype:DisplayObject in canvasChildren)
						if (isotype is IExportableSVG)
							_svgData += '<svg x="' + isotype.x + 
											'" y="' + isotype.y + 
											'" width="' + isotype.width + 
											'" height="' + isotype.height + '">' +
										IExportableSVG(isotype).svgData +
										'</svg>'; 
					_svgData += '\n</svg>';
				}
			}

			return _svgData;
		}

		override public function get elementType():String
		{
			return "isotype";
		}
		
		private var _rendererDataValue:Number;
		/** Set a unit data value to the renderer used for the Isotype.*/
		public function set rendererDataValue(val:Number):void
		{
			_rendererDataValue = val;
		}
		public function get rendererDataValue():Number
		{
			return _rendererDataValue;
		}

		public function IsotypeElement()
		{
			super();
			direction = HORIZONTAL;
			collisionScale = SCALE1;
		}
	
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! graphicRenderer)
				graphicRenderer = new ClassFactory(RectangleRenderer);
		}

		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
trace(getTimer(), "drawing isotype");
				super.drawElement();
				clearAll();

				if (direction == HORIZONTAL)
					drawHorizontalLayout();
				else
					drawVerticalLayout();

				_invalidatedElementGraphic = false;
	trace(getTimer(), "END drawing isotype");
			}

		}
		
		private function createIsoGeometries(displayObj:DisplayObject, bounds:RegularRectangle, totalValue:Number, unitValue:Number):Canvas
		{
			var isoGroup:Canvas = new Canvas();
  			isoGroup.verticalScrollPolicy = "off";
			isoGroup.horizontalScrollPolicy = "off"; 
 			
			var totalPixels:Number;
			var actualRendererSize:Number;
			if (direction == VERTICAL)
			{
				totalPixels = Math.abs(bounds.height);
				actualRendererSize = displayObj.height;
			} else {
				totalPixels = Math.abs(bounds.width);
				actualRendererSize = displayObj.width;
			}
			
			var unitPixels:Number = totalPixels * unitValue/totalValue;
			var resizingRatio:Number = actualRendererSize / unitPixels;
			
			displayObj.width /= resizingRatio;
			displayObj.height /= resizingRatio;
			
			var numRepetitions:Number = Math.ceil(totalValue / unitValue);
			for (var i:uint = 0; i<numRepetitions; i++)
			{
				var resizedItem:DisplayObject = itemRenderer.newInstance();
				resizedItem.width = (displayObj.width > 0) ? displayObj.width : unitPixels;
				resizedItem.height = (displayObj.height > 0) ? displayObj.height : unitPixels;
				if (direction == VERTICAL)
				{
					resizedItem.x = bounds.width/2 - resizedItem.width/2
					if (scale2.direction == BaseScale.POSITIVE)
						resizedItem.y = totalPixels - resizedItem.height * (i+1);
					else 
						resizedItem.y = resizedItem.height * i - totalPixels;
				} else {
					resizedItem.y = bounds.height/2 - resizedItem.height/2
					if (scale1.direction == BaseScale.POSITIVE)
						resizedItem.x = resizedItem.width * i + (unitPixels-resizedItem.width)/2;
					else 
						resizedItem.x = totalPixels - (resizedItem.width * (i+1) + (unitPixels-resizedItem.width)/2);
				}
				
				isoGroup.addChild(resizedItem);
			}
			return isoGroup;
		}

		private function drawHorizontalLayout():void
		{
			var xPos:Number, yPos:Number, zPos:Number = NaN;
			var j:Object;

			var x0:Number = getXMinPosition();

			var availableThickness:Number = NaN, finalThickness:Number = 0; 
			if (scale2)
			{
				if (scale2 is IEnumerableScale)
					availableThickness = scale2.size/IEnumerableScale(scale2).dataProvider.length * chart.thicknessRatio;
				else if (scale2 is INumerableScale)
					availableThickness = scale2.size / 
							(INumerableScale(scale2).max - INumerableScale(scale2).min) * chart.thicknessRatio;
			} 

			ggIndex = 0;

			var tmpDim1:String;
			var innerBase1:Number;

			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				var currentItem:Object = _dataItems[cursorIndex];
				
				var tmpArray:Array = (dim1 is Array) ? dim1 as Array : [String(dim1)];
				
				innerBase1 = 0;
				j = currentItem[dim2];

				for (var i:Number = 0; i<tmpArray.length; i++)
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

					tmpDim1 = tmpArray[i];
					if (scale2)
					{
						yPos = scale2.getPosition(currentItem[dim2]);
	
						if (isNaN(availableThickness))
	 						availableThickness = scale2.dataInterval * chart.thicknessRatio;
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
						dataFields[DIM1] = tmpArray[i];
					}
					
					if (isNaN(yPos) || isNaN(xPos))
					{
						continue;	
					}
					
					switch (_stackType)
					{
						case OVERLAID:
							finalThickness = availableThickness;
							yPos = yPos - availableThickness/2;
							break;
						case STACKED:
							finalThickness  = availableThickness;
							yPos = yPos - availableThickness/2;
							break;
						case CLUSTER:
							yPos = yPos + availableThickness/2 - availableThickness/_total * (_stackPosition + 1);
							finalThickness  = availableThickness/_total;
							break;
					}
					
					var innerThickness:Number;
					switch (_collisionType)
					{
						case OVERLAID:
							innerThickness = finalThickness;
							break;
						case STACKED:
							innerThickness = finalThickness;
							x0 = scale1.getPosition(innerBase1);
							innerBase1 += currentItem[tmpDim1];
							break;
						case CLUSTER:
							innerThickness = finalThickness/tmpArray.length;
							yPos = yPos + innerThickness * i;
							break;
					}
						
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

					var bounds:RegularRectangle = new RegularRectangle(x0, yPos, xPos -x0, innerThickness);
					bounds.fill = fill;
					bounds.alpha = 0;

					createTTGG(currentItem, dataFields, xPos, yPos+innerThickness/2, scale2RelativeValue, 3, i);

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
					{
						gg = ttGG;
						gg.target = this;
					}
					gg.geometryCollection.addItem(bounds);
					
					var itmDisplay:DisplayObject;
					if (itemRenderer != null)
					{
						itmDisplay = itemRenderer.newInstance();
					}
					var totalValue:Number;
					totalValue = currentItem[tmpDim1];
					
					var isoGeometries:Canvas = createIsoGeometries(itmDisplay, bounds, totalValue, rendererDataValue);
					isoGeometries.width = Math.abs(bounds.width);
					isoGeometries.height = Math.abs(bounds.height);
					if (scale1.direction == BaseScale.POSITIVE)
						isoGeometries.x = bounds.x;
					else
						isoGeometries.x = width-Math.abs(bounds.width);
					isoGeometries.y = bounds.y;
					
					addChildAt(isoGeometries,0);
				}
			}
		}
		
		private function drawVerticalLayout():void
		{
			var xPos:Number, yPos:Number, zPos:Number = NaN;
			var j:Object;

			var y0:Number = getYMinPosition();

			var availableThickness:Number = NaN, finalThickness:Number = 0; 

			if (scale1)
			{
				if (scale1 is IEnumerableScale)
					availableThickness = scale1.size/IEnumerableScale(scale1).dataProvider.length * chart.thicknessRatio;
				else if (scale1 is INumerableScale)
					availableThickness = scale1.size / 
							(INumerableScale(scale1).max - INumerableScale(scale1).min) * chart.thicknessRatio;
			} 

			ggIndex = 0;

			var tmpDim2:String;
			var innerBase2:Number;

			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				var currentItem:Object = _dataItems[cursorIndex];
				
				var tmpArray:Array = (dim2 is Array) ? dim2 as Array : [String(dim2)];
				
				innerBase2 = 0;
				j = currentItem[dim1];

				for (var i:Number = 0; i<tmpArray.length; i++)
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

					tmpDim2 = tmpArray[i];
					if (scale1)
					{
						xPos = scale1.getPosition(currentItem[dim1]);
	
						if (isNaN(availableThickness))
	 						availableThickness = scale1.dataInterval * chart.thicknessRatio;
					} 
					
					if (scale2)
					{
						if (_stackType == STACKED)
						{
							y0 = scale2.getPosition(baseValues[j] + innerBase2);
							yPos = scale2.getPosition(
								baseValues[j] + Math.max(0,currentItem[tmpDim2] + innerBase2));
						} else {
							yPos = scale2.getPosition(currentItem[tmpDim2] + innerBase2);
						}
						dataFields[DIM2] = tmpArray[i];
					}
					
					if (isNaN(yPos) || isNaN(xPos))
					{
						continue;	
					}
					
					switch (_stackType)
					{
						case OVERLAID:
							finalThickness = availableThickness;
							xPos = xPos - availableThickness/2;
							break;
						case STACKED:
							finalThickness  = availableThickness;
							xPos = xPos - availableThickness/2;
							break;
						case CLUSTER:
							xPos = xPos + availableThickness/2 - availableThickness/_total * (_stackPosition + 1);
							finalThickness  = availableThickness/_total;
							break;
					}
					
					var innerThickness:Number;
					switch (_collisionType)
					{
						case OVERLAID:
							innerThickness = finalThickness;
							break;
						case STACKED:
							innerThickness = finalThickness;
							y0 = scale2.getPosition(innerBase2);
							innerBase2 += currentItem[tmpDim2];
							break;
						case CLUSTER:
							innerThickness = finalThickness/tmpArray.length;
							xPos = xPos + innerThickness * i;
							break;
					}
						
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

					var bounds:RegularRectangle = new RegularRectangle(xPos, yPos, innerThickness, y0 -yPos);
					bounds.fill = fill;
					bounds.alpha = 0;

					createTTGG(currentItem, dataFields, xPos+innerThickness/2, yPos, scale2RelativeValue, 3, i);

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
					{
						gg = ttGG;
						gg.target = this;
					}
					gg.geometryCollection.addItem(bounds);
					
					var itmDisplay:DisplayObject;
					if (itemRenderer != null)
					{
						itmDisplay = itemRenderer.newInstance();
					}
					var totalValue:Number;
					totalValue = currentItem[tmpDim2];

					var isoGeometries:Canvas = createIsoGeometries(itmDisplay, bounds, totalValue, rendererDataValue);
					isoGeometries.width = bounds.width;
					isoGeometries.height = bounds.height;
					isoGeometries.x = bounds.x;
					isoGeometries.y = bounds.y;
					
					addChildAt(isoGeometries,0);
				}
			}
		}

		// Be sure to remove all children in case an item renderer is used
		override public function clearAll():void
		{
			super.clearAll();
			if (_itemRenderer)
				for (var i:uint = 0; i<numChildren; )
					removeChild(getChildAt(0));
		}
	}
}