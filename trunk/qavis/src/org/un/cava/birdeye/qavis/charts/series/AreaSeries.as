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
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.AreaChart;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
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
				if (yAxis)
				{
					if (yAxis is NumericAxis)
						NumericAxis(yAxis).max = maxYValue;
				} else {
					if (chart && chart.yAxis && chart.yAxis is NumericAxis)
						NumericAxis(chart.yAxis).max = maxYValue;
				}
			}
		}

		private var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number, zPos:Number;
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
			cursor.seek(CursorBookmark.FIRST);

			// gg will be the GeometryGroup that will store the global Area 
			// polygon. All hit area elements will be put in ttGeom
			// this increases performances in case the user doesn't set
			// showDataTips to true in the parent chart
			// if it's a 3D chart, than gg will be instantiated for each pair of datavalues
			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);
			while (!cursor.afterLast)
			{
				// if the series has its own x axis, than get the x coordinate
				// position of the data value filtered by xField
				if (xAxis)
						xPos = xAxis.getPosition(cursor.current[xField]);
				else 
						// otherwise use the parent chart x axis to do that
						xPos = chart.xAxis.getPosition(cursor.current[xField]);
				
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = xField;
				
				// if the series has its own y axis, than get the y coordinate
				// position of the data value filtered by yField
				if (yAxis)
				{
					// if the stackType is stacked100, than the y0 coordinate of 
					// the current baseValue is added to the y coordinate of the current
					// data value filtered by yField
					if (_stackType == STACKED100)
					{
						y0 = yAxis.getPosition(baseValues[j]);
						yPos = yAxis.getPosition(
							baseValues[j++] + Math.max(0,cursor.current[yField]));
					} else 
						// if not stacked, than the y coordinate is given by the own y axis
						yPos = yAxis.getPosition(cursor.current[yField]);

					dataFields[1] = yField;
				} else {
					// if no own y axis than use the parent chart y axis to achive the same
					// as above
					if (_stackType == STACKED100)
					{
						y0 = chart.yAxis.getPosition(baseValues[j]);
						yPos = chart.yAxis.getPosition(
							baseValues[j++] + Math.max(0,cursor.current[yField]));
					} else {
						yPos = chart.yAxis.getPosition(cursor.current[yField]);
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
				

				var yAxisRelativeValue:Number = NaN;

				if (zAxis)
				{
					zPos = zAxis.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZAxis(zAxis).height - zPos;
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
					yAxisRelativeValue = XYZAxis(chart.zAxis).height - zPos;
					dataFields[2] = zField;
				}

				// if showdatatips than create a new GeometryGroup and set its 
				// tooltip along with the hit area and events
				if (chart.showDataTips)
				{	// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createGG(cursor.current, dataFields, xPos, yPos, yAxisRelativeValue, 3, ttShapes,ttXoffset,ttYoffset);
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
		
		/** @Private 
		 * Get the x minimum position of the AreaSeries (only used in case the AreaSeries is drawn 
		 * vertically, i.e. the x axis is linear).*/ 
		private function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (xAxis)
			{
				if (xAxis is NumericAxis)
					xPos = xAxis.getPosition(minXValue);
			} else {
				if (chart.xAxis is NumericAxis)
					xPos = chart.xAxis.getPosition(minXValue);
			}
			
			return xPos;
		}
		
		/** @Private 
		 * Returns the y minimum position of the AreaSeries.*/ 
		private function getYMinPosition():Number
		{
			var yPos:Number;
			if (yAxis && yAxis is NumericAxis)
			{
				if (_baseAtZero)
					yPos = yAxis.getPosition(0);
				else
					yPos = yAxis.getPosition(minYValue);
			} else {
				if (chart.yAxis is NumericAxis)
				{
					if (_baseAtZero)
						yPos = chart.yAxis.getPosition(0);
					else
						yPos = chart.yAxis.getPosition(minYValue);
				}
			}
			return yPos;
		}

		private var ttGG:DataItemLayout;
		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		override protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new DataItemLayout();
			ttGG.target = this;
 			if (chart.showDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				addChild(ttGG);
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
 			if (chart.dataTipFunction != null)
				ttGG.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = chart.dataTipPrefix;
 			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}

		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		override protected function calculateMaxY():void
		{
			super.calculateMaxY();
			if (chart && chart is AreaChart && stackType == STACKED100)
				_maxYValue = Math.max(_maxYValue, AreaChart(chart).maxStacked100);
		}
	}
}