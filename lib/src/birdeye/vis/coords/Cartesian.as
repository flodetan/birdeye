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
 
package birdeye.vis.coords
{	
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	
	import birdeye.vis.VisScene;
	import birdeye.vis.scales.BaseScale;
	import birdeye.vis.scales.*;
	import birdeye.vis.elements.geometry.CartesianElement;
	import birdeye.vis.interfaces.*;
	
	/** A CartesianChart can be used to create any 2D or 3D cartesian charts available in the library
	 * apart from those who might have specific features, like stackable series or data-sizable items.
	 * Those specific features are managed directly by charts that extends the CartesianChart 
	 * (AreaChart, BarChart, ColumnChart for stackable series and ScatterPlot, BubbleChart for 
	 * data-sizable items.
	 * The CartesianChart serves as container for all axes and series and coordinates the different
	 * data loading and creation of each component.
	 * If a CartesianChart is provided with an axis, this axis will be shared by all series that have 
	 * not that same axis (x, y or z). In the same way, the CartesianChart provides a dataProvider property 
	 * that can be shared with series that have not a dataProvider. In case the CartesianChart dataProvider 
	 * is used along with some Series dataProvider, than the relevant values defined be the series fields
	 * of all these dataProviders will define the axes (min, max for NumericAxis elements 
	 * for CategoryAxis, etc).
	 * 
	 * A CartesianChart may have multiple and different type of series, multiple axes and 
	 * multiple dataProvider(s).
	 * Most of available cartesian charts are also 3D. If a series specifies the zField, than the chart will
	 * be a 3D chart. By default zAxis is placed at the bottom right of the chart, for this reason it's
	 * recommended to place yAxis to the left of the chart when using 3D charts.
	 * Given the current 3D limitations of the FP platform, for which is not possible to draw
	 * real 3D graphics (moveTo, drawRect, drawLine etc don't include the z coordinate), the AreaChart 
	 * and LineChart are not 3D yet. 
	 * */ 
	[DefaultProperty("dataProvider")]
	[Exclude(name="seriesContainer", kind="property")]
	public class Cartesian extends VisScene
	{
		/** Array of series, mandatory for any cartesian chart.
		 * Each series must implement the ICartesianSeries interface which defines 
		 * methods that allow to set fields, basic styles, axes, dataproviders, renderers,
		 * max and min values, etc. Look at the ICartesianSeries for more details.
		 * Each series can define its own axes, which will have higher priority over the axes
		 * that are provided by the dataProvider (a cartesian chart). In case no axes are 
		 * defined for the series, than those of the data provider are used. 
		 * The data provider (cartesian chart) axes values (min, max, etc) are calculated 
		 * based on the group of series that share them.*/
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.ICartesianSeries")]
        [ArrayElementType("birdeye.vis.interfaces.ICartesianSeries")]
		override public function set series(val:Array):void
		{
			_series = val;
			var stackableSeries:Array = [];
			for (var i:Number = 0, j:Number = 0, t:Number = 0; i<_series.length; i++)
			{
				// if the series doesn't have an own x axis, than
				// it's necessary to create a default x axis inside the
				// cartesian chart. This axis will be shared by all series that
				// have no own x axis
				if (! ICartesianSeries(_series[i]).xAxis)
					needDefaultXAxis = true;

				// if the series doesn't have an own y axis, than
				// it's necessary to create a default y axis inside the
				// cartesian chart. This axis will be shared by all series that
				// have no own y axis
				if (! ICartesianSeries(_series[i]).yAxis)
					needDefaultYAxis = true;
					
				// set the chart target inside the series to 'this'
				// in the future the seriestarget could be an external chart 
				if (! ICartesianSeries(_series[i]).chart)
					ICartesianSeries(_series[i]).chart = this;
					
				// count all stackable series according their type (overlaid, stacked100...)
				// and store its position. This allows to have a general CartesianChart 
				// series that are stackable, where the type of stack used is defined internally
				// the series itself. In case BarChart, AreaChart or ColumnChart are used, than
				// the series stack type is definde directly by the chart.
				// however the following allows keeping the possibility of using stackable series inside
				// a general cartesian chart
				if (_series[i] is IStack)
				{
					if (isNaN(stackableSeries[IStack(_series[i]).seriesType]) || stackableSeries[IStack(_series[i]).seriesType] == undefined) 
						stackableSeries[IStack(_series[i]).seriesType] = 1;
					else 
						stackableSeries[IStack(_series[i]).seriesType] += 1;
					
					IStack(_series[i]).stackPosition = stackableSeries[IStack(_series[i]).seriesType]; 
				} 
			}
			
			// if a series is stackable, than its total property 
			// represents the number of all stackable series with the same type inside the
			// same chart. This allows having multiple series type inside the same chart (TODO) 
			for (j = 0; j<_series.length; j++)
				if (_series[j] is IStack)
					IStack(_series[j]).total = stackableSeries[IStack(_series[j]).seriesType]; 
						
			invalidateProperties();
			invalidateDisplayList();
		}

		private var _is3D:Boolean = false;
		public function get is3D():Boolean
		{
			return _is3D;
		}

		protected var needDefaultXAxis:Boolean;
		protected var needDefaultYAxis:Boolean;
		protected var _xAxis:IAxisUI;
		/** Define the x axis. If it has not defined its placement, than set it to BOTTOM*/ 
		public function set xAxis(val:IAxisUI):void
		{
			_xAxis = val;
			if (_xAxis.placement != BaseScale.BOTTOM && _xAxis.placement != BaseScale.TOP)
				_xAxis.placement = BaseScale.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xAxis():IAxisUI
		{
			return _xAxis;
		}

		protected var _yAxis:IAxisUI;
		/** Define the y axis. If it has not defined its placement, than set it to TOP*/ 
		public function set yAxis(val:IAxisUI):void
		{
			_yAxis = val;
			if (_yAxis.placement != BaseScale.LEFT && _yAxis.placement != BaseScale.RIGHT)
				_yAxis.placement = BaseScale.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yAxis():IAxisUI
		{
			return _yAxis;
		}

 		protected var _zAxis:IAxisUI;
		/** Define the z axis. If it has not defined its placement, than set it to DIAGONAL*/ 
		public function set zAxis(val:IAxisUI):void
		{
			_zAxis = val;
			if (_zAxis.placement != BaseScale.DIAGONAL)
				_zAxis.placement = BaseScale.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zAxis():IAxisUI
		{
			return _zAxis;
		}

		// UIComponent flow

		public function Cartesian() 
		{
			super();
		}
		
		private var leftContainer:Container, rightContainer:Container;
		private var topContainer:Container, bottomContainer:Container;
		private var zContainer:Container;
		/** @Private
		 * Crete and add all containers that define the chart structure.
		 * The seriesContainer will contain all chart series. Remove scrolling and clip the content 
		 * to true for each of them.*/ 
		override protected function createChildren():void
		{
			super.createChildren();
			addChild(leftContainer = new HBox());
			addChild(rightContainer = new HBox());
			addChild(topContainer = new VBox());
			addChild(bottomContainer = new VBox());
			addChild(zContainer = new HBox());
			addChild(_seriesContainer);
			
			zContainer.verticalScrollPolicy = "off";
			zContainer.clipContent = false;
			zContainer.horizontalScrollPolicy = "off";
			zContainer.setStyle("horizontalAlign", "left");

			leftContainer.verticalScrollPolicy = "off";
			leftContainer.clipContent = false;
			leftContainer.horizontalScrollPolicy = "off";
			leftContainer.setStyle("horizontalAlign", "right");

			rightContainer.verticalScrollPolicy = "off";
			rightContainer.clipContent = false;
			rightContainer.horizontalScrollPolicy = "off";
			rightContainer.setStyle("horizontalAlign", "left");

			topContainer.verticalScrollPolicy = "off";
			topContainer.clipContent = false;
			topContainer.horizontalScrollPolicy = "off";
			topContainer.setStyle("verticalAlign", "bottom");

			bottomContainer.verticalScrollPolicy = "off";
			bottomContainer.clipContent = false;
			bottomContainer.horizontalScrollPolicy = "off";
			bottomContainer.setStyle("verticalAlign", "top");
		}

		protected var nCursors:Number;
		/** @Private 
		 * When properties are committed, first remove all current children, second check for series owned axes 
		 * and put them on the corresponding container (left, top, right, bottom). If no axes are defined for one 
		 * or more series, than create the default axes and add them to the related container.
		 * Once all axes are identified (including the default ones), than we can feed them with the 
		 * corresponding data.*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			needDefaultXAxis = needDefaultYAxis = false;
			
			removeAllElements();
			
			nCursors = 0;
			
			if (series)
			{
 				for (var i:int = 0; i<series.length; i++)
				{
					// if series dataprovider doesn' exist or it refers to the
					// chart dataProvider, than set its cursor to this chart cursor (this.cursor)
					if (cursor && (! ISeries(_series[i]).dataProvider 
									|| ISeries(_series[i]).dataProvider == this.dataProvider))
						ISeries(_series[i]).cursor = cursor;

					// nCursors is used in feedAxes to check that all series cursors are ready
					// and therefore check that axes can be properly feeded
					if (cursor || ISeries(_series[i]).cursor)
						nCursors += 1;

					_seriesContainer.addChild(DisplayObject(series[i]));
					var xAxis:IAxisUI = ICartesianSeries(series[i]).xAxis;
					if (xAxis)
					{
						switch (xAxis.placement)
						{
							case BaseScale.TOP:
								topContainer.addChild(DisplayObject(xAxis));
								break; 
							case BaseScale.BOTTOM:
								bottomContainer.addChild(DisplayObject(xAxis));
								break;
						}
					} else 
						needDefaultXAxis = true;
						
					var yAxis:IAxisUI = ICartesianSeries(series[i]).yAxis;
					if (yAxis)
					{
						switch (yAxis.placement)
						{
							case BaseScale.LEFT:
								leftContainer.addChild(DisplayObject(yAxis));
								break;
							case BaseScale.RIGHT:
								rightContainer.addChild(DisplayObject(yAxis));
								break;
						}
					} else 
						needDefaultYAxis = true;

					var tmpZAxis:IAxisUI = ICartesianSeries(series[i]).zAxis;
					if (tmpZAxis)
					{
						zContainer.addChild(DisplayObject(tmpZAxis));
						
						// this will be replaced by a depth property 
 						IAxis(tmpZAxis).size = width; 
 						// the zAxis is in reality an yAxis which is rotated of 90 degrees
 						// on its X coordinate. This will be replaced by a real z axis, when 
 						// FP will provide methods to draw real 3d lines
						zContainer.rotationX = -90;
						
						// this adjusts the positioning of the axis after the rotation
						zContainer.z = width;
						_is3D = true;
 					}
				}
			}

			if (_zAxis)
			{
				_is3D = true;
				zContainer.addChild(DisplayObject(_zAxis));
				// this will be replaced by a depth property 
 				IAxis(_zAxis).size = width; 
 				// the zAxis is in reality an yAxis which is rotated of 90 degrees
 				// on its X coordinate. This will be replaced by a real z axis, when 
 				// FP will provide methods to draw real 3d lines
				zContainer.rotationX = -90;
				// this adjusts the positioning of the axis after the rotation
				zContainer.z = width;
			}
			
			// if some series have no own y axis, than create a default one for the chart
			// that will be used by all series without a y axis
 			if (needDefaultYAxis)
			{
				if (!_yAxis)
					createYAxis();
					
				if (_yAxis.placement == BaseScale.RIGHT)
					rightContainer.addChild(DisplayObject(_yAxis));
				else
					leftContainer.addChild(DisplayObject(_yAxis));
			}
 			// if some series have no own x axis, than create a default one for the chart
			// that will be used by all series without a x axis
			if (needDefaultXAxis)
			{
				if (!_xAxis)
					createXAxis();

				if (_xAxis.placement == BaseScale.TOP)
					topContainer.addChild(DisplayObject(_xAxis));
				else
					bottomContainer.addChild(DisplayObject(_xAxis));
			}
			
			// init all axes, default and series owned 
			if (! axesFeeded)
				feedAxes();
		}
		
		override protected function measure():void
		{
			super.measure();
		}
		
		private var notTurnedYet:Boolean = true;
		/** @Private
		 * In order to calculate the space left for data visualization (seriesContainer) 
		 * we must validate all other containers sizes, which in turn depend on the axes sizes.
		 * So, we first calculate the size needed by each axes container and finally 
		 * set the available size and position for the seriesContainer.*/
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			setActualSize(w,h);
			
			validateBounds();
			leftContainer.y = rightContainer.y = topContainer.height;
			bottomContainer.x = topContainer.x = leftContainer.width;
			leftContainer.x = 0;
			topContainer.y = 0; 
			bottomContainer.y = h - bottomContainer.height;
			rightContainer.x = w - rightContainer.width;

			chartBounds = new Rectangle(leftContainer.x + leftContainer.width, 
										topContainer.y + topContainer.height,
										w - (leftContainer.width + rightContainer.width),
										h - (topContainer.height + bottomContainer.height));
										
			topContainer.width = bottomContainer.width 
				= chartBounds.width;
			leftContainer.height = rightContainer.height 
				= chartBounds.height;
			
			// the z container is placed at the right of the chart
  			zContainer.x = int(chartBounds.width + leftContainer.width);
			zContainer.y = int(chartBounds.height);

			if (showGrid)
				drawGrid();
				
			if (axesFeeded && (_seriesContainer.x != chartBounds.x ||
				_seriesContainer.y != chartBounds.y ||
				_seriesContainer.width != chartBounds.width ||
				_seriesContainer.height != chartBounds.height))
			{
				_seriesContainer.x = chartBounds.x;
				_seriesContainer.y = chartBounds.y;
 				_seriesContainer.width = chartBounds.width;
				_seriesContainer.height = chartBounds.height;
    			for (var i:int = 0; i<_series.length; i++)
				{
					CartesianElement(_series[i]).width = chartBounds.width;
					CartesianElement(_series[i]).height = chartBounds.height;
				}
 	
				// listeners like legends will listen to this event
				dispatchEvent(new Event("ProviderReady"));
				
				if (_is3D)
					rotationY = 42;
				else
					transform.matrix3D = null;
 			}
		}
		
		// other methods
		
		/** @Private
		 * Validate border containers sizes, that depend on the axes sizes that they contain.*/
		private function validateBounds():void
		{
			var tmpSize:Number = 0;
			for (var i:Number = 0; i<leftContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(leftContainer.getChildAt(i)).maxLblSize;
				IAxis(leftContainer.getChildAt(i)).size = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(rightContainer.getChildAt(i)).maxLblSize;
				IAxis(rightContainer.getChildAt(i)).size = rightContainer.height;				
			}
			
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(bottomContainer.getChildAt(i)).maxLblSize;
				IAxis(bottomContainer.getChildAt(i)).size = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(topContainer.getChildAt(i)).maxLblSize;
				IAxis(topContainer.getChildAt(i)).size = topContainer.width;
			}
			
			topContainer.height = tmpSize;
		}
		
		private var currentSeries:ICartesianSeries;
		/** @Private
		 * Feed the axes with either elements (for ex. CategoryAxis) or max and min (for numeric axis).*/
		private function feedAxes():void
		{
			if (nCursors == series.length)
			{
				var elements:Array = [];
				var j:Number = 0;
				
				var maxMin:Array;
				
				// check if a default y axis exists
				if (yAxis)
				{
					if (yAxis is IEnumerableAxis)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentSeries = ICartesianSeries(_series[i]);
							// if the series have their own data provider but have not their own
							// yAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentSeries.dataProvider 
								&& currentSeries.dataProvider != dataProvider
								&& ! currentSeries.yAxis)
							{
								currentSeries.cursor.seek(CursorBookmark.FIRST);
								while (!currentSeries.cursor.afterLast)
								{
									if (elements.indexOf(
										currentSeries.cursor.current[IEnumerableAxis(yAxis).categoryField]) 
										== -1)
										elements[j++] = 
											currentSeries.cursor.current[IEnumerableAxis(yAxis).categoryField];
									currentSeries.cursor.moveNext();
								}
							}
						}
						
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (elements.indexOf(cursor.current[IEnumerableAxis(yAxis).categoryField]) == -1)
									elements[j++] = 
										cursor.current[IEnumerableAxis(yAxis).categoryField];
								cursor.moveNext();
							}
						}

						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							IEnumerableAxis(yAxis).elements = elements;
					} else {
						// if the default y axis is numeric, than calculate its min max values
						maxMin = getMaxMinYValueFromSeriesWithoutYAxis();
						INumerableAxis(yAxis).max = maxMin[0];
						INumerableAxis(yAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;

				// check if a default y axis exists
				if (xAxis)
				{
					if (xAxis is IEnumerableAxis)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentSeries = ICartesianSeries(_series[i]);
							// if the series have their own data provider but have not their own
							// xAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentSeries.dataProvider 
								&& currentSeries.dataProvider != dataProvider
								&& ! currentSeries.xAxis)
							{
								currentSeries.cursor.seek(CursorBookmark.FIRST);
								while (!currentSeries.cursor.afterLast)
								{
									if (elements.indexOf(
										currentSeries.cursor.current[IEnumerableAxis(xAxis).categoryField]) 
										== -1)
										elements[j++] = 
											currentSeries.cursor.current[IEnumerableAxis(xAxis).categoryField];
									currentSeries.cursor.moveNext();
								}
							}
						}
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (elements.indexOf(cursor.current[IEnumerableAxis(xAxis).categoryField]) == -1)
									elements[j++] = 
										cursor.current[IEnumerableAxis(xAxis).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							IEnumerableAxis(xAxis).elements = elements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinXValueFromSeriesWithoutXAxis();
						INumerableAxis(xAxis).max = maxMin[0];
						INumerableAxis(xAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;

				// check if a default z axis exists
				if (zAxis)
				{
					if (zAxis is IEnumerableAxis)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentSeries = ICartesianSeries(_series[i]);
							// if the series have their own data provider but have not their own
							// zAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentSeries.dataProvider 
								&& currentSeries.dataProvider != dataProvider
								&& ! currentSeries.zAxis)
							{
								currentSeries.cursor.seek(CursorBookmark.FIRST);
								while (!currentSeries.cursor.afterLast)
								{
									if (elements.indexOf(
										currentSeries.cursor.current[IEnumerableAxis(zAxis).categoryField]) 
										== -1)
										elements[j++] = 
											currentSeries.cursor.current[IEnumerableAxis(zAxis).categoryField];
									currentSeries.cursor.moveNext();
								}
							}
						}
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (elements.indexOf(cursor.current[IEnumerableAxis(zAxis).categoryField]) == -1)
									elements[j++] = 
										cursor.current[IEnumerableAxis(zAxis).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							IEnumerableAxis(zAxis).elements = elements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinZValueFromSeriesWithoutZAxis();
						INumerableAxis(zAxis).max = maxMin[0];
						INumerableAxis(zAxis).min = maxMin[1];
					}
				} 

				elements = [];
				j = 0;
				
				// check if a default color axis exists
				if (colorAxis)
				{
						// if the default color axis is numeric, than calculate its min max values
						maxMin = getMaxMinColorValueFromSeriesWithoutColorAxis();
						colorAxis.max = maxMin[0];
						colorAxis.min = maxMin[1];
				} 
				
				// init axes of all series that have their own axes
				// since these are children of each series, they are 
				// for sure ready for feeding and it won't affect the axesFeeded status
				for (var i:Number = 0; i<series.length; i++)
					initSeriesAxes(series[i]);
					
				axesFeeded = true;
			}
		}
		
		/** @Private
		 * Calculate the min max values for the default vertical (y) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinYValueFromSeriesWithoutYAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = ICartesianSeries(series[i]);
				// check if the series has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.yAxis && (isNaN(max) || max < currentSeries.maxYValue))
					max = currentSeries.maxYValue;
				// check if the series has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!currentSeries.yAxis && (isNaN(min) || min > currentSeries.minYValue))
					min = currentSeries.minYValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default x (x) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinXValueFromSeriesWithoutXAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;

			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = ICartesianSeries(series[i]);
				// check if the series has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.xAxis && (isNaN(max) || max < currentSeries.maxXValue))
					max = currentSeries.maxXValue;
				// check if the series has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.xAxis && (isNaN(min) || min > currentSeries.minXValue))
					min = currentSeries.minXValue;
			}
					
			return [max,min];
		}
		
		
		/** @Private
		 * Calculate the min max values for the default z axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinZValueFromSeriesWithoutZAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = ICartesianSeries(series[i]);
				// check if the series has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.zAxis && (isNaN(max) || max < currentSeries.maxZValue))
					max = currentSeries.maxZValue;
				// check if the series has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.zAxis && (isNaN(min) || min > currentSeries.minZValue))
					min = currentSeries.minZValue;
			}
					
			return [max,min];
		}
		
		/** @Private
		 * Calculate the min max values for the default color axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinColorValueFromSeriesWithoutColorAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = series[i];
				if (currentSeries.colorField)
				{
					// check if the series has its own color axis and if its max value exists and 
					// is higher than the current max
					if (!currentSeries.colorAxis && (isNaN(max) || max < currentSeries.maxColorValue))
						max = currentSeries.maxColorValue;
					// check if the series has its own color axis and if its min value exists and 
					// is lower than the current min
					if (!currentSeries.colorAxis && (isNaN(min) || min > currentSeries.minColorValue))
						min = currentSeries.minColorValue;
				}
			}
					
			return [max,min];
		}

		
		/** @Private
		 * Init the axes owned by the series passed to this method.*/
		private function initSeriesAxes(series:ICartesianSeries):void
		{
			if (series.cursor)
			{
				var elements:Array = [];
				var j:Number = 0;

				series.cursor.seek(CursorBookmark.FIRST);
				
				if (series.xAxis is IEnumerableAxis)
				{
					while (!series.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (elements.indexOf(series.cursor.current[IEnumerableAxis(series.xAxis).categoryField]) == -1)
							elements[j++] = 
								series.cursor.current[IEnumerableAxis(series.xAxis).categoryField];
						series.cursor.moveNext();
					}
					
					// set the elements propery of the CategoryAxis owned by the current series
					if (elements.length > 0)
						IEnumerableAxis(series.xAxis).elements = elements;
	
				} else if (series.xAxis is INumerableAxis)
				{
					// if the x axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the series, than they are calculated now
					INumerableAxis(series.xAxis).max =
						series.maxXValue;
					INumerableAxis(series.xAxis).min =
						series.minXValue;
				}
	
				elements = [];
				j = 0;
				series.cursor.seek(CursorBookmark.FIRST);
				
				if (series.yAxis is IEnumerableAxis)
				{
					while (!series.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (elements.indexOf(series.cursor.current[IEnumerableAxis(series.yAxis).categoryField]) == -1)
							elements[j++] = 
								series.cursor.current[IEnumerableAxis(series.yAxis).categoryField];
						series.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current series
					if (elements.length > 0)
						IEnumerableAxis(series.yAxis).elements = elements;
	
				} else if (series.yAxis is INumerableAxis)
				{
					// if the y axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the series, than they are calculated now
					INumerableAxis(series.yAxis).max =
						series.maxYValue;
					INumerableAxis(series.yAxis).min =
						series.minYValue;
				}
	
				elements = [];
				j = 0;
				series.cursor.seek(CursorBookmark.FIRST);
				
				if (series.zAxis is IEnumerableAxis)
				{
					while (!series.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (elements.indexOf(series.cursor.current[IEnumerableAxis(series.zAxis).categoryField]) == -1)
							elements[j++] = 
								series.cursor.current[IEnumerableAxis(series.zAxis).categoryField];
						series.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current series
					if (elements.length > 0)
						IEnumerableAxis(series.zAxis).elements = elements;
	
				} else if (series.zAxis is INumerableAxis)
				{
					// if the axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the series, than they are calculated now
					INumerableAxis(series.zAxis).max =
						series.maxZValue;
					INumerableAxis(series.yAxis).min =
						series.minZValue;
				}

				if (series.colorAxis)
				{
					// if the axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the series, than they are calculated now
					series.colorAxis.max =
						series.maxColorValue;
					series.colorAxis.min =
						series.minColorValue;
				}
			}
		}
		
		private var gridGG:GeometryGroup;
		protected function drawGrid():void
		{
			if (xAxis && yAxis && _seriesContainer.width>0 && _seriesContainer.height>0)
			{
				if (!gridGG)
				{
					gridGG = new GeometryGroup();
				}

				if (yAxis is INumerableAxis)
				{
					var minY:Number = 0;
					var maxY:Number = yAxis.size;
					
					// since the yAxis is up side down, the y interval is given by:
					var interval:Number = yAxis.getPosition(INumerableAxis(yAxis).max - yAxis.interval);
					var i:Number = 0;
					
					for (var yValue:Number = minY; yValue < maxY; yValue += interval)
					{
						var item:Line = Line(gridGG.geometryCollection.getItemAt(i));
						if (item)
						{
							item.x = 0;
							item.y = yValue;
							item.x1 = _seriesContainer.width;
							item.y1 = yValue;
						} else {
							item = new Line(0, yValue, xAxis.size, yValue);
							item.stroke = new SolidStroke(_gridColor, _gridAlpha, _gridWeight)
							gridGG.geometryCollection.addItem(item);
						}
						i++;
					}
					
					var n:Number = gridGG.geometryCollection.items.length;
					if (i<n)
						for (var j:Number = n; j>=i; j--)
							gridGG.geometryCollection.removeItemAt(j);

					gridGG.target = _seriesContainer;
					_seriesContainer.graphicsCollection.addItem(gridGG);
				}
			}
		}
		
		/** @Private
		 * The creation of default axes can be overrided so that it's possible to 
		 * select a specific default setup. For example, for the bar chart the default 
		 * y axis is a category axis and the x one is linear.
		 * However if CartesianChart is used to build the chart, than a constant axis is used, 
		 * since the user might want to have a single axis only for the chart. 
		 * In this case the constant axis, returning a constant value for any input data,
		 * allows to have all shapes (plots, scatters, etc) aligned on the other remaining 
		 * axis's positions. */
		protected function createYAxis():void
		{
				yAxis = new ConstantAxis();
				yAxis.placement = BaseScale.LEFT;
		}
		/** @Private */
		protected function createXAxis():void
		{
			xAxis = new ConstantAxis();
			xAxis.placement = BaseScale.BOTTOM;
		}

		private function removeAllElements():void
		{
			var i:int; 
			var child:*;
			
			if (leftContainer)
			{
				for (i = 0; i<leftContainer.numChildren; i++)
				{
					child = leftContainer.getChildAt(0); 
					if (child is IAxisUI)
						IAxisUI(child).removeAllElements();
				}
				leftContainer.removeAllChildren();
			}

			if (rightContainer)
			{
				for (i = 0; i<rightContainer.numChildren; i++)
				{
					child = rightContainer.getChildAt(0); 
					if (child is IAxisUI)
						IAxisUI(child).removeAllElements();
				}
				rightContainer.removeAllChildren();
			}
			
			if (topContainer)
			{
				for (i = 0; i<topContainer.numChildren; i++)
				{
					child = topContainer.getChildAt(0); 
					if (child is IAxisUI)
						IAxisUI(child).removeAllElements();
				}
				topContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IAxisUI)
						IAxisUI(child).removeAllElements();
				}
				bottomContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IAxisUI)
						IAxisUI(child).removeAllElements();
				}
				bottomContainer.removeAllChildren();
			}

			if (_seriesContainer)
			{
	  			var nChildren:int = _seriesContainer.numChildren;
				for (i = 0; i<nChildren; i++)
				{
					child = _seriesContainer.getChildAt(0); 
					if (child is ISeries)
						ISeries(child).removeAllElements();
					_seriesContainer.removeChildAt(0);
				}
			}
		}
	}
}