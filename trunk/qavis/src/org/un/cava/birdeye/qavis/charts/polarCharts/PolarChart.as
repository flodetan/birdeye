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
 
package org.un.cava.birdeye.qavis.charts.polarCharts
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.BaseChart;
	import org.un.cava.birdeye.qavis.charts.axis.BaseAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.PercentAngleAxis;
	import org.un.cava.birdeye.qavis.charts.axis.RadarAxisUI;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisUI;
	import org.un.cava.birdeye.qavis.charts.interfaces.IEnumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IPolarSeries;
	import org.un.cava.birdeye.qavis.charts.interfaces.ISeries;
	import org.un.cava.birdeye.qavis.charts.interfaces.IStack;
	import org.un.cava.birdeye.qavis.charts.polarSeries.PolarSeries;
	
	/** 
	 * The PolarChart is the base chart that is extended by all charts that are
	 * based on polar coordinates (PieChart, RadarChart, CoxCombo, etc). 
	 * The PolarChart serves as container for all axes and series and coordinates the different
	 * data loading and creation of each component.
	 * 
	 * If a PolarChart is provided with an axis, this axis will be shared by all series that have 
	 * not that same axis (angle, and/or radius). 
	 * In the same way, the PolarChart provides a dataProvider property 
	 * that can be shared with series that have not a dataProvider. In case the PolarChart dataProvider 
	 * is used along with some Series dataProvider, than the relevant values defined be the series fields
	 * of all these dataProviders will define the axes.
	 * 
	 * A PolarChart may have multiple and different type of series, multiple axes and 
	 * multiple dataProvider(s).
	 * */ 
	[DefaultProperty("dataProvider")]
	public class PolarChart extends BaseChart
	{
        [Inspectable(category="General", arrayType="org.un.cava.birdeye.qavis.charts.interfaces.IPolarSeries")]
        [ArrayElementType("org.un.cava.birdeye.qavis.charts.interfaces.IPolarSeries")]
		override public function set series(val:Array):void
		{
			_series = val;
			var stackableSeries:Array = [];

			for (var i:Number = 0; i<_series.length; i++)
			{
				// if the series doesn't have an own angle axis, than
				// it's necessary to create a default angle axis inside the
				// polar chart. This axis will be shared by all series that
				// have no own angle axis
				if (! IPolarSeries(_series[i]).angleAxis)
					needDefaultAngleAxis = true;

				// if the series doesn't have an own radius axis, than
				// it's necessary to create a default radius axis inside the
				// polar chart. This axis will be shared by all series that
				// have no own radius axis
				if (! IPolarSeries(_series[i]).radiusAxis)
					needDefaultRadiusAxis = true;
					
				// set the chart target inside the series to 'this'
				// in the future the series target could be an external chart 
				if (! IPolarSeries(_series[i]).polarChart)
					IPolarSeries(_series[i]).polarChart = this;
				
				// count all stackable series according their type (overlaid, stacked100...)
				// and store their position. This allows to have a general PolarChart 
				// series that are stackable, where the type of stack used is defined internally
				// the series itself. In case of RadarChart, is used, than
				// the series stack type is defined directly by the chart.
				// however the following allows keeping the possibility of using stackable series inside
				// a general polar chart
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
			// same chart. This allows having multiple series type inside the same chart 
			for (i = 0; i<_series.length; i++)
				if (_series[i] is IStack)
					IStack(_series[i]).total = stackableSeries[IStack(_series[i]).seriesType]; 
		}

		protected var _radarAxis:RadarAxisUI;
		public function set radarAxis(val:RadarAxisUI):void
		{
			_radarAxis = val;
			_radarAxis.polarChart = this;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radarAxis():RadarAxisUI
		{
			return _radarAxis;
		}
		
		protected var needDefaultAngleAxis:Boolean;
		protected var needDefaultRadiusAxis:Boolean;
		protected var _angleAxis:IAxis;
		/** Set the angle axis. Set its placement to NONE*/ 
		public function set angleAxis(val:IAxis):void
		{
			_angleAxis = val;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get angleAxis():IAxis
		{
			return _angleAxis;
		}

		protected var _radiusAxis:IAxis;
		/** Define the radius axis. If it has not defined its placement, than set it to 
		 * horizontal-center*/ 
		public function set radiusAxis(val:IAxis):void
		{
			_radiusAxis = val;
			if (val is IAxisUI 	&& IAxisUI(_radiusAxis).placement != BaseAxisUI.HORIZONTAL_CENTER 
								&& IAxisUI(_radiusAxis).placement != BaseAxisUI.VERTICAL_CENTER)
				IAxisUI(_radiusAxis).placement = BaseAxisUI.HORIZONTAL_CENTER;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusAxis():IAxis
		{
			return _radiusAxis;
		}
		
		private var _origin:Point;
		public function set origin(val:Point):void
		{
			_origin = val;
			invalidateDisplayList();
		}
		public function get origin():Point
		{
			return _origin;
		}

		private var _columnWidthRate:Number = 3/5;
		public function set columnWidthRate(val:Number):void
		{
			_columnWidthRate = val;
			invalidateDisplayList();
		}
		public function get columnWidthRate():Number
		{
			return _columnWidthRate;
		}
		
		protected var _fontSize:Number = 10;
		public function set fontSize(val:Number):void
		{
			_fontSize = val;
			invalidateDisplayList();
		}
		
		public function PolarChart()
		{
			super();
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
			needDefaultAngleAxis = needDefaultRadiusAxis = false;
			
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

					addChild(DisplayObject(series[i]));
					if (IPolarSeries(series[i]).radiusAxis)
						addChild(DisplayObject(IPolarSeries(series[i]).radiusAxis));
					else 
						needDefaultRadiusAxis = true;

					if (! IPolarSeries(series[i]).angleAxis)
						needDefaultAngleAxis = true;
				}
			}

			// if some series have no own radius axis, than create a default one for the chart
			// that will be used by all series without a radius axis
			if (needDefaultRadiusAxis && !_radarAxis)
			{
				if (!_radiusAxis)
					createRadiusAxis();

				if (_radiusAxis is IAxisUI)
					addChild(DisplayObject(_radiusAxis));
			}

			// if some series have no own angle axis, than create a default one for the chart
			// that will be used by all series without a angle axis
			if (needDefaultAngleAxis && !_radarAxis)
			{
				if (!_angleAxis)
					createAngleAxis();
			}
			
			// init all axes, default and series owned 
			if (! axesFeeded)
				feedAxes();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			setActualSize(unscaledWidth, unscaledHeight);
			
			if (showAllDataTips)
				removeDataItems();
			
			_origin = new Point(unscaledWidth/2, unscaledHeight/2);
			
			if (radarAxis)
			{
				radarAxis.radiusSize = DisplayObject(radarAxis).width  
					= Math.min(unscaledWidth, unscaledHeight)/2;
			} 
			
			if (radiusAxis)
			{
				if (radiusAxis is IAxis)
				{
					radiusAxis.size = Math.min(unscaledWidth, unscaledHeight)/2;
				}
				
				if (radiusAxis is IAxisUI)
				{
					switch (IAxisUI(radiusAxis).placement)
					{
						case BaseAxisUI.HORIZONTAL_CENTER:
							DisplayObject(radiusAxis).x = _origin.x;
							DisplayObject(radiusAxis).y = _origin.y;
							break;
						case BaseAxisUI.VERTICAL_CENTER:
							DisplayObject(radiusAxis).x = _origin.x;
							DisplayObject(radiusAxis).y = _origin.y;
							break;
					}
				}
			} 
			
			for (var i:int = 0; i<_series.length; i++)
			{
				DisplayObject(_series[i]).width = unscaledWidth;
				DisplayObject(_series[i]).height = unscaledHeight;
			}
			
			if (_showAllDataTips)
			{
				for (i = 0; i<numChildren; i++)
				{
					if (getChildAt(i) is DataItemLayout)
						DataItemLayout(getChildAt(i)).showToolTip();
				}
			}

			// listeners like legends will listen to this event
			dispatchEvent(new Event("ProviderReady"));
		}

		protected var currentSeries:IPolarSeries;
		/** @Private
		 * Feed the axes with either elements (for ex. CategoryAxis) or max and min (for numeric axis).*/
		protected function feedAxes():void
		{
			if (nCursors == series.length)
			{
				var elements:Array = [];
				var j:Number = 0;
				
				var maxMin:Array;
				
				// check if a default y axis exists
				if (angleAxis)
				{
					if (angleAxis is IEnumerableAxis)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentSeries = PolarSeries(_series[i]);
							// if the series has its own data provider but has not its own
							// angleAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentSeries.dataProvider 
								&& currentSeries.dataProvider != dataProvider
								&& ! currentSeries.angleAxis)
							{
								currentSeries.cursor.seek(CursorBookmark.FIRST);
								while (!currentSeries.cursor.afterLast)
								{
									if (elements.indexOf(
										currentSeries.cursor.current[IEnumerableAxis(angleAxis).categoryField]) 
										== -1)
										elements[j++] = 
											currentSeries.cursor.current[IEnumerableAxis(angleAxis).categoryField];
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
								if (elements.indexOf(cursor.current[IEnumerableAxis(angleAxis).categoryField]) == -1)
									elements[j++] = 
										cursor.current[IEnumerableAxis(angleAxis).categoryField];
								cursor.moveNext();
							}
						}

						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							IEnumerableAxis(angleAxis).elements = elements;
					} else if (angleAxis is INumerableAxis){
						
						if (INumerableAxis(angleAxis).scaleType != BaseAxisUI.PERCENT)
						{
							// if the default x axis is numeric, than calculate its min max values
							maxMin = getMaxMinAngleValueFromSeriesWithoutAngleAxis();
							INumerableAxis(angleAxis).max = maxMin[0];
							INumerableAxis(angleAxis).min = maxMin[1];
						} else {
							setPositiveTotalAngleValueInSeries();
						}
					}
				} 
				
				elements = [];
				j = 0;

				// check if a default y axis exists
				if (radiusAxis)
				{
					if (radiusAxis is IEnumerableAxis)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentSeries = IPolarSeries(_series[i]);
							// if the series have their own data provider but have not their own
							// xAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentSeries.dataProvider 
								&& currentSeries.dataProvider != dataProvider
								&& ! currentSeries.radiusAxis)
							{
								currentSeries.cursor.seek(CursorBookmark.FIRST);
								while (!currentSeries.cursor.afterLast)
								{
									if (elements.indexOf(
										currentSeries.cursor.current[IEnumerableAxis(radiusAxis).categoryField]) 
										== -1)
										elements[j++] = 
											currentSeries.cursor.current[IEnumerableAxis(radiusAxis).categoryField];
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
								if (elements.indexOf(cursor.current[IEnumerableAxis(radiusAxis).categoryField]) == -1)
									elements[j++] = 
										cursor.current[IEnumerableAxis(radiusAxis).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategoryAxis
						if (elements.length > 0)
							IEnumerableAxis(radiusAxis).elements = elements;
					} else if (radiusAxis is INumerableAxis){
						
						if (INumerableAxis(radiusAxis).scaleType != BaseAxisUI.CONSTANT)
						{
							// if the default x axis is numeric, than calculate its min max values
							maxMin = getMaxMinRadiusValueFromSeriesWithoutRadiusAxis();
						} else {
							maxMin = [1,1];
							INumerableAxis(radiusAxis).size = Math.min(width, height)/2;
						}
						INumerableAxis(radiusAxis).max = maxMin[0];
						INumerableAxis(radiusAxis).min = maxMin[1];
					}
				} 

				elements = [];
				j = 0;

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
		private function getMaxMinRadiusValueFromSeriesWithoutRadiusAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = PolarSeries(series[i]);
				// check if the series has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.radiusAxis && (isNaN(max) || max < currentSeries.maxRadiusValue))
					max = currentSeries.maxRadiusValue;
				// check if the series has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!currentSeries.radiusAxis && (isNaN(min) || min > currentSeries.minRadiusValue))
					min = currentSeries.minRadiusValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default vertical (y) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinAngleValueFromSeriesWithoutAngleAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = PolarSeries(series[i]);
				// check if the series has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!currentSeries.angleAxis && (isNaN(max) || max < currentSeries.maxAngleValue))
					max = currentSeries.maxAngleValue;
				// check if the series has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!currentSeries.angleAxis && (isNaN(min) || min > currentSeries.minAngleValue))
					min = currentSeries.minAngleValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the total of positive values to set in the percent axis and set it for each series.*/
		private function setPositiveTotalAngleValueInSeries():void
		{
			var tot:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				currentSeries = PolarSeries(series[i]);
				// check if the series has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!isNaN(currentSeries.totalAnglePositiveValue))
					INumerableAxis(angleAxis).totalPositiveValue = currentSeries.totalAnglePositiveValue;
			}
		}

		/** @Private
		 * Init the axes owned by the series passed to this method.*/
		private function initSeriesAxes(series:IPolarSeries):void
		{
			if (series.cursor)
			{
				var elements:Array = [];
				var j:Number = 0;

				series.cursor.seek(CursorBookmark.FIRST);
				
				if (series.angleAxis is IEnumerableAxis)
				{
					while (!series.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (elements.indexOf(series.cursor.current[IEnumerableAxis(series.angleAxis).categoryField]) == -1)
							elements[j++] = 
								series.cursor.current[IEnumerableAxis(series.angleAxis).categoryField];
						series.cursor.moveNext();
					}
					
					// set the elements propery of the CategoryAxis owned by the current series
					if (elements.length > 0)
						IEnumerableAxis(series.angleAxis).elements = elements;
	
				} else if (series.angleAxis is INumerableAxis)
				{
					INumerableAxis(series.angleAxis).max =
						series.maxAngleValue;
					INumerableAxis(series.angleAxis).min =
						series.minAngleValue;
				}
	
				elements = [];
				j = 0;
				series.cursor.seek(CursorBookmark.FIRST);
				
				if (series.radiusAxis is IEnumerableAxis)
				{
					while (!series.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (elements.indexOf(series.cursor.current[IEnumerableAxis(series.radiusAxis).categoryField]) == -1)
							elements[j++] = 
								series.cursor.current[IEnumerableAxis(series.radiusAxis).categoryField];
						series.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current series
					if (elements.length > 0)
						IEnumerableAxis(series.radiusAxis).elements = elements;
	
				} else if (series.radiusAxis is INumerableAxis)
				{
					INumerableAxis(series.radiusAxis).max =
						series.maxRadiusValue;
					INumerableAxis(series.radiusAxis).min =
						series.minRadiusValue;
				}
	
			}
		}

		/** @Private
		 * The creation of default axes can be overrided so that it's possible to 
		 * select a specific default setup.*/
		protected function createAngleAxis():void
		{
			angleAxis = new PercentAngleAxis();

			// and/or to be overridden
		}
		/** @Private */
		protected function createRadiusAxis():void
		{
			radiusAxis = new NumericAxis();

			// and/or to be overridden
		}

		private function removeAllElements():void
		{
			var i:int; 
			var child:*;
			
			for (i = 0; i<numChildren; i++)
			{
				child = getChildAt(0); 
				if (child is IAxisUI)
					IAxisUI(child).removeAllElements();
				if (child is DataItemLayout)
				{
					DataItemLayout(child).removeAllElements();
					DataItemLayout(child).geometryCollection.items = [];
					DataItemLayout(child).geometry = [];
				}

				removeChildAt(0);
			}
		}
	}
}