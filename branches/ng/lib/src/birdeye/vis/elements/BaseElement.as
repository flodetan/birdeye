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
 
package birdeye.vis.elements
{
	import birdeye.vis.VisScene;
	import birdeye.vis.coords.Cartesian;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.interfaces.IScale;
	import birdeye.vis.interfaces.IScaleUI;
	import birdeye.vis.scales.BaseScale;
	import birdeye.vis.scales.MultiScale;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.MouseEvent;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.IToolTip;
	import mx.events.ToolTipEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	[Style(name="rendererSize",type="Number",inherit="no")]

	[Style(name="colors",type="Array",inherit="no")]

	[Style(name="gradientColors",type="Array",inherit="no")]
	[Style(name="gradientAlphas",type="Array",inherit="no")]

	[Style(name="fillColor",type="uint",inherit="no")]
	[Style(name="fillAlpha",type="Number",inherit="no")]

	[Style(name="strokeColor",type="uint",inherit="yes")]
	[Style(name="strokeAlpha",type="Number",inherit="no")]
	[Style(name="strokeWeight",type="uint",inherit="no")]
	
	[Style(name="labelFont",type="String",inherit="no")]
	[Style(name="labelSize",type="uint",inherit="no")]
	[Style(name="labelColor",type="uint",inherit="no")]

	[Exclude(name="chart", kind="property")]
	[Exclude(name="cursor", kind="property")]
	
	public class BaseElement extends Surface implements IElement
	{
		protected var _invalidatedDisplay:Boolean = false;
		
		private var _chart:ICoordinates;
		public function set chart(val:ICoordinates):void
		{
			_chart = val;
			invalidateProperties();
		}
		public function get chart():ICoordinates
		{
			return _chart;
		}
		
		private var _filter1:*;
		/** Implement filtering for data values on dim1. The filter can be a String an Array or a 
		 * function.*/
		public function set filter1(val:Array):void
		{
			_filter1 = val;
			invalidateDisplayList();
		}

		private var _filter2:*;
		/** Implement filtering for data values on dim2. The filter can be a String an Array or a 
		 * function.*/
		public function set filter2(val:Array):void
		{
			_filter2 = val;
			invalidateDisplayList();
		}

		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		private var _collisionScale:String;
		/** Set the scale that defines the 'direction' of the stack. For ex. BarElements are stacked horizontally with 
		 * stack100 and vertically with normal stack. Columns (for both polar and cartesians)
		 * are stacked vertically with stack100, and horizontally for normal stack.*/
		public function set collisionScale(val:String):void
		{
			_collisionScale = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get collisionScale():String
		{
			return _collisionScale;
		}
		
		protected var _showFieldName:Boolean = false;
		public function set showFieldName(val:Boolean):void
		{
			_showFieldName = val;
			invalidateDisplayList();
		}
		public function get showFieldName():Boolean
		{
			return _showFieldName;
		}

		protected var _showItemRenderer:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set showItemRenderer(val:Boolean):void
		{
			_showItemRenderer = val;
			invalidatingDisplay();
		}

		protected var _rendererSize:Number = 10;
		public function set rendererSize(val:Number):void
		{
			_rendererSize = val;
			invalidatingDisplay();
		}

		protected var _extendMouseEvents:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set extendMouseEvents(val:Boolean):void
		{
			_extendMouseEvents = val;
			invalidatingDisplay();
		}
		
		protected var _showAllDataItems:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set showAllDataItems(val:Boolean):void
		{
			_showAllDataItems = val;
			invalidatingDisplay();
		}

		private var _colorScale:INumerableScale;
		/** Define an axis to set the colorField for data items.*/
		public function set colorScale(val:INumerableScale):void
		{
			_colorScale = val;
			_colorScale.format = false;

			invalidatingDisplay();
		}
		public function get colorScale():INumerableScale
		{
			return _colorScale;
		}

		private var _sizeScale:INumerableScale;
		/** Define a scale to set the sizeField for data items.*/
		public function set sizeScale(val:INumerableScale):void
		{
			_sizeScale = val;
			_sizeScale.format = false;

			invalidatingDisplay();
		}
		public function get sizeScale():INumerableScale
		{
			return _sizeScale;
		}


		private var _dim1:Object;
		public function set dim1(val:Object):void
		{
			_dim1= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim1():Object
		{
			return _dim1;
		}
		
		private var _dim2:Object;
		public function set dim2(val:Object):void
		{
			_dim2= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim2():Object
		{
			return _dim2;
		}

		private var _dim3:String;
		public function set dim3(val:String):void
		{
			_dim3= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim3():String
		{
			return _dim3;
		}

		private var _scale1:IScale;
		public function set scale1(val:IScale):void
		{
			_scale1 = val;
			if (_scale1.placement != BaseScale.BOTTOM && _scale1.placement != BaseScale.TOP)
				_scale1.placement = BaseScale.BOTTOM;

			invalidateProperties();
			invalidatingDisplay();
		}
		public function get scale1():IScale
		{
			return _scale1;
		}
		
		private var _scale2:IScale;
		public function set scale2(val:IScale):void
		{
			_scale2 = val;
			
/* 			if POLAR
			if (val is IScaleUI && IScaleUI(_scale2).placement != BaseScale.HORIZONTAL_CENTER 
								&& IScaleUI(_scale2).placement != BaseScale.VERTICAL_CENTER)
				IScaleUI(_scale2).placement = BaseScale.HORIZONTAL_CENTER;
 			if CARTESIAN
 			if (_scale2.placement != BaseScale.LEFT && _scale2.placement != BaseScale.RIGHT)
				_scale2.placement = BaseScale.LEFT;
 */			

			invalidateProperties();
			invalidatingDisplay();
		}
		public function get scale2():IScale
		{
			return _scale2;
		}
		
		private var _scale3:IScale;
		public function set scale3(val:IScale):void
		{
			_scale3 = val;
			if (_scale3.placement != BaseScale.DIAGONAL)
				_scale3.placement = BaseScale.DIAGONAL;

			invalidateProperties();
			invalidatingDisplay();
		}
		public function get scale3():IScale
		{
			return _scale3;
		}
		
		protected var _maxDim1Value:Number = NaN;
		public function get maxDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_maxDim1Value))
				_maxDim1Value = getMaxValue(dim1);
			return _maxDim1Value;
		}

		protected var _maxDim2Value:Number = NaN;
		public function get maxDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale) && isNaN(_maxDim2Value))
				_maxDim2Value = getMaxValue(dim2);
			return _maxDim2Value;
		}

		protected var _minDim1Value:Number = NaN;
		public function get minDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_minDim1Value))
				_minDim1Value = getMinValue(dim1);
			return _minDim1Value;
		}

		protected var _minDim2Value:Number = NaN;
		public function get minDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale) && isNaN(_minDim2Value))
				_minDim2Value = getMinValue(dim2);
			return _minDim2Value;
		}

		protected var _maxDim3Value:Number = NaN;
		public function get maxDim3Value():Number
		{
			if (! (scale3 is IEnumerableScale) && isNaN(_maxDim3Value))
				_maxDim3Value = getMaxValue(dim3);
			return _maxDim3Value;
		}

		private var _minDim3Value:Number = NaN;
		public function get minDim3Value():Number
		{
			if (! (scale3 is IEnumerableScale) && isNaN(_minDim3Value))
				_minDim3Value = getMinValue(dim3);
			return _minDim3Value;
		}

		private var _totalDim1PositiveValue:Number = NaN;
		public function get totalDim1PositiveValue():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_totalDim1PositiveValue))
				_totalDim1PositiveValue = getTotalPositiveValue(dim1);
			return _totalDim1PositiveValue;
		}
		
		protected var _maxColorValue:Number = NaN;
		public function get maxColorValue():Number
		{
			_maxColorValue = getMaxValue(colorField);
			return _maxColorValue;
		}

		private var _minColorValue:Number = NaN;
		public function get minColorValue():Number
		{
			_minColorValue = getMinValue(colorField);
			return _minColorValue;
		}

		private var _colorField:String;
		public function set colorField(val:String):void
		{
			_colorField = val;
			invalidatingDisplay();
		}
		public function get colorField():String
		{
			return _colorField;
		}

		protected var _maxSizeValue:Number = NaN;
		public function get maxSizeValue():Number
		{
			_maxSizeValue = getMaxValue(_sizeField);
			return _maxSizeValue;
		}

		private var _minSizeValue:Number = NaN;
		public function get minSizeValue():Number
		{
			_minSizeValue = getMinValue(_sizeField);
			return _minSizeValue;
		}

		private var _sizeField:String;
		public function set sizeField(val:String):void
		{
			_sizeField = val;
			invalidatingDisplay();
		}
		public function get sizeField():String
		{
			return _sizeField;
		}

		private var _labelField:String;
		public function set labelField(val:String):void
		{
			_labelField = val;
			invalidatingDisplay();
		}
		public function get labelField():String
		{
			return _labelField;
		}

		private var _multiScale:MultiScale;
		public function set multiScale(val:MultiScale):void
		{
			_multiScale = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get multiScale():MultiScale
		{
			return _multiScale;
		}

		protected var gg:DataItemLayout;
		protected var dataItems:Array = [];
		protected var fill:IGraphicsFill;
		protected var stroke:IGraphicsStroke = new SolidStroke(0x888888,1,1);
		
		protected var _dataProvider:Object=null;
		/** Set the data provider for the series, if the series doesn't have its own dataProvider
		 * than it will automatically take the chart data provider. It's not necessary
		 * to specify the chart data provider, and it's recommended not to do it. */
		public function set dataProvider(value:Object):void
		{
			//_dataProvider = value;
			if(typeof(value) == "string")
	    	{
	    		//string becomes XML
	        	value = new XML(value);
	     	}
	        else if(value is XMLNode)
	        {
	        	//AS2-style XMLNodes become AS3 XML
				value = new XML(XMLNode(value).toString());
	        }
			else if(value is XMLList)
			{
				if(XMLList(value).children().length()>0){
					value = new XMLListCollection(value.children() as XMLList);
				}else{
					value = new XMLListCollection(value as XMLList);
				}
			}
			else if(value is Array)
			{
				value = new ArrayCollection(value as Array);
			}
			
			if(value is XML)
			{
				var list:XMLList = new XMLList();
				list += value;
				this._dataProvider = new XMLListCollection(list.children());
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            this._dataProvider = ICollectionView(value);
	        }else if(value is Object)
			{
				// convert to an array containing this one item
				this._dataProvider = new ArrayCollection( [value] );
	  		}
	  		else
	  		{
	  			this._dataProvider = new ArrayCollection();
	  		}
	  		if (ICollectionView(_dataProvider).length > 0)
	  		{
		  		_cursor = ICollectionView(_dataProvider).createCursor();
		  		
		  		// in case the chart is cartesian, we must invalidate 
		  		// also the chart properties and display list
		  		// to let the chart update with the element data provider change. in fact
		  		// the element dataprovider modifies the chart data and axes properties
		  		// therefore it modifies the chart properties and displaying
		  		if (chart is Cartesian)
		  		{
			  		Cartesian(chart).axesFeeded = false;
			  		Cartesian(chart).invalidateProperties();
			  		Cartesian(chart).invalidateDisplayList();
		  		}

		  		invalidateSize();
		  		invalidateProperties();
				invalidatingDisplay();
	  		}
		}		
		/**
		* Set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		protected var _cursor:IViewCursor;
		public function set cursor(val:IViewCursor):void
		{
			_cursor = val;
			_maxDim1Value = _maxDim2Value = _maxDim3Value = _totalDim1PositiveValue = NaN;
			_minDim1Value = _minDim2Value = _minDim3Value = NaN;
			_minColorValue = _maxColorValue = _minSizeValue = _maxSizeValue = NaN;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get cursor():IViewCursor
		{
			return _cursor;
		}
		
		protected var _size:Number = 5;
		public function set size(val:Number):void
		{
			_size = val;
			invalidatingDisplay();
		}
		
		private var _randomColors:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set randomColors(val:Boolean):void
		{
			_randomColors = val;
			invalidatingDisplay();
		}
		public function get randomColors():Boolean
		{
			return _randomColors;
		}
		
		private var _alphaFill:Number;
		/** Set the fill alpha.*/
		public function set alphaFill(val:Number):void
		{
			_alphaFill = val;
			invalidatingDisplay();
		}
		public function get alphaFill():Number
		{
			return _alphaFill;
		}
		
		private var _alphaStroke:Number;
		/** Set the stroke alpha.*/
		public function set alphaStroke(val:Number):void
		{
			_alphaStroke = val;
			invalidatingDisplay();
		}
		public function get alphaStroke():Number
		{
			return _alphaStroke;
		}

		private var _colorFill:Number;
		/** Set the fill color to be used for data items.*/
		public function set colorFill(val:Number):void
		{
			_colorFill = val;
			invalidatingDisplay();
		}
		public function get colorFill():Number
		{
			return _colorFill;
		}

		protected var _colorStroke:Number;
		/** Set the stroke color to be used for the data items.*/
		public function set colorStroke(val:Number):void
		{
			_colorStroke = val;
			invalidatingDisplay();
		}
		public function get colorStroke():Number
		{
			return _colorStroke;
		}
		
		protected var _weightStroke:Number;
		/** Set the stroke color to be used for the data items.*/
		public function set weightStroke(val:Number):void
		{
			_weightStroke = val;
			invalidatingDisplay();
		}
		public function get weightStroke():Number
		{
			return _weightStroke;
		}

		protected var _colors:Array;

		protected var _colorGradients:Array;
		/** Set the gradientColors to be used for the data items.*/
		public function set colorGradients(val:Array):void
		{
			_colorGradients = val;
			invalidatingDisplay();
		}
		public function get colorGradients():Array
		{
			return _colorGradients;
		}

		protected var _alphaGradients:Array;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set alphaGradients(val:Array):void
		{
			_alphaGradients = val;
			invalidatingDisplay();
		}
		public function get alphaGradients():Array
		{
			return _alphaGradients;
		}

		protected var _fontLabel:String;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set fontLabel(val:String):void
		{
			_fontLabel = val;
			invalidatingDisplay();
		}
		public function get fontLabel():String
		{
			return _fontLabel;
		}

		protected var _sizeLabel:Number;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set sizeLabel(val:Number):void
		{
			_sizeLabel = val;
			invalidatingDisplay();
		}
		public function get sizeLabel():Number
		{
			return _sizeLabel;
		}

		protected var _colorLabel:Number;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set colorLabel(val:Number):void
		{
			_colorLabel = val;
			invalidatingDisplay();
		}
		public function get colorLabel():Number
		{
			return _colorLabel;
		}

		protected var _sizeRenderer:uint;
		/** Set the _sizeRenderer to be used for the data items.*/
		public function set sizeRenderer(val:uint):void
		{
			_sizeRenderer = val;
			invalidatingDisplay();
		}
		public function get sizeRenderer():uint
		{
			return _sizeRenderer;
		}

		private var _mouseDoubleClickFunction:Function;
		/** Set the function that should be used when a mouse double click event is triggered.
		 * This function must accept an DataItemLayout as input value.
		 * The DataItemLayout object contains all information about the data value
		 * that has been clicked, particularly, its x-y-z coordinates, its data item, 
		 * it's positioning over the axes, its fills and strokes....*/
		public function set mouseDoubleClickFunction(val:Function):void
		{
			_mouseDoubleClickFunction = val;
		}
		public function get mouseDoubleClickFunction():Function
		{
			return _mouseDoubleClickFunction;
		}

		private var _mouseClickFunction:Function;
		/** Set the function that should be used when a mouse click event is triggered.
		 * This function must accept an DataItemLayout as input value.
		 * The DataItemLayout object contains all information about the data value
		 * that has been clicked, particularly, its x-y-z coordinates, its data item, 
		 * it's positioning over the axes, its fills and strokes....*/
		public function set mouseClickFunction(val:Function):void
		{
			_mouseClickFunction = val;
		}
		public function get mouseClickFunction():Function
		{
			return _mouseClickFunction;
		}
		
		private var _displayName:String;
		/** Set the display name to be used for the legend.*/
		public function set displayName(val:String):void
		{
			_displayName= val;
		}
		public function get displayName():String
		{
			return _displayName;
		}
		
		private var _itemRenderer:Class;
		/** Set the item renderer to be used for both data items layout and related legend item.*/
		public function set itemRenderer(val:Class):void
		{
			_itemRenderer = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		protected var _source:Object;
		public function set source(val:Object):void
		{
			_source = val;
			invalidatingDisplay();
		}
		public function get source():Object
		{
			return _source;
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
		
		// UIComponent flow

		public function BaseElement()
		{
			super();
			collisionScale = VERTICAL;
		}

		override protected function createChildren():void
		{
			super.createChildren();

			// gg will be the GeometryGroup that will store the global series geometries
			// All hit area will be put in ttGeom
			// this increases performances in case the user doesn't set
			// showDataTips to true in the parent chart or interactive functions
			// Being gg a data item layout, it's still possible to add interactivity to gg
			// in this case there will be a gg instance for each data item 
			// if it's a 3D chart (apart from area and line series), 
			// than gg will be instantiated for each triple of datavalues
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);
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
		
		// Override updateDisplayList() to update the component
		// based on the style setting.
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (_invalidatedDisplay)
				drawElement();
		}

		// other methods

		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}
		
		protected function invalidatingDisplay():void
		{
			_invalidatedDisplay = true;
			invalidateDisplayList();
		}

		public function drawElement():void
		{
			if (stylesChanged)
			{
				// Redraw gradient fill only if style changed.
				if (!_colors)
					_colors = getStyle("colors");

				if (!_colorGradients)
					_colorGradients = getStyle("gradientColors");
				if (!_alphaGradients)
					_alphaGradients = getStyle("gradientAlphas");
				
				if (!isNaN(_colorFill))
					_colorFill = getStyle("fillColor");
				if (!_alphaFill)
					_alphaFill = getStyle("fillAlpha");
				
				if (isNaN(_colorStroke))
					_colorStroke = getStyle("strokeColor");
				
				if (isNaN(_alphaStroke))
					_alphaStroke = getStyle("strokeAlpha");
				
				if (isNaN(_weightStroke))
					_weightStroke = getStyle("strokeWeight");

				if (!_fontLabel)
					_fontLabel = getStyle("labelFont");

				if (isNaN(_colorLabel))
					_colorLabel = getStyle("labelColor");

				if (isNaN(_sizeLabel))
					_sizeLabel = getStyle("labelSize");

				if (isNaN(_sizeRenderer))
					_sizeRenderer = getStyle("rendererSize");

 				stylesChanged = false;
			}

			if (colorGradients)
			{
				fill = new LinearGradientFill();
				var grStop:GradientStop = new GradientStop(colorGradients[0])
				grStop.alpha = alphaGradients[0];
				var g:Array = new Array();
				g.push(grStop);

				grStop = new GradientStop(colorGradients[1]);
				grStop.alpha = alphaGradients[1];
				g.push(grStop);

				LinearGradientFill(fill).gradientStops = g;
			} else if (!_colors)
				fill = new SolidFill(colorFill, alphaFill);
			
			stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);

			if (ggBackGround)
			{
				ggBackGround.target = this;
				rectBackGround.width = unscaledWidth;
				rectBackGround.height = unscaledHeight;
			}
			
			// to be overridden by each element implementation
		}
		
		protected function isReadyForLayout():Boolean
		{
			// verify than all element axes (or chart's if none owned by the element)
			// are ready. If they aren't the element can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;
			
			if (scale2)
			{
				if (scale2 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(scale2).dataProvider);
				
				axesCheck = axesCheck && (scale2.size>0);
			} 

			if (scale1)
			{
				if (scale1 is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(scale1).dataProvider);

				axesCheck = axesCheck && (scale1.size>0);
			} 

			if ((multiScale && multiScale.scales) || (chart.multiScale && chart.multiScale.scales))
				axesCheck = true;

			var colorsCheck:Boolean = 
				(fill || stroke || colorScale);

			var globalCheck:Boolean = 
/* 				   (!isNaN(_minDim1Value) || !isNaN(_minDim2Value))
				&& (!isNaN(_maxDim1Value) || !isNaN(_maxDim2Value))
				&&  */width>0 && height>0
				&& chart
				&& cursor;
			
			return globalCheck && axesCheck && colorsCheck;
		}

		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		protected function handleRollOver(e:MouseEvent):void 
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

			if (scale2 && scale2 is IScaleUI && IScaleUI(scale2).pointer && chart.coordType == VisScene.CARTESIAN)
			{
				IScaleUI(scale2).pointerY = extGG.posY;
				IScaleUI(scale2).pointer.visible = true;
			} 

			if (scale1 && scale1 is IScaleUI && IScaleUI(scale1).pointer && chart.coordType == VisScene.CARTESIAN)
			{
				IScaleUI(scale1).pointerX = extGG.posX;
				IScaleUI(scale1).pointer.visible = true;
			}
			
			if (scale3 && scale3 is IScaleUI && IScaleUI(scale3).pointer && chart.coordType == VisScene.CARTESIAN)
			{
				IScaleUI(scale3).pointerY = extGG.posZ;
				IScaleUI(scale3).pointer.visible = true;
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
			if (chart.showDataTips)
			{
				extGG.hideToolTip();
				if (!_showAllDataItems)
					extGG.hideToolTipGeometry();
				myTT = null;
				toolTip = null;
			}

			if (scale1 && scale1 is IScaleUI && IScaleUI(scale1).pointer)
				IScaleUI(scale1).pointer.visible = false;

			if (scale2 && scale2 is IScaleUI && IScaleUI(scale2).pointer)
				IScaleUI(scale2).pointer.visible = false;

			if (scale3 && scale3 is IScaleUI && IScaleUI(scale3).pointer)
				IScaleUI(scale3).pointer.visible = false;
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

		protected var ggIndex:Number;
		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaElement, thus improving performances.*/ 
		protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN, showGeometry:Boolean = true):void
		{
			if (graphicsCollection.items && graphicsCollection.items.length > ggIndex)
				ttGG = graphicsCollection.items[ggIndex];
			else {
				ttGG = new DataItemLayout();
				graphicsCollection.addItem(ttGG);
			}
			ggIndex++;
			ttGG.target = chart.elementsContainer;
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);

			var hitMouseArea:Circle = new Circle(xPos, yPos, 5); 
			hitMouseArea.fill = new SolidFill(0x000000, 0);
			ttGG.geometryCollection.addItem(hitMouseArea);

 			if (chart.showDataTips || chart.showAllDataTips)
			{ 
				initGGToolTip();
				ttGG.create(cursor.current, dataFields, xPos, yPos, zPos, radius, shapes, ttXoffset, ttYoffset, true, showGeometry);
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
		protected function initGGToolTip():void
		{
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
 			if (chart.dataTipFunction != null)
				ttGG.dataTipFunction = chart.dataTipFunction;
			if (chart.dataTipPrefix!= null)
				ttGG.dataTipPrefix = chart.dataTipPrefix;
		}

		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("BaseElement");
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			selector.defaultFactory = function():void
			{
				this.gradientColors = null;
				this.gradientAlphas = [0.5, 0.5];

				this.fillColor = 0x000000;
				this.fillAlpha = 1;

				this.strokeColor = 0x111111;
				this.strokeAlpha = 1;
				this.strokeWeight = 1;

				this.labelFont = "verdana";
				this.labelSize = 9;
				this.labelColor = 0x000000;
				
				this.rendererSize = 10;

				this.stylesChanged = true;
			} 
			StyleManager.setStyleDeclaration("BaseElement", selector, true);
		}
		
		// Override the styleChanged() method to detect changes in your new style.
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			// Check to see if style changed.
			switch(styleProp)
			{
				case "gradientColors":
				case "gradientAlphas":
				case "fillColor":
				case "fillAlpha":
				case "strokeColor":
				case "strokeAlpha":
				case "strokeWeight":
				case "labelFont":
				case "labelSize":
				case "labelColor":
					invalidateDisplayList();
				break;
			} 
		}
		
		private var currentValue:Number;
		protected function getTotalPositiveValue(field:Object):Number
		{
			var tot:Number = NaN;
			if (cursor && field)
			{
				cursor.seek(CursorBookmark.FIRST);
				while (!cursor.afterLast)
				{
					var tmpArray:Array = (dim1 is Array) ? dim1 as Array : [String(dim1)];
					
					for (var i:Number = 0; i<tmpArray.length; i++)
					{
						currentValue = cursor.current[tmpArray[i]];
						if (currentValue > 0)
						{
							if (isNaN(tot))
								tot = currentValue;
							else
								tot += currentValue;
						}
					}
					_cursor.moveNext();
				}
			}
			return tot;
		}

		protected function getMinValue(field:Object):Number
		{
			var min:Number = NaN;

			if (cursor && field)
			{
				_cursor.seek(CursorBookmark.FIRST);
				while (!_cursor.afterLast)
				{
					currentValue = _cursor.current[field];
					if (isNaN(min) || min > currentValue)
						min = currentValue;
					
					_cursor.moveNext();
				}
			}
			return min;
		}

		protected function getMaxValue(field:Object):Number
		{
			var max:Number = NaN;

			if (cursor && field)
			{
				_cursor.seek(CursorBookmark.FIRST);
				while (!_cursor.afterLast)
				{
					currentValue = _cursor.current[field];
					if (isNaN(max) || max < currentValue)
						max = currentValue;
					
					_cursor.moveNext();
				}
			}
			return max;
		}

		/** Remove all graphic elements of the series.*/
		public function removeAllElements():void
		{
			if (gg) 
				gg.removeAllElements();
			
			var nElements:int = graphicsCollection.items.length;
			if (nElements > 0)
			{
				for (var i:int = 0; i<nElements; i++)
				{
					if (graphicsCollection.items[i] is DataItemLayout)
					{
						DataItemLayout(graphicsCollection.items[i]).removeEventListener(MouseEvent.ROLL_OVER, handleRollOver);
						DataItemLayout(graphicsCollection.items[i]).removeEventListener(MouseEvent.ROLL_OUT, handleRollOut);
						DataItemLayout(graphicsCollection.items[i]).removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
						DataItemLayout(graphicsCollection.items[i]).removeEventListener(MouseEvent.CLICK, onMouseClick);
						DataItemLayout(graphicsCollection.items[i]).removeAllElements();
					} else if (graphicsCollection.items[i] is GeometryGroup) {
						GeometryGroup(graphicsCollection.items[i]).geometry = []; 
						GeometryGroup(graphicsCollection.items[i]).geometryCollection.items = [];
					}
				}
			} 
/* 
 			for (i = numChildren - 1; i>=0; i--)
			{
				if (getChildAt(i) is DataItemLayout)
				{
					DataItemLayout(getChildAt(i)).removeEventListener(MouseEvent.ROLL_OVER, handleRollOver);
					DataItemLayout(getChildAt(i)).removeEventListener(MouseEvent.ROLL_OUT, handleRollOut);
					DataItemLayout(getChildAt(i)).removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
					DataItemLayout(getChildAt(i)).removeEventListener(MouseEvent.CLICK, onMouseClick);
					DataItemLayout(getChildAt(i)).removeAllElements();
				}
				removeChildAt(i);
			}
 			graphicsCollection.items = [];
 */  		}
		
		protected var rectBackGround:RegularRectangle;
		protected var ggBackGround:GeometryGroup;
		protected var tooltipCreationListening:Boolean = false;
		/** @Private 
		 * Init the custom tooltip of the series in case showdatatips is true.*/
		protected function initCustomTip():void
		{
			addEventListener(ToolTipEvent.TOOL_TIP_CREATE, onTTCreate);
			toolTip = "";

			// background is needed on each series to allow custom tooltip events
			// all over the series space, mostly on those data items  
			// located at the border of the series or gg
			ggBackGround = new GeometryGroup();
			graphicsCollection.addItemAt(ggBackGround,0);
			rectBackGround = new RegularRectangle(0,0,0, 0);
			rectBackGround.fill = new SolidFill(0x000000,0);
			ggBackGround.geometryCollection.addItem(rectBackGround);
			
			// once this is true, the listener will not be added anymore
			tooltipCreationListening = true;
		}

		protected var ttGG:DataItemLayout;
		/** @Private
		 * Override the creation of ttGeom. This should be unified among polar and cartesian series.
		 * In order to improve performances in case the showdatatips is false
		 * the ttGG creation will not be called and there will be only 1 gg, unless
		 * interactivity is required or dim3 is not null and gg must be placed in the 3D space.*/ 
