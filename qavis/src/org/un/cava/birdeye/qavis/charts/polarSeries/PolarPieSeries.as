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
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxis;
	import org.un.cava.birdeye.qavis.charts.renderers.ArcPath;
	import org.un.cava.birdeye.qavis.charts.renderers.CircleRenderer;

	public class PolarPieSeries extends PolarStackableSeries
	{
		private var _extendMouseEvents:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set extendMouseEvents(val:Boolean):void
		{
			_extendMouseEvents = val;
			invalidateDisplayList();
		}
		
		private var _innerRadius:Number;
		public function set innerRadius(val:Number):void
		{
			_innerRadius = val;
			invalidateDisplayList();
		}

		private var _plotRadius:Number = 10;
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
				itemRenderer = CircleRenderer;

			if (isNaN(_strokeColor))
				_strokeColor = 0x000000;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];

			var angle:Number, radius:Number = NaN;
			
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
				radius = radiusAxis.size;
				dataFields[1] = radiusField;
			} else if (polarChart.radiusAxis) {
				radius = polarChart.radiusAxis.size;
				dataFields[1] = radiusField;
			}
			
			if (_total>0)
			{
				_innerRadius = radius/_total * _stackPosition; 
				radius = radius/_total * (1 + _stackPosition) * polarChart.columnWidthRate;
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

				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
 				if (ttGG && _extendMouseEvents)
					gg = ttGG;
 				
				stroke.weight = 1;

				var arc:IGeometry;
				
				if (_innerRadius > radius)
					_innerRadius = radius;

				arc = new ArcPath(Math.max(0, _innerRadius), radius, startAngle, angle, polarChart.origin);
	
				var tempColor:int;
				
				if (randomColors)
				{
					tempColor = Math.random() * 255 * 255 * 255;
					arc.fill = new SolidFill(tempColor);
				} else if (fill)
				{
					arc.fill = fill;
				}

				arc.stroke = stroke;

				gg.geometryCollection.addItemAt(arc,0); 
				
				startAngle += angle;

				if (labelField)
				{
					var label:RasterText = new RasterText();
					label.text = cursor.current[labelField];
					label.fontFamily = "verdana";
					label.fontWeight = "bold";
					label.fill = new SolidFill(0x000000);
					label.x = xPos;
					label.y = yPos;
					gg.geometryCollection.addItem(label); 
				}

 				cursor.moveNext();
			}
			
			var aAxis:IAxis = null;
			
			if (angleAxis)
				aAxis = angleAxis;
			else 
				aAxis = polarChart.angleAxis;
				
			if (displayName && aAxis && aAxis.size < 360)
			{
				label = new RasterText();
				label.text = displayName;
				label.fontFamily = "verdana";
				label.fontWeight = "bold";
				label.fill = new SolidFill(0x000000);
				label.x = PolarCoordinateTransform.getX(0, _innerRadius, polarChart.origin);
				label.y = PolarCoordinateTransform.getY(0, _innerRadius, polarChart.origin);
				gg.geometryCollection.addItem(label); 
			}
		}
	}
}