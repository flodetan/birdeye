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
 
package org.un.cava.birdeye.qavis.charts.cartesianSeries
{
	import com.degrafa.IGeometry;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxisUI;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IRasterRenderer;
	import org.un.cava.birdeye.qavis.charts.interfaces.IScatter;
	import org.un.cava.birdeye.qavis.charts.interfaces.ISizableItem;
	import org.un.cava.birdeye.qavis.charts.renderers.CircleRenderer;
	import org.un.cava.birdeye.qavis.charts.renderers.RasterRenderer;

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

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = CircleRenderer;
		}

		private var scatter:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];
			// prepare data for a standard tooltip message in case the user
			// has not set a dataTipFunction
			dataFields[0] = xField;
			dataFields[1] = yField;
			dataFields[2] = radiusField;
			if (zField) 
				dataFields[3] = zField;

			var xPos:Number, yPos:Number, zPos:Number = NaN;
			var dataValue:Number;
			var radius:Number;
			
			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (xAxis)
				{
					xPos = xAxis.getPosition(cursor.current[xField]);
				} else if (chart.xAxis) {
					xPos = chart.xAxis.getPosition(cursor.current[xField]);
				}
				
				if (yAxis)
				{
					yPos = yAxis.getPosition(cursor.current[yField]);
				} else if (chart.yAxis) {
					yPos = chart.yAxis.getPosition(cursor.current[yField]);
				}

				dataValue = cursor.current[radiusField];
				radius = getRadius(dataValue);
 				var bounds:Rectangle = new Rectangle(xPos - radius, yPos - radius, radius * 2, radius * 2);

				var yAxisRelativeValue:Number = NaN;

				if (zAxis)
				{
					zPos = zAxis.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZAxisUI(zAxis).height - zPos;
				} else if (chart.zAxis) {
					zPos = chart.zAxis.getPosition(cursor.current[zField]);
					// since there is no method yet to draw a real z axis 
					// we create an y axis and rotate it to properly visualize 
					// a 'fake' z axis. however zPos over this y axis corresponds to 
					// the axis height - zPos, because the y axis in Flex is 
					// up side down. this trick allows to visualize the y axis as
					// if it would be a z. when there will be a 3d line class, it will 
					// be replaced
					yAxisRelativeValue = XYZAxisUI(chart.zAxis).height - zPos;
				}

				// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
				// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
				createTTGG(cursor.current, dataFields, xPos, yPos, yAxisRelativeValue, 3);

				if (zField)
				{
					if (!isNaN(zPos))
					{
						gg = new DataItemLayout();
						gg.target = this;
						graphicsCollection.addItem(gg);
						ttGG.z = gg.z = zPos;
					} else
						zPos = 0;
				}
				
 				if (_source)
					scatter = new RasterRenderer(bounds, _source);
 				else 
					scatter = new itemRenderer(bounds);
  
				scatter.fill = fill;
				scatter.stroke = stroke;
				gg.geometryCollection.addItemAt(scatter,0);
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
		
		private function getRadius(dataValue:Number):Number
		{
			var maxRadius:Number = 10;
			var radius:Number = 1;
			if (chart && chart is ISizableItem)
			{
				maxRadius = ISizableItem(chart).maxRadius;
				radius = maxRadius * (dataValue - _minRadiusValue)/(_maxRadiusValue - _minRadiusValue);
			}
			
			return radius;
		}
	}
}