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
 
package org.un.cava.birdeye.qavis.charts.polarSeries
{
	import adobe.utils.CustomActions;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.core.IToolTip;
	import mx.events.ToolTipEvent;
	
	import org.un.cava.birdeye.qavis.charts.BaseSeries;
	import org.un.cava.birdeye.qavis.charts.axis.BaseAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAngleAxis;
	import org.un.cava.birdeye.qavis.charts.axis.CategoryAxisUI;
	import org.un.cava.birdeye.qavis.charts.axis.RadarAxisUI;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisUI;
	import org.un.cava.birdeye.qavis.charts.interfaces.IEnumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.IPolarSeries;
	import org.un.cava.birdeye.qavis.charts.polarCharts.PolarChart;

	public class PolarSeries extends BaseSeries implements IPolarSeries
	{
		private var _polarChart:PolarChart;
		public function set polarChart(val:PolarChart):void
		{
			_polarChart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get polarChart():PolarChart
		{
			return _polarChart;
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
		  		polarChart.axesFeeded = false;
		  		polarChart.invalidateProperties();
		  		polarChart.invalidateDisplayList();

		  		invalidateSize();
		  		invalidateProperties();
				invalidateDisplayList();
	  		}
		}
		private var _angleField:String;
		public function set angleField(val:String):void
		{
			_angleField = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get angleField():String
		{
			return _angleField;
		}
		
		private var _radiusField:String;
		public function set radiusField(val:String):void
		{
			_radiusField= val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusField():String
		{
			return _radiusField;
		}

		private var _angleAxis:IAxis;
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
		
		private var _radiusAxis:IAxisUI;
		public function set radiusAxis(val:IAxisUI):void
		{
			_radiusAxis = val;
			if (_radiusAxis.placement != BaseAxisUI.HORIZONTAL_CENTER && _radiusAxis.placement != BaseAxisUI.VERTICAL_CENTER)
				_radiusAxis.placement = BaseAxisUI.HORIZONTAL_CENTER;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusAxis():IAxisUI
		{
			return _radiusAxis;
		}
		
		private var _radarAxis:RadarAxisUI;
		public function set radarAxis(val:RadarAxisUI):void
		{
			_radarAxis = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radarAxis():RadarAxisUI
		{
			return _radarAxis;
		}

		protected var _maxAngleValue:Number = 360;
		public function get maxAngleValue():Number
		{
			if (! (_angleAxis is CategoryAngleAxis))
				calculateMaxAngle();
			return _maxAngleValue;
		}

		protected var _maxRadiusValue:Number = NaN;
		public function get maxRadiusValue():Number
		{
			if (! (_radiusAxis is CategoryAxisUI))
				calculateMaxRadius();
			return _maxRadiusValue;
		}

		private var _minAngleValue:Number = 0;
		public function get minAngleValue():Number
		{
			if (! (_angleAxis is CategoryAngleAxis))
				calculateMinAngle();
			return _minAngleValue;
		}

		private var _minRadiusValue:Number = NaN;
		public function get minRadiusValue():Number
		{
			if (! (_radiusAxis is CategoryAngleAxis))
				calculateMinRadius();
			return _minRadiusValue;
		}

		// UIComponent flow
		
		public function PolarSeries():void
		{
			super();
			
		}
		
		private var rectBackGround:RegularRectangle;
		private var ggBackGround:GeometryGroup;
		private var tooltipCreationListening:Boolean = false;
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (polarChart && polarChart.customTooltTipFunction!=null && !tooltipCreationListening)
			{
				addEventListener(ToolTipEvent.TOOL_TIP_CREATE, onTTCreate);
				toolTip = "";
	
				// background is needed on each series to allow mouse events
				// all over the series space, mostly on those elements 
				// that are located at the border of the series
				ggBackGround = new GeometryGroup();
				graphicsCollection.addItemAt(ggBackGround,0);
				rectBackGround = new RegularRectangle(0,0,0, 0);
				rectBackGround.fill = new SolidFill(0x000000,0);
				ggBackGround.geometryCollection.addItem(rectBackGround);
				tooltipCreationListening = true;
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

			if (angleAxis)
			{
				if (angleAxis is INumerableAxis)
					axesCheck = !isNaN(_maxAngleValue) || !isNaN(_minAngleValue)
				else if (angleAxis is IEnumerableAxis)
					axesCheck = Boolean(IEnumerableAxis(angleAxis).elements);
			} else if (polarChart && polarChart.angleAxis)
			{
				if (polarChart.angleAxis is INumerableAxis)
					axesCheck = !isNaN(_maxAngleValue) || !isNaN(_minAngleValue)
				else if (polarChart.angleAxis is IEnumerableAxis)
					axesCheck = Boolean(IEnumerableAxis(polarChart.angleAxis ).elements);
			} else
				axesCheck = false;

			if (radiusAxis)
			{
				if (radiusAxis is INumerableAxis)
					axesCheck = axesCheck && (!isNaN(_maxRadiusValue) || !isNaN(_minRadiusValue))
				else if (radiusAxis is IEnumerableAxis)
					axesCheck = axesCheck && IEnumerableAxis(radiusAxis).elements;
			} else if (polarChart && polarChart.radiusAxis)
			{
				if (polarChart.radiusAxis is INumerableAxis)
					axesCheck = axesCheck && (!isNaN(_maxRadiusValue) || !isNaN(_minRadiusValue))
				else if (polarChart.radiusAxis is IEnumerableAxis)
					axesCheck = axesCheck && IEnumerableAxis(polarChart.radiusAxis).elements;
			} else
				axesCheck = false;
				
			if (radarAxis || polarChart.radarAxis)
				axesCheck = true;

			var colorsCheck:Boolean = 
				(fill || stroke || isNaN(fillColor) || isNaN(strokeColor));

			var globalCheck:Boolean = 
				   (!isNaN(_minAngleValue) || !isNaN(_minRadiusValue))
				&& (!isNaN(_maxAngleValue) || !isNaN(_maxRadiusValue))
				&& width>0 && height>0
				&& polarChart && angleField && radiusField
				&& (polarChart.origin)
				&& cursor;
			
			return globalCheck && axesCheck && colorsCheck;
		}

		protected function calculateMaxRadius():void
		{
			_maxRadiusValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && radiusField)
			{
				if (isNaN(_maxRadiusValue) || _maxRadiusValue < _cursor.current[radiusField])
					_maxRadiusValue = _cursor.current[radiusField];
				
				_cursor.moveNext();
			}
		}

		protected function calculateMaxAngle():void
		{
			_maxAngleValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && angleField)
			{
				if (isNaN(_maxAngleValue) || _maxAngleValue < _cursor.current[angleField])
					_maxAngleValue = _cursor.current[angleField];
				_cursor.moveNext();
			}
		}

		private function calculateMinRadius():void
		{
			_minRadiusValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && radiusField)
			{
				if (isNaN(_minRadiusValue) || _minRadiusValue > _cursor.current[radiusField])
					_minRadiusValue = _cursor.current[radiusField];
				
				_cursor.moveNext();
			}
		}

		private function calculateMinAngle():void
		{
			_minAngleValue = NaN;
			_cursor.seek(CursorBookmark.FIRST);
			while (!_cursor.afterLast && angleField)
			{
				if (isNaN(_minAngleValue) || _minAngleValue > _cursor.current[angleField])
					_minAngleValue = _cursor.current[angleField];
				
				_cursor.moveNext();
			}
		}
		
		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}

		private var myTT:IToolTip;
		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:DataItemLayout = DataItemLayout(e.target);

			if (polarChart.customTooltTipFunction != null)
			{
				myTT = polarChart.customTooltTipFunction(extGG);
	 			toolTip = myTT.text;
			} else {
				extGG.showToolTip();
			}
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		protected function handleRollOut(e:MouseEvent):void
		{ 
			var extGG:DataItemLayout = 	DataItemLayout(e.target);
			extGG.hideToolTip();
			myTT = null;
			toolTip = null;
/* 			if (ToolTipManager.currentToolTip)
				ToolTipManager.currentToolTip = null;
 */		}

		override public function removeAllElements():void
		{
			if (gg) 
				gg.removeAllElements();
			
			var nElements:int = graphicsCollection.items.length;
			if (nElements > 1)
			{
				for (var i:int = 0; i<nElements; i++)
				{
					if (graphicsCollection.items[i] is DataItemLayout)
						DataItemLayout(graphicsCollection.items[i]).removeAllElements();
				}
			} 

			for (i = numChildren - 1; i>=0; i--)
			{
				if (getChildAt(i) is DataItemLayout)
					DataItemLayout(getChildAt(i)).removeAllElements();
				removeChildAt(i);
			}
			graphicsCollection.items = [];
		}

		protected var ttGG:DataItemLayout;
		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new DataItemLayout();
			ttGG.target = this;
 			if (polarChart.showDataTips || polarChart.showAllDataTips)
			{
				initGGToolTip();
				ttGG.createToolTip(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
 			} else {
				graphicsCollection.addItem(ttGG);
			}
			
			if (polarChart.showAllDataTips)
			{
				ttGG.showToolTip();
				ttGG.showToolTipGeometry();
			}
		}
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaSeries, thus improving performances.*/ 
		protected function initGGToolTip():void
		{
			ttGG.target = polarChart;
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (polarChart.dataTipFunction != null)
				ttGG.dataTipFunction = polarChart.dataTipFunction;
			if (polarChart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = polarChart.dataTipPrefix;
 			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}
		
		protected function createInteractiveGG(item:Object, dataFields:Array, 
								xPos:Number, yPos:Number,	zPos:Number):void
		{
			gg = new DataItemLayout();
			gg.target = this;
			gg.createInteractiveGG(item,dataFields,xPos,yPos,zPos);
		}

		protected function addInteractive(items:Object, dataFields:Array):void
		{
			gg.addInteractive(items,dataFields);
		}
	}
}