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
	import mx.core.Application;
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
        [Inspectable(category="General", arrayType="org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries")]
        [ArrayElementType("org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries")]
		override public function set series(val:Array):void
		{
			_series = val;
			var stackableSeries:Array = [];
			for (var i:Number = 0, j:Number = 0, t:Number = 0; i<_series.length; i++)
			{
				if (! ICartesianSeries(_series[i]).horizontalAxis)
					needDefaultXAxis = true;

				if (! ICartesianSeries(_series[i]).verticalAxis)
					needDefaultYAxis = true;
					
				if (! ICartesianSeries(_series[i]).dataProvider)
					ICartesianSeries(_series[i]).dataProvider = this;
					
				if (_series[i] is IStack)
				{
					if (isNaN(stackableSeries[IStack(_series[i]).seriesType]) || stackableSeries[IStack(_series[i]).seriesType] == undefined) 
						stackableSeries[IStack(_series[i]).seriesType] = 1;
					else 
						stackableSeries[IStack(_series[i]).seriesType] += 1;
					
					IStack(_series[i]).stackPosition = stackableSeries[IStack(_series[i]).seriesType]; 
				} 
			}
			for (j = 0; j<_series.length; j++)
				if (_series[j] is IStack)
					IStack(_series[j]).total = stackableSeries[IStack(_series[j]).seriesType]; 
						
			invalidateProperties();
			invalidateDisplayList();
		}

		protected var needDefaultXAxis:Boolean;
		protected var needDefaultYAxis:Boolean;
		protected var _horizontalAxis:IAxisLayout;
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

