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
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxis;
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
		
		private var _xAxis:IAxisLayout;
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
		
		private var _yAxis:IAxisLayout;
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
		
		private var _zAxis:IAxisLayout;
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
		
		protected var _maxYValue:Number = NaN;
		public function get maxYValue():Number
		{
			if (! (yAxis is CategoryAxis))
				calculateMaxY();
			return _maxYValue;
		}

		protected var _maxXValue:Number = NaN;
		public function get maxXValue():Number
		{
			if (! (xAxis is CategoryAxis))
				calculateMaxX();
			return _maxXValue;
		}

		private var _minYValue:Number = NaN;
		public function get minYValue():Number
		{
			if (! (yAxis is CategoryAxis))
				calculateMinY();
			return _minYValue;
		}

		private var _minXValue:Number = NaN;
		public function get minXValue():Number
		{
			if (! (xAxis is CategoryAxis))
				calculateMinX();
			return _minXValue;
		}

		protected var _maxZValue:Number = NaN;
		public function get maxZValue():Number
		{
			if (! (zAxis is CategoryAxis))
				calculateMaxZ();
			return _maxZValue;
		}

		private var _minZValue:Number = NaN;
		public function get minZValue():Number
		{
			if (! (zAxis is CategoryAxis))
				calculateMinZ();
			return _minZValue;
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
			
			if (yAxis)
			{
				if (yAxis is NumericAxis)
					minMaxCheck = !isNaN(maxYValue) || !isNaN(minYValue)
			} else if (dataProvider && dataProvider.yAxis && dataProvider.yAxis is NumericAxis)
				minMaxCheck = !isNaN(maxYValue) || !isNaN(minYValue)
				
			if (xAxis)
			{
				if (xAxis is NumericAxis)
					minMaxCheck = minMaxCheck && (!isNaN(maxXValue) || !isNaN(minXValue))
			} else if (dataProvider && dataProvider.xAxis && dataProvider.xAxis is NumericAxis)
				minMaxCheck = minMaxCheck && (!isNaN(maxXValue) || !isNaN(minXValue))

			var yAxisCheck:Boolean = 
				(yAxis || (dataProvider && dataProvider.yAxis));
			
			var xAxisCheck:Boolean = 
				(xAxis || (dataProvider && dataProvider.xAxis));

			var colorsCheck:Boolean = 
				(fillColor || strokeColor);

			var globalCheck:Boolean = 
				   (!isNaN(minXValue) || !isNaN(minYValue))
				&& (!isNaN(maxXValue) || !isNaN(maxYValue))
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

		protected function calculateMaxY():void
		{
			_maxYValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && yField)
			{
				if (isNaN(_maxYValue) || _maxYValue < _dataProvider.cursor.current[yField])
					_maxYValue = _dataProvider.cursor.current[yField];
				
				_dataProvider.cursor.moveNext();
			}
		}

		protected function calculateMaxZ():void
		{
			_maxZValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && zField)
			{
				if (isNaN(_maxZValue) || _maxZValue < _dataProvider.cursor.current[zField])
					_maxXValue = _dataProvider.cursor.current[zField];
				_dataProvider.cursor.moveNext();
			}
		}

		protected function calculateMaxX():void
		{
			_maxXValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && xField)
			{
				if (isNaN(_maxXValue) || _maxXValue < _dataProvider.cursor.current[xField])
					_maxXValue = _dataProvider.cursor.current[xField];
				_dataProvider.cursor.moveNext();
			}
		}

		private function calculateMinY():void
		{
			_minYValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && yField)
			{
				if (isNaN(_minYValue) || _minYValue > _dataProvider.cursor.current[yField])
					_minYValue = _dataProvider.cursor.current[yField];
				
				_dataProvider.cursor.moveNext();
			}
		}

		private function calculateMinZ():void
		{
			_minZValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && zField)
			{
				if (isNaN(_minZValue) || _minZValue > _dataProvider.cursor.current[zField])
					_minZValue = _dataProvider.cursor.current[zField];
				
				_dataProvider.cursor.moveNext();
			}
		}

		private function calculateMinX():void
		{
			_minXValue = NaN;
			_dataProvider.cursor.seek(CursorBookmark.FIRST);
			while (!_dataProvider.cursor.afterLast && xField)
			{
				if (isNaN(_minXValue) || _minXValue > _dataProvider.cursor.current[xField])
					_minXValue = _dataProvider.cursor.current[xField];
				
				_dataProvider.cursor.moveNext();
			}
		}
		
 		protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, zPos:Number, radius:Number,
									shapes:Array = null /* of IGeometry */, ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			gg = new ExtendedGeometryGroup();
			gg.target = this;
 			if (dataProvider.showDataTips)
			{
				initGGToolTip();
				gg.createToolTip(dataProvider.cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
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

			tip.alpha = 0.8;
			dispatchEvent(new Event("showToolTip"));
			extGG.showToolTipGeometry();
			
			if (yAxis)
			{
				yAxis.pointerY = extGG.posY;
				yAxis.pointer.visible = true;
			} else {
				dataProvider.yAxis.pointerY = extGG.posY;
				dataProvider.yAxis.pointer.visible = true;
			} 

			if (xAxis)
			{
				xAxis.pointerX = extGG.posX;
				xAxis.pointer.visible = true;
			} else {
				dataProvider.xAxis.pointerX = extGG.posX;
				dataProvider.xAxis.pointer.visible = true;
			} 

			if (zAxis)
			{
				zAxis.pointerY = extGG.posZ;
				zAxis.pointer.visible = true;
			} else if (dataProvider.zAxis) {
				dataProvider.zAxis.pointerY = extGG.posZ;
				dataProvider.zAxis.pointer.visible = true;
			} 
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		protected function handleRollOut(e:MouseEvent):void
		{ 
			if (yAxis)
				yAxis.pointer.visible = false;
			else
				dataProvider.yAxis.pointer.visible = false;

			if (xAxis)
				xAxis.pointer.visible = false;
			else
				dataProvider.xAxis.pointer.visible = false;

			if (zAxis)
				zAxis.pointer.visible = false;
			else if (dataProvider.zAxis)
				dataProvider.zAxis.pointer.visible = false;

/* 			if (yAxis)
				yAxis.pointerY = height;
			else 
				dataProvider.yAxis.pointerY = height;

			if (xAxis)
				xAxis.pointerX = 0;
			else 
				dataProvider.xAxis.pointerX = 0; */

			ToolTipManager.destroyToolTip(tip);
			ExtendedGeometryGroup(e.target).hideToolTipGeometry();
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
				var zPos:uint = child.transform.getRelativeMatrix3D(root).position.z;
				sortLayers.push([zPos, child]);
				removeChildAt(0);
			}
			// sort them and add them back (in reverse order).
			sortLayers.sortOn("0", Array.NUMERIC | Array.DESCENDING);
			for (i = 0; i < nChildren; i++) {
				addChild(sortLayers[i][1]);
			}
		}
	}
}