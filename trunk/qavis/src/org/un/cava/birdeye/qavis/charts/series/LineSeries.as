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
 
package org.un.cava.birdeye.qavis.charts.series
{
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxis;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.renderers.LineRenderer;

	public class LineSeries extends CartesianSeries
	{
		private var _form:String;
		public function set form(val:String):void
		{
			_form = val;
		}
		
		public function LineSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = LineRenderer;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			cursor.seek(CursorBookmark.FIRST);
			
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number, zPos:Number;
			var j:Number = 0;
			var dataFields:Array = [];
			
			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);
			while (!cursor.afterLast)
			{
				if (xAxis)
				{
					xPos = xAxis.getPosition(cursor.current[xField]);
					dataFields[0] = xField;
				} else {
					xPos = chart.xAxis.getPosition(cursor.current[xField]);
					dataFields[0] = xField;
				}
				
				if (yAxis)
				{
					yPos = yAxis.getPosition(cursor.current[yField]);
					dataFields[1] = yField;
				} else {
					yPos = chart.yAxis.getPosition(cursor.current[yField]);
					dataFields[1] = yField;
				}
				
				var yAxisRelativeValue:Number = NaN;

				if (zAxis)
				{
					zPos = zAxis.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZAxis(zAxis).height - zPos;
					dataFields[2] = zField;
				} else if (chart.zAxis) {
					zPos = chart.zAxis.getPosition(cursor.current[zField]);
					// since there is no method yet to draw a real z axis 
					// we create an y axis and rotate it to properly visualize 
					// a 'fake' z axis. however zPos over this y axis corresponds to 
					// the axis height - zPos, because the y axis in Flex is 
					// up side down. this trick allows to visualize the y axis as
					// if it would be a z. when there will be a 3d line class, it will 
					// be replaced
					yAxisRelativeValue = XYZAxis(chart.zAxis).height - zPos;
					dataFields[2] = zField;
				}

				if (chart.showDataTips)
				{	// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createGG(cursor.current, dataFields, xPos, yPos, yAxisRelativeValue, 3);
					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);
				}

				if (j++ > 0)
				{
					var line:Line = new Line(xPrev,yPrev,xPos,yPos);
					line.fill = fill;
					line.stroke = stroke;
					gg.geometryCollection.addItemAt(line,0);
					line = null;
				}
				xPrev = xPos; yPrev = yPos;
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
		
 		private var ttGG:DataItemLayout;
		override protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeomtry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new DataItemLayout();
			ttGG.target = this;
 			if (chart.showDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(cursor.current, dataFields, xPos, yPos, zPos, radius);
 			} else {
				addChild(ttGG);
			}
		}
		
		override protected function initGGToolTip():void
		{
			ttGG.target = this;
			ttGG.toolTipFill = new SolidFill(strokeColor);
			ttGG.toolTipStroke = stroke;
 			if (chart.dataTipFunction != null)
				ttGG.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = chart.dataTipPrefix;
 			addChild(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}
 	}
}