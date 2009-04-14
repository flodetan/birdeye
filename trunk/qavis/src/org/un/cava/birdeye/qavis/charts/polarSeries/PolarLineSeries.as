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
 
package org.un.cava.birdeye.qavis.charts.polarSeries
{
	import com.degrafa.paint.SolidFill;
	
	import org.un.cava.birdeye.qavis.charts.renderers.LineRenderer;

	public class PolarLineSeries extends PolarAreaSeries
	{
/* 		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarLineSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = CircleRenderer;
			if (isNaN(_strokeColor))
				_strokeColor = 0x000000;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
/*		override protected function drawSeries():void
		{
			var dataFields:Array = [];

			var angle:Number, radius:Number;
			
			var xPrev:Number, yPrev:Number;
			var firstX:Number, firstY:Number;
			var j:Number = 0;
			
			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (angleAxis)
				{
					angle = angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				} else if (polarChart.angleAxis) {
					angle = polarChart.angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				}
				
				if (radiusAxis)
				{
					radius = radiusAxis.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				} else if (polarChart.radiusAxis) {
					radius = polarChart.radiusAxis.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				}

				if (radarAxis)
				{
					angle = radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = NumericAxis(radarAxis.radiusAxes[
										cursor.current[radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				} else if (polarChart.radarAxis) {
					angle = polarChart.radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = NumericAxis(polarChart.radarAxis.radiusAxes[
										cursor.current[polarChart.radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, polarChart.origin); 
				if (polarChart.showDataTips)
				{	
					createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);				
				}

				if (mouseClickFunction!=null || mouseDoubleClickFunction!=null)
				{
					createInteractiveGG(cursor.current, dataFields, xPos, yPos, NaN);
				}
				
				if (j++ == 0)
				{
					firstX = xPos;
					firstY = yPos;
				} else {
					var line:Line = new Line(xPrev,yPrev,xPos,yPos);
					line.fill = fill;
					line.stroke = stroke;
					gg.geometryCollection.addItemAt(line,0);
				}
				
				xPrev = xPos; yPrev = yPos;
 				cursor.moveNext();
 				
 				if (cursor.afterLast)
 				{
					line = new Line(firstX,firstY,xPos,yPos);
					line.fill = fill;
					stroke.weight = 2;
					line.stroke = stroke;
					gg.geometryCollection.addItemAt(line,0);
 				}
			}
		} */
		
		override protected function commitProperties():void
		{
			if (! itemRenderer)
				itemRenderer = LineRenderer;

			super.commitProperties();
		}
		
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			if (isNaN(_strokeColor))
				_strokeColor = 0x000000;
			
			super.drawSeries();
			if (poly) 
				poly.fill = new SolidFill(null,0);
		}

	}
}