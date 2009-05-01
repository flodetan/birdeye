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
 
package org.un.cava.birdeye.qavis.charts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
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
	
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.interfaces.ISeries;

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
	
	public class BaseSeries extends Surface implements ISeries
	{
		protected var _extendMouseEvents:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set extendMouseEvents(val:Boolean):void
		{
			_extendMouseEvents = val;
			invalidateDisplayList();
		}
		
		private var _colorAxis:INumerableAxis;
		/** Define an axis to set the colorField for data items.*/
		public function set colorAxis(val:INumerableAxis):void
		{
			_colorAxis = val;

			invalidateDisplayList();
		}
		public function get colorAxis():INumerableAxis
		{
			return _colorAxis;
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
			invalidateDisplayList();
		}
		public function get colorField():String
		{
			return _colorField;
		}

		private var _labelField:String;
		public function set labelField(val:String):void
		{
			_labelField = val;
			invalidateDisplayList();
		}
		public function get labelField():String
		{
			return _labelField;
		}

		protected var gg:DataItemLayout;
		protected var dataItems:Array = [];
		protected var fill:IGraphicsFill = new SolidFill(0x888888,0);
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
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get cursor():IViewCursor
		{
			return _cursor;
		}
		
		private var _randomColors:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set randomColors(val:Boolean):void
		{
			_randomColors = val;
			invalidateDisplayList();
		}
		public function get randomColors():Boolean
		{
			return _randomColors;
		}
		
		private var _alphaFill:Number = 1;
		/** Set the fill alpha.*/
		public function set alphaFill(val:Number):void
		{
			_alphaFill = val;
			invalidateDisplayList();
		}
		public function get alphaFill():Number
		{
			return _alphaFill;
		}
		
		private var _alphaStroke:Number = 1;
		/** Set the stroke alpha.*/
		public function set alphaStroke(val:Number):void
		{
			_alphaStroke = val;
			invalidateDisplayList();
		}
		public function get alphaStroke():Number
		{
			return _alphaStroke;
		}

		private var _colorFill:uint;
		/** Set the fill color to be used for data items.*/
		public function set colorFill(val:uint):void
		{
			_colorFill = val;
			invalidateDisplayList();
		}
		public function get colorFill():uint
		{
			return _colorFill;
		}

		protected var _colorStroke:uint;
		/** Set the stroke color to be used for the data items.*/
		public function set colorStroke(val:uint):void
		{
			_colorStroke = val;
			invalidateDisplayList();
		}
		public function get colorStroke():uint
		{
			return _colorStroke;
		}
		
		protected var _weightStroke:uint;
		/** Set the stroke color to be used for the data items.*/
		public function set weightStroke(val:uint):void
		{
			_weightStroke = val;
			invalidateDisplayList();
		}
		public function get weightStroke():uint
		{
			return _weightStroke;
		}

		protected var _colorGradients:Array;
		/** Set the gradientColors to be used for the data items.*/
		public function set colorGradients(val:Array):void
		{
			_colorGradients = val;
			invalidateDisplayList();
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
			invalidateDisplayList();
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
			invalidateDisplayList();
		}
		public function get fontLabel():String
		{
			return _fontLabel;
		}

		protected var _sizeLabel:uint;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set sizeLabel(val:uint):void
		{
			_sizeLabel = val;
			invalidateDisplayList();
		}
		public function get sizeLabel():uint
		{
			return _sizeLabel;
		}

		protected var _colorLabel:uint;
		/** Set the gradientAlphas to be used for the data items.*/
		public function set colorLabel(val:uint):void
		{
			_colorLabel = val;
			invalidateDisplayList();
		}
		public function get colorLabel():uint
		{
			return _colorLabel;
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
			invalidateDisplayList();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		protected var _source:Object;
		public function set source(val:Object):void
		{
			_source = val;
			invalidateDisplayList();
		}
		public function get source():Object
		{
			return _source;
		}
		
		// UIComponent flow
		
		public function BaseSeries()
		{
			super();
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
		
		// Override updateDisplayList() to update the component
		// based on the style setting.
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (stylesChanged)
			{
				// Redraw gradient fill only if style changed.
				colorGradients = getStyle("gradientColors");
				alphaGradients = getStyle("gradientAlphas");
				
				colorFill = getStyle("fillColor");
				alphaFill = getStyle("fillAlpha");
				
				colorStroke = getStyle("strokeColor");
				alphaStroke = getStyle("strokeAlpha");
				weightStroke = getStyle("strokeWeight");

				fontLabel = getStyle("labelFont");
				colorLabel = getStyle("labelColor");
				sizeLabel = getStyle("labelSize");

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
			} else 
				fill = new SolidFill(colorFill, alphaFill);
			
			stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
		}

		// other methods

		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("BaseSeries");
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

				this.stylesChanged = true;
			} 
			StyleManager.setStyleDeclaration("BaseSeries", selector, true);
		}
		
		// Override the styleChanged() method to detect changes in your new style.
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			// Check to see if style changed.
			if (styleProp == "gradientColors" || styleProp == "gradientAlphas")
				invalidateDisplayList();
		}
		
		private var currentValue:Number;
		protected function getTotalPositiveValue(field:String):Number
		{
			var tot:Number = NaN;
			if (cursor && field)
			{
				cursor.seek(CursorBookmark.FIRST);
				while (!cursor.afterLast)
				{
					currentValue = cursor.current[field];
					if (currentValue > 0)
					{
						if (isNaN(tot))
							tot = currentValue;
						else
							tot += currentValue;
					}

					_cursor.moveNext();
				}
			}
			return tot;
		}

		protected function getMinValue(field:String):Number
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

		protected function getMaxValue(field:String):Number
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
			if (nElements > 1)
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
					}
				}
			} 

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
		}
		
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
		 * interactivity is required or zField is not null and gg must be placed in the 3D space.*/ 
		protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									zPos:Number, radius:Number, shapes:Array = null /* of IGeometry */, 
									ttXoffset:Number = NaN, ttYoffset:Number = NaN):void
		{
			// override
		}
		
		/** @Private
		 * Init the ttGG after its creation.*/ 
		protected function initGGToolTip():void
		{
			// override
		}
		
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
		protected function handleRollOver(e:MouseEvent):void 
		{
			// override
			// depends on chart type (polar, cartesian,..)
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

		/**
		* @Private 
		 * Triggered when a value is assigned to the UIComponent tooltip (String), 
		 * and the event target is the tooltip created during the assignement.
		 * Here you we can change the created tooltip with a custom one.*/
		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}
		
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