/* 		protected var _zAxis:IAxisLayout;
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
 */

		// UIComponent flow

		public function CartesianChart() 
		{
			super();
		}
		
		private var leftContainer:Container, rightContainer:Container;
		private var topContainer:Container, bottomContainer:Container;
		private var seriesContainer:UIComponent;
		override protected function createChildren():void
		{
			super.createChildren();
			addChild(leftContainer = new HBox());
			addChild(rightContainer = new HBox());
			addChild(topContainer = new VBox());
			addChild(bottomContainer = new VBox());
			addChild(seriesContainer = new UIComponent());
			
			leftContainer.verticalScrollPolicy = "off";
			leftContainer.clipContent = false;
			leftContainer.horizontalScrollPolicy = "off";

			rightContainer.verticalScrollPolicy = "off";
			rightContainer.clipContent = false;
			rightContainer.horizontalScrollPolicy = "off";

			topContainer.verticalScrollPolicy = "off";
			topContainer.clipContent = false;
			topContainer.horizontalScrollPolicy = "off";

			bottomContainer.verticalScrollPolicy = "off";
			bottomContainer.clipContent = false;
			bottomContainer.horizontalScrollPolicy = "off";
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			needDefaultXAxis = needDefaultYAxis = false;
			
			leftContainer.removeAllChildren();
			rightContainer.removeAllChildren();
			topContainer.removeAllChildren();
			bottomContainer.removeAllChildren();
			for (var i:Number = seriesContainer.numChildren; i>0; i--)
				seriesContainer.removeChildAt(i-1);

			if (series)
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

			if (needDefaultYAxis)
			{
				if (!_verticalAxis)
				{
					verticalAxis = new LinearAxis();
					verticalAxis.placement = XYAxis.LEFT;
				}
				leftContainer.addChild(DisplayObject(_verticalAxis));
			}
			if (needDefaultXAxis)
			{
				if (!_horizontalAxis)
				{
					horizontalAxis = new LinearAxis();
					horizontalAxis.placement = XYAxis.BOTTOM;
				}
				bottomContainer.addChild(DisplayObject(_horizontalAxis));
			}
			feedAxes();
			validateBounds();
		}
		
		override protected function measure():void
		{
			super.measure();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);

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
			
			seriesContainer.x = chartBounds.x;
			seriesContainer.y = chartBounds.y;
			seriesContainer.width = chartBounds.width;
			seriesContainer.height = chartBounds.height;
		}
		
		// other methods
		
		private function validateBounds():void
		{
			var tmpSize:Number = 0;
			for (var i:Number = 0; i<leftContainer.numChildren; i++)
			{
				tmpSize += XYAxis(leftContainer.getChildAt(i)).width + 1;
				XYAxis(leftContainer.getChildAt(i)).height = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYAxis(rightContainer.getChildAt(i)).width + 5;
				XYAxis(rightContainer.getChildAt(i)).height = rightContainer.height;				
			}
				
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYAxis(bottomContainer.getChildAt(i)).height + 5;
				XYAxis(bottomContainer.getChildAt(i)).width = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYAxis(topContainer.getChildAt(i)).height + 3;
				XYAxis(topContainer.getChildAt(i)).width = topContainer.width;
			}
			
			topContainer.height = tmpSize;
		}
		
		private function feedAxes():void
		{
			if (cursor)
			{
				var elements:Array = [];
				var j:Number = 0;
				cursor.seek(CursorBookmark.FIRST);
				
				var maxMin:Array;
				
				if (verticalAxis)
				{
					if (verticalAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							elements[j++] = 
								cursor.current[CategoryAxis(verticalAxis).categoryField];
							cursor.moveNext();
						}
						if (elements.length > 0)
							CategoryAxis(verticalAxis).elements = elements;
					} else {
						maxMin = getMaxMinYValueFromSeriesWithoutVAxis();
						NumericAxis(verticalAxis).max = maxMin[0];
						NumericAxis(verticalAxis).min = maxMin[1];
					}
				} 
				
				elements = [];
				j = 0;
				cursor.seek(CursorBookmark.FIRST);

				if (horizontalAxis)
				{
					if (horizontalAxis is CategoryAxis)
					{
						while (!cursor.afterLast)
						{
							elements[j++] = 
								cursor.current[CategoryAxis(horizontalAxis).categoryField];
							cursor.moveNext();
						}
						if (elements.length > 0)
							CategoryAxis(horizontalAxis).elements = elements;
					} else {
						maxMin = getMaxMinXValueFromSeriesWithoutHAxis();
						NumericAxis(horizontalAxis).max = maxMin[0];
						NumericAxis(horizontalAxis).min = maxMin[1];
					}
				} 
				for (var i:Number = 0; i<series.length; i++)
					initSeriesAxes(series[i]);
			}
		}
		
		private function getMaxMinYValueFromSeriesWithoutVAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				if (!CartesianSeries(series[i]).verticalAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxVerticalValue))
					max = CartesianSeries(series[i]).maxVerticalValue;
				if (!CartesianSeries(series[i]).verticalAxis && (isNaN(min) || min > CartesianSeries(series[i]).minVerticalValue))
					min = CartesianSeries(series[i]).minVerticalValue;
			}
					
			return [max,min];
		}

		private function getMaxMinXValueFromSeriesWithoutHAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<series.length; i++)
			{
				if (!CartesianSeries(series[i]).horizontalAxis && (isNaN(max) || max < CartesianSeries(series[i]).maxHorizontalValue))
					max = CartesianSeries(series[i]).maxHorizontalValue;
				if (!CartesianSeries(series[i]).horizontalAxis && (isNaN(min) || min > CartesianSeries(series[i]).minHorizontalValue))
					min = CartesianSeries(series[i]).minHorizontalValue;
			}
					
			return [max,min];
		}
		
		private function initSeriesAxes(series:ICartesianSeries):void
		{
			var elements:Array = [];
			var j:Number = 0;
			cursor.seek(CursorBookmark.FIRST);
				
			if (ICartesianSeries(series).horizontalAxis is CategoryAxis)
			{
				while (!cursor.afterLast)
				{
					elements[j++] = 
						cursor.current[CategoryAxis(ICartesianSeries(series).horizontalAxis).categoryField];
					cursor.moveNext();
				}
						
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).horizontalAxis).elements = elements;

			} else if (ICartesianSeries(series).horizontalAxis is NumericAxis)
			{
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
					elements[j++] = 
						cursor.current[CategoryAxis(ICartesianSeries(series).verticalAxis).categoryField];
					cursor.moveNext();
				}
						
				if (elements.length > 0)
					CategoryAxis(ICartesianSeries(series).verticalAxis).elements = elements;

			} else if (ICartesianSeries(series).verticalAxis is NumericAxis)
			{
				NumericAxis(ICartesianSeries(series).verticalAxis).max =
					ICartesianSeries(series).maxVerticalValue;
				NumericAxis(ICartesianSeries(series).verticalAxis).min =
					ICartesianSeries(series).minVerticalValue;
			}
		}
	}
}