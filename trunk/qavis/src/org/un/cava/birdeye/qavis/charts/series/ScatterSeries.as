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
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IScatter;
	import org.un.cava.birdeye.qavis.charts.interfaces.ISizableItem;
	import org.un.cava.birdeye.qavis.charts.renderers.CircleRenderer;

	[Exclude(name="maxRadiusValue", kind="property")]
	[Exclude(name="minRadiusValue", kind="property")]
	public class ScatterSeries extends CartesianSeries implements IScatter 
	{
		private var _maxRadiusValue:Number = NaN;
		public function set maxRadiusValue(val:Number):void
		{
			_maxRadiusValue = val;
			invalidateDisplayList();
		}
		
		private var _minRadiusValue:Number = NaN;
		public function set minRadiusValue(val:Number):void
		{
			_minRadiusValue = val;
			invalidateDisplayList();
		}
		
		private var _radiusField:String;
		public function set radiusField(val:String):void
		{
			_radiusField = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusField():String
		{
			return _radiusField;
		}
		
		public function ScatterSeries()
		{
			super();
		}

		private var scatter:IGeometry;
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			var dataFields:Array = [];

			var xPos:Number, yPos:Number;
			var dataValue:Number;
			var radius:Number;
			
			if (!itemRenderer)
				itemRenderer = CircleRenderer;

			dataProvider.cursor.seek(CursorBookmark.FIRST);
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

				dataValue = dataProvider.cursor.current[radiusField];

				radius = getRadius(dataValue);
 				var bounds:RegularRectangle = new RegularRectangle(xPos - radius, yPos - radius, radius * 2, radius * 2);

				if (dataProvider.showDataTips)
				{
					createGG(dataProvider.cursor.current, dataFields, xPos, yPos, 3);
					var hitMouseArea:RegularRectangle = bounds; 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					gg.geometryCollection.addItem(hitMouseArea);
				}

				scatter = new itemRenderer(bounds);
				scatter.fill = fill;
				scatter.stroke = stroke;
				gg.geometryCollection.addItemAt(scatter,0);
				dataProvider.cursor.moveNext();
			}
		}
		
		private function getRadius(dataValue:Number):Number
		{
			var maxRadius:Number = 10;
			var radius:Number = 1;
			if (dataProvider && dataProvider is ISizableItem)
			{
				maxRadius = ISizableItem(dataProvider).maxRadius;
				radius = maxRadius * (dataValue - _minRadiusValue)/(_maxRadiusValue - _minRadiusValue);
			}
			
			return radius;
		}
	}
}