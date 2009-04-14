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
 
package org.un.cava.birdeye.qavis.charts.cartesianSeries
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.core.IToolTip;
	import mx.events.ToolTipEvent;
	
	import org.un.cava.birdeye.qavis.charts.BaseSeries;
	import org.un.cava.birdeye.qavis.charts.axis.BaseAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxisUI;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.CartesianChart;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisUI;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;
	import org.un.cava.birdeye.qavis.charts.interfaces.IEnumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;

	[Exclude(name="index", kind="property")]
	public class CartesianSeries extends BaseSeries implements ICartesianSeries
	{
		private var _chart:CartesianChart;
		public function set chart(val:CartesianChart):void
		{
			_chart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get chart():CartesianChart
		{
			return _chart;
		}

		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
	  		if (ICollectionView(_dataProvider).length > 0)
	  		{
		  		_cursor = ICollectionView(_dataProvider).createCursor();
		  		
		  		// we must invalidate also the chart properties and display list
		  		// to let the chart update with the series data provider change. in fact
		  		// the series dataprovider modifies the chart data and axes properties
		  		// therefore it modifies the chart properties and displaying
		  		chart.axesFeeded = false;
		  		chart.invalidateProperties();
		  		chart.invalidateDisplayList();

		  		invalidateSize();
		  		invalidateProperties();
				invalidateDisplayList();
	  		}
		}

		private var _xField:String;
		public function set xField(val:String):void
		{
			_xField= val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xField():String
		{
			return _xField;
		}
		
		private var _yField:String;
		public function set yField(val:String):void
		{
			_yField= val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yField():String
		{
			return _yField;
		}

		private var _zField:String;
		public function set zField(val:String):void
		{
			_zField= val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zField():String
		{
			return _zField;
		}

		private var _index:Number;
		public function set index(val:Number):void
		{
			_index = val;
		}

		public function get index():Number
		{
			return _index;
		}
		
		private var _xAxis:IAxisUI;
		public function set xAxis(val:IAxisUI):void
		{
			_xAxis = val;
			if (_xAxis.placement != BaseAxisUI.BOTTOM && _xAxis.placement != BaseAxisUI.TOP)
				_xAxis.placement = BaseAxisUI.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xAxis():IAxisUI
		{
			return _xAxis;
		}
		
		private var _yAxis:IAxisUI;
		public function set yAxis(val:IAxisUI):void
		{
			_yAxis = val;
			if (_yAxis.placement != BaseAxisUI.LEFT && _yAxis.placement != BaseAxisUI.RIGHT)
				_yAxis.placement = BaseAxisUI.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yAxis():IAxisUI
		{
			return _yAxis;
		}
		
		private var _zAxis:IAxisUI;
		public function set zAxis(val:IAxisUI):void
		{
			_zAxis = val;
			if (_zAxis.placement != BaseAxisUI.DIAGONAL)
				_zAxis.placement = BaseAxisUI.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zAxis():IAxisUI
		{
			return _zAxis;
		}
		
		protected var _maxYValue:Number = NaN;
		public function get maxYValue():Number
		{
			if (! (yAxis is CategoryAxisUI))
				calculateMaxY();
			return _maxYValue;
		}

		protected var _maxXValue:Number = NaN;
		public function get maxXValue():Number
		{
			if (! (xAxis is CategoryAxisUI))
				calculateMaxX();
			return _maxXValue;
		}

		private var _minYValue:Number = NaN;
		public function get minYValue():Number
		{
			if (! (yAxis is CategoryAxisUI))
				calculateMinY();
			return _minYValue;
		}

		private var _minXValue:Number = NaN;
		public function get minXValue():Number
		{
			if (! (xAxis is CategoryAxisUI))
				calculateMinX();
			return _minXValue;
		}

		protected var _maxZValue:Number = NaN;
		public function get maxZValue():Number
		{
			if (! (zAxis is CategoryAxisUI))
				calculateMaxZ();
			return _maxZValue;
		}

		private var _minZValue:Number = NaN;
		public function get minZValue():Number
		{
			if (! (zAxis is CategoryAxisUI))
				calculateMinZ();
			return _minZValue;
		}

		// UIComponent flow

		public function CartesianSeries():void
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// since we use Degrafa, the background is needed in the series
			// to allow events for tooltips all over the series.
			// tooltips are triggered by ttGG objects. 
			// if showdatatips is true all interactivity events are triggered and
			// managed through ttGG.
			
			// if showDataTips is false than it's still possible to manage 
			// interactivity events thourgh gg, but in this case we must 
			// remove the background to allow these interactivities, since gg is at the series
			// level and not the chart one. if we don't remove the background, gg
			// belonging to other series could be covered by the background and 
			// interactivity becomes impossible
			// therefore background is created only if showDataTips is true
			if (chart && chart.customTooltTipFunction!=null && chart.showDataTips && !tooltipCreationListening)
			{
				initCustomTip();
			}
		}
 
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (fill)
				fill.alpha = fillAlpha;

			removeAllElements();
			
			if (ggBackGround)
			{
				ggBackGround.target = this;
				rectBackGround.width = unscaledWidth;
				rectBackGround.height = unscaledHeight;
			}

 			if (isReadyForLayout())
 				drawSeries()
		}
		
		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}


		protected function drawSeries():void
		{
			// to be overridden by each series implementation
		}
		
		private function isReadyForLayout():Boolean
		{
			// verify than all series axes (or chart's if none owned by the series)
			// are ready. If they aren't the series can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;
			
			if (yAxis)
			{
				if (yAxis is INumerableAxis)
					axesCheck = !isNaN(_maxYValue) || !isNaN(_minYValue)
				else if (yAxis is IEnumerableAxis)
					axesCheck = Boolean(IEnumerableAxis(yAxis).elements);
			} else if (chart && chart.yAxis)
			{
				if (chart.yAxis is INumerableAxis)
					axesCheck = !isNaN(_maxYValue) || !isNaN(_minYValue)
				else if (chart.yAxis is IEnumerableAxis)
					axesCheck = Boolean(IEnumerableAxis(chart.yAxis).elements);
			} else
				axesCheck = false;

			if (xAxis)
			{
				if (xAxis is INumerableAxis)
					axesCheck = axesCheck && (!isNaN(_maxXValue) || !isNaN(_minXValue))
				else if (xAxis is IEnumerableAxis)
					axesCheck = axesCheck && IEnumerableAxis(xAxis).elements;
			} else if (chart && chart.xAxis)
			{
				if (chart.xAxis is INumerableAxis)
					axesCheck = axesCheck && (!isNaN(_maxXValue) || !isNaN(_minXValue))
				else if (chart.xAxis is IEnumerableAxis)
					axesCheck = axesCheck && IEnumerableAxis(chart.xAxis).elements;
			} else
				axesCheck = false;

			var colorsCheck:Boolean = 
				(fillColor || strokeColor);

			var globalCheck:Boolean = 
				   (!isNaN(_minXValue) || !isNaN(_minYValue))
				&& (!isNaN(_maxXValue) || !isNaN(_maxYValue))
				&& width>0 && height>0
				&& chart && xField && yField
				&& cursor;
			
			return globalCheck && axesCheck && colorsCheck;
		}

		protected function calculateMaxY():void
		{
			_maxYValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && yField)
			{
				if (isNaN(_maxYValue) || _maxYValue < _cursor.current[yField])
					_maxYValue = _cursor.current[yField];
				
				_cursor.moveNext();
			}
		}

		protected function calculateMaxZ():void
		{
			_maxZValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && zField)
			{
				if (isNaN(_maxZValue) || _maxZValue < _cursor.current[zField])
					_maxXValue = _cursor.current[zField];
				_cursor.moveNext();
			}
		}

		protected function calculateMaxX():void
		{
			_maxXValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && xField)
			{
				if (isNaN(_maxXValue) || _maxXValue < _cursor.current[xField])
					_maxXValue = _cursor.current[xField];
				_cursor.moveNext();
			}
		}

		private function calculateMinY():void
		{
			_minYValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && yField)
			{
				if (isNaN(_minYValue) || _minYValue > _cursor.current[yField])
					_minYValue = _cursor.current[yField];
				
				_cursor.moveNext();
			}
		}

		private function calculateMinZ():void
		{
			_minZValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && zField)
			{
				if (isNaN(_minZValue) || _minZValue > _cursor.current[zField])
					_minZValue = _cursor.current[zField];
				
				_cursor.moveNext();
			}
		}

		private function calculateMinX():void
		{
			_minXValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && xField)
			{
				if (isNaN(_minXValue) || _minXValue > _cursor.current[xField])
					_minXValue = _cursor.current[xField];
				
				_cursor.moveNext();
			}
		}
		
		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		override protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:DataItemLayout = DataItemLayout(e.target);

			if (chart.customTooltTipFunction != null)
			{
				myTT = chart.customTooltTipFunction(extGG);
	 			toolTip = myTT.text;
			} else {
				extGG.showToolTip();
			}

			var pos:Point = localToGlobal(new Point(extGG.posX, extGG.posY));
	
			if (yAxis)
			{
				yAxis.pointerY = extGG.posY;
				yAxis.pointer.visible = true;
			} else {
				chart.yAxis.pointerY = extGG.posY;
				chart.yAxis.pointer.visible = true;
			} 

			if (xAxis)
			{
				xAxis.pointerX = extGG.posX;
				xAxis.pointer.visible = true;
			} else {
				chart.xAxis.pointerX = extGG.posX;
				chart.xAxis.pointer.visible = true;
			} 

			if (zAxis)
			{
				zAxis.pointerY = extGG.posZ;
				zAxis.pointer.visible = true;
			} else if (chart.zAxis) {
				chart.zAxis.pointerY = extGG.posZ;
				chart.zAxis.pointer.visible = true;
			} 
		}

		/** @Private
		 * Sort the surface elements according their z position.*/ 
		protected function zSort():void
		{
			var sortLayers:Array = new Array();
			var nChildren:int = numChildren;
			for(var i:int = 0; i < nChildren; i++) 
			{
				var child:* = getChildAt(0); 
				var zPos:uint = DataItemLayout(child).posZ;
				sortLayers.push([zPos, child]);
				removeChildAt(0);
			}
			// sort them and add them back
			sortLayers.sortOn("0", Array.NUMERIC);
			for (i = 0; i < nChildren; i++) 
				addChild(sortLayers[i][1]);
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		override protected function handleRollOut(e:MouseEvent):void
		{ 
			var extGG:DataItemLayout = 	DataItemLayout(e.target);
			extGG.hideToolTip();
			myTT = null;
			toolTip = null;

			if (yAxis)
				yAxis.pointer.visible = false;
			else
				chart.yAxis.pointer.visible = false;

			if (xAxis)
				xAxis.pointer.visible = false;
			else
				chart.xAxis.pointer.visible = false;

			if (zAxis)
				zAxis.pointer.visible = false;
			else if (chart.zAxis)
				chart.zAxis.pointer.visible = false;
		}

		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		override protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new DataItemLayout();
			ttGG.target = this;
 			if (chart.showDataTips || chart.showAllDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				graphicsCollection.addItem(ttGG);
			}
			
			if (chart.showAllDataTips)
			{
				ttGG.showToolTip();
				ttGG.showToolTipGeometry();
			}
		}
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * series, thus improving performances.*/ 
		override protected function initGGToolTip():void
		{
			ttGG.target = chart.seriesContainer;
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (chart.dataTipFunction != null)
				ttGG.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = chart.dataTipPrefix;
 			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
			
			if (mouseClickFunction != null)
				ttGG.addEventListener(MouseEvent.CLICK, super.onMouseClick);

			if (mouseDoubleClickFunction != null)
				ttGG.addEventListener(MouseEvent.DOUBLE_CLICK, super.onMouseDoubleClick);
		}
	}
}