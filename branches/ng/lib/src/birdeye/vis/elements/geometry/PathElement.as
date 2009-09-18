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
	import birdeye.vis.data.UtilSVG;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.scales.*;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Point;

	public class PathElement extends BaseElement
	{
		private var _createJoint:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set createJoint(val:Boolean):void
		{
			_createJoint = val;
			invalidateDisplayList();
		}
		
		public function PathElement()
		{
			super();
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedElementGraphic)
			{
				super.drawElement();
				clearAll();
				
				circleData = "";
				
				var splitGroups:Array = createSplitGroups();

				var startX:Number, startY:Number;
				var previousStartX:Number, previousStartY:Number;
				var sizeStart:Number = NaN;
				var previousSize:Number = NaN;
	
				ggIndex = 0;
				
				const CURRENT_ITEM:Number = 0, X:Number = 1, Y:Number = 2, SIZE:Number = 3;
				
				if (splitGroups)
				{
					for each (var sequence:Array in splitGroups)
					{
						previousStartX = previousStartY = NaN;
						for (var i:uint = 0; i<sequence.length; i++)
						{
							var item:Array = sequence[i];
							startX = scale1.getPosition(item[X]);
							startY = scale2.getPosition(item[Y]);
							if (sizeScale && sizeField)
								sizeStart = sizeScale.getPosition(item[SIZE]);
							
							if (isNaN(previousStartX) || isNaN(previousStartY))
							{
								previousStartX = startX;
								previousStartY = startY;
								previousSize = sizeStart;
								continue;
							}
							
							createPathSegment(item[CURRENT_ITEM], previousStartX, previousStartY, startX, startY,  
											((i==0) || (i==sequence.length-1)),
											previousSize, sizeStart);
							
							previousStartX = startX;
							previousStartY = startY;
							if (sizeField)
								previousSize = sizeStart;
						}
					}
				} else { // consider the whole data as 1 path sequence group 
					previousStartX = previousStartY = NaN;
					for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
					{
						var currentItem:Object = _dataItems[cursorIndex];
						
						if (scale1)
							startX = scale1.getPosition(currentItem[dim1]);
						
						if (scale2)
							startY = scale2.getPosition(currentItem[dim2]);
						
						if (sizeScale && sizeField)
							sizeStart = sizeScale.getPosition(currentItem[sizeField]);

						if (isNaN(previousStartX) || isNaN(previousStartY))
						{
							previousStartX = startX;
							previousStartY = startY;
							previousSize = sizeStart;
							continue;
						}
						
						createPathSegment(currentItem, previousStartX, previousStartY, startX, startY, 
										((cursorIndex==0) || (cursorIndex==_dataItems.length-1)),
											previousSize, sizeStart);
							
						previousStartX = startX;
						previousStartY = startY;
						if (sizeField)
							previousSize = sizeStart;
					}
				}
				
				createSVG();
				_invalidatedElementGraphic = false;
			}
		}
		
		private var circleData:String = "";
		private function createPathSegment(currentItem:Object, startX:Number, startY:Number, endX:Number, endY:Number, 
											isFirstOrLast:Boolean, sizeStart:Number = NaN, sizeEnd:Number = NaN):void
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
	
			var centerX:Number = startX + (endX - startX)/2;
			var centerY:Number = startY + (endY - startY)/2;

			// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
			// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
			createTTGG(currentItem, dataFields, centerX, centerY, NaN, 3);
			
			if (_extendMouseEvents)
			{
				gg = ttGG;
				gg.target = this;
			}

			if (isNaN(sizeStart) || isNaN(sizeEnd))
			{
				// line to P1
				data = "M" + String(startX) + "," + String(startY) + " ";
				// line to P2
				data+= "L" + String(endX) + "," + String(endY) + " ";
			} else {
				var angleStartEnd:Number = Math.atan2(-(endY-startY), endX-startX) * 180/Math.PI;
				var xDeltaStart:Number = sizeStart/2 * Math.sin(angleStartEnd*Math.PI/180);
				var yDeltaStart:Number = sizeStart/2 * Math.cos(angleStartEnd*Math.PI/180);
				var xDeltaEnd:Number = sizeEnd/2 * Math.sin(angleStartEnd*Math.PI/180);
				var yDeltaEnd:Number = sizeEnd/2 * Math.cos(angleStartEnd*Math.PI/180);

				var p1:Point, p2:Point, p3:Point, p4:Point;
				
				p1 = new Point(startX - xDeltaStart, startY - yDeltaStart);
				p2 = new Point(startX + xDeltaStart, startY + yDeltaStart);
				p3 = new Point(endX + xDeltaEnd, endY + yDeltaEnd);
				p4 = new Point(endX - xDeltaEnd, endY - yDeltaEnd);
				
				var data:String;
 				// move to P1 
				data = "M" + String(p1.x) + "," + String(p1.y) + " ";
				// line to P2
				data+= "L" + String(p2.x) + "," + String(p2.y) + " ";
 				// line to P3
				data+= "L" + String(p3.x) + "," + String(p3.y) + " ";
 				// line to P4
				data+= "L" + String(p4.x) + "," + String(p4.y) + " ";
				// line to P1 and close
				data+= "L" + String(p1.x) + "," + String(p1.y) + " z ";
			}
 			
			if (colorScale)
			{
				var col:* = colorScale.getPosition(currentItem[colorField]);
				if (col is Number)
				{
					fill = new SolidFill(col);
					rgbFill = UtilSVG.toHex(col);
				} else if (col is IGraphicsFill)
					fill = col;
			}
			
			if (_createJoint && !isNaN(sizeStart) && !isFirstOrLast)
			{
				var tmpCircleData:String;
				// move to 1st inner point
				tmpCircleData = "M" + String(endX+sizeEnd/2) + " " + String(endY) + " ";
	
				// arc to 2nd inner point with radius = r
				tmpCircleData += "A" + String(sizeEnd/2) + " " + String(sizeEnd/2) + " 0 " + "1 1 " + String(endX+sizeEnd/2) + " " + String(endY-0.001)  + " z ";
				
				var circle:Path = new Path(tmpCircleData);
				circleData += tmpCircleData;
				circle.fill = fill;
				circle.stroke = stroke;
				gg.geometryCollection.addItemAt(circle,0);
			}
 			var path:Path= new Path(data);
			addSVGData('\n<path d="' + data + '"/>');
			addSVGData('\n<path d="' + tmpCircleData + '"/>');
			path.fill = fill;
			path.stroke = stroke;
			gg.geometryCollection.addItem(path);
		}

		
		/**
		 * @Private
		 * Create an array whose elements are identified by the name of the splitField.
		 * Each item of the array is an array containing the paths sequence for each splitField group.*/
		private function createSplitGroups():Array
		{
			var sGroups:Array = [];
			if (splitField)
			{
				for (var i:uint = 0; i<_dataItems.length; i++)
				{
					var currentItem:Object = _dataItems[i];
					if (currentItem[splitField])
					{
						if (sGroups[currentItem[splitField]] == null)
							sGroups[currentItem[splitField]] = [];
						if (sizeField)
							(sGroups[currentItem[splitField]] as Array).push([currentItem, currentItem[dim1], currentItem[dim2], currentItem[sizeField]]);
						else
							(sGroups[currentItem[splitField]] as Array).push([currentItem, currentItem[dim1], currentItem[dim2]]);
					}
				}
			} else // consider the whole data as a path sequence
				sGroups = null;
				
			return sGroups;
		}
 	}
}