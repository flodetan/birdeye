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
	import birdeye.vis.scales.*;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;

	public class LinkElement extends SegmentElement
	{
		public function LinkElement()
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

				var p1:Point, p2:Point, p3:Point, p4:Point;
				
				var startX:Number, startY:Number;
				var endX:Number, endY:Number;
				var sizeStart:Number = NaN;
				var sizeEnd:Number = NaN;
	
				ggIndex = 0;
	
				for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
				{
					startX = startY = NaN;
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
					
					if (!currentItem[dimEnd] || !currentItem[dimStart])
						continue;
						
					if (scale1)
					{
						startX = scale1.getPosition(currentItem[dimStart]);
						endX = scale1.getPosition(currentItem[dimEnd]);
					}
					
					if (scale2)
					{
						startY = scale2.getPosition(currentItem[dimStart]);
						endY = scale2.getPosition(currentItem[dimEnd]);
					}
					
					if (colorScale)
					{
						var col:* = colorScale.getPosition(currentItem[colorField]);
						if (col is Number)
							fill = new SolidFill(col);
						else if (col is IGraphicsFill)
							fill = col;
					}
					
					if (sizeScale)
					{
						if (sizeField)
						{
							var weight:Number = sizeScale.getPosition(currentItem[sizeField]);
							stroke = new SolidStroke(colorStroke, alphaStroke, weight);
						} if (sizeStartField && sizeEndField)
						{
							sizeStart = sizeScale.getPosition(currentItem[sizeStartField]);
							sizeEnd = sizeScale.getPosition(currentItem[sizeEndField]);
						}
					}
					
					var centerX:Number = startX + (endX - startX)/2;
					var centerY:Number = startY + (endY - startY)/2;
	
					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(currentItem, dataFields, centerX, centerY, NaN, 3);
					
					if (_extendMouseEvents)
						gg = ttGG;

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
						data+= "L" + String(p1.x) + "," + String(p1.y) + " z";
					}
 					
 					var path:Path= new Path(data);
					path.fill = fill;
					path.stroke = stroke;
					gg.geometryCollection.addItemAt(path,0);
				}
				_invalidatedElementGraphic = false;
			}
		}
 	}
}