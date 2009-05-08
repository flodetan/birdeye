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
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;
	
	import birdeye.vis.scales.XYZ;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.guides.renderers.TextRenderer;

	public class LabelElement extends CartesianElement
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
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
		override protected function drawElement():void
		{
			fill = new SolidFill(colorLabel); 
			
			var dataFields:Array = [];
			// prepare data for a standard tooltip message in case the user
			// has not set a dataTipFunction
			dataFields[0] = xField;
			dataFields[1] = yField;
			if (zField) 
				dataFields[2] = zField;

			var xPos:Number, yPos:Number, zPos:Number = NaN;
			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (xScale)
				{
					xPos = xScale.getPosition(cursor.current[xField]);
				} else if (chart.xScale) {
					xPos = chart.xScale.getPosition(cursor.current[xField]);
				}
				
				if (yScale)
				{
					yPos = yScale.getPosition(cursor.current[yField]);
				} else if (chart.yScale) {
					yPos = chart.yScale.getPosition(cursor.current[yField]);
				}

				var yAxisRelativeValue:Number = NaN;

				if (zScale)
				{
					zPos = zScale.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZ(zScale).height - zPos;
				} else if (chart.zAxis) {
					zPos = chart.zAxis.getPosition(cursor.current[zField]);
					// since there is no method yet to draw a real z axis 
					// we create an y axis and rotate it to properly visualize 
					// a 'fake' z axis. however zPos over this y axis corresponds to 
					// the axis height - zPos, because the y axis in Flex is 
					// up side down. this trick allows to visualize the y axis as
					// if it would be a z. when there will be a 3d line class, it will 
					// be replaced
					yAxisRelativeValue = XYZ(chart.zAxis).height - zPos;
				}

				if (colorAxis)
				{
					colorFill = colorAxis.getPosition(cursor.current[colorField]);
					fill = new SolidFill(colorFill);
				} else if (chart.colorAxis) {
					colorFill = chart.colorAxis.getPosition(cursor.current[colorField]);
					fill = new SolidFill(colorFill);
				}

				// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
				// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
				createTTGG(cursor.current, dataFields, xPos, yPos, yAxisRelativeValue, _plotRadius);

				if (zField)
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
				if (zField)
				{
					gg.z = zPos;
					if (isNaN(zPos))
						zPos = 0;
				}
 				cursor.moveNext();
			}
			
			if (zField)
				zSort();
		}
	}
}