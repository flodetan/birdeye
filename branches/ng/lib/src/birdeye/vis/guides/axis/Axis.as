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
 
package birdeye.vis.guides.axis
{
	import birdeye.vis.elements.events.ElementRollOutEvent;
	import birdeye.vis.elements.events.ElementRollOverEvent;
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.guides.IAxis;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.Category;
	
	import com.degrafa.GeometryComposition;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.RotateTransform;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
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
	
	
	[Style(name="pointerColor",type="uint",inherit="no")]
	[Style(name="pointerSize",type="uint",inherit="no")]
	[Style(name="pointerWeight",type="uint",inherit="no")]
	public class Axis extends Surface implements IAxis
	{
		private var _scale:IScale;
		
		public var _targets:Array = new Array();
		public var gg:GeometryComposition;
		
		protected var invalidated:Boolean = false;

		/** Set the axis line color.*/
		protected var stroke:IGraphicsStroke;

		/** Set the axis fill color.*/
		protected var fill:IGraphicsFill;

		
		public function Axis()
		{
			styleName = "Axis";
		}

		public function get parentContainer():Object
		{
			return parent as Object;
		}
		
		private var svgText:String;
		private var _svgData:String;
		/** String containing the svg data to be exported.*/ 
		public function set svgData(val:String):void
		{
			_svgData = val;
		}
		public function get svgData():String
		{
			return _svgData;
		}

		private var _data:Object;
		/** Define the data to be passed to the axisRenderer.*/
		public function set data(val:Object):void
		{
			_data = val;
			invalidateDisplayList();
		}
		public function get data():Object
		{
			return _data;
		}
		
		private var _labelRenderer:IFactory;
		/** Set the label renderer following the standard Flex approach. The label renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set labelRenderer(val:IFactory):void
		{
			_labelRenderer= val;
			invalidateDisplayList();
		}
		public function get labelRenderer():IFactory
		{
			return _labelRenderer;
		}

		protected var _labelRendererWidth:uint;
		/** Set the label renderer width to be used for the data items.*/
		public function set labelRendererWidth(val:uint):void
		{
			_labelRendererWidth = val;
			invalidateDisplayList()
		}
		public function get labelRendererWidth():uint
		{
			return _labelRendererWidth;
		}

		protected var _labelRendererHeight:uint;
		/** Set the axis renderer height to be used for the data items.*/
		public function set labelRendererHeight(val:uint):void
		{
			_labelRendererHeight = val;
			invalidateDisplayList();
		}
		public function get labelRendererHeight():uint
		{
			return _labelRendererHeight;
		}

		private var _axisRenderer:IFactory;
		/** Set the axis renderer following the standard Flex approach. The axis renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set axisRenderer(val:IFactory):void
		{
			_axisRenderer= val;
			invalidateDisplayList();
		}
		public function get axisRenderer():IFactory
		{
			return _axisRenderer;
		}
		
		protected var _axisRendererWidth:uint;
		/** Set the axis renderer width to be used for the data items.*/
		public function set axisRendererWidth(val:uint):void
		{
			_axisRendererWidth = val;
			invalidateDisplayList()
		}
		public function get axisRendererWidth():uint
		{
			return _axisRendererWidth;
		}

		protected var _axisRendererHeight:uint;
		/** Set the axis renderer height to be used for the data items.*/
		public function set axisRendererHeight(val:uint):void
		{
			_axisRendererHeight = val;
			invalidateDisplayList();
		}
		public function get axisRendererHeight():uint
		{
			return _axisRendererHeight;
		}

		public function get position():String
		{
			return "sides";
		}
		
		private var _thickAlignment:String = "left";
		
		public function set scale(s:IScale):void
		{
			_scale = s;
			
			if (_scale is Category)
			{
				_thickAlignment = "center";
			}
			else
			{
				_thickAlignment = "left";
			}
		}
		
		private var _padding:Number = 15;
		/** Space left between multiple axes placed in the same location (left, top, bottom...).*/
		public function set padding(val:Number):void
		{
			_padding = val;
			invalidateDisplayList()
		}
		
		public function get scale():IScale
		{
			return _scale;
		}
		
		protected var _size:Number;
		public function set size(val:Number):void
		{
			_size = val;
			switch (placement)
			{
				case HORIZONTAL_CENTER:
				case BOTTOM:
				case TOP:
					width = _size;
					break;
				case VERTICAL_CENTER:
				case RIGHT:
				case LEFT:
				case DIAGONAL:
					height = _size;
					break;
			}

			invalidateDisplayList();

		}
		/** @Private
		 * Get the size of the axis ,i.e. either its width or height depending on the placement selected.
		 */
		public function get size():Number
		{
			if (isNaN(_size) && (width>0 || height>0))
				refreshSize();
			return _size;
		}
		
		protected var _alternateLabels:Number = 0;
		/** Alternate labels positions to prevent overlapping. This sets the pixels distance among labels.
		 * If placement is bottom/top, than the distance is considered vertically, otherwise it will be 
		 * considered horizontally.*/
		public function set alternateLabels(val:Number):void
		{
			_alternateLabels = val;
		}
		
				protected var _rotateLabels:Number = 0;
		/** Set the angle rotation of labels.*/
		public function set rotateLabels(val:Number):void
		{
			_rotateLabels = val;
			invalidateDisplayList();
		}

		protected var _rotateLabelsOn:String = "center";
		/** Set the angle rotation point of labels.*/
		[Inspectable(enumeration="topLeft,centerLeft,bottomLeft,centerTop,center,centerBottom,topRight,centerRight,bottomRight")]
		protected function set rotateLabelsOn(val:String):void
		{
			_rotateLabelsOn = val;
			invalidateDisplayList();
		}
		
				private var _alphaFill:Number;
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
		
		private var _alphaStroke:Number;
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

		private var _colorFill:Number = NaN;
		/** Set the fill color to be used for the axis.*/
		public function set colorFill(val:Number):void
		{
			_colorFill = val;
			invalidateDisplayList();
		}
		public function get colorFill():Number
		{
			return _colorFill;
		}

		protected var _colorStroke:Number = NaN;
		/** Set the stroke color to be used for the axis.*/
		public function set colorStroke(val:Number):void
		{
			_colorStroke = val;
			invalidateDisplayList();
		}
		public function get colorStroke():Number
		{
			return _colorStroke;
		}
		
		protected var _weightStroke:Number = NaN;
		/** Set the stroke weigth  to be used for the axis.*/
		public function set weightStroke(val:Number):void
		{
			_weightStroke = val;
			invalidateDisplayList();
		}
		public function get weightStroke():Number
		{
			return _weightStroke;
		}

		protected var _colorGradients:Array;
		/** Set the gradientColors to be used for the the axis.*/
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
		/** Set the gradient alphas to be used for the the axis.*/
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
		/** Set the font label to be used for the axis.*/
		public function set fontLabel(val:String):void
		{
			_fontLabel = val;
			invalidateDisplayList();
		}
		public function get fontLabel():String
		{
			return _fontLabel;
		}

		protected var _sizeLabel:Number = NaN;
		/** Set the font size of the label to be used for the axis.*/
		public function set sizeLabel(val:Number):void
		{
			_sizeLabel = val;
			invalidateDisplayList();
		}
		public function get sizeLabel():Number
		{
			return _sizeLabel;
		}

		protected var _colorLabel:Number = NaN;
		/** Set the label color to be used for the axis.*/
		public function set colorLabel(val:Number):void
		{
			_colorLabel = val;
			invalidateDisplayList();
		}
		public function get colorLabel():Number
		{
			return _colorLabel;
		}

		protected var _colorPointer:uint;
		/** Set the pointer color used in the axis.*/
		public function set colorPointer(val:uint):void
		{
			_colorPointer = val;
			invalidateDisplayList();
		}
		public function get colorPointer():uint
		{
			return _colorPointer;
		}
		
		protected var _sizePointer:Number = NaN;
		/** Set the pointer size used in the axis.*/
		public function set sizePointer(val:Number):void
		{
			_sizePointer = val;
			invalidateDisplayList();
		}
		public function get sizePointer():Number
		{
			return _sizePointer;
		}

		protected var _weightPointer:Number = NaN;
		/** Set the pointer weight used in the axis.*/
		public function set weightPointer(val:Number):void
		{
			_weightPointer = val;
			invalidateDisplayList();
		}
		public function get weightPointer():Number
		{
			return _weightPointer;
		}
		
		private var _showPointer:Boolean = true;
		/** Show pointer on the axis */
		[Inspectable(enumeration="false,true")]
		public function set showPointer(val:Boolean):void
		{
			_showPointer = val;
		}
		public function get showPointer():Boolean
		{
			return _showPointer;
		}

		/** Position the pointer to the specified x position. Used by a cartesian series
		 * if the current axis is x.*/
		private function set pointerX(val:Number):void
		{
			if (pointer)
				pointer.x = pointer.x1 = val;
		}
		
		/** Position the pointer to the specified y position. Used by a cartesian series
		 * if the current axis is vertical.*/
		private function set pointerY(val:Number):void
		{
			if (pointer) 
				pointer.y = pointer.y1 = val;
		}

		protected var _pointer:Line;
		public function set pointer(val:Line):void
		{
			_pointer = val;
			invalidateDisplayList();
		}
		public function get pointer():Line
		{
			return _pointer;
		}
		
		protected var _scaleInterval:Number = NaN;
		/** Set the scale interval between scale values (pixels, colors..). */
		public function set scaleInterval(val:Number):void
		{
			_scaleInterval = val;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scaleInterval():Number
		{
			return _scaleInterval;
		}

		protected var _showAxis:Boolean = true;
		/** Show the axis layout. */
		[Inspectable(enumeration="true,false")]
		public function set showAxis(val:Boolean):void
		{
			_showAxis = val;
			invalidateDisplayList();
		}
		public function get showAxis():Boolean
		{
			return _showAxis;
		}
		
		public function get targets():Array
		{
			return _targets;
		}
		
		
		public function get maxLabelSize():Number
		{
			if (scale && isNaN(maxLblSize) && placement && size > 0)
				calculateMaxLabelSize();
				
			return maxLblSize;
		}
		
		/** Diagonal placement for the axis (used for the z axis). */
		public static const DIAGONAL:String = "diagonal";
		/** TOP placement for the axis. */
		public static const TOP:String = "top";
		/** BOTTOM placement for the axis. */
		public static const BOTTOM:String = "bottom";
		/** LEFT placement for the axis. */
		public static const LEFT:String = "left";
		/** RIGHT placement for the axis. */
		public static const RIGHT:String = "right";
		/** VERTICAL_CENTER placement for the axis. */
		public static const VERTICAL_CENTER:String = "vertical_center";
		/** HORIZONTAL_CENTER placement for the axis. */
		public static const HORIZONTAL_CENTER:String = "horizontal_center";
		
		private var _placement:String;
		/** Set the placement for this axis. */
		[Inspectable(enumeration="top,bottom,left,right,vertical_center,horizontal_center,diagonal")]
		public function set placement(val:String):void
		{
			_placement = val;
			invalidateProperties()
			invalidateSize();
			invalidateDisplayList();
		}
		public function get placement():String
		{
			return _placement;
		}
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#coordinates
		 */
		private var _coordinates:ICoordinates;
		public function set coordinates(val:ICoordinates):void
		{
			// first remove old event listeners if they exist
			if (_coordinates)
			{
				_coordinates.removeEventListener(ElementRollOutEvent.ELEMENT_ROLL_OUT, onElementRollOut);
				_coordinates.removeEventListener(ElementRollOverEvent.ELEMENT_ROLL_OVER, onElementRollOver);
			}
			
			_coordinates = val;
			
			// add the new event listeners
			if (_coordinates)
			{
				_coordinates.addEventListener(ElementRollOverEvent.ELEMENT_ROLL_OVER, onElementRollOver);
				_coordinates.addEventListener(ElementRollOutEvent.ELEMENT_ROLL_OUT, onElementRollOut);
			}		
		}
		
		public function get coordinates():ICoordinates
		{
			return _coordinates;
		}
		
				/** @Private */
		override protected function createChildren():void
		{
			if (showAxis)
			{
				super.createChildren();
				gg = new GeometryComposition();
				targets.push(this);
				gg.graphicsTarget = targets;
				invalidateDisplayList();
			}
		}

		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if (styleProp == "gradientColors" || styleProp == null)
			{
				if (!colorGradients && getStyle("gradientColors") != this.colorGradients && getStyle("gradientColors") != undefined)
				{
					this.colorGradients = getStyle("gradientColors");
				}
			}
			
			if (styleProp == "gradientAlphas" || styleProp == null)
			{
				if (!alphaGradients && getStyle("gradientAlphas") != this.alphaGradients && getStyle("gradientAlphas") != undefined)
				{
					this.alphaGradients = getStyle("gradientAlphas");
				}
			}

			if (styleProp == "fillColor" || styleProp == null)
			{
				if (isNaN(colorFill) && getStyle("fillColor") != this.colorFill && getStyle("fillColor") != undefined)
				{
					this.colorFill = getStyle("fillColor");
				}
			}
			
			if (styleProp == "fillAlpha" || styleProp == null)
			{
				if (isNaN(alphaFill) && getStyle("fillAlpha") != this.alphaFill && getStyle("fillAlpha") != undefined)
				{
					this.alphaFill = getStyle("fillAlpha");
				}
			}
			
			if (styleProp == "strokeColor" || styleProp == null)
			{
				if (isNaN(colorStroke) && getStyle("strokeColor") != this.colorStroke && getStyle("strokeColor") != undefined)
				{
					this.colorStroke = getStyle("strokeColor");
				}
			}

			if (styleProp == "strokeAlpha" || styleProp == null)
			{
				if (isNaN(alphaStroke) && getStyle("strokeAlpha") != this.alphaStroke && getStyle("strokeAlpha") != undefined)
				{
					this.alphaStroke = getStyle("strokeAlpha");
				}
			}

			if (styleProp == "strokeWeight" || styleProp == null)
			{
				if (isNaN(weightStroke) && getStyle("strokeWeight") != this.weightStroke && getStyle("strokeWeight") != undefined)
				{
					this.weightStroke = getStyle("strokeWeight");
				}
			}
			
			if (styleProp == "labelFont" || styleProp == null)
			{
				if (!fontLabel && getStyle("labelFont") != this.fontLabel && getStyle("labelFont") != undefined)
				{
					this.fontLabel = getStyle("labelFont");
				}
			}
			
			if (styleProp == "labelColor" || styleProp == null)
			{
				if (isNaN(colorLabel) && getStyle("labelColor") != this.colorLabel && getStyle("labelColor") != undefined)
				{
					this.colorLabel = getStyle("labelColor");
				}
			}
			
			if (styleProp == "labelSize" || styleProp == null)
			{
				if (isNaN(sizeLabel) && getStyle("labelSize") != this.sizeLabel && getStyle("labelSize") != undefined)
				{
					this.sizeLabel = getStyle("labelSize");
				}
			}

			if (styleProp == "pointerColor" || styleProp == null)
			{
				if (isNaN(colorPointer) && getStyle("pointerColor") != this.colorPointer && getStyle("pointerColor") != undefined)
				{
					this.colorPointer = getStyle("pointerColor");
				}
			}
			
			if (styleProp == "pointerSize" || styleProp == null)
			{
				if (isNaN(sizePointer) && getStyle("pointerSize") != this.sizePointer && getStyle("pointerSize") != undefined)
				{
					this.sizePointer = getStyle("pointerSize");
				}
			}

			if (styleProp == "pointerWeight" || styleProp == null)
			{
				if (isNaN(weightPointer) && getStyle("pointerWeight") != this.weightPointer && getStyle("pointerWeight") != undefined)
				{
					this.weightPointer = getStyle("pointerWeight");
				}
			}

		}
		
		private var stylesChanged:Boolean = false;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("Axis");
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			selector.defaultFactory = function():void
			{
				this.gradientColors = [0xFF0000, 0x0000FF];
				this.gradientAlphas = [0.5, 0.5];

				this.fillColor = 0x000000;
				this.fillAlpha = 1;

				this.strokeColor = 0x000000;
				this.strokeAlpha = 1;
				this.strokeWeight = 1;

				this.labelFont = "verdana";
				this.labelSize = 8;
				this.labelColor = 0x000000;

				this.pointerColor = 0xff0000;
				this.pointerSize = 10;
				this.pointerWeight = 3;

				this.stylesChanged = true;
			} 
			StyleManager.setStyleDeclaration("Axis", selector, true);
		}
		
		public function clearAll():void
		{
			if (gg)
			{
				gg.geometry = [];
				gg.geometryCollection.items = [];
			}
			
			if (this.graphicsCollection.items)
			{
				var nElements:int = this.graphicsCollection.items.length;
				if (nElements > 0)
				{
					for (var i:int = 0; i<nElements; i++)
					{
						if (this.graphicsCollection.items[i] is GeometryComposition)
						{
							GeometryComposition(this.graphicsCollection.items[i]).geometry = []; 
							GeometryComposition(this.graphicsCollection.items[i]).geometryCollection.items = [];
						}
					}
				} 
			}

			for (i = numChildren - 1; i >= 0; i--) {
				removeChildAt(i);
			}
			invalidated = true;
		}

		private function refreshSize():void
		{
			switch (placement)
			{
				case HORIZONTAL_CENTER:
				case BOTTOM:
				case TOP:
					_size = width;
					break;
				case VERTICAL_CENTER:
				case RIGHT:
				case LEFT:
				case DIAGONAL:
					_size = height;
					break;
			}
		}
		
		private var _showLabels:Boolean = true;
		/** Show labels on the axis */
		[Inspectable(enumeration="false,true")]
		public function set showLabels(val:Boolean):void
		{
			_showLabels = val;
			invalidateDisplayList();
		}
		public function get showLabels():Boolean
		{
			return _showLabels;
		}
		
		protected var _maxLblSize:Number = 0;
		public function set maxLblSize(val:Number):void
		{
			_maxLblSize = val;
		}
		public function get maxLblSize():Number
		{
			return _maxLblSize;
		}

		/** @Private */
		protected function calculateMaxLabelStyled():void
		{
			if (!showAxis)
				maxLblSize = 0;
			// calculate according font size and style
			// consider auto-size and thick size too
		}
		
		override protected function measure():void
		{
			super.measure();
 				
 			if (scale && placement && scale.completeDataValues.length > 0)
				calculateMaxLabelSize();
 		}
		
		private var prevWidth:Number = NaN, prevHeight:Number = NaN;
		private var xMin:Number = NaN, xMax:Number = NaN, yMin:Number = NaN, yMax:Number = NaN, sign:Number;
		public function drawGuide(bounds:Rectangle):void
		{
			var w:Number = unscaledWidth, h:Number = unscaledHeight;
			if (prevWidth != w || prevHeight != h)
			{
				prevWidth = w;
				prevHeight = h;
				invalidated = true;
			}

			if (showAxis && invalidated)
			{
				clearAll();
				svgText = svgData = "";

				drawAxisLine(w,h)
	
				//if (readyForLayout)
				//{
					switch (placement)
					{
						case BOTTOM:
						case HORIZONTAL_CENTER:
							xMin = 0; xMax = w;
							yMin = 0; yMax = 0;
							sign = 1;
							_pointer = new Line(0,0, 0, sizePointer);
							break;
						case TOP:
							xMin = 0; xMax = w;
							yMin = h; yMax = h;
							sign = -1;
							_pointer = new Line(0,h-sizePointer, 0, h);
							break;
						case LEFT:
						case VERTICAL_CENTER:
							xMin = w; xMax = w;
							yMin = 0; yMax = h;
							sign = -1;
							_pointer = new Line(w-sizePointer,h, w, h);
							break;
						case RIGHT:
						case DIAGONAL:							
							xMin = 0; xMax = 0;
							yMin = 0; yMax = h;
							sign = 1;
							_pointer = new Line(0,h, +sizePointer, h);
							break;
					}
					drawAxes(xMin, xMax, yMin, yMax, sign);
					_pointer.stroke = new SolidStroke(colorPointer, 1, weightPointer);
					_pointer.visible = false;

					svgData = '\n<g style="stroke:#000000' + 
						';stroke-width:1;stroke-opacity:1;">\n' +
						svgText + '\n<path d="' + svgData + '"\n/>\n</g>' ;
					gg.geometryCollection.addItem(_pointer);
				//}
			}
		}
		/** @Private
		 * Draw the axis depending on the current unscaled size and its placement
		 */
		protected function drawAxisLine(w:Number, h:Number):void
		{
			var x0:Number, x1:Number, y0:Number, y1:Number;
			
			switch (placement)
			{
				case BOTTOM:
				case HORIZONTAL_CENTER:
					x0 = 0; x1 = w;
					y0 = 0; y1 = 0;
					break;
				case TOP:
					x0 = 0; x1 = w;
					y0 = h; y1 = h;
					break;
				case LEFT:
				case VERTICAL_CENTER:
					x0 = w; x1 = w;
					y0 = 0; y1 = h;
					break;
				case RIGHT:
 				case DIAGONAL:
					x0 = 0; x1 = 0;
					y0 = 0; y1 = h;
					break;
 				case DIAGONAL:
					x0 = 0; x1 = 0;
					y0 = 0; y1 = h;
					break;
			}
			
			var tmpSVG:String = "M" + String(x0) + "," + String(y0) + " " + 
							"L" + String(x1) + "," + String(y1) + " ";

			var line:Path = new Path(tmpSVG);
			svgData += tmpSVG;
			line.stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);

			gg.geometryCollection.addItem(line);

		}
	
		/** @Private
		 * Calculate the maximum label size, necessary to define the needed 
		 * width (for y axes) or height (for x axes) of the CategoryAxis.*/
		protected function calculateMaxLabelSize():void
		{
			var tmp:RasterText = new RasterText();
			tmp.fontFamily = fontLabel;
			tmp.fontSize = sizeLabel;
			tmp.autoSize = TextFieldAutoSize.LEFT;
			tmp.autoSizeField = true;
			
			maxLblSize = 0;
			for (var i:Number = 0;i<scale.completeDataValues.length;i++)
			{
				tmp.text = String(scale.completeDataValues[i]);
				maxLblSize = Math.max(maxLblSize, tmp.textWidth);
			}
			if (showAxis)
			{
					switch (placement)
					{
						case TOP:
						case BOTTOM:
						case HORIZONTAL_CENTER:
							//height = Math.max(5,maxLblSize * Math.sin(-_rotateLabels*Math.PI/180));
							minHeight = _padding + sizeLabel + 10 + maxLblSize * Math.sin(-_rotateLabels*Math.PI/180);
							break;							
						case LEFT:
						case RIGHT:
						case VERTICAL_CENTER:				
							minWidth = _padding + Math.max(5, maxLblSize * Math.cos(_rotateLabels*Math.PI/180));
							break;
					}

				// calculate the maximum label size according to the 
				// styles defined for the axis 
				calculateMaxLabelStyled();
			} 
			else
			{
				maxLblSize = 0;
			}
		}
		
		/** @Private
		 * Override this method to draw the axis depending on its type (linear, category, etc)
		 */
		protected var thickWidth:Number = 5; 
		 
		protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			if (scale && scale.completeDataValues.length > 0 && isNaN(maxLblSize) && placement && size > 0)
				calculateMaxLabelSize();
			
			if (invalidated)
			{	
				if (!axisRenderer)
				{
					drawLabels(xMin, xMax, yMin, yMax, sign);
				} else {
					var axisRnd:DisplayObject = axisRenderer.newInstance();
					if (data && axisRnd is IDataRenderer)
						(axisRnd as IDataRenderer).data = data;
					addChild(axisRnd);

					if (axisRendererWidth > 0)
						DisplayObject(axisRnd).width = axisRendererWidth ;
					else if (parent)
						DisplayObject(axisRnd).width = parent.width;
					if (axisRendererHeight > 0)
						DisplayObject(axisRnd).height = axisRendererHeight;
					else if (parent)
						DisplayObject(axisRnd).height = parent.height;
				}
			}
		}
		
		private function drawLabels(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
trace(getTimer(), "drawing axis");
			invalidated = false;

			var thick:Path;
			var label:RasterText;
			
			// allow category labels to be intervalled, thus avoiding overlapping
			var completeValuesInterval:uint = 1;
			if (scale is IEnumerableScale && scaleInterval>1)
				completeValuesInterval = scaleInterval;
			// vertical orientation
			if (xMin == xMax)
			{
				for (var i:uint = 0; i<scale.completeDataValues.length; i += completeValuesInterval)
				{
					var dataLabel:Object = scale.completeDataValues[i];
					// create thick line
					var yPos:Number = scale.getPosition(dataLabel);
					if (coordinates && coordinates.origin)
					{
						yPos = coordinates.origin.y - yPos;	
					}

					var tmpSVG:String = "M" + String(xMin + thickWidth * sign) + "," + String(yPos) + " " + 
									"L" + String(xMax) + "," + String(yPos) + " ";
		
		 			thick = new Path(tmpSVG);
					svgData += tmpSVG;

					thick.stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
					gg.geometryCollection.addItem(thick);
		
					if (!_labelRenderer)
					{
						// create label 
						label = createLabelText("vertical", String(dataLabel), yPos);
						label.fill = new SolidFill(colorLabel);
						gg.geometryCollection.addItem(label);
					} else {
						var labelRnd:DisplayObject = createLabelRenderer(dataLabel);
						labelRnd.y = yPos - labelRnd.height/2;
						if (placement == LEFT)
							labelRnd.x = width - thickWidth - (labelRnd.width);
						else
							labelRnd.x = thickWidth * sign;
					}
				}
			} else {
			// horizontal orientation
				for (i = 0; i<scale.completeDataValues.length; i += completeValuesInterval)
				{
					dataLabel = scale.completeDataValues[i];
					
					var xPos:Number = scale.getPosition(dataLabel);

					// create thick line
					tmpSVG = "M" + String(xPos) + "," + String(yMin + thickWidth * sign) + " " + 
									"L" + String(xPos) + "," + String(yMax) + " ";
		
		 			thick = new Path(tmpSVG);
					svgData += tmpSVG;
					thick.stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
					gg.geometryCollection.addItem(thick);

					if (!_labelRenderer)
					{
						// create label 
						label = createLabelText("horizontal", String(dataLabel), NaN);
						label.fill = new SolidFill(colorLabel);
						gg.geometryCollection.addItem(label);
					} else {
						labelRnd = createLabelRenderer(dataLabel);
						labelRnd.x = xPos - labelRnd.width/2;
						if (placement == TOP)
							labelRnd.y = height - thickWidth - (labelRnd.height);
						else
							labelRnd.y = thickWidth * sign;
					}
				}
			}
		}
		
		private function createLabelText(direction:String, dataLabel:String, pos:Number):RasterText
		{
			var svgTextY:Number;
			var label:RasterText;
			if (direction == "vertical")
			{
 				label = new RasterText();
 				label.fontFamily = fontLabel;
 				label.fontSize = sizeLabel;
 				//label.visible = true;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.autoSizeField = true;
				label.text = String(dataLabel);
				if (!isNaN(_rotateLabels) && _rotateLabels != 0)
				{
					var rot:RotateTransform = new RotateTransform();
					rot = new RotateTransform();
					switch (placement)
					{
						case RIGHT:
							_rotateLabelsOn = "centerLeft";
							break;
						case LEFT:
							_rotateLabelsOn = "centerRight";
							break;
					}
					rot.registrationPoint = _rotateLabelsOn;
					rot.angle = _rotateLabels;
					label.transform = rot;
				}
				
				svgTextY = pos + label.displayObject.height/2;
				label.y = pos-(label.displayObject.height )/2;
				if (placement == LEFT)
					label.x = width - thickWidth - (label.textWidth + 4);
				else
					label.x = thickWidth * sign;
				
			} else { // horizontal
				// create label 
 				label = new RasterText();
 				label.fontFamily = fontLabel;
 				label.fontSize = sizeLabel;
 				//label.visible = true;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.autoSizeField = true;
				label.text = String(dataLabel);
				label.y = thickWidth;
				svgTextY = thickWidth + label.displayObject.height;

				if (!isNaN(_rotateLabels) && _rotateLabels != 0)
				{
					rot = new RotateTransform();
					switch (placement)
					{
						case TOP:
							_rotateLabelsOn = "centerLeft";
							label.x = scale.getPosition(dataLabel);
							label.y += height*.9; 
							break;
						case BOTTOM:
							_rotateLabelsOn = "topRight";
							label.x = scale.getPosition(dataLabel)-(label.textWidth + 4)*.9; 
							break;
					}
					rot.registrationPoint = _rotateLabelsOn;
					rot.angle = _rotateLabels;
					label.transform = rot;
				} else {
					label.x = scale.getPosition(dataLabel)-(label.textWidth + 4)/2; 
					if (placement == TOP)
					{
						label.y += label.fontSize;
					}
				}
			}
				
			svgText += '\n<text style="font-family: ' + fontLabel + 
							'; font-size: ' + sizeLabel + 
							'; stroke-width: 1; font-weight: 1;"' +
							' x="' + label.x + '" ' + 
							'y="' + svgTextY + '">' + String(dataLabel) +
							'\n</text>';
			return label;
		}
		
		private function createLabelRenderer(dataLabel:Object):DisplayObject
		{
			var lblRenderer:DisplayObject = labelRenderer.newInstance();
			if (lblRenderer is IDataRenderer)
				(lblRenderer as IDataRenderer).data = dataLabel;
			addChild(lblRenderer);
	
			if (sizeLabel> 0)
				DisplayObject(lblRenderer).width = DisplayObject(lblRenderer).height = sizeLabel;
			else {
				if (labelRendererWidth > 0)
					DisplayObject(lblRenderer).width = labelRendererWidth;
	
				if (labelRendererHeight > 0)
					DisplayObject(lblRenderer).height = labelRendererHeight;
			}
			return lblRenderer;
		}
		
		private function onElementRollOver(e:ElementRollOverEvent):void
		{
			if (_pointer)
			{
				var pos:Object;
				if (scale == e.scale1)
				{
					pos = e.pos1;	
				}
				else if (scale == e.scale2)
				{
					pos = e.pos2;
				}
				else if (scale == e.scale3)
				{
					pos = e.pos3;
				}
				else
				{
					return;
				}
					
				switch (placement)
				{
					case Axis.BOTTOM:
					case Axis.HORIZONTAL_CENTER:
					case Axis.TOP:
						pointerX = scale.getPosition(pos);
						_pointer.visible = true;
						break;
					case Axis.LEFT:
					case Axis.VERTICAL_CENTER:
					case Axis.RIGHT:
						var posY:Number = scale.getPosition(pos);
						if (coordinates && coordinates.origin)
						{
							posY = coordinates.origin.y - posY;
						}

						pointerY = posY;
						_pointer.visible = true;
						break;

				}
			}
		}
		
		private function onElementRollOut(e:ElementRollOutEvent):void
		{
			if (_pointer)
			{
				this._pointer.visible = false;
			}
		}
		

	}
}