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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.data.UtilSVG;
	import birdeye.vis.elements.events.ElementRollOutEvent;
	import birdeye.vis.elements.events.ElementRollOverEvent;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.coords.IValidatingCoordinates;
	import birdeye.vis.interfaces.data.IVisualDataID;
	import birdeye.vis.interfaces.elements.IElement;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.RotateTransform;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.core.IFactory;
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.events.ToolTipEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import org.greenthreads.IThread;
	import org.greenthreads.ThreadProcessor;

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
	
	public class BaseElement extends BaseDataElement implements IElement, IThread
	{
		
		protected var _showFieldName:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set showFieldName(val:Boolean):void
		{
			_showFieldName = val;
			invalidatingDisplay();
		}
		public function get showFieldName():Boolean
		{
			return _showFieldName;
		}

		private var _labelOffsetX:Number;
		public function set labelOffsetX(val:Number):void
		{
			_labelOffsetX = val;
			invalidatingDisplay();
		}		
		public function get labelOffsetX():Number
		{
			return _labelOffsetX;
		}		

		private var _labelOffsetY:Number;
		public function set labelOffsetY(val:Number):void
		{
			_labelOffsetY = val;
			invalidatingDisplay();
		}		
		public function get labelOffsetY():Number
		{
			return _labelOffsetY;
		}		
		
		private var _labelRotation:Number;
		public function set labelRotation(val:Number):void
		{
			_labelRotation = val;
			invalidatingDisplay();
		}		
		public function get labelRotation():Number
		{
			return _labelRotation;
		}

		protected var _showGraphicRenderer:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set showGraphicRenderer(val:Boolean):void
		{
			_showGraphicRenderer = val;
			invalidatingDisplay();
		}

		protected var _rendererSize:Number = 5;
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
		
		protected var _showAllDataTipsOnRollOver:Boolean = false;
		[Inspectable(enumeration="true,false")]
		/**
		 * If set to true, all the datatips of an element will be shown on roll over on a datapoint.
		 * @default false
		 */
		public function set showAllDataTipsOnRollOver(val:Boolean):void
		{
			_showAllDataTipsOnRollOver = val;
			invalidatingDisplay();
		}

		protected var _showTipGeometry:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set showTipGeometry(val:Boolean):void
		{
			_showTipGeometry = val;
			invalidatingDisplay();
		}
		
		
		private var _dataTipOffsetX:Number = -20;
		/**
		 * Set the x offset of the datatip
		 * @default -20
		 */ 
		public function set dataTipOffsetX(val:Number):void
		{
			_dataTipOffsetX = val;
			
			invalidatingDisplay();
		}
		
		public function get dataTipOffsetX():Number
		{
			return _dataTipOffsetX;	
		}
		
		
		private var _dataTipOffsetY:Number = 40;
		/**
		 * Set the y offset of the datatip
		 * @default 400
		 */ 
		public function set dataTipOffsetY(val:Number):void
		{
			_dataTipOffsetY = val;
			
			invalidatingDisplay();
		}
		
		public function get dataTipOffsetY():Number
		{
			return _dataTipOffsetY;	
		}	

		protected function getItemFillColor(item:Object):IGraphicsFill {
			var f:IGraphicsFill = null;
			if (colorScale) {
				var col:* = colorScale.getPosition(item[colorField]);
				if (col is Number) {
					f = new SolidFill(col);
				} else if (col is IGraphicsFill) {
					f = col;
				}
			}
			if (!f) {
				f = fill;
			}
			return f;
		}


		protected var gg:GeometryGroup;
		protected var fill:IGraphicsFill;
		protected var stroke:IGraphicsStroke = new SolidStroke(0x888888,1,1);
		
		
		protected var _graphicRendererSize:Number = 5;
		public function set graphicRendererSize(val:Number):void
		{
			_graphicRendererSize = val;
			invalidatingDisplay();
		}

		protected var _hitAreaSize:Number = 5;
		public function set hitAreaSize(val:Number):void
		{
			_hitAreaSize = val;
			invalidatingDisplay();
		}
		
		private var lastRandomColor:int = -1;
		private var _randomColors:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set randomColors(val:Boolean):void
		{
			_randomColors = val;
			_colorsChanged = true;
			invalidateProperties();
		}
		public function get randomColors():Boolean
		{
			return _randomColors;
		}

		protected var _colorsStart:Array;
		public function set colorsStart(val:Array):void
		{
			_colorsStart = val;
			_colorsChanged = true;
			invalidateProperties();
		}		

		protected var _colorsStop:Array;
		public function set colorsStop(val:Array):void
		{
			_colorsStop = val;
			_colorsChanged = true;
			invalidateProperties();
		}			
		private var _alphaFill:Number;
		/** Set the fill alpha.*/
		public function set alphaFill(val:Number):void
		{
			_alphaFill = val;
			_colorsChanged = true;
			invalidateProperties();
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
			_colorsChanged = true;
			invalidateProperties();
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
			_colorsChanged = true;
			invalidateProperties();
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
			_colorsChanged = true;
			invalidateProperties();
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
			_colorsChanged = true;
			
			invalidateProperties();
		}
		public function get weightStroke():Number
		{
			return _weightStroke;
		}

		protected var _colors:Array;
		protected var _colorsChanged:Boolean = true;

		protected var _colorGradients:Array;
		/** Set the gradientColors to be used for the data items.*/
		public function set colorGradients(val:Array):void
		{
			_colorGradients = val;
			_colorsChanged = true;
			invalidateProperties();
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
			_colorsChanged = true;
			invalidateProperties();
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

		protected var _rendererWidth:uint;
		/** Set the renderer width to be used for the data items.*/
		public function set rendererWidth(val:uint):void
		{
			_rendererWidth = val;
			invalidatingDisplay();
		}
		public function get rendererWidth():uint
		{
			return _rendererWidth;
		}

		protected var _rendererHeight:uint;
		/** Set the renderer height to be used for the data items.*/
		public function set rendererHeight(val:uint):void
		{
			_rendererHeight = val;
			invalidatingDisplay();
		}
		public function get rendererHeight():uint
		{
			return _rendererHeight;
		}

		private var _draggableItems:Boolean = false;
		/** If set to true, than data items can be dragged. */
		[Inspectable(enumeration="true,false")]
		public function set draggableItems(val:Boolean):void
		{
			_draggableItems = val;
			invalidatingDisplay();
		}
		public function get draggableItems():Boolean
		{
			return _draggableItems;
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
		
		private var _mouseOverFunction:Function;
		/** Set the function that should be used when a mouse over event is triggered.
		 * This function must accept an DataItemLayout as input value.
		 * The DataItemLayout object contains all information about the data value
		 * that has been clicked, particularly, its x-y-z coordinates, its data item, 
		 * it's positioning over the axes, its fills and strokes....*/
		public function set mouseOverFunction(val:Function):void
		{
			_mouseOverFunction = val;
		}
		public function get mouseOverFunction():Function
		{
			return _mouseOverFunction ;
		}
		
		private var _mouseOutFunction:Function;
		/** Set the function that should be used when a roll out event is triggered.
		 * This function must accept an DataItemLayout as input value.
		 * The DataItemLayout object contains all information about the data value
		 * that has been clicked, particularly, its x-y-z coordinates, its data item, 
		 * it's positioning over the axes, its fills and strokes....*/
		public function set mouseOutFunction(val:Function):void
		{
			_mouseOutFunction = val;
		}
		public function get mouseOutFunction():Function
		{
			return _mouseOutFunction ;
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
		
		private var _graphicsRenderer:IFactory;
		private var _graphicsRendererChanged:Boolean = true; // to init
		protected var _graphicsRendererInst:IGeometry = null;
		/** Set the graphics renderer to be used for both data items layout and related legend item.*/
		public function set graphicRenderer(val:IFactory):void
		{
			_graphicsRenderer = val;
			_graphicsRendererChanged = true;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get graphicRenderer():IFactory
		{
			return _graphicsRenderer;
		}
		
		protected var _source:Object;
		protected var _sourceChanged:Boolean = false
		public function set source(val:Object):void
		{
			_source = val;
			_sourceChanged = true;
			
			invalidateProperties();
		}
		public function get source():Object
		{
			return _source;
		}
		
		/** 
		 * Indicate whether to have a background or not. Sometimes it's useful that the 
		 * visscene is empty, for ex. when it shares the same space with another visscene and 
		 * we want the scene on the back to have his interactivity.
		 */
		public var _backgroundEmpty:Boolean = false;
		[Inspectable(enumeration="true,false")]
		public function set backgroundEmpty(val:Boolean):void
		{
			_backgroundEmpty = val;
		}
		public function get backgroundEmpty():Boolean
		{
			return _backgroundEmpty;
		}
		
		// UIComponent flow

		public function BaseElement()
		{
			super();

		}

		override protected function redraw(o:Object):void
		{
			if (o != null)
			{
				ThreadProcessor.getInstance().addThread(this);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (_graphicsRendererChanged)
			{
				_graphicsRendererChanged = false;
				
				if (_graphicsRenderer)
				{
					_graphicsRendererInst = _graphicsRenderer.newInstance();
				}
				else
				{
					createDefaultGraphicsRenderer();
				}
				
				invalidatingDisplay();
			}
			
			if (_colorsChanged)
			{
				_colorsChanged = false;
				
				getFillStrokeColors();
				fillValues = getFillValues();
				rgbFill = UtilSVG.toHex(fillValues[0]);
				rgbStroke = UtilSVG.toHex(colorStroke);
				
				invalidatingDisplay();
			}
			
			if (_sourceChanged)
			{
				_sourceChanged = false;
				
				if (_source)
				{
					_graphicsRendererInst = new RasterRenderer(null, _source);
				}
			}
		}
		
		
		override protected function invalidatingDisplay() : void
		{
			super.invalidatingDisplay();
			
			if (visScene is IValidatingCoordinates)
			{
				(visScene as IValidatingCoordinates).invalidateElement(this);
			}
		}
		
		
		protected function createDefaultGraphicsRenderer():void
		{
			
		}

		
		// greentrheading
		public function get priority():int
		{
			return ThreadProcessor.PRIORITY_ELEMENT;
		}
		
		
		public function preDraw():Boolean
		{
			_currentItemIndex = 0;
			
			return true;
		}
		
		protected var _currentItemIndex:int = 0;
		
		public function drawDataItem():Boolean
		{
			return checkDrawableDataItems();
		}
		
		protected function checkDrawableDataItems():Boolean
		{
			if (!_dataItems) return false;
			_currentItemIndex++;
			return _currentItemIndex < _dataItems.length;
		}
		
		public function endDraw():void
		{
			
		}
		
		public function clear():void
		{
			this.graphics.clear();
		}
		

		// other methods

		/**
		* @Private 
		 * Triggered when a value is assigned to the UIComponent tooltip (String), 
		 * and the event target is the tooltip created during the assignement.
		 * Here we can change the created tooltip with a custom one.*/
		private function onTTCreate(e:ToolTipEvent):void
		{
			e.toolTip = myTT;
		}
		

		/**
		 * Make sure that the given location in the elementscontainer is transformed to the right x,y</br>
		 * for the tooltiplayer (can be different coordinate systems.
		 */
		protected function transformToTooltipCoordinate(p:Point):Point
		{
			var elC:UIComponent = this.visScene.elementsContainer;
			// get the tooltiplayer
			var ttl:UIComponent = this.visScene.tooltipLayer;
			
			return ttl.globalToContent(elC.contentToGlobal(p));
		}

		

		
		override protected function isReadyForLayout():Boolean
		{
			var colorsCheck:Boolean = 
				(fill || stroke || colorScale);
			
			return super.isReadyForLayout() && colorsCheck;
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
			if (!backgroundEmpty)
			{
				ggBackGround = new GeometryGroup();
				graphicsCollection.addItemAt(ggBackGround,0);
				rectBackGround = new RegularRectangle(0,0,0, 0);
				rectBackGround.fill = new SolidFill(0x000000,0);
				ggBackGround.geometryCollection.addItem(rectBackGround);
			}
			
			// once this is true, the listener will not be added anymore
			tooltipCreationListening = true;
		}


			
		public function getFill():IGraphicsFill
		{
			return fill;
		}

		public function getStroke():IGraphicsStroke
		{
			return stroke;
		}
		
		protected function prepareForItemDisplayObjectsCreation():void {
		
			if (_itemDisplayObjects) {
				for (var itemId:Object in _itemDisplayObjects) {
					_itemDisplayObjects[itemId] = null;
				}
			} else {
				_itemDisplayObjects = new Dictionary();
			}
		}

		protected var _itemDisplayObjects:Dictionary;

		public function getItemDisplayObject(itemId:Object):DisplayObject {
			return _itemDisplayObjects[itemId];
		}

		/**
		 * @param itemId
		 * @param geometries Array of IGeometry objects 
		 **/
		protected function createItemDisplayObject(currentItem:Object, dataFields:Array, pos:Point, itemId:Object, renderers:Object):void {
			var geometries:Array = renderers.graphicRenderer;
			var itmDisplayObject:DisplayObject = renderers.itemRenderer;
			if (itmDisplayObject)
			{
				itmDisplayObject.x = pos.x; 
				itmDisplayObject.y = pos.y; 
				addChild(itmDisplayObject);
				_itemDisplayObjects[itemId] = itmDisplayObject;
				if (mouseDoubleClickFunction != null)
					DisplayObject(_itemDisplayObjects[itemId]).addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
				if (mouseClickFunction != null)
					DisplayObject(_itemDisplayObjects[itemId]).addEventListener(MouseEvent.CLICK, onMouseClick);
			} else if (geometries)
			{
				createTTGG(currentItem, dataFields, NaN, NaN, NaN, NaN);
				ttGG.geometry = geometries;
		        ttGG.x = pos.x; 
		        ttGG.y = pos.y; 
		        ttGG.target = this;
				_itemDisplayObjects[itemId] = ttGG;
			}
			
			if (_itemDisplayObjects[itemId] is IVisualDataID && currentItem[nodeIdField])
				IVisualDataID(_itemDisplayObjects[itemId]).visualObjectID = currentItem[nodeIdField];
		}
		
		protected function getRendererWidth(item:Object = null):Number
		{
			if (sizeScale && sizeField && item)
				return sizeScale.getPosition(item[sizeField]);
			
			if (rendererWidth>0)
				return rendererWidth;
			
			if (sizeRenderer>0)
				return sizeRenderer;
				
			return NaN;
		}

		protected function getRendererHeight(item:Object = null):Number
		{
			if (sizeScale && sizeField  && item)
				return sizeScale.getPosition(item[sizeField]);
			
			if (rendererHeight>0)
				return rendererHeight;
			
			if (sizeRenderer>0)
				return sizeRenderer;
				
			return NaN;
		}

		public function refresh(updatedDataItems:Vector.<Object>, field:Object = null, colorFieldValues:Array = null, fieldID:Object = null):void
		{
			// for the moment only overridden by PolygonElement
		}
		
		/*
		* Styling && Color
		*/
		
		
		protected var fillValues:Array;
		protected var rgbFill:String;
		protected var rgbStroke:String;

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
			
			if (styleProp == null || styleProp == "gradientColors" )
			{
				if (!_colorGradients)
				{
					_colorGradients = getStyle("gradientColors");
					invalidatingDisplay();
				}		
			}
			
			if (styleProp == null || styleProp == "gradientAlphas")
			{
				if (!_alphaGradients)
				{
					_alphaGradients = getStyle("gradientAlphas");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "fillColor")
			{
				if (isNaN(_colorFill))
				{
					_colorFill = getStyle("fillColor");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "fillAlpha")
			{
				if (!_alphaFill)
				{
					_alphaFill = getStyle("fillAlpha");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "strokeColor")
			{
				if (isNaN(_colorStroke))
				{
					_colorStroke = getStyle("strokeColor");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "strokeAlpha")
			{
				if (isNaN(_alphaStroke))
				{
					_alphaStroke = getStyle("strokeAlpha");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "strokeWeight")
			{
				if (isNaN(_weightStroke))
				{
					_weightStroke = getStyle("strokeWeight");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "labelFont")
			{
				if (!_fontLabel)
				{
					_fontLabel = getStyle("labelFont");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "labelSize")
			{
				if (isNaN(_sizeLabel))
				{
					_sizeLabel = getStyle("labelSize");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "labelColor")
			{
				if (isNaN(_colorLabel))
				{
					_colorLabel = getStyle("labelColor");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "rendererSize")
			{
				if (isNaN(_sizeRenderer))
				{
					_sizeRenderer = getStyle("rendererSize");
					invalidatingDisplay();
				}
			}
			
			if (styleProp == null || styleProp == "colors")
			{
				if (!_colors)
				{
					_colors = getStyle("colors");
					invalidatingDisplay();
				}
			}
		}
		
		private function getFillStrokeColors():void
		{
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
			
			var c:uint = 0;
			var tempColor:int;
			if (_colorsStart && _colorsStop)
			{
				if (c < _colorsStart.length)
				{
					fill = new LinearGradientFill();
					grStop = new GradientStop(_colorsStart[c])
					grStop.alpha = alpha;
					g = new Array();
					g.push(grStop);
					
					grStop = new GradientStop(_colorsStop[c]);
					grStop.alpha = alpha;
					g.push(grStop);
					
					LinearGradientFill(fill).gradientStops = g;
				}
			}  else if (_colors)
			{
				if (c < _colors.length)
					fill = new SolidFill(_colors[c]);
				else
					fill = new SolidFill(_colors[_colors.length]);
			} else if (randomColors)
			{
				if (lastRandomColor == -1)
					lastRandomColor = Math.random() * 255 * 255 * 255;
				fill = new SolidFill(lastRandomColor);
			}
			
			stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
		}
		
		private function getFillValues():Array
		{
			if (colorGradients)
				return colorGradients;
			
			if (_colorsStart && _colorsStop)
				return [_colorsStart, _colorsStop];
			else if (randomColors)
			{
				if (lastRandomColor == -1)
					lastRandomColor = Math.random() * 255 * 255 * 255;
				return [lastRandomColor];
			}
			return [colorFill];
		}
		
		
		
		/*
		* Tooltips
		*/
		
		protected var ttGG:DataItemLayout;
		private var label:TextRenderer;
		protected var ggIndex:Number;
		/** @Private
		 * Override the creation of ttGeom in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * AreaElement, thus improving performances.*/ 
		protected function createTTGG(item:Object, dataFields:Array, xPos:Number, yPos:Number, 
									  zPos:Number, radius:Number, collisionIndex:Number = NaN, shapes:Array = null /* of IGeometry */, 
									  ttXoffset:Number = NaN, ttYoffset:Number = NaN, showGeometry:Boolean = true):void
		{
			if (graphicsCollection.items && graphicsCollection.items.length > ggIndex)
				ttGG = graphicsCollection.items[ggIndex];
			else {
				ttGG = new DataItemLayout();
				graphicsCollection.addItem(ttGG);
			}
			
			if (labelField && labelCreationNotOverridden)
			{
				var text:String;
				if (item[labelField])
					text = item[labelField];
				else
					text = labelField;
				
				label = new TextRenderer(xPos, yPos,
					text, new SolidFill(colorLabel), true, true, sizeLabel, fontLabel);
				
				if (!isNaN(_labelOffsetX) && _labelOffsetX != 0)
					label.x += _labelOffsetX;
				if (!isNaN(_labelOffsetY) && _labelOffsetY != 0)
					label.y += _labelOffsetY;
				
				if (labelRotation) {
					var transform:RotateTransform = new RotateTransform();
					transform.angle= labelRotation;
					transform.registrationPoint = "bottomLeft";
					
					label.transform = transform;
				}
				
				addSVGData(label.svgData);
				ttGG.geometryCollection.addItemAt(label,0); 
			}
			ggIndex++;
			ttGG.target = visScene.elementsContainer;
			ttGG.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			ttGG.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
			
			ttGG.hitMouseArea = createMouseHitArea(xPos, yPos, _hitAreaSize);
			
			if (visScene.showDataTips || visScene.showAllDataTips)
			{ 
				initGGToolTip();
				if (isNaN(ttXoffset)) ttXoffset = _dataTipOffsetX;
				if (isNaN(ttYoffset)) ttYoffset = _dataTipOffsetY;
				ttGG.create(item, dataFields, xPos, yPos, zPos, radius, collisionIndex, shapes, ttXoffset, ttYoffset, true, showGeometry);
			} else {
				// if no tips than just add data info and location info needed for pointers
				ttGG.create(item, dataFields, xPos, yPos, zPos, NaN,collisionIndex, null, NaN, NaN, false);
			}
			
			if (visScene.showAllDataTips)
			{
				ttGG.showToolTip();
			} 
			
			if (mouseClickFunction != null)
				ttGG.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			if (mouseDoubleClickFunction != null)
				ttGG.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			
			if (draggableItems)
			{
				if (!_extendMouseEvents)
					gg.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
				else
					ttGG.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			}
		}
		
		
		
		
		/**
		 * Show the tooltip shape associated to this DataItemLayout. 
		 */
		private function showGeometryTip(extGG:DataItemLayout):void
		{
			if (_showTipGeometry && !_showAllDataItems)
			{
				Geometry(extGG.hitMouseArea).alpha = 1;
				
			}		
		}
		
		/**
		 * Hide the tooltip shape associated to this DataItemLayout. 
		 */
		private function hideGeometryTip(extGG:DataItemLayout):void
		{
			if (_showTipGeometry && !_showAllDataItems)
			{
				Geometry(extGG.hitMouseArea).alpha = 0;
			}
		}
		
		/** @Private
		 * Override the init initGGToolTip in order to avoid the usage of gg also in case
		 * the showdatatips is false. In that case there will only be 1 instance of gg in the 
		 * element, thus improving performances.*/ 
		protected function initGGToolTip():void
		{
			ttGG.toolTipFill = fill;
			ttGG.toolTipStroke = stroke;
			if (visScene.dataTipFunction != null)
				ttGG.dataTipFunction = visScene.dataTipFunction;
			if (visScene.dataTipPrefix!= null)
				ttGG.dataTipPrefix = visScene.dataTipPrefix;
		}
	
		
		/*
		* Interactivity
		*/
		
		public var hitAreaFunction:Function;
		protected function createMouseHitArea(xPos:Number, yPos:Number, size:Number):IGeometry
		{
			if (hitAreaFunction != null)
				return hitAreaFunction(xPos, yPos, size);
			else {
				var geom:CircleRenderer = new CircleRenderer(new Rectangle(xPos-size, yPos-size, size*2, size*2)); 
				geom.fill = fill;
				geom.stroke = stroke;
				
				if (!_showAllDataItems)
					geom.alpha = 0;
				else
					addSVGData(geom.svgData);
				
				return geom;
			}
		}
		
		protected var draggedItem:Object;
		private var draggedItemPreviousTarget:DisplayObjectContainer;
		protected var isDraggingNow:Boolean = false;
		protected var offsetX:Number, offsetY:Number;
		/**
		 * @Private 
		 * Starts item moving and trigger mouse move listener
		 */
		protected function startDragging(e:MouseEvent):void
		{
			var itemX:Number, itemY:Number;
			draggedItem = e.target;
			if (draggedItem is IVisualDataID)
			{
				if (draggedItem is DataItemLayout)
				{
					draggedItem as DataItemLayout;
					isDraggingNow = true;
					draggedItemPreviousTarget = draggedItem.target;
					draggedItem.target = visScene.elementsContainer;
				} 
				
				if (draggedItem is DisplayObject)
				{
					draggedItem as DisplayObject;
					itemX = DisplayObject(draggedItem).x;
					itemY = DisplayObject(draggedItem).y;
				}
				
				offsetX = e.stageX - itemX;
				offsetY = e.stageY - itemY;
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dragDataItem);
				dispatchEvent(new Event("DraggingStarted")); // TODO: create specific event 
			}
		}
		
		/**
		 * @Private 
		 * Move the data item while the mouse moves 
		 */
		protected function dragDataItem(e:MouseEvent):void
		{
			draggedItem.x = e.stageX - offsetX;
			draggedItem.y = e.stageY - offsetY;
			dispatchEvent(new Event("ItemMoving"));
			e.updateAfterEvent();
		}
		
		/**
		 * @Private 
		 * Stop data item moving 
		 */
		private function stopDragging(e:MouseEvent):void
		{
			if (isDraggingNow)
			{
				draggedItem.target = draggedItemPreviousTarget;
				isDraggingNow = false;
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragDataItem)
			dispatchEvent(new Event("DragComplete"));
		}
		
		
		/** @Private 
		 * Custom tooltip variable.*/
		protected var myTT:IToolTip;
		/**
		 * @private 
		 * Show/position tooltip and handle custom mouse over function.*/
		protected function handleRollOver(e:MouseEvent):void 
		{
			var extGG:DataItemLayout = DataItemLayout(e.target);
			
			if (isDraggingNow) return;
			
			if (visScene.showDataTips) {
				
				if (_showAllDataTipsOnRollOver)
				{
					for (var i:uint=0;i<graphicsCollection.items.length;i++)
					{
						if (graphicsCollection.items[i] is DataItemLayout)
						{
							var gg:DataItemLayout = graphicsCollection.items[i] as DataItemLayout;
							
							if (!gg.hitMouseArea) continue;
							
							if (visScene.customTooltTipFunction != null)
							{
								myTT = visScene.customTooltTipFunction(gg.currentItem);
								toolTip = myTT.text;
							} else {
								gg.showToolTip();
								showGeometryTip(gg);
							}
						}
					}
				}
				else
				{
					if (visScene.customTooltTipFunction != null)
					{
						myTT = visScene.customTooltTipFunction(extGG.currentItem);
						toolTip = myTT.text;
					} else {
						extGG.showToolTip();
						showGeometryTip(extGG);
					}
				}
			}
			
			var rollOverE:ElementRollOverEvent = new ElementRollOverEvent(ElementRollOverEvent.ELEMENT_ROLL_OVER);
			
			var tmpDim1:String;
			if (dim1 is Array)
				tmpDim1 = dim1[extGG.collisionTypeIndex];
			else 
				tmpDim1 = String(dim1);
			
			var tmpDim2:String;
			if (dim2 is Array)
				tmpDim2 = dim2[extGG.collisionTypeIndex];
			else 
				tmpDim2 = String(dim2);
			
			var tmpDim3:String;
			if (dim3 is Array)
				tmpDim3 = dim2[extGG.collisionTypeIndex];
			else
				tmpDim3 = String(dim3);
			
			
			rollOverE.dim1 = tmpDim1;
			rollOverE.dim2 = tmpDim2;
			rollOverE.dim3 = tmpDim3
			rollOverE.scale1 = scale1;
			rollOverE.scale2 = scale2;
			
			if (extGG.currentItem)
			{
				rollOverE.pos1 = extGG.currentItem[tmpDim1];
				rollOverE.pos2 = extGG.currentItem[tmpDim2];
				rollOverE.pos3 = extGG.currentItem[tmpDim3];
			}
			
			visScene.dispatchEvent(rollOverE);
			
			if (_mouseOverFunction != null)
				_mouseOverFunction(extGG);
		}
		
		/**
		 * @private 
		 * Destroy/hide tooltip 
		 * 
		 */
		protected function handleRollOut(e:MouseEvent):void
		{ 
			var extGG:DataItemLayout = 	DataItemLayout(e.target);
			
			
			
			if (visScene.showDataTips)
			{
				extGG.hideToolTip();
				hideGeometryTip(extGG);
				
				if (_showAllDataTipsOnRollOver)
				{
					for (var i:uint=0;i<graphicsCollection.items.length;i++)
					{
						if (graphicsCollection.items[i] is DataItemLayout)
						{
							var gg:DataItemLayout = graphicsCollection.items[i] as DataItemLayout;
							
							if (!gg.hitMouseArea) continue;
							
							gg.hideToolTip();
							hideGeometryTip(gg);
							
						}
					}
				}
				
				myTT = null;
				toolTip = null;
			}
			
			if (isDraggingNow) return;
			
			var rolloutE:ElementRollOutEvent = new ElementRollOutEvent(ElementRollOutEvent.ELEMENT_ROLL_OUT);
			
			visScene.dispatchEvent(rolloutE);
			
			if (_mouseOutFunction != null)
				_mouseOutFunction(extGG);
		}
		
		/** Implement function to manage mouse click events.*/
		public function onMouseClick(e:MouseEvent):void
		{
			var target:DataItemLayout;
			
			if (isDraggingNow) return;
			
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
			
			if (isDraggingNow) return;
			
			if (e.target is DataItemLayout)
			{
				target = DataItemLayout(e.target);
				
				_mouseDoubleClickFunction(target);
			}
		}
		
		
		
		/*
		* SVG Stuff
		*/
		
		protected function addSVGData(data:Object):void
		{
			svgMultiColorData.push({
				data: data,
				rgbFill: rgbFill,
				fillAlpha: alphaFill,
				rgbStroke: rgbStroke,
				strokeAlpha: alphaStroke
			});
		}
		
		protected function createSVG():void
		{
			_svgData = "";
			for each(var svg:Object in svgMultiColorData)
			{
				_svgData += 
					'\n<g style="' +
					'fill:' + ((svg.rgbFill) ? '#' + svg.rgbFill:'none') + 
					';fill-opacity:' + svg.fillAlpha + ';' + 
					'stroke:' + ((svg.rgbStroke) ? '#' + svg.rgbStroke:'none') + 
					';stroke-opacity:' + svg.strokeAlpha + ';">' + 
					svg.data + 
					'\n</g>';
			} 
		}
		
		protected var svgMultiColorData:Array = [];
		protected var _svgData:String;
		/** This property contains all the svg data representing this element visualization. 
		 * The svg data is collected from all renderers that implement the IExportableSVG interface.
		 * These renderers can either be texts, basic graphics, images or more complex renderers that 
		 * are external to the library (although the external renderers, for ex. mxml components,
		 *  have to manually implement this interface).*/  
		public function set svgData(val:String):void
		{
			_svgData = val;
		}
		public function get svgData():String
		{
			return _svgData;
		}
		
		
	}
}
