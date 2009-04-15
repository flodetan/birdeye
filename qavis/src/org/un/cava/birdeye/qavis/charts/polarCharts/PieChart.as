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

package org.un.cava.birdeye.qavis.charts.polarCharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAngleAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarStackableSeries;
	
	public class PieChart extends PolarChart
	{
		private var _type:String = PolarStackableSeries.OVERLAID;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally).*/
		[Inspectable(enumeration="overlaid,stacked")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function RadarChart()
		{
			super();
			addChild(labels = new Surface());

			gg = new GeometryGroup();
			gg.target = labels;
			labels.addChild(gg);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (!contains(labels))
				addChild(labels);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (angleAxis && origin)
				drawLabels();
		}
		
		private var labels:Surface;
		private var gg:GeometryGroup;
		private function drawLabels():void
		{
			var aAxis:INumerableAxis = INumerableAxis(angleAxis);

			var radius:int = Math.min(unscaledWidth, unscaledHeight)/2;

			if (aAxis && radius>0)
			{
				removeAllLabels();
				for (var i:int = 0; i<nEle; i++)
				{
					var angle:int = aAxis.getPosition(ele[i]);
					var position:Point = PolarCoordinateTransform.getXY(angle,radius,origin);
					
					var label:RasterText = new RasterText();
					label.text = String(ele[i]);
 					label.fontFamily = "verdana";
 					label.fontSize = 9;
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(0x000000);

					label.x = position.x;
					label.y = position.y;
					
					gg.geometryCollection.addItem(label);
				}

				switch (_layout)
				{
					case RADAR: 
						if (radarAxis)
							createRadarLayout1();
						else
							createRadarLayout2();
						break;
					case COLUMN:
						createColumnLayout()
						break;
				}
			}
		}
		
		private function removeAllLabels():void
		{
			if (gg)
				gg.geometryCollection.items = [];
		}
		
		private function createRadarLayout1():void
		{
			var aAxis:CategoryAngleAxis = radarAxis.angleAxis;
			var ele:Array = aAxis.elements;
			var rAxis:NumericAxis = radarAxis.radiusAxes[ele[0]];
			
			if (aAxis && rAxis)
			{
				var interval:int = aAxis.interval;
				var nEle:int = ele.length;
	
				var rMin:Number = rAxis.min;
				var rMax:Number = rAxis.max;
				
				var angle:int;
				var radius:int;
				var position:Point;
	
				for (radius = rMin + rAxis.interval; radius<rMax; radius += rAxis.interval)
				{
					var poly:Polygon = new Polygon();
					poly.data = "";
	
					for (var j:int = 0; j<nEle; j++)
					{
						angle = aAxis.getPosition(ele[j]);
						position = PolarCoordinateTransform.getXY(angle, rAxis.getPosition(radius), origin)
						poly.data += String(position.x) + "," + String(position.y) + " ";
					}
					poly.stroke = new SolidStroke(0x000000,.15);
					gg.geometryCollection.addItem(poly);
				}
			}
		}

		private function createRadarLayout2():void
		{
			var aAxis:CategoryAngleAxis = CategoryAngleAxis(angleAxis);
			var ele:Array = aAxis.elements;
			var interval:int = aAxis.interval;
			var nEle:int = ele.length;
			
			if (radiusAxis is NumericAxisUI)
			{
				var rAxis:NumericAxisUI = NumericAxisUI(radiusAxis);
				var rMin:Number = rAxis.min;
				var rMax:Number = rAxis.max;
				
				var angle:int;
				var radius:int;
				var position:Point = PolarCoordinateTransform.getXY(angle,radius-10,origin);

				for (radius = rMin + rAxis.interval; radius<rMax; radius += rAxis.interval)
				{
					var poly:Polygon = new Polygon();
					poly.data = "";

					for (var j:int = 0; j<nEle; j++)
					{
						angle = aAxis.getPosition(ele[j]);
						position = PolarCoordinateTransform.getXY(angle, rAxis.getPosition(radius), origin)
						poly.data += String(position.x) + "," + String(position.y) + " ";
					}
					poly.stroke = new SolidStroke(0x000000,.15);
					gg.geometryCollection.addItem(poly);
				}
			}
			
		}
		
		private function createColumnLayout():void
		{
			var rad:int = Math.min(unscaledWidth, unscaledHeight)/2;
			var circle:Circle = new Circle(origin.x, origin.y, rad-20);
			circle.stroke = new SolidStroke(0x000000);

			gg.geometryCollection.addItem(circle);
		}
	}
}