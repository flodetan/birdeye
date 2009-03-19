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
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.BarChart;
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
			if (stackType == STACKED100)
			{
				if (horizontalAxis)
				{
					if (horizontalAxis is NumericAxis)
						NumericAxis(horizontalAxis).max = maxHorizontalValue;
				} else {
					if (dataProvider && dataProvider.horizontalAxis && dataProvider.horizontalAxis is NumericAxis)
						NumericAxis(dataProvider.horizontalAxis).max = maxHorizontalValue;
				}
			}
		}

		private var poly:IGeometry;
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			for (var i:Number = numChildren - 1; i>=0; i--)
				removeChildAt(i);

			var xPos:Number, yPos:Number;
			var j:Number = 0;

			if (!itemRenderer)
				itemRenderer = RectangleRenderer;

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
		
			var x0:Number = getXMinPosition();
			var size:Number = NaN, barWidth:Number = 0; 
			var dataFields:Array = [];

			dataProvider.cursor.seek(CursorBookmark.FIRST);

			while (!dataProvider.cursor.afterLast)
			{
				if (verticalAxis)
				{
					if (verticalAxis is NumericAxis)
					{
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);
						dataFields[0] = yField;
					} else if (verticalAxis is CategoryAxis) {
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[0] = displayName;
					}

					if (isNaN(size))
						size = verticalAxis.interval*(4/5);
				} else {
					if (dataProvider.verticalAxis is NumericAxis)
					{
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[yField]);
						dataFields[0] = yField;
					} else if (dataProvider.verticalAxis is CategoryAxis) {
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[0] = displayName;
					}

					if (isNaN(size))
						size = dataProvider.verticalAxis.interval*(4/5);
				}
				
				if (horizontalAxis)
				{
					if (_stackType == STACKED100)
					{
						x0 = horizontalAxis.getPosition(baseValues[j]);
						xPos = horizontalAxis.getPosition(
							baseValues[j++] + Math.max(0,dataProvider.cursor.current[xField]));
					} else {
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
					}
					dataFields[1] = xField;
				}
				else {
					if (dataProvider.horizontalAxis is NumericAxis)
					{
						if (_stackType == STACKED100)
						{
							x0 = dataProvider.horizontalAxis..getPosition(baseValues[j]);
							xPos = dataProvider.horizontalAxis..getPosition(
								baseValues[j++] + Math.max(0,dataProvider.cursor.current[xField]));
						} else {
							xPos = dataProvider.horizontalAxis..getPosition(dataProvider.cursor.current[xField]);
						}
						dataFields[1] = xField;
					} else if (dataProvider.horizontalAxis is CategoryAxis) {
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[1] = displayName;
					}
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
						line.stroke = new SolidStroke(0x000000,1,2);
		 				ttShapes.push(line)
						break;
					case STACKED:
						yPos = yPos + size/2 - size/_total * _stackPosition;
						barWidth  = size/_total;
						break;
				}
				
				createGG(dataProvider.cursor.current, dataFields, xPos, yPos+barWidth/2, 3,ttShapes,ttXoffset,ttYoffset);

 				var bounds:RegularRectangle = new RegularRectangle(x0, yPos, xPos -x0, barWidth);

				poly = new itemRenderer(bounds);
				poly.fill = fill;
				poly.stroke = stroke;
				gg.geometryCollection.addItemAt(poly,0);
				dataProvider.cursor.moveNext();
			}
		}
		
		private function getXMinPosition():Number
		{
			var xPos:Number;
			if (horizontalAxis && horizontalAxis is NumericAxis)
			{
				if (_baseAtZero)
					xPos = horizontalAxis.getPosition(0);
				else
					xPos = horizontalAxis.getPosition(NumericAxis(horizontalAxis).min);
			} else {
				if (dataProvider.horizontalAxis is NumericAxis)
				{
					if (_baseAtZero)
						xPos = dataProvider.horizontalAxis.getPosition(0);
					else
						xPos = dataProvider.horizontalAxis.getPosition(NumericAxis(dataProvider.horizontalAxis).min);
				}
			}
			return xPos;
		}
		
		override protected function calculateMaxHorizontal():void
		{
			super.calculateMaxHorizontal();
			if (dataProvider && dataProvider is BarChart && stackType == STACKED100) 
				_maxHorizontalValue = Math.max(_maxHorizontalValue, BarChart(dataProvider).maxStacked100);
		}
	}
}