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
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.MouseEvent;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.AreaChart;
	import org.un.cava.birdeye.qavis.charts.data.ExtendedGeometryGroup;
	import org.un.cava.birdeye.qavis.charts.renderers.TriangleRenderer;

	public class AreaSeries extends StackableSeries
	{
		override public function get seriesType():String
		{
			return "area";
		}

		private var _baseAtZero:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidateProperties();
			invalidateDisplayList()
		}
		
		private var _form:String;
		public function set form(val:String):void
		{
			_form = val;
		}
		
		public function AreaSeries()
		{
			super();
		}

		override protected function commitProperties():void
		{
			// doesn't need to override commitProperties, since it doesn't need to listen
			// to axes interval changes 
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

		private var poly:Polygon;
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);

			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number;
			var j:Number = 0;
			var t:Number = 0;
			
			var y0:Number = getYMinPosition();
			var y0Prev:Number;
			var dataFields:Array = [];

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
			
			if (! itemRenderer)
				itemRenderer = TriangleRenderer;

			dataProvider.cursor.seek(CursorBookmark.FIRST);
			gg = new ExtendedGeometryGroup();
			gg.target = this;
			graphicsCollection.addItem(gg);
			while (!dataProvider.cursor.afterLast)
			{
				if (horizontalAxis)
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
				else 
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
				
				dataFields[0] = xField;
				
				if (verticalAxis)
				{
					if (_stackType == STACKED100)
					{
						y0 = verticalAxis.getPosition(baseValues[j]);
						yPos = verticalAxis.getPosition(
							baseValues[j++] + Math.max(0,dataProvider.cursor.current[yField]));
					} else 
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);

					dataFields[1] = yField;
				} else {
					if (_stackType == STACKED100)
					{
						y0 = dataProvider.verticalAxis.getPosition(baseValues[j]);
						yPos = dataProvider.verticalAxis.getPosition(
							baseValues[j++] + Math.max(0,dataProvider.cursor.current[yField]));
					} else {
						yPos = dataProvider.verticalAxis.getPosition(dataProvider.cursor.current[yField]);
					}

					dataFields[1] = yField;
				}
				
				if (_stackType == STACKED100)
				{
						ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos, yPos, xPos + + ttXoffset/3, yPos + ttYoffset);
						line.stroke = new SolidStroke(0xaaaaaa,1,2);
		 				ttShapes[0] = line;
				}
				
				if (dataProvider.showDataTips)
				{
					createGG(dataProvider.cursor.current, dataFields, xPos, yPos, 3, ttShapes,ttXoffset,ttYoffset);
					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);				}

				if (t++ > 0) 
				{
					poly = new Polygon()
					poly.data =  String(xPrev) + "," + String(y0Prev) + " " +
								String(xPrev) + "," + String(yPrev) + " " +
								String(xPos) + "," + String(yPos) + " " +
								String(xPos) + "," + String(y0);
					poly.fill = fill;
					poly.stroke = stroke;
					gg.geometryCollection.addItemAt(poly,0);
				}
				y0Prev = y0;
				xPrev = xPos; yPrev = yPos;
				dataProvider.cursor.moveNext();
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
					yPos = verticalAxis.getPosition(minVerticalValue);
			} else {
				if (dataProvider.verticalAxis is NumericAxis)
				{
					if (_baseAtZero)
						yPos = dataProvider.verticalAxis.getPosition(0);
					else
						yPos = dataProvider.verticalAxis.getPosition(minVerticalValue);
				}
			}
			return yPos;
		}

		private var ttGG:ExtendedGeometryGroup;
		override protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, radius:Number,
									shapes:Array = null /* of IGeometry */, ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new ExtendedGeometryGroup();
			ttGG.target = this;
 			if (dataProvider.showDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(dataProvider.cursor.current, dataFields, xPos, yPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				graphicsCollection.addItem(ttGG);
			}
		}
		
		override protected function initGGToolTip():void
		{
			ttGG.target = this;
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (dataProvider.dataTipFunction != null)
				ttGG.dataTipFunction = dataProvider.dataTipFunction;
			if (dataProvider.dataTipPrefix!= null)
				ttGG.dataTipPrefix = dataProvider.dataTipPrefix;
 			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}

		override protected function calculateMaxVertical():void
		{
			super.calculateMaxVertical();
			if (dataProvider && dataProvider is AreaChart && stackType == STACKED100)
				_maxVerticalValue = Math.max(_maxVerticalValue, AreaChart(dataProvider).maxStacked100);
		}
	}
}