/* 		protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry , 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			// override
		}
 */		
		/** @Private
		 * Init the ttGG after its creation.*/ 
/* 		protected function initGGToolTip():void
		{
			// override
		}
 */		
		/** Implement function to manage mouse click events.*/
		public function onMouseClick(e:MouseEvent):void
		{
			var target:DataItemLayout;
			if (e.target is DataItemLayout)
			{
				target = DataItemLayout(e.target);
				 
				_mouseClickFunction(target);
			}
		}

		/** Implement function to manage mouse double click events.*/
		public function onMouseDoubleClick(e:MouseEvent):void
		{
			var target:DataItemLayout;
			if (e.target is DataItemLayout)
			{
				target = DataItemLayout(e.target);
				 
				_mouseDoubleClickFunction(target);
			}
		}

		/** @Private 
		 * Custom tooltip variable.*/
		protected var myTT:IToolTip;
		/**
		* @private 
		 * Show and position tooltip.*/
/* 		protected function handleRollOver(e:MouseEvent):void 
		{
			// override
			// depends on chart type (polar, cartesian,..)
		}
 */
		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
/* 		protected function handleRollOut(e:MouseEvent):void
		{ 
			var extGG:DataItemLayout = 	DataItemLayout(e.target);
			extGG.hideToolTip();
			if (!_showAllDataItems)
				extGG.hideToolTipGeometry();
			myTT = null;
			toolTip = null;
 			if (ToolTipManager.currentToolTip)
				ToolTipManager.currentToolTip = null;
 		}
 */
		/**
		* @Private 
		 * Triggered when a value is assigned to the UIComponent tooltip (String), 
		 * and the event target is the tooltip created during the assignement.
		 * Here you we can change the created tooltip with a custom one.*/
/* 		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}
 */		
		public function getFill():IGraphicsFill
		{
			return fill;
		}

		public function getStroke():IGraphicsStroke
		{
			return stroke;
		}
	}
}