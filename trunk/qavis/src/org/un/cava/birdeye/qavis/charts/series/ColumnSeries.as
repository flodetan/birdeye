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
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.ColumnChart;
	import org.un.cava.birdeye.qavis.charts.renderers.RectangleRenderer;

	public class ColumnSeries extends StackableSeries 
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
		
		public function ColumnSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (stackType == STACKED100)
			{
				if (verticalAxis)
				{
					if (verticalAxis is NumericAxis)
						NumericAxis(verticalAxis).max = maxVerticalValue;
				} else {
					if (dataProvider && dataProvider.verticalAxis && dataProvider.verticalAxis is NumericAxis)
						NumericAxis(dataProvider.verticalAxis).max = maxVerticalValue;
				}
			}
		}

		private var poly:IGeometry;
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			for (var i:Number = numChildren - 1; i>=0; i--)
				removeChildAt(i);

			var dataFields:Array = [];

			var xPos:Number, yPos:Number;
			var j:Number = 0;
			
			if (!itemRenderer)
				itemRenderer = RectangleRenderer;

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
			
			var y0:Number = getYMinPosition();
			var size:Number = NaN, colWidth:Number = 0; 

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
					if (isNaN(size))
						size = horizontalAxis.interval*(4/5);
				} else {
					if (dataProvider.horizontalAxis is NumericAxis)
					{
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
						dataFields[0] = xField;
					} else if (dataProvider.horizontalAxis is CategoryAxis) {
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[0] = displayName;
					}
					if (isNaN(size))
						size = dataProvider.horizontalAxis.interval*(4/5);
				}
				
			if (verticalAxis)
				{
					if (_stackType == STACKED100)
					{
						y0 = verticalAxis.getPosition(baseValues[j]);
						yPos = verticalAxis.getPosition(
							baseValues[j++] + Math.max(0,dataProvider.cursor.current[yField]));
					} else {
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);
					}
					dataFields[1] = yField;
				}
				else {
					if (dataProvider.verticalAxis is NumericAxis)
					{
						if (_stackType == STACKED100)
						{
							y0 = dataProvider.verticalAxis..getPosition(baseValues[j]);
							yPos = dataProvider.verticalAxis..getPosition(
								baseValues[j++] + Math.max(0,dataProvider.cursor.current[yField]));
						} else {
							yPos = dataProvider.verticalAxis..getPosition(dataProvider.cursor.current[yField]);
						}
						dataFields[1] = yField;
					} else if (dataProvider.verticalAxis is CategoryAxis) {
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[displayName]);
						dataFields[1] = displayName;
					}
				}
				
				switch (_stackType)
				{
					case OVERLAID:
						colWidth = size;
						xPos = xPos - size/2;
						break;
					case STACKED100:
						colWidth = size;
						xPos = xPos - size/2;
						ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos+ colWidth/2, yPos, xPos + colWidth/2 + ttXoffset/3, yPos + ttYoffset);
						line.stroke = new SolidStroke(0x000000,1,2);
		 				ttShapes.push(line)
						break;
					case STACKED:
						xPos = xPos + size/2 - size/_total * _stackPosition;
						colWidth = size/_total;
						break;
				}
				
				createGG(dataProvider.cursor.current, dataFields, xPos + colWidth/2, yPos, 3,ttShapes,ttXoffset,ttYoffset);

 				var bounds:RegularRectangle = new RegularRectangle(xPos, yPos, colWidth, y0 - yPos);

				poly = new itemRenderer(bounds);

				poly.fill = fill;
				poly.stroke = stroke;
				gg.geometryCollection.addItemAt(poly,0);
				dataProvider.cursor.moveNext();
				
				ttShapes = [];
			}
		}
		
		private function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (horizontalAxis)
			{
				if (horizontalAxis is NumericAxis)
					xPos = horizontalAxis.getPosition(minHorizontalValue);
			} else {
				if (dataProvider.horizontalAxis is NumericAxis)
					xPos = dataProvider.horizontalAxis.getPosition(minHorizontalValue);
			}
			
			return xPos;
		}
		
		private function getYMinPosition():Number
		{
			var yPos:Number;
			if (verticalAxis && verticalAxis is NumericAxis)
			{
				if (_baseAtZero)
					yPos = verticalAxis.getPosition(0);
				else
					yPos = verticalAxis.getPosition(NumericAxis(verticalAxis).min);
			} else {
				if (dataProvider.verticalAxis is NumericAxis)
				{
					if (_baseAtZero)
						yPos = dataProvider.verticalAxis.getPosition(0);
					else
						yPos = dataProvider.verticalAxis.getPosition(NumericAxis(dataProvider.verticalAxis).min);
				}
			}
			return yPos;
		}
		
		override protected function calculateMaxVertical():void
		{
			super.calculateMaxVertical();
			if (dataProvider && dataProvider is ColumnChart && stackType == STACKED100)
				_maxVerticalValue = Math.max(_maxVerticalValue, ColumnChart(dataProvider).maxStacked100);
		}
	}
}