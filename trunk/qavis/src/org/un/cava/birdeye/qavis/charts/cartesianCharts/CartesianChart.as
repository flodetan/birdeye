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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.qavis.charts.BaseChart;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.LinearAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.XYAxis;
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
				// if the series doesn't have an own horizontal axis, than
				// it's necessary to create a default horizontal axis inside the
				// cartesian chart. This axis will be shared by all series that
				// have no own horizontal axis
				if (! ICartesianSeries(_series[i]).horizontalAxis)
					needDefaultXAxis = true;

				// if the series doesn't have an own vertical axis, than
				// it's necessary to create a default vertical axis inside the
				// cartesian chart. This axis will be shared by all series that
				// have no own vertical axis
				if (! ICartesianSeries(_series[i]).verticalAxis)
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

		protected var needDefaultXAxis:Boolean;
		protected var needDefaultYAxis:Boolean;
		protected var _horizontalAxis:IAxisLayout;
		/** Define the horizontal axis. If it has not defined its placement, than set it to BOTTOM*/ 
		public function set horizontalAxis(val:IAxisLayout):void
		{
			_horizontalAxis = val;
			if (_horizontalAxis.placement != XYAxis.BOTTOM && _horizontalAxis.placement != XYAxis.TOP)
				_horizontalAxis.placement = XYAxis.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get horizontalAxis():IAxisLayout
		{
			return _horizontalAxis;
		}

		protected var _verticalAxis:IAxisLayout;
		/** Define the vertical axis. If it has not defined its placement, than set it to TOP*/ 
		public function set verticalAxis(val:IAxisLayout):void
		{
			_verticalAxis = val;
			if (_verticalAxis.placement != XYAxis.LEFT && _verticalAxis.placement != XYAxis.RIGHT)
				_verticalAxis.placement = XYAxis.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get verticalAxis():IAxisLayout
		{
			return _verticalAxis;
		}

 		protected var _zAxis:IAxisLayout;
		/** Define the z axis. If it has not defined its placement, than set it to DIAGONAL*/ 
		public function set zAxis(val:IAxisLayout):void
		{
			_zAxis = val;
			if (_zAxis.placement != XYAxis.DIAGONAL)
				_zAxis.placement = XYAxis.DIAGONAL;

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
		private var seriesContainer:UIComponent = new UIComponent();
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
			addChild(seriesContainer);
			
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
					var xAxis:IAxisLayout = ICartesianSeries(series[i]).horizontalAxis;
					if (xAxis)
					{
						switch (xAxis.placement)
						{
							case XYAxis.TOP:
								topContainer.addChild(DisplayObject(xAxis));
								break; 
							case XYAxis.BOTTOM:
								bottomContainer.addChild(DisplayObject(xAxis));
								break;
						}
					} else 
						needDefaultXAxis = true;
						
					var yAxis:IAxisLayout = ICartesianSeries(series[i]).verticalAxis;
					if (yAxis)
					{
						switch (yAxis.placement)
						{
							case XYAxis.LEFT:
								leftContainer.addChild(DisplayObject(yAxis));
								break;
							case XYAxis.RIGHT:
								rightContainer.addChild(DisplayObject(yAxis));
								break;
						}
					} else 
						needDefaultYAxis = true;
				}
			}
			
			// if some series have no own vertical axis, than create a default one for the chart
			// that will be used by all series without a vertical axis
			if (needDefaultYAxis)
			{
				if (!_verticalAxis)
					createVerticalAxis();
					
				if (_verticalAxis.placement == XYAxis.RIGHT)
					rightContainer.addChild(DisplayObject(_verticalAxis));
				else
					leftContainer.addChild(DisplayObject(_verticalAxis));
			}
			// if some series have no own horizontal axis, than create a default one for the chart
			// that will be used by all series without a horizontal axis
			if (needDefaultXAxis)
			{
				if (!_horizontalAxis)
					createHorizontalAxis();

				if (_horizontalAxis.placement == XYAxis.TOP)
					topContainer.addChild(DisplayObject(_horizontalAxis));
				else
					bottomContainer.addChild(DisplayObject(_horizontalAxis));
			}
			
			// init all axes, default and series owned 
			feedAxes();
		}
		
		override protected function measure():void
		{
			super.measure();
		}
		
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
				
			if (seriesContainer.x != chartBounds.x ||
				seriesContainer.y != chartBounds.y ||
				seriesContainer.width != chartBounds.width ||
				seriesContainer.height != chartBounds.height)
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
				tmpSize += XYAxis(leftContainer.getChildAt(i)).maxLblSize;
				XYAxis(leftContainer.getChildAt(i)).height = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYAxis(rightContainer.getChildAt(i)).maxLblSize;
				XYAxis(rightContainer.getChildAt(i)).height = rightContainer.height;				
			}
			
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYAxis(bottomContainer.getChildAt(i)).maxLblSize;
				XYAxis(bottomContainer.getChildAt(i)).width = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYAxis(topContainer.getChildAt(i)).maxLblSize;
				XYAxis(topContainer.getChildAt(i)).width = topContainer.width;
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
				
				// check if a default vertical axis exists
				if (verticalAxis)
				{
					if (verticalAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							// if the category value already exists in the axis, than skip it
							if (elements.indexOf(cursor.current[CategoryAxis(verticalAxis).categoryField]) == -1)
								elements[j++] = 
									cursor.current[CategoryAxis(verticalAxis).categoryField];
							cursor.moveNext();
						}
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							CategoryAxis(verticalAxis).elements = elements;
					} else {
						// if the default vertical axis is numeric, than calculate its min max values
						maxMin = getMaxMinYValueFromSeriesWithoutVAxis();
						NumericAxis(verticalAxis).max = maxMin[0];
						NumericAxis(verticalAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;
				cursor.seek(CursorBookmark.FIRST);

				// check if a default vertical axis exists
				if (horizontalAxis)
				{
					if (horizontalAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							// if the category value already exists in the axis, than skip it
							if (elements.indexOf(cursor.current[CategoryAxis(horizontalAxis).categoryField]) == -1)
								elements[j++] = 
									cursor.current[CategoryAxis(horizontalAxis).categoryField];
							cursor.moveNext();
						}
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							CategoryAxis(horizontalAxis).elements = elements;
					} else {
						// if the default horizontal axis is numeric, than calculate its min max values
						maxMin = getMaxMinXValueFromSeriesWithoutHAxis();
						NumericAxis(horizontalAxis).max = maxMin[0];
						NumericAxis(horizontalAxis).min = maxMin[1];
					}
				} 
				
				// init all series that have their own axes
				for (var i:Number = 0; i<series.length; i++)
					initSeriesAxes(series[i]);
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
				// check if the series has its own vertical axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).verticalAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxVerticalValue))
					max = CartesianSeries(series[i]).maxVerticalValue;
				// check if the series has its own vertical axis and if its min value exists and 
				// is lower than the current min
				if (!CartesianSeries(series[i]).verticalAxis && (isNaN(min) || min > CartesianSeries(series[i]).minVerticalValue))
					min = CartesianSeries(series[i]).minVerticalValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default horizontal (x) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinXValueFromSeriesWithoutHAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				// check if the series has its own horizontal axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).horizontalAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxHorizontalValue))
					max = CartesianSeries(series[i]).maxHorizontalValue;
				// check if the series has its own horizontal axis and if its max value exists and 
				// is higher than the current max
				if (!CartesianSeries(series[i]).horizontalAxis && (isNaN(min) || min > CartesianSeries(series[i]).minHorizontalValue))
					min = CartesianSeries(series[i]).minHorizontalValue;
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
				
			if (ICartesianSeries(series).horizontalAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					// if the category value already exists in the axis, than skip it
					if (elements.indexOf(cursor.current[CategoryAxis(ICartesianSeries(series).horizontalAxis).categoryField]) == -1)
						elements[j++] = 
							cursor.current[CategoryAxis(ICartesianSeries(series).horizontalAxis).categoryField];
					cursor.moveNext();
				}
				
				// set the elements propery of the CategoryAxis owned by the current series
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).horizontalAxis).elements = elements;

			} else if (ICartesianSeries(series).horizontalAxis is NumericAxis)
			{
				// if the horizontal axis is numeric than set its maximum and minimum values 
				// if the max and min are not yet defined for the series, than they are calculated now
				NumericAxis(ICartesianSeries(series).horizontalAxis).max =
					ICartesianSeries(series).maxHorizontalValue;
				NumericAxis(ICartesianSeries(series).horizontalAxis).min =
					ICartesianSeries(series).minHorizontalValue;
			}

			elements = [];
			j = 0;
			cursor.seek(CursorBookmark.FIRST);
			
			if (ICartesianSeries(series).verticalAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					// if the category value already exists in the axis, than skip it
					if (elements.indexOf(cursor.current[CategoryAxis(ICartesianSeries(series).verticalAxis).categoryField]) == -1)
						elements[j++] = 
							cursor.current[CategoryAxis(ICartesianSeries(series).verticalAxis).categoryField];
					cursor.moveNext();
				}
						
				// set the elements propery of the CategoryAxis owned by the current series
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).verticalAxis).elements = elements;

			} else if (ICartesianSeries(series).verticalAxis is NumericAxis)
			{
				// if the vertical axis is numeric than set its maximum and minimum values 
				// if the max and min are not yet defined for the series, than they are calculated now
				NumericAxis(ICartesianSeries(series).verticalAxis).max =
					ICartesianSeries(series).maxVerticalValue;
				NumericAxis(ICartesianSeries(series).verticalAxis).min =
					ICartesianSeries(series).minVerticalValue;
			}
		}
		
		/** @Private
		 * The creation of default axes can be overrided so that it's possible to 
		 * select a specific default setup. For example, for the bar chart the default 
		 * vertical axis is a category axis and the horizontal one is linear.*/
		protected function createVerticalAxis():void
		{
				verticalAxis = new LinearAxis();
				verticalAxis.placement = XYAxis.LEFT;
		}
		/** @Private */
		protected function createHorizontalAxis():void
		{
			horizontalAxis = new LinearAxis();
			horizontalAxis.placement = XYAxis.BOTTOM;
		}

	}
}