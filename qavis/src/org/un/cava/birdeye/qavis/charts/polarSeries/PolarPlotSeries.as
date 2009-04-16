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
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.renderers.CircleRenderer;

	public class PolarPlotSeries extends PolarSeries
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarPlotSeries()
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

		private var plot:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
		
			var angle:Number, radius:Number;
			
			if (!itemRenderer)
				itemRenderer = CircleRenderer;
			
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
					radius = INumerableAxis(radarAxis.radiusAxes[
										cursor.current[radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				} else if (polarChart.radarAxis) {
					angle = polarChart.radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = INumerableAxis(polarChart.radarAxis.radiusAxes[
										cursor.current[polarChart.radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, polarChart.origin); 
				if (polarChart.showDataTips)
				{	
					if (polarChart.customTooltTipFunction == null)
					{
	 					ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos, yPos, xPos + ttXoffset/3, yPos + ttYoffset);
						line.stroke = new SolidStroke(0xaaaaaa,1,2);
		 				ttShapes[0] = line;
						createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius,ttShapes,ttXoffset,ttYoffset);
					} else 
						createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
						
 					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);
				} else if (mouseClickFunction!=null || mouseDoubleClickFunction!=null)
				{
					createInteractiveGG(cursor.current, dataFields, xPos, yPos, NaN);
				}
				
 				var bounds:RegularRectangle = new RegularRectangle(xPos - _plotRadius, yPos - _plotRadius, _plotRadius * 2, _plotRadius * 2);

  				plot = new itemRenderer(bounds);
  				
				plot.fill = fill;
				plot.stroke = stroke;
				gg.geometryCollection.addItemAt(plot,0); 
 				cursor.moveNext();
			}
		}
	}
}