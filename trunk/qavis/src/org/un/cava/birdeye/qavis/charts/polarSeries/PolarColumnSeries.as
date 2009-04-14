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
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.paint.SolidFill;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.renderers.TriangleRenderer;

	public class PolarColumnSeries extends PolarStackableSeries
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarColumnSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (! itemRenderer)
				itemRenderer = TriangleRenderer;

			if (isNaN(_strokeColor))
				_strokeColor = 0x000000;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];

			var angle:Number, radius:Number;
			
			var arcSize:Number = NaN;
			
			var angleInterval:Number;
			if (angleAxis) 
				angleInterval = angleAxis.interval * polarChart.columnWidthRate;
			else if (polarChart.angleAxis)
				angleInterval = polarChart.angleAxis.interval * polarChart.columnWidthRate;
			else if (radarAxis)
				angleInterval = radarAxis.angleAxis.interval * polarChart.columnWidthRate;
			else if (polarChart.radarAxis)
				angleInterval = polarChart.radarAxis.angleAxis.interval * polarChart.columnWidthRate;
				
			switch (_stackType)
			{
				case STACKED:
					arcSize = angleInterval/_total;
					break;
				case OVERLAID:
					arcSize = angleInterval;
					break;
			}
				
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

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

				var arcCenterX:Number = polarChart.origin.x - radius;
				var arcCenterY:Number = polarChart.origin.y - radius;
				var startAngle:Number; 
				switch (_stackType) 
				{
					case STACKED:
						startAngle = angle - angleInterval/2 +arcSize*(_stackPosition-1);
						break;
					case OVERLAID:
						startAngle = angle - angleInterval/2;
						break;
				}
				var wSize:Number, hSize:Number;
				wSize = hSize = radius*2;

				var xPos:Number = PolarCoordinateTransform.getX(startAngle+arcSize/2, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(startAngle+arcSize/2, radius, polarChart.origin); 

				if (polarChart.showDataTips)
				{	
					createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);
				} else if (mouseClickFunction!=null || mouseDoubleClickFunction!=null)
				{
					createInteractiveGG(cursor.current, dataFields, xPos, yPos, NaN);
				}
				
				var arc:EllipticalArc = 
					new EllipticalArc(arcCenterX, arcCenterY, wSize, hSize, startAngle, arcSize, "pie");

				stroke.weight = 1;

				arc.fill = fill;
				arc.stroke = stroke;
				gg.geometryCollection.addItemAt(arc,0); 
 				cursor.moveNext();
			}
		}
	}
}