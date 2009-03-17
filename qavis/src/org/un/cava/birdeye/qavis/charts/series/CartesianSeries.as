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
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import mx.collections.CursorBookmark;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxis;
	import org.un.cava.birdeye.qavis.charts.axis.XYAxis;
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.CartesianChart;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;

	public class CartesianSeries extends UIComponent implements ICartesianSeries
	{
		protected var surf:Surface;
		protected var gg:GeometryGroup;
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
			fill = new SolidFill(_fillColor);
			invalidateDisplayList();
		}
		public function get fillColor():Number
		{
			return _fillColor;
		}

		private var _fillStroke:Number = NaN;
		public function set fillStroke(val:Number):void
		{
			_fillStroke = val;
			stroke = new SolidStroke(_fillStroke);
			invalidateDisplayList();
		}
		public function get fillStroke():Number
		{
			return _fillStroke;
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
			surf = new Surface();
			gg = new GeometryGroup();
			gg.target = surf;
			surf.graphicsCollection.addItem(gg);
			addChild(surf);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		// other methods
		
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
			_maxVerticalValue = _maxVerticalValue;
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
	}
}