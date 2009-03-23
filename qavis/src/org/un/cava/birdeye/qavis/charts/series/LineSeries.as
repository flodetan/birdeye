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
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.data.ExtendedGeometryGroup;

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

		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			dataProvider.cursor.seek(CursorBookmark.FIRST);
			
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number;
			var j:Number = 0;
			var dataFields:Array = [];
			
			gg = new ExtendedGeometryGroup();
			gg.target = this;
			graphicsCollection.addItem(gg);
			while (!dataProvider.cursor.afterLast)
			{
				if (horizontalAxis)
				{
					if (horizontalAxis is NumericAxis)
					{
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
						dataFields[0] = xField;
					} else if (horizontalAxis is CategoryAxis) {
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[0] = displayName;
					}
				} else {
					if (dataProvider.horizontalAxis is NumericAxis)
					{
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
						dataFields[0] = xField;
					} else if (dataProvider.horizontalAxis is CategoryAxis) {
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[0] = displayName;
					}
				}
				
				if (verticalAxis)
				{
					if (verticalAxis is NumericAxis)
					{
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);
						dataFields[1] = yField;
					} else if (verticalAxis is CategoryAxis) {
						dataFields[1] = displayName;
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
					}
				} else {
					if (dataProvider.verticalAxis is NumericAxis)
					{
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[yField]);
						dataFields[1] = yField;
					} else if (dataProvider.verticalAxis is CategoryAxis) {
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[1] = displayName;
					}
				}
				
				if (dataProvider.showDataTips)
				{
					createGG(dataProvider.cursor.current, dataFields, xPos, yPos, 3);
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
				dataProvider.cursor.moveNext();
			}
		}
		
 		private var ttGG:ExtendedGeometryGroup;
		override protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, radius:Number,
									shapes:Array = null , ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new ExtendedGeometryGroup();
			ttGG.target = this;
 			if (dataProvider.showDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(dataProvider.cursor.current, dataFields, xPos, yPos, radius);
 			} else {
				graphicsCollection.addItem(ttGG);
			}
		}
		
		override protected function initGGToolTip():void
		{
			ttGG.target = this;
			ttGG.toolTipFill = new SolidFill(fillStroke);
			ttGG.toolTipStroke = stroke;
 			if (dataProvider.dataTipFunction != null)
				ttGG.dataTipFunction = dataProvider.dataTipFunction;
			if (dataProvider.dataTipPrefix!= null)
				ttGG.dataTipPrefix = dataProvider.dataTipPrefix;
 			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}
 	}
}