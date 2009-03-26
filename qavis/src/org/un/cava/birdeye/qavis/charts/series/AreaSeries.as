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
		/** It overrides the get seriesType to force the result to be "area".
		 * seriesType is used to provide the possibility of using stackable series
		 * within any type of chart instead of only using them inside their own 
		 * chart type.*/
		override public function get seriesType():String
		{
			return "area";
		}

		private var _baseAtZero:Boolean = true;
		/** If true, if min and max values of a series are positive (negative), 
		 * than the base of the AreaSeries will be 0, instead of the min (max) value.*/
		[Inspectable(enumeration="true,false")]
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidateProperties();
			invalidateDisplayList()
		}
		
		private var _form:String;
		/** The form defines the shape type of the series, ("curve", "line").*/
		public function set form(val:String):void
		{
			_form = val;
			invalidateDisplayList();
		}
		
		public function AreaSeries()
		{
			super();
		}

		override protected function commitProperties():void
		{
			// select the item renderer (must be an IGeomentry)
			if (! itemRenderer)
				itemRenderer = TriangleRenderer;

			// doesn't need to call super.commitProperties(), since it doesn't need to listen
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
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number;
			var j:Number = 0;
			var t:Number = 0;
			
			var y0:Number = getYMinPosition();
			var y0Prev:Number;
			var dataFields:Array = [];

			// shapes array defining the tooltip geometries
			var ttShapes:Array;
			// tooltip distance from the hitarea position
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
			
			// move data provider cursor at the beginning
			dataProvider.cursor.seek(CursorBookmark.FIRST);

			// gg will be the GeometryGroup that will store the global Area 
			// polygon. All hit area elements will be put in ttGeom
			// this increases performances in case the user doesn't set
			// showDataTips to true in the parent chart
			gg = new ExtendedGeometryGroup();
			gg.target = this;
			graphicsCollection.addItem(gg);
			while (!dataProvider.cursor.afterLast)
			{
				// if the series has its own x axis, than get the x coordinate
				// position of the data value filtered by xField
				if (horizontalAxis)
						xPos = horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
				else 
						// otherwise use the parent chart x axis to do that
						xPos = dataProvider.horizontalAxis.getPosition(dataProvider.cursor.current[xField]);
				
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = xField;
				
				// if the series has its own y axis, than get the y coordinate
				// position of the data value filtered by yField
				if (verticalAxis)
				{
					// if the stackType is stacked100, than the y0 coordinate of 
					// the current baseValue is added to the y coordinate of the current
					// data value filtered by yField
					if (_stackType == STACKED100)
					{
						y0 = verticalAxis.getPosition(baseValues[j]);
						yPos = verticalAxis.getPosition(
							baseValues[j++] + Math.max(0,dataProvider.cursor.current[yField]));
					} else 
						// if not stacked, than the y coordinate is given by the own vertical axis
						yPos = verticalAxis.getPosition(dataProvider.cursor.current[yField]);

					dataFields[1] = yField;
				} else {
					// if no own vertical axis than use the parent chart y axis to achive the same
					// as above
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
				
				// if stacked 100 than change the default tooltip shape to a line
				// that won't be covered by the children layering
				if (_stackType == STACKED100)
				{
						ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos, yPos, xPos + + ttXoffset/3, yPos + ttYoffset);
						line.stroke = new SolidStroke(0xaaaaaa,1,2);
		 				ttShapes[0] = line;
				}
				
				// if showdatatips than create a new GeometryGroup and set its 
				// tooltip along with the hit area and events
				if (dataProvider.showDataTips)
				{
					createGG(dataProvider.cursor.current, dataFields, xPos, yPos, 3, ttShapes,ttXoffset,ttYoffset);
					var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
					hitMouseArea.fill = new SolidFill(0x000000, 0);
					ttGG.geometryCollection.addItem(hitMouseArea);				
				}

				// create the polygon only if there is more than 1 data value
				// there cannot be an area with only the first data value 
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

				// store previous data values coordinates, to rely them 
				// to the next data value coordinates
				y0Prev = y0;
				xPrev = xPos; yPrev = yPos;
				dataProvider.cursor.moveNext();
			}
		}
		
		/** @Private 
		 * Get the x minimum position of the AreaSeries (only used in case the AreaSeries is drawn 
		 * vertically, i.e. the horizontal axis is linear).*/ 
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
		
		/** @Private 
		 * Returns the y minimum position of the AreaSeries.*/ 
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
		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
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
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
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

		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		override protected function calculateMaxVertical():void
		{
			super.calculateMaxVertical();
			if (dataProvider && dataProvider is AreaChart && stackType == STACKED100)
				_maxVerticalValue = Math.max(_maxVerticalValue, AreaChart(dataProvider).maxStacked100);
		}
	}
}