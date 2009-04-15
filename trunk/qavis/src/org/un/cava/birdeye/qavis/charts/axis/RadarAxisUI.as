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
 
package org.un.cava.birdeye.qavis.charts.axis
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import org.un.cava.birdeye.qavis.charts.polarCharts.PolarChart;

	public class RadarAxisUI extends Surface
	{
		private var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		private var _polarChart:PolarChart;
		public function set polarChart(val:PolarChart):void
		{
			_polarChart = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		private var _angleCategory:String;
		public function set angleCategory(val:String):void
		{
			_angleCategory = val;
			var tmpAngleAxis:CategoryAngleAxis = new CategoryAngleAxis();
			tmpAngleAxis.categoryField = val;
			angleAxis = tmpAngleAxis;
		}
		public function get angleCategory():String
		{
			return _angleCategory;
		}
		
		private var _radiusSize:Number;
		public function set radiusSize(val:Number):void
		{
			_radiusSize = val;
			invalidateDisplayList();
		}
		public function get radiusSize():Number
		{
			return _radiusSize;
		}
		
		private var _angleAxis:CategoryAngleAxis;
		public function set angleAxis(val:CategoryAngleAxis):void
		{
			_angleAxis = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get angleAxis():CategoryAngleAxis
		{
			return _angleAxis;
		}
		
		private var _radiusAxes:Array;
		public function set radiusAxes(val:Array):void
		{
			_radiusAxes = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusAxes():Array
		{
			return _radiusAxes;
		}

		private var _fontSize:Number = 8;
		public function set fontSize(val:Number):void
		{
			_fontSize = val;
			invalidateDisplayList();
		}

		// UIComponent methods
		
		private var gg:GeometryGroup;
		public function RadarAxisUI()
		{
			super();
			gg = new GeometryGroup();
			gg.target = this;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			graphicsCollection.addItem(gg);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
 			if (angleAxis && radiusAxes && _radiusSize)
				drawAxes();
		}
		
		// other methods
		
 		public function feedRadiusAxes(elementsMinMax:Array):void
		{
			if (_angleCategory && _angleAxis && _angleAxis.elements)
			{
				radiusAxes = [];
				for each (var element:String in angleAxis.elements)
				{
					radiusAxes[element] = new NumericAxis();
					if (_function != null)
						NumericAxis(radiusAxes[element]).f = _function;
					
					// if all values are positive, than we fix the base at zero, otherwise
					// the columns with minium values won't show up in the chart
					NumericAxis(radiusAxes[element]).min = Math.min(0, elementsMinMax[element].min);
					NumericAxis(radiusAxes[element]).max = elementsMinMax[element].max;
					NumericAxis(radiusAxes[element]).size = radiusSize;
					NumericAxis(radiusAxes[element]).interval = (NumericAxis(radiusAxes[element]).max 
																- NumericAxis(radiusAxes[element]).min)/5;
				}
			}
		} 
		
		private function drawAxes():void
		{
			gg.geometryCollection.items = [];
			gg.geometry = [];
			
			var line:Line;
			
			var ele:Array = angleAxis.elements;
			var interval:int = angleAxis.interval;
			var nEle:int = angleAxis.elements.length;

			for (var i:int = 0; i<nEle; i++)
			{
				NumericAxis(radiusAxes[ele[i]]).size = radiusSize;
				var angle:int = angleAxis.getPosition(ele[i]);
				var endPosition:Point = PolarCoordinateTransform.getXY(angle,radiusSize,_polarChart.origin);
				
 				line = new Line(_polarChart.origin.x, _polarChart.origin.y, endPosition.x, endPosition.y);
				line.stroke = new SolidStroke(0x000000,.4);
				gg.geometryCollection.addItem(line);

 				var radiusAxis:NumericAxis = NumericAxis(radiusAxes[ele[i]]);
 				var rad:Number;
 				
 				for (var snap:int = radiusAxis.min; snap<radiusAxis.max; snap += radiusAxis.interval)
 				{
 					rad = radiusAxis.getPosition(snap);
	 				var labelPosition:Point = PolarCoordinateTransform.getXY(angle,rad,_polarChart.origin);
					var label:RasterText = new RasterText();
					label.text = String(snap);
	 				label.fontFamily = "verdana";
	 				label.fontSize = _fontSize;
	 				label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(0x000000);
	
					label.x = labelPosition.x;
					label.y = labelPosition.y;

					gg.geometryCollection.addItem(label);
 				} 
			}
		}
	}
}