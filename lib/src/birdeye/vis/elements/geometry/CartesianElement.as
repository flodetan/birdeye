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

		private var _index:Number;
		public function set index(val:Number):void
		{
			_index = val;
		}

		public function get index():Number
		{
			return _index;
		}
		
		private var _scale1:IScaleUI;
		public function set scale1(val:IScaleUI):void
		{
			_scale1 = val;
			if (_scale1.placement != BaseScale.BOTTOM && _scale1.placement != BaseScale.TOP)
				_scale1.placement = BaseScale.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scale1():IScaleUI
		{
			return _scale1;
		}
		
		private var _scale2:IScaleUI;
		public function set scale2(val:IScaleUI):void
		{
			_scale2 = val;
			if (_scale2.placement != BaseScale.LEFT && _scale2.placement != BaseScale.RIGHT)
				_scale2.placement = BaseScale.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scale2():IScaleUI
		{
			return _scale2;
		}
		
		private var _scale3:IScaleUI;
		public function set scale3(val:IScaleUI):void
		{
			_scale3 = val;
			if (_scale3.placement != BaseScale.DIAGONAL)
				_scale3.placement = BaseScale.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scale3():IScaleUI
		{
			return _scale3;
		}
		
		protected var _maxDim1Value:Number = NaN;
		public function get maxDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale))
				_maxDim1Value = getMaxValue(dim1);
			return _maxDim1Value;
		}

		protected var _maxDim2Value:Number = NaN;
		public function get maxDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale))
				_maxDim2Value = getMaxValue(dim2);
			return _maxDim2Value;
		}

		private var _minDim1Value:Number = NaN;
		public function get minDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale))
				_minDim1Value = getMinValue(dim1);
			return _minDim1Value;
		}

		private var _minDim2Value:Number = NaN;
		public function get minDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale))
				_minDim2Value = getMinValue(dim2);
			return _minDim2Value;
		}

		protected var _maxDim3Value:Number = NaN;
		public function get maxDim3Value():Number
		{
			if (! (scale3 is IEnumerableScale))
				_maxDim3Value = getMaxValue(dim3);
			return _maxDim3Value;
		}

		private var _minDim3Value:Number = NaN;
		public function get minDim3Value():Number
		{
			if (! (scale3 is IEnumerableScale))
				_minDim3Value = getMinValue(dim3);
			return _minDim3Value;
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
			
			if (scale2)
			{
				if (scale2 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(scale2).dataProvider);
			} else if (chart && chart.scale2)
			{
				if (chart.scale2 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(chart.scale2).dataProvider);
			} else
				axesCheck = false;

			if (scale1)
			{
				if (scale1 is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(scale1).dataProvider);
			} else if (chart && chart.scale1)
			{
				if (chart.scale1 is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(chart.scale1).dataProvider);
			} else
				axesCheck = false;

			var colorsCheck:Boolean = 
				(fill || stroke);

			var globalCheck:Boolean = 
				   (!isNaN(_minDim1Value) || !isNaN(_minDim2Value))
				&& (!isNaN(_maxDim1Value) || !isNaN(_maxDim2Value))
				&& width>0 && height>0
				&& chart && (dim1 || dim2)
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
	
			if (scale2 && scale2.pointer)
			{
				scale2.pointerY = extGG.posY;
				scale2.pointer.visible = true;
			} else if (chart.scale2 && chart.scale2.pointer) {
				chart.scale2.pointerY = extGG.posY;
				chart.scale2.pointer.visible = true;
			} 

			if (scale1 && scale1.pointer)
			{
				scale1.pointerX = extGG.posX;
				scale1.pointer.visible = true;
			} else if (chart.scale1 && chart.scale1.pointer) {
				chart.scale1.pointerX = extGG.posX;
				chart.scale1.pointer.visible = true;
			} 

			if (scale3 && scale3.pointer)
			{
				scale3.pointerY = extGG.posZ;
				scale3.pointer.visible = true;
			} else if (chart.scale3 && chart.scale3.pointer) {
				chart.scale3.pointerY = extGG.posZ;
				chart.scale3.pointer.visible = true;
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

			if (scale1 && scale1.pointer)
				scale1.pointer.visible = false;
			else if (chart.scale1 && chart.scale1.pointer) 
				chart.scale1.pointer.visible = false;

			if (scale2 && scale2.pointer)
				scale2.pointer.visible = false;
			else if (chart.scale2 && chart.scale2.pointer) 
				chart.scale2.pointer.visible = false;

			if (scale3 && scale3.pointer)
				scale3.pointer.visible = false;
			else if (chart.scale3 && chart.scale3.pointer) 
				chart.scale3.pointer.visible = false;
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