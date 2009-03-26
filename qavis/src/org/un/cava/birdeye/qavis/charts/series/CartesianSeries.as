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
	import com.degrafa.Surface;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.CursorBookmark;
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.NumericAxis;
	import org.un.cava.birdeye.qavis.charts.axis.XYAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.CartesianChart;
	import org.un.cava.birdeye.qavis.charts.data.ExtendedGeometryGroup;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;

	public class CartesianSeries extends Surface implements ICartesianSeries
	{
		protected var gg:ExtendedGeometryGroup;
		protected var fill:SolidFill = new SolidFill(0x888888,0);
		protected var stroke:SolidStroke = new SolidStroke(0x888888,1,1);
		
		private var _dataProvider:CartesianChart;
		public function set dataProvider(val:CartesianChart):void
		{
			_dataProvider = val;
		}
		public function get dataProvider():CartesianChart
		{
			return _dataProvider;
		}
		
		private var _displayName:String;
		public function set displayName(val:String):void
		{
			_displayName= val;
		}
		public function get displayName():String
		{
			return _displayName;
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

		private var _index:Number;
		public function set index(val:Number):void
		{
			_index = val;
		}

		private var _fillColor:Number = NaN;
		public function set fillColor(val:Number):void
		{
			_fillColor = val;
			fill = new SolidFill(_fillColor, fillAlpha);
			invalidateDisplayList();
		}
		public function get fillColor():Number
		{
			return _fillColor;
		}

		private var _fillAlpha:Number = 1;
		public function set fillAlpha(val:Number):void
		{
			_fillAlpha = val;
			invalidateDisplayList();
		}
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}

		private var _strokeColor:Number = NaN;
		public function set strokeColor(val:Number):void
		{
			_strokeColor = val;
			stroke = new SolidStroke(_strokeColor);
			invalidateDisplayList();
		}
		public function get strokeColor():Number
		{
			return _strokeColor;
		}

		public function get index():Number
		{
			return _index;
		}
		
		private var _horizontalAxis:IAxisLayout;
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
		
		private var _verticalAxis:IAxisLayout;
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
		
		private var _itemRenderer:Class;
		public function set itemRenderer(val:Class):void
		{
			_itemRenderer = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		protected var _maxVerticalValue:Number = NaN;
		public function get maxVerticalValue():Number
		{
			if (! (verticalAxis is CategoryAxis))
				calculateMaxVertical();
			return _maxVerticalValue;
		}

		protected var _maxHorizontalValue:Number = NaN;
		public function get maxHorizontalValue():Number
		{
			if (! (horizontalAxis is CategoryAxis))
				calculateMaxHorizontal();
			return _maxHorizontalValue;
		}

		private var _minVerticalValue:Number = NaN;
		public function get minVerticalValue():Number
		{
			if (! (verticalAxis is CategoryAxis))
				calculateMinVertical();
			return _minVerticalValue;
		}

		private var _minHorizontalValue:Number = NaN;
		public function get minHorizontalValue():Number
		{
			if (! (horizontalAxis is CategoryAxis))
				calculateMinHorizontal();
			return _minHorizontalValue;
		}

		// UIComponent flow

		public function CartesianSeries():void
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			gg = new ExtendedGeometryGroup();
			gg.target = this;
			graphicsCollection.addItem(gg);
		}

		private var resizeListenerSet:Boolean = false;
		override protected function commitProperties():void
		{
			super.commitProperties();
			
/* 			if (parent && parent.parent is CartesianChart && !resizeListenerSet)
			{
				CartesianChart(parent.parent).addEventListener("ProviderReady",validateBounds);
				resizeListenerSet = true;
			}
 */				
		}
 
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (fill)
				fill.alpha = fillAlpha;

			removeAllElements();
			
			if (isReadyForLayout())
				drawSeries()
		}
		
		protected function drawSeries():void
		{
			// to be overridden by each series implementation
		}
		
		private function isReadyForLayout():Boolean
		{
			var minMaxCheck:Boolean = true;
			
			if (verticalAxis)
			{
				if (verticalAxis is NumericAxis)
					minMaxCheck = !isNaN(maxVerticalValue) || !isNaN(minVerticalValue)
			} else if (dataProvider && dataProvider.verticalAxis && dataProvider.verticalAxis is NumericAxis)
				minMaxCheck = !isNaN(maxVerticalValue) || !isNaN(minVerticalValue)
				
			if (horizontalAxis)
			{
				if (horizontalAxis is NumericAxis)
					minMaxCheck = minMaxCheck && (!isNaN(maxHorizontalValue) || !isNaN(minHorizontalValue))
			} else if (dataProvider && dataProvider.horizontalAxis && dataProvider.horizontalAxis is NumericAxis)
				minMaxCheck = minMaxCheck && (!isNaN(maxHorizontalValue) || !isNaN(minHorizontalValue))

			var yAxisCheck:Boolean = 
				(verticalAxis || (dataProvider && dataProvider.verticalAxis));
			
			var xAxisCheck:Boolean = 
				(horizontalAxis || (dataProvider && dataProvider.horizontalAxis));

			var colorsCheck:Boolean = 
				(fillColor || strokeColor);

			var globalCheck:Boolean = 
				   (!isNaN(minHorizontalValue) || !isNaN(minVerticalValue))
				&& (!isNaN(maxHorizontalValue) || !isNaN(maxVerticalValue))
				&& width>0 && height>0
				&& dataProvider && xField && yField;
			
			return globalCheck && yAxisCheck && xAxisCheck && colorsCheck && minMaxCheck;
		}

		public function removeAllElements():void
		{
			if (dataProvider.showDataTips) 
			{
				var nElements:int = graphicsCollection.items.length;
				if (nElements > 1)
				{
					for (var i:int = 0; i<nElements; i++)
					{
						if (getChildAt(0) is ExtendedGeometryGroup)
							ExtendedGeometryGroup(getChildAt(0)).removeAllElements();
					}
				} else if (gg) {
					gg.geometryCollection.items = [];
					gg.geometry = [];
				}
				for (i = numChildren - 1; i>=0; i--)
					removeChildAt(i);
				graphicsCollection.items = [];
			} else if (gg)
			{
				gg.geometryCollection.items = [];
				gg.geometry = [];
			}
		}

		protected function calculateMaxVertical():void
		{
			_maxVerticalValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && yField)
			{
				if (isNaN(_maxVerticalValue) || _maxVerticalValue < _dataProvider.cursor.current[yField])
					_maxVerticalValue = _dataProvider.cursor.current[yField];
				
				_dataProvider.cursor.moveNext();
			}
		}

		protected function calculateMaxHorizontal():void
		{
			_maxHorizontalValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && xField)
			{
				if (isNaN(_maxHorizontalValue) || _maxHorizontalValue < _dataProvider.cursor.current[xField])
					_maxHorizontalValue = _dataProvider.cursor.current[xField];
				_dataProvider.cursor.moveNext();
			}
		}

		private function calculateMinVertical():void
		{
			_minVerticalValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && yField)
			{
				if (isNaN(_minVerticalValue) || _minVerticalValue > _dataProvider.cursor.current[yField])
					_minVerticalValue = _dataProvider.cursor.current[yField];
				
				_dataProvider.cursor.moveNext();
			}
		}

		private function calculateMinHorizontal():void
		{
			_minHorizontalValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && xField)
			{
				if (isNaN(_minHorizontalValue) || _minHorizontalValue > _dataProvider.cursor.current[xField])
					_minHorizontalValue = _dataProvider.cursor.current[xField];
				
				_dataProvider.cursor.moveNext();
			}
		}
		
 		protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, radius:Number,
									shapes:Array = null /* of IGeometry */, ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			gg = new ExtendedGeometryGroup();
			gg.target = this;
 			if (dataProvider.showDataTips)
			{
				initGGToolTip();
				gg.createToolTip(dataProvider.cursor.current, dataFields, xPos, yPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				graphicsCollection.addItem(gg);
			}
		}
 
		private var tip:ToolTip; 
		/**
		* @private 
		 * Init the GeomGroupToolTip and its listeners
		 * 
		*/
 		protected function initGGToolTip():void
		{
			gg.target = this;
			gg.toolTipFill = fill;
			gg.toolTipStroke = stroke;
 			if (dataProvider.dataTipFunction != null)
				gg.dataTipFunction = dataProvider.dataTipFunction;
			if (dataProvider.dataTipPrefix!= null)
				gg.dataTipPrefix = dataProvider.dataTipPrefix;
 			graphicsCollection.addItem(gg);
			gg.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			gg.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}

		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:ExtendedGeometryGroup = ExtendedGeometryGroup(e.target);
			var pos:Point = localToGlobal(new Point(extGG.posX, extGG.posY));
			tip = ToolTipManager.createToolTip(extGG.toolTip, 
												pos.x + extGG.xTTOffset,	pos.y + extGG.yTTOffset)	as ToolTip;

			tip.alpha = 0.7;
			dispatchEvent(new Event("showToolTip"));
			extGG.showToolTipGeometry();
			
			if (verticalAxis)
			{
				verticalAxis.pointerY = extGG.posY;
				verticalAxis.pointer.visible = true;
			} else {
				dataProvider.verticalAxis.pointerY = extGG.posY;
				dataProvider.verticalAxis.pointer.visible = true;
			} 

			if (horizontalAxis)
			{
				horizontalAxis.pointerX = extGG.posX;
				horizontalAxis.pointer.visible = true;
			} else {
				dataProvider.horizontalAxis.pointerX = extGG.posX;
				dataProvider.horizontalAxis.pointer.visible = true;
			} 
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		protected function handleRollOut(e:MouseEvent):void
		{ 
			if (verticalAxis)
				verticalAxis.pointer.visible = false;
			else
				dataProvider.verticalAxis.pointer.visible = false;

			if (horizontalAxis)
				horizontalAxis.pointer.visible = false;
			else
				dataProvider.horizontalAxis.pointer.visible = false;

/* 			if (verticalAxis)
				verticalAxis.pointerY = height;
			else 
				dataProvider.verticalAxis.pointerY = height;

			if (horizontalAxis)
				horizontalAxis.pointerX = 0;
			else 
				dataProvider.horizontalAxis.pointerX = 0; */

			ToolTipManager.destroyToolTip(tip);
			ExtendedGeometryGroup(e.target).hideToolTipGeometry();
		}
	}
}