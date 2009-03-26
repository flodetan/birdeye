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
 
package org.un.cava.birdeye.qavis.charts.cartesianCharts
{	
	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	
	import org.un.cava.birdeye.qavis.charts.BaseChart;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.LinearAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;
	import org.un.cava.birdeye.qavis.charts.interfaces.IStack;
	import org.un.cava.birdeye.qavis.charts.series.CartesianSeries;
	
	[DefaultProperty("dataProvider")]
	public class CartesianChart extends BaseChart
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
        [Inspectable(category="General", arrayType="org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries")]
        [ArrayElementType("org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries")]
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
					
				// set the data provider inside the series to 'this'
				if (! ICartesianSeries(_series[i]).dataProvider)
					ICartesianSeries(_series[i]).dataProvider = this;
					
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
		protected var _xAxis:IAxisLayout;
		/** Define the x axis. If it has not defined its placement, than set it to BOTTOM*/ 
		public function set xAxis(val:IAxisLayout):void
		{
			_xAxis = val;
			if (_xAxis.placement != XYZAxis.BOTTOM && _xAxis.placement != XYZAxis.TOP)
				_xAxis.placement = XYZAxis.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xAxis():IAxisLayout
		{
			return _xAxis;
		}

		protected var _yAxis:IAxisLayout;
		/** Define the y axis. If it has not defined its placement, than set it to TOP*/ 
		public function set yAxis(val:IAxisLayout):void
		{
			_yAxis = val;
			if (_yAxis.placement != XYZAxis.LEFT && _yAxis.placement != XYZAxis.RIGHT)
				_yAxis.placement = XYZAxis.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yAxis():IAxisLayout
		{
			return _yAxis;
		}

 		protected var _zAxis:IAxisLayout;
		/** Define the z axis. If it has not defined its placement, than set it to DIAGONAL*/ 
		public function set zAxis(val:IAxisLayout):void
		{
			_zAxis = val;
			if (_zAxis.placement != XYZAxis.DIAGONAL)
				_zAxis.placement = XYZAxis.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zAxis():IAxisLayout
		{
			return _zAxis;
		}

		// UIComponent flow

		public function CartesianChart() 
		{
			super();
		}
		
		private var leftContainer:Container, rightContainer:Container;
		private var topContainer:Container, bottomContainer:Container;
		private var zContainer:Container;
		private var seriesContainer:Surface = new Surface();
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
			addChild(seriesContainer);
			
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
			
			leftContainer.removeAllChildren();
			rightContainer.removeAllChildren();
			topContainer.removeAllChildren();
			bottomContainer.removeAllChildren();
			zContainer.removeAllChildren();
						
  			var nChildren:int = seriesContainer.numChildren;
			for (var i:Number = 0; i<nChildren; i++)
			{
				if (seriesContainer.getChildAt(0) is ICartesianSeries)
					ICartesianSeries(series[0]).removeAllElements();
				seriesContainer.removeChildAt(0);
			}

			if (series)
			{
 				for (i = 0; i<series.length; i++)
				{
					seriesContainer.addChild(DisplayObject(series[i]));
					var xAxis:IAxisLayout = ICartesianSeries(series[i]).xAxis;
					if (xAxis)
					{
						switch (xAxis.placement)
						{
							case XYZAxis.TOP:
								topContainer.addChild(DisplayObject(xAxis));
								break; 
							case XYZAxis.BOTTOM:
								bottomContainer.addChild(DisplayObject(xAxis));
								break;
						}
					} else 
						needDefaultXAxis = true;
						
					var yAxis:IAxisLayout = ICartesianSeries(series[i]).yAxis;
					if (yAxis)
					{
						switch (yAxis.placement)
						{
							case XYZAxis.LEFT:
								leftContainer.addChild(DisplayObject(yAxis));
								break;
							case XYZAxis.RIGHT:
								rightContainer.addChild(DisplayObject(yAxis));
								break;
						}
					} else 
						needDefaultYAxis = true;

					var tmpZAxis:IAxisLayout = ICartesianSeries(series[i]).zAxis;
					if (tmpZAxis)
					{
						zContainer.addChild(DisplayObject(tmpZAxis));
 						XYZAxis(tmpZAxis).height = 500; 
						zContainer.rotationX = -90;
						zContainer.z = 500;
						_is3D = true;
 					}
				}
			}

			if (_zAxis)
			{
				_is3D = true;
				zContainer.addChild(DisplayObject(_zAxis));
 				XYZAxis(_zAxis).height = 500; 
				zContainer.rotationX = -90;
				zContainer.z = 500;
			}
			
			// if some series have no own y axis, than create a default one for the chart
			// that will be used by all series without a y axis
			if (needDefaultYAxis)
			{
				if (!_yAxis)
					createYAxis();
					
				if (_yAxis.placement == XYZAxis.RIGHT)
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

				if (_xAxis.placement == XYZAxis.TOP)
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
			
			var zContX:int = chartBounds.width + leftContainer.width;
			var zContY:int = chartBounds.height;
  			zContainer.x = zContX;
			zContainer.y = zContY;

			if (axesFeeded && (seriesContainer.x != chartBounds.x ||
				seriesContainer.y != chartBounds.y ||
				seriesContainer.width != chartBounds.width ||
				seriesContainer.height != chartBounds.height))
			{
				seriesContainer.x = chartBounds.x;
				seriesContainer.y = chartBounds.y;
				seriesContainer.width = chartBounds.width;
				seriesContainer.height = chartBounds.height;
  				for (var i:int = 0; i<_series.length; i++)
				{
					CartesianSeries(_series[i]).width = chartBounds.width;
					CartesianSeries(_series[i]).height = chartBounds.height;
				}
	
				
				// listeners like legends will listen to this event
				dispatchEvent(new Event("ProviderReady"));
				
				if (_is3D)
					rotationY = 39;
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
				XYZAxis(leftContainer.getChildAt(i)).height = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(rightContainer.getChildAt(i)).maxLblSize;
				XYZAxis(rightContainer.getChildAt(i)).height = rightContainer.height;				
			}
			
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(bottomContainer.getChildAt(i)).maxLblSize;
				XYZAxis(bottomContainer.getChildAt(i)).width = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(topContainer.getChildAt(i)).maxLblSize;
				XYZAxis(topContainer.getChildAt(i)).width = topContainer.width;
			}
			
			topContainer.height = tmpSize;
		}
		
		/** @Private
		 * Feed the axes with either elements (for ex. CategoryAxis) or max and min (for numeric axis).*/
		private function feedAxes():void
		{
			if (cursor)
			{
				var elements:Array = [];
				var j:Number = 0;
				cursor.seek(CursorBookmark.FIRST);
				
				var maxMin:Array;
				
				// check if a default y axis exists
				if (yAxis)
				{
					if (yAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							// if the category value already exists in the axis, than skip it
							if (elements.indexOf(cursor.current[CategoryAxis(yAxis).categoryField]) == -1)
								elements[j++] = 
									cursor.current[CategoryAxis(yAxis).categoryField];
							cursor.moveNext();
						}
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							CategoryAxis(yAxis).elements = elements;
					} else {
						// if the default y axis is numeric, than calculate its min max values
						maxMin = getMaxMinYValueFromSeriesWithoutVAxis();
						NumericAxis(yAxis).max = maxMin[0];
						NumericAxis(yAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;
				cursor.seek(CursorBookmark.FIRST);

				// check if a default y axis exists
				if (xAxis)
				{
					if (xAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							// if the category value already exists in the axis, than skip it
							if (elements.indexOf(cursor.current[CategoryAxis(xAxis).categoryField]) == -1)
								elements[j++] = 
									cursor.current[CategoryAxis(xAxis).categoryField];
							cursor.moveNext();
						}
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							CategoryAxis(xAxis).elements = elements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinXValueFromSeriesWithoutHAxis();
						NumericAxis(xAxis).max = maxMin[0];
						NumericAxis(xAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;
				cursor.seek(CursorBookmark.FIRST);

				// check if a default y axis exists
				if (zAxis)
				{
					if (zAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							// if the category value already exists in the axis, than skip it
							if (elements.indexOf(cursor.current[CategoryAxis(zAxis).categoryField]) == -1)
								elements[j++] = 
									cursor.current[CategoryAxis(zAxis).categoryField];
							cursor.moveNext();
						}
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							CategoryAxis(zAxis).elements = elements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinZValueFromSeriesWithoutHAxis();
						NumericAxis(zAxis).max = maxMin[0];
						NumericAxis(zAxis).min = maxMin[1];
					}
				} 

				// init all series that have their own axes
				// since these are children of each series, they are 
				// for sure ready for feeding and it won't affect the axesNotFeeded status
				for (var i:Number = 0; i<series.length; i++)
					initSeriesAxes(series[i]);
					
				axesFeeded = true;
			}
		}
		
		/** @Private
		 * Calculate the min max values for the default vertical (y) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinYValueFromSeriesWithoutVAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				// check if the series has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).yAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxYValue))
					max = CartesianSeries(series[i]).maxYValue;
				// check if the series has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!CartesianSeries(series[i]).yAxis && (isNaN(min) || min > CartesianSeries(series[i]).minYValue))
					min = CartesianSeries(series[i]).minYValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default x (x) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinXValueFromSeriesWithoutHAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				// check if the series has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).xAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxXValue))
					max = CartesianSeries(series[i]).maxXValue;
				// check if the series has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).xAxis && (isNaN(min) || min > CartesianSeries(series[i]).minXValue))
					min = CartesianSeries(series[i]).minXValue;
			}
					
			return [max,min];
		}
		
		
		/** @Private
		 * Calculate the min max values for the default z axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinZValueFromSeriesWithoutHAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				// check if the series has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).zAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxZValue))
					max = CartesianSeries(series[i]).maxZValue;
				// check if the series has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).zAxis && (isNaN(min) || min > CartesianSeries(series[i]).minZValue))
					min = CartesianSeries(series[i]).minZValue;
			}
					
			return [max,min];
		}
		
		
		/** @Private
		 * Init the axes owned by the series passed to this method.*/
		private function initSeriesAxes(series:ICartesianSeries):void
		{
			var elements:Array = [];
			var j:Number = 0;
			cursor.seek(CursorBookmark.FIRST);
				
			if (ICartesianSeries(series).xAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					// if the category value already exists in the axis, than skip it
					if (elements.indexOf(cursor.current[CategoryAxis(ICartesianSeries(series).xAxis).categoryField]) == -1)
						elements[j++] = 
							cursor.current[CategoryAxis(ICartesianSeries(series).xAxis).categoryField];
					cursor.moveNext();
				}
				
				// set the elements propery of the CategoryAxis owned by the current series
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).xAxis).elements = elements;

			} else if (ICartesianSeries(series).xAxis is NumericAxis)
			{
				// if the x axis is numeric than set its maximum and minimum values 
				// if the max and min are not yet defined for the series, than they are calculated now
				NumericAxis(ICartesianSeries(series).xAxis).max =
					ICartesianSeries(series).maxXValue;
				NumericAxis(ICartesianSeries(series).xAxis).min =
					ICartesianSeries(series).minXValue;
			}

			elements = [];
			j = 0;
			cursor.seek(CursorBookmark.FIRST);
			
			if (ICartesianSeries(series).yAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					// if the category value already exists in the axis, than skip it
					if (elements.indexOf(cursor.current[CategoryAxis(ICartesianSeries(series).yAxis).categoryField]) == -1)
						elements[j++] = 
							cursor.current[CategoryAxis(ICartesianSeries(series).yAxis).categoryField];
					cursor.moveNext();
				}
						
				// set the elements propery of the CategoryAxis owned by the current series
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).yAxis).elements = elements;

			} else if (ICartesianSeries(series).yAxis is NumericAxis)
			{
				// if the y axis is numeric than set its maximum and minimum values 
				// if the max and min are not yet defined for the series, than they are calculated now
				NumericAxis(ICartesianSeries(series).yAxis).max =
					ICartesianSeries(series).maxYValue;
				NumericAxis(ICartesianSeries(series).yAxis).min =
					ICartesianSeries(series).minYValue;
			}

			elements = [];
			j = 0;
			cursor.seek(CursorBookmark.FIRST);
			
			if (ICartesianSeries(series).zAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					// if the category value already exists in the axis, than skip it
					if (elements.indexOf(cursor.current[CategoryAxis(ICartesianSeries(series).zAxis).categoryField]) == -1)
						elements[j++] = 
							cursor.current[CategoryAxis(ICartesianSeries(series).zAxis).categoryField];
					cursor.moveNext();
				}
						
				// set the elements propery of the CategoryAxis owned by the current series
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).zAxis).elements = elements;

			} else if (ICartesianSeries(series).zAxis is NumericAxis)
			{
				// if the axis is numeric than set its maximum and minimum values 
				// if the max and min are not yet defined for the series, than they are calculated now
				NumericAxis(ICartesianSeries(series).zAxis).max =
					ICartesianSeries(series).maxZValue;
				NumericAxis(ICartesianSeries(series).yAxis).min =
					ICartesianSeries(series).minZValue;
			}
		}
		
		/** @Private
		 * The creation of default axes can be overrided so that it's possible to 
		 * select a specific default setup. For example, for the bar chart the default 
		 * y axis is a category axis and the x one is linear.*/
		protected function createYAxis():void
		{
				yAxis = new LinearAxis();
				yAxis.placement = XYZAxis.LEFT;
		}
		/** @Private */
		protected function createXAxis():void
		{
			xAxis = new LinearAxis();
			xAxis.placement = XYZAxis.BOTTOM;
		}

	}
}