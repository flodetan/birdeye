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
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxisUI;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.BarChart;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.renderers.RectangleRenderer;

	public class BarSeries extends StackableSeries 
	{
		override public function get seriesType():String
		{
			return "column";
		}

		private var _baseAtZero:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidateProperties();
			invalidateDisplayList()
		}
		public function get baseAtZero():Boolean
		{
			return _baseAtZero;
		}
		
		private var _form:String;
		public function set form(val:String):void
		{
			_form = val;
		}
		
		public function BarSeries()
		{
			super();
		}
	
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (!itemRenderer)
				itemRenderer = RectangleRenderer;

			if (stackType == STACKED100 && cursor)
			{
				if (xAxis)
				{
					if (xAxis is INumerableAxis)
						INumerableAxis(xAxis).max = maxXValue;
				} else {
					if (chart && chart.xAxis && chart.xAxis is INumerableAxis)
						INumerableAxis(chart.xAxis).max = maxXValue;
				}
			}
		}

		private var poly:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];

			var xPos:Number, yPos:Number, zPos:Number = NaN;
			var j:Object;

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
		
			var x0:Number = getXMinPosition();
			var size:Number = NaN, barWidth:Number = 0; 

			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			cursor.seek(CursorBookmark.FIRST);

			while (!cursor.afterLast)
			{
				if (yAxis)
				{
					yPos = yAxis.getPosition(cursor.current[yField]);

					dataFields[0] = yField;

					if (isNaN(size))
 						size = yAxis.interval*deltaSize;
				} else {
					yPos = chart.yAxis.getPosition(cursor.current[yField]);

					dataFields[0] = yField;

					if (isNaN(size))
						size = chart.yAxis.interval*deltaSize;
				}
				
				j = cursor.current[yField];
				if (xAxis)
				{
					if (_stackType == STACKED100)
					{
						x0 = xAxis.getPosition(baseValues[j]);
						xPos = xAxis.getPosition(
							baseValues[j] + Math.max(0,cursor.current[xField]));
					} else {
						xPos = xAxis.getPosition(cursor.current[xField]);
					}
					dataFields[1] = xField;
				}
				else {
					if (_stackType == STACKED100)
					{
						x0 = chart.xAxis.getPosition(baseValues[j]);
						xPos = chart.xAxis.getPosition(
							baseValues[j] + Math.max(0,cursor.current[xField]));
					} else 
						xPos = chart.xAxis.getPosition(cursor.current[xField]);

					dataFields[1] = xField;
				}
				
				switch (_stackType)
				{
					case OVERLAID:
						barWidth = size;
						yPos = yPos - size/2;
						break;
					case STACKED100:
						barWidth  = size;
						yPos = yPos - size/2;
						ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos, yPos + barWidth/2, xPos + ttXoffset/3, yPos + barWidth/2 + ttYoffset);
						line.stroke = new SolidStroke(0xaaaaaa,1,2);
		 				ttShapes[0] = line;
						break;
					case STACKED:
						yPos = yPos + size/2 - size/_total * _stackPosition;
						barWidth  = size/_total;
						break;
				}
				
				var bounds:RegularRectangle = new RegularRectangle(x0, yPos, xPos -x0, barWidth);

				var yAxisRelativeValue:Number = NaN;

				// TODO: fix stacked100 on 3D
				if (zAxis)
				{
					zPos = zAxis.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZAxisUI(zAxis).height - zPos;
					dataFields[2] = zField;
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
					dataFields[2] = zField;
				}

				// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
				// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
				createTTGG(cursor.current, dataFields, xPos, yPos+barWidth/2, yAxisRelativeValue, 3,ttShapes,ttXoffset,ttYoffset);

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

				poly = new itemRenderer(bounds);
				poly.fill = fill;
				poly.stroke = stroke;
				gg.geometryCollection.addItemAt(poly,0);
				cursor.moveNext();
			}

			if (zField)
				zSort();
		}
		
		private function getXMinPosition():Number
		{
			var xPos:Number;
			if (xAxis && xAxis is INumerableAxis)
			{
				if (_baseAtZero)
					xPos = xAxis.getPosition(0);
				else
					xPos = xAxis.getPosition(INumerableAxis(xAxis).min);
			} else {
				if (chart.xAxis is INumerableAxis)
				{
					if (_baseAtZero)
						xPos = chart.xAxis.getPosition(0);
					else
						xPos = chart.xAxis.getPosition(INumerableAxis(chart.xAxis).min);
				}
			}
			return xPos;
		}
	}
}