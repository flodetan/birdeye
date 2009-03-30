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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.CursorBookmark;
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	
	import org.un.cava.birdeye.qavis.charts.BaseSeries;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxis;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;
	import org.un.cava.birdeye.qavis.charts.interfaces.IEnumerable;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerable;

	[Exclude(name="index", kind="property")]
	public class CartesianSeries extends BaseSeries implements ICartesianSeries
	{
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
			// verify than all series axes (or chart's if none owned by the series)
			// are ready. If they aren't the series can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;
			
			if (yAxis)
			{
				if (yAxis is INumerable)
					axesCheck = !isNaN(_maxYValue) || !isNaN(_minYValue)
				else if (yAxis is IEnumerable)
					axesCheck = Boolean(IEnumerable(yAxis).elements);
			} else if (chart && chart.yAxis)
			{
				if (chart.yAxis is INumerable)
					axesCheck = !isNaN(_maxYValue) || !isNaN(_minYValue)
				else if (chart.yAxis is IEnumerable)
					axesCheck = Boolean(IEnumerable(chart.yAxis).elements);
			} else
				axesCheck = false;

			if (xAxis)
			{
				if (xAxis is INumerable)
					axesCheck = axesCheck && (!isNaN(_maxXValue) || !isNaN(_minXValue))
				else if (xAxis is IEnumerable)
					axesCheck = axesCheck && IEnumerable(xAxis).elements;
			} else if (chart && chart.xAxis)
			{
				if (chart.xAxis is INumerable)
					axesCheck = axesCheck && (!isNaN(_maxXValue) || !isNaN(_minXValue))
				else if (chart.xAxis is IEnumerable)
					axesCheck = axesCheck && IEnumerable(chart.xAxis).elements;
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
		
 		protected function createGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, zPos:Number, radius:Number,
									shapes:Array = null /* of IGeometry */, ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			gg = new DataItemLayout();
			gg.target = this;
 			if (chart.showDataTips)
			{
				initGGToolTip();
				gg.createToolTip(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				addChild(gg);
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
 			if (chart.dataTipFunction != null)
				gg.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				gg.dataTipPrefix = chart.dataTipPrefix;
			addChild(gg);
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
			var extGG:DataItemLayout = DataItemLayout(e.target);
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
				chart.yAxis.pointer.visible = false;

			if (xAxis)
				xAxis.pointer.visible = false;
			else
				chart.xAxis.pointer.visible = false;

			if (zAxis)
				zAxis.pointer.visible = false;
			else if (chart.zAxis)
				chart.zAxis.pointer.visible = false;

/* 			if (yAxis)
				yAxis.pointerY = height;
			else 
				chart.yAxis.pointerY = height;

			if (xAxis)
				xAxis.pointerX = 0;
			else 
				chart.xAxis.pointerX = 0; */

			if (tip)
				ToolTipManager.destroyToolTip(tip);
			DataItemLayout(e.target).hideToolTipGeometry();
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
				var zPos:uint = DataItemLayout(child).posZ;//child.transform.getRelativeMatrix3D(root).position.z;
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