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
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.renderers.ArcPath;
	import org.un.cava.birdeye.qavis.charts.renderers.TriangleRenderer;

	public class PolarPieSeries extends PolarStackableSeries
	{
		private var _innerRadius:Number = 0;
		public function set innerRadius(val:Number):void
		{
			_innerRadius = val;
			invalidateDisplayList();
		}

		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		[Inspectable(enumeration="overlaid,stacked100")]
		override public function set stackType(val:String):void
		{
			super.stackType = val;
		}
		
		public function PolarPieSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (_stackType != OVERLAID || _stackType != STACKED100)
				_stackType = STACKED100;

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
			
			var startAngle:Number = 0; 
			
			var arcSize:Number = NaN;
			
			switch (_stackType)
			{
				case STACKED100:
					break;
				case OVERLAID:
					break;
			}
				
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			if (radiusAxis)
			{
				radius = radiusAxis.getPosition(null);
				dataFields[1] = radiusField;
			} else if (polarChart.radiusAxis) {
				radius = polarChart.radiusAxis.getPosition(null);
				dataFields[1] = radiusField;
			}
			
			var arcCenterX:Number = polarChart.origin.x - radius;
			var arcCenterY:Number = polarChart.origin.y - radius;

			var wSize:Number, hSize:Number;
			wSize = hSize = radius*2;

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
				
				var xPos:Number = PolarCoordinateTransform.getX(startAngle + angle/2, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(startAngle + angle/2, radius, polarChart.origin); 

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
				
				stroke.weight = 1;

				var arc:IGeometry;
				
				if (_innerRadius>0)
					arc = new ArcPath(Math.max(0, radius - 10), radius, startAngle, arcSize, polarChart.origin);
				else
					arc = 
						new EllipticalArc(arcCenterX, arcCenterY, wSize, hSize, startAngle, angle, "pie");
	
				arc.fill = fill;
				arc.stroke = stroke;

				gg.geometryCollection.addItemAt(arc,0); 
				
				startAngle = angle;
 				cursor.moveNext();
			}
		}
	}
}