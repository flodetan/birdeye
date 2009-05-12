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
 
package birdeye.vis.elements.geometry
{
	import com.degrafa.geometry.Circle;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.scales.*;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.*;
	import birdeye.vis.coords.Polar;

	public class PolarElement extends BaseElement implements IPolarElement
	{
		private var _polarChart:Polar;
		public function set polarChart(val:Polar):void
		{
			_polarChart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get polarChart():Polar
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

		private var _radarAxis:MultiScale;
		public function set radarAxis(val:MultiScale):void
		{
			_radarAxis = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radarAxis():MultiScale
		{
			return _radarAxis;
		}

		// UIComponent flow
		
		public function PolarElement():void
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
			// interactivity events thourgh ttGG but it's not necessary to 
			// have a background for these other events

			if (polarChart && polarChart.customTooltTipFunction!=null && polarChart.showDataTips && !tooltipCreationListening)
			{
				initCustomTip();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			removeAllElements();
			
			if (ggBackGround)
			{
				ggBackGround.target = this;
				rectBackGround.width = unscaledWidth;
				rectBackGround.height = unscaledHeight;
			}

 			if (isReadyForLayout())
 				drawElement()
		}
		
		protected function drawElement():void
		{
			// to be overridden by each series implementation
		}
		
		private function isReadyForLayout():Boolean
		{
			// verify that all series axes (or chart's if none owned by the series)
			// are ready. If they aren't the series can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;

			if (scale1)
			{
				if (scale1 is INumerableScale)
					axesCheck = !isNaN(INumerableScale(scale1).min) || !isNaN(INumerableScale(scale1).max)
								|| !isNaN(INumerableScale(scale1).totalPositiveValue);
				else if (scale1 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(scale1).dataProvider);
			} else if (polarChart && polarChart.scale1)
			{
				if (polarChart.scale1 is INumerableScale)
					axesCheck = !isNaN(INumerableScale(polarChart.scale1).min) || !isNaN(INumerableScale(polarChart.scale1).max)
								|| !isNaN(INumerableScale(polarChart.scale1).totalPositiveValue);
				else if (polarChart.scale1 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(polarChart.scale1 ).dataProvider);
			} else
				axesCheck = false;

			if (scale2)
			{
				if (scale2 is INumerableScale)
					axesCheck = axesCheck && (!isNaN(INumerableScale(scale2).min) 
												|| !isNaN(INumerableScale(scale2).max)
												|| !isNaN(INumerableScale(scale2).totalPositiveValue));
				else if (scale2 is IEnumerableScale)
					axesCheck = axesCheck && IEnumerableScale(scale2).dataProvider;
			} else if (polarChart && polarChart.scale2)
			{
				if (polarChart.scale2 is INumerableScale)
					axesCheck = axesCheck && (!isNaN(INumerableScale(polarChart.scale2).min)
												|| !isNaN(INumerableScale(polarChart.scale2).max)
												|| !isNaN(INumerableScale(polarChart.scale2).totalPositiveValue))
				else if (polarChart.scale2 is IEnumerableScale)
					axesCheck = axesCheck && IEnumerableScale(polarChart.scale2).dataProvider;
			} else
				axesCheck = false;
				
			if ((radarAxis && radarAxis.radiusAxes) || (polarChart.multiScale && polarChart.multiScale.radiusAxes))
				axesCheck = true;

			var colorsCheck:Boolean = 
				(fill || stroke || isNaN(colorFill) || isNaN(colorStroke));

			var globalCheck:Boolean = 
/* 				   (!isNaN(_minDim1Value) || !isNaN(_minDim2Value))
				&& (!isNaN(_maxDim1Value) || !isNaN(_maxDim1Value)) */
				width>0 && height>0
				&& polarChart && (dim1 || dim1)
				&& (polarChart.origin)
				&& cursor;
			
			return globalCheck && axesCheck && colorsCheck;
		}

		override protected function handleRollOver(e:MouseEvent):void 
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

		override protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			// no need to create a ttGG for a polar chart unless interactivity
			// or tooltips are requested 
 			if (polarChart.showDataTips || polarChart.showAllDataTips 
 				|| mouseClickFunction!=null || mouseDoubleClickFunction!=null)
 			{
				ttGG = new DataItemLayout();
				ttGG.target = polarChart;
				graphicsCollection.addItem(ttGG);
	
				var hitMouseArea:Circle = new Circle(xPos, yPos, radius); 
				hitMouseArea.fill = new SolidFill(0x000000, 0);
				ttGG.geometryCollection.addItem(hitMouseArea);
	
	 			if (polarChart.showDataTips || polarChart.showAllDataTips)
				{
					initGGToolTip();
					ttGG.create(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
					ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
					ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
	 			} else if (mouseClickFunction!=null || mouseDoubleClickFunction!=null)
				{
					// if no tips but interactivity is required than add roll over events and pass
					// data and positioning information about the current data item 
					ttGG.create(cursor.current, dataFields, xPos, yPos, zPos, NaN, null, NaN, NaN, false);
				} 
				
				if (polarChart.showAllDataTips)
				{
					ttGG.showToolTip();
					ttGG.showToolTipGeometry();
				} else if (_showAllDataItems)
					ttGG.showToolTipGeometry()
	
				if (mouseClickFunction != null)
					ttGG.addEventListener(MouseEvent.CLICK, onMouseClick);
	
				if (mouseDoubleClickFunction != null)
					ttGG.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
 			}
		}
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaElement, thus improving performances.*/ 
		override protected function initGGToolTip():void
		{
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (polarChart.dataTipFunction != null)
				ttGG.dataTipFunction = polarChart.dataTipFunction;
			if (polarChart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = polarChart.dataTipPrefix;
		}
	}
}