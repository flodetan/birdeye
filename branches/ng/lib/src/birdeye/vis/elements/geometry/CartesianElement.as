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
	import flash.geom.Point;
	
	import mx.collections.ICollectionView;
	import mx.events.ToolTipEvent;
	
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.scales.BaseScale;
	import birdeye.vis.coords.Cartesian;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.IScaleUI;
	import birdeye.vis.interfaces.ICartesianElement;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.ISizableItem;

	[Exclude(name="index", kind="property")]
	public class CartesianElement extends BaseElement implements ICartesianElement
	{
		private var _chart:Cartesian;
		public function set chart(val:Cartesian):void
		{
			_chart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get chart():Cartesian
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
		  		// to let the chart update with the element data provider change. in fact
		  		// the element dataprovider modifies the chart data and axes properties
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
		
		private var _xAxis:IScaleUI;
		public function set xScale(val:IScaleUI):void
		{
			_xAxis = val;
			if (_xAxis.placement != BaseScale.BOTTOM && _xAxis.placement != BaseScale.TOP)
				_xAxis.placement = BaseScale.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xScale():IScaleUI
		{
			return _xAxis;
		}
		
		private var _yAxis:IScaleUI;
		public function set yScale(val:IScaleUI):void
		{
			_yAxis = val;
			if (_yAxis.placement != BaseScale.LEFT && _yAxis.placement != BaseScale.RIGHT)
				_yAxis.placement = BaseScale.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yScale():IScaleUI
		{
			return _yAxis;
		}
		
		private var _zAxis:IScaleUI;
		public function set zScale(val:IScaleUI):void
		{
			_zAxis = val;
			if (_zAxis.placement != BaseScale.DIAGONAL)
				_zAxis.placement = BaseScale.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zScale():IScaleUI
		{
			return _zAxis;
		}
		
		protected var _maxYValue:Number = NaN;
		public function get maxYValue():Number
		{
			if (! (yScale is IEnumerableScale))
				_maxYValue = getMaxValue(yField);
			return _maxYValue;
		}

		protected var _maxXValue:Number = NaN;
		public function get maxXValue():Number
		{
			if (! (xScale is IEnumerableScale))
				_maxXValue = getMaxValue(xField);
			return _maxXValue;
		}

		private var _minYValue:Number = NaN;
		public function get minYValue():Number
		{
			if (! (yScale is IEnumerableScale))
				_minYValue = getMinValue(yField);
			return _minYValue;
		}

		private var _minXValue:Number = NaN;
		public function get minXValue():Number
		{
			if (! (xScale is IEnumerableScale))
				_minXValue = getMinValue(xField);
			return _minXValue;
		}

		protected var _maxZValue:Number = NaN;
		public function get maxZValue():Number
		{
			if (! (zScale is IEnumerableScale))
				_maxZValue = getMaxValue(zField);
			return _maxZValue;
		}

		private var _minZValue:Number = NaN;
		public function get minZValue():Number
		{
			if (! (zScale is IEnumerableScale))
				_minZValue = getMinValue(zField);
			return _minZValue;
		}

		// UIComponent flow

		public function CartesianElement():void
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// since we use Degrafa, the background is needed in the element
			// to allow events for tooltips all over the element.
			// tooltips are triggered by ttGG objects. 
			// if showdatatips is true all interactivity events are triggered and
			// managed through ttGG.
			
			// if showDataTips is false than it's still possible to manage 
			// interactivity events thourgh gg, but in this case we must 
			// remove the background to allow these interactivities, since gg is at the element
			// level and not the chart one. if we don't remove the background, gg
			// belonging to other element could be covered by the background and 
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
		
		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}


		protected function drawElement():void
		{
			// to be overridden by each element implementation
		}
		
		private function isReadyForLayout():Boolean
		{
			// verify than all element axes (or chart's if none owned by the element)
			// are ready. If they aren't the element can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;
			
			if (yScale)
			{
				if (yScale is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(yScale).dataProvider);
			} else if (chart && chart.yScale)
			{
				if (chart.yScale is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(chart.yScale).dataProvider);
			} else
				axesCheck = false;

			if (xScale)
			{
				if (xScale is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(xScale).dataProvider);
			} else if (chart && chart.xScale)
			{
				if (chart.xScale is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(chart.xScale).dataProvider);
			} else
				axesCheck = false;

			var colorsCheck:Boolean = 
				(fill || stroke);

			var globalCheck:Boolean = 
				   (!isNaN(_minXValue) || !isNaN(_minYValue))
				&& (!isNaN(_maxXValue) || !isNaN(_maxYValue))
				&& width>0 && height>0
				&& chart && (xField || yField)
				&& cursor;
			
			return globalCheck && axesCheck && colorsCheck;
		}

		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		override protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:DataItemLayout = DataItemLayout(e.target);

			if (chart.showDataTips) {
				if (chart.customTooltTipFunction != null)
				{
					myTT = chart.customTooltTipFunction(extGG);
		 			toolTip = myTT.text;
				} else 
					extGG.showToolTip();
			}

			var pos:Point = localToGlobal(new Point(extGG.posX, extGG.posY));
	
			if (yScale && yScale.pointer)
			{
				yScale.pointerY = extGG.posY;
				yScale.pointer.visible = true;
			} else if (chart.yScale && chart.yScale.pointer) {
				chart.yScale.pointerY = extGG.posY;
				chart.yScale.pointer.visible = true;
			} 

			if (xScale && xScale.pointer)
			{
				xScale.pointerX = extGG.posX;
				xScale.pointer.visible = true;
			} else if (chart.xScale && chart.xScale.pointer) {
				chart.xScale.pointerX = extGG.posX;
				chart.xScale.pointer.visible = true;
			} 

			if (zScale && zScale.pointer)
			{
				zScale.pointerY = extGG.posZ;
				zScale.pointer.visible = true;
			} else if (chart.zAxis && chart.zAxis.pointer) {
				chart.zAxis.pointerY = extGG.posZ;
				chart.zAxis.pointer.visible = true;
			} 
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		override protected function handleRollOut(e:MouseEvent):void
		{ 
			var extGG:DataItemLayout = 	DataItemLayout(e.target);
			if (chart.showDataTips)
			{
				extGG.hideToolTip();
				if (!_showAllDataItems)
					extGG.hideToolTipGeometry();
				myTT = null;
				toolTip = null;
			}

			if (xScale && xScale.pointer)
				xScale.pointer.visible = false;
			else if (chart.xScale && chart.xScale.pointer) 
				chart.xScale.pointer.visible = false;

			if (yScale && yScale.pointer)
				yScale.pointer.visible = false;
			else if (chart.yScale && chart.yScale.pointer) 
				chart.yScale.pointer.visible = false;

			if (zScale && zScale.pointer)
				zScale.pointer.visible = false;
			else if (chart.zAxis && chart.zAxis.pointer) 
				chart.zAxis.pointer.visible = false;
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
				var zPos:uint = DataItemLayout(child).z;
				sortLayers.push([zPos, child]);
				removeChildAt(0);
			}
			// sort them and add them back
			sortLayers.sortOn("0", Array.NUMERIC);
			for (i = 0; i < nChildren; i++) 
				addChild(sortLayers[i][1]);
		}

		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaElement, thus improving performances.*/ 
		override protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			ttGG = new DataItemLayout();
			ttGG.target = chart.elementsContainer;
			graphicsCollection.addItem(ttGG);
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);

			var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
			hitMouseArea.fill = new SolidFill(0x000000, 0);
			ttGG.geometryCollection.addItem(hitMouseArea);

 			if (chart.showDataTips || chart.showAllDataTips)
			{ 
				initGGToolTip();
				ttGG.create(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset);
			} else if (mouseClickFunction!=null || mouseDoubleClickFunction!=null)
			{
				// if no tips but interactivity is required than add roll over events and pass
				// data and positioning information about the current data item 
				ttGG.create(cursor.current, dataFields, xPos, yPos, zPos, NaN, null, NaN, NaN, false);
			} else {
				// if no tips and no interactivity than just add location info needed for pointers
				ttGG.create(null, null, xPos, yPos, zPos, NaN, null, NaN, NaN, false);
			}

			if (chart.showAllDataTips)
			{
				ttGG.showToolTip();
				ttGG.showToolTipGeometry();
			} else if (_showAllDataItems)
				ttGG.showToolTipGeometry();

			if (mouseClickFunction != null)
				ttGG.addEventListener(MouseEvent.CLICK, onMouseClick);

			if (mouseDoubleClickFunction != null)
				ttGG.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
		}
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * element, thus improving performances.*/ 
		override protected function initGGToolTip():void
		{
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (chart.dataTipFunction != null)
				ttGG.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = chart.dataTipPrefix;
		}
	}
}