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
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.scales.XYZ;
	
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;

	public class LabelElement extends BaseElement
	{
		public function LabelElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			itemRenderer = TextRenderer;

			fill = new SolidFill(colorLabel); 
		}

		private var label:TextRenderer;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout())
			{
				removeAllElements();
				fill = new SolidFill(colorLabel); 
				
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim1;
				dataFields[1] = dim2;
				if (dim3) 
					dataFields[2] = dim3;
	
				var xPos:Number, yPos:Number, zPos:Number = NaN;

				if (graphicsCollection.items && graphicsCollection.items.length>0)
					gg = graphicsCollection.items[0];
				else
				{
					gg = new DataItemLayout();
					graphicsCollection.addItem(gg);
				}
				gg.target = this;
				ggIndex = 1;
	
				cursor.seek(CursorBookmark.FIRST);
				while (!cursor.afterLast)
				{
					if (scale1)
					{
						xPos = scale1.getPosition(cursor.current[dim1]);
					} 
					
					if (scale2)
					{
						yPos = scale2.getPosition(cursor.current[dim2]);
					}
					
					var scale2RelativeValue:Number = NaN;
	
					if (scale3)
					{
						zPos = scale3.getPosition(cursor.current[dim3]);
						// since there is no method yet to draw a real z axis 
						// we create an y axis and rotate it to properly visualize 
						// a 'fake' z axis. however zPos over this y axis corresponds to 
						// the axis height - zPos, because the y axis in Flex is 
						// up side down. this trick allows to visualize the y axis as
						// if it would be a z. when there will be a 3d line class, it will 
						// be replaced
						scale2RelativeValue = XYZ(scale3).height - zPos;
					} 
	
					if (colorScale)
					{
						colorFill = colorScale.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					} 
	
					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(cursor.current, dataFields, xPos, yPos, scale2RelativeValue, _plotRadius);
	
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
					
	 				var bounds:Rectangle = new Rectangle(xPos - _plotRadius, yPos - _plotRadius, _plotRadius * 2, _plotRadius * 2);
	
					if (labelField)
					{
						label = new TextRenderer(null);
						if (cursor.current[labelField])
							label.text = cursor.current[labelField];
						else
							label.text = labelField;
							
						label.fill = fill;
						label.fontSize = sizeLabel;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.x = xPos - label.displayObject.width/2;
						label.y = yPos - label.displayObject.height/2;
						gg.geometryCollection.addItemAt(label,0); 
					}
					if (dim3)
					{
						gg.z = zPos;
						if (isNaN(zPos))
							zPos = 0;
					}
	 				cursor.moveNext();
				}
				
				if (dim3)
					zSort();
			}
		}
	}
}