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
 
package birdeye.vis.scales
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import birdeye.vis.interfaces.IAxisUI;
	
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

	public class BaseAxis extends UIComponent implements IAxisUI
	{
		protected var surf:Surface;
		protected var gg:GeometryGroup;

		/** Set the axis line color.*/
		protected var stroke:IGraphicsStroke;

		/** Set the axis fill color.*/
		protected var fill:IGraphicsFill;
		
		/** Scale type: Linear */
		public static const LINEAR:String = "linear";
		/** Scale type: Percent */
		public static const PERCENT:String = "percent";
		/** Scale type: CONSTANT */
		public static const CONSTANT:String = "constant";
		/** Scale type: Numeric (general numeric scale that could be used for custom numeric axes)*/
		public static const NUMERIC:String = "linear";
		/** Scale type: Category */
		public static const CATEGORY:String = "category";
		/** Scale type: Logaritmic */
		public static const LOG:String = "log";
		/** Scale type: DateTime */
		public static const DATE_TIME:String = "date_time";
		
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

		private var _colorFill:uint;
		/** Set the fill color to be used for the axis.*/
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
		/** Set the stroke color to be used for the axis.*/
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
		/** Set the stroke weigth  to be used for the axis.*/
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

		protected var _sizeLabel:uint;
		/** Set the font size of the label to be used for the axis.*/
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
		/** Set the label color to be used for the axis.*/
		public function set colorLabel(val:uint):void
		{
			_colorLabel = val;
			invalidateDisplayList();
		}
		public function get colorLabel():uint
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
		
		protected var _sizePointer:uint;
		/** Set the pointer size used in the axis.*/
		public function set sizePointer(val:uint):void
		{
			_sizePointer = val;
			invalidateDisplayList();
		}
		public function get sizePointer():uint
		{
			return _sizePointer;
		}

		protected var _weightPointer:uint;
		/** Set the pointer weight used in the axis.*/
		public function set weightPointer(val:uint):void
		{
			_weightPointer = val;
			invalidateDisplayList();
		}
		public function get weightPointer():uint
		{
			return _weightPointer;
		}

		protected var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/** Position the pointer to the specified x position. Used by a cartesian series
		 * if the current axis is x.*/
		public function set pointerX(val:Number):void
		{
			if (pointer)
				pointer.x = pointer.x1 = val;
		}
		
		/** Position the pointer to the specified y position. Used by a cartesian series
		 * if the current axis is vertical.*/
		public function set pointerY(val:Number):void
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
		
		protected var _scaleType:String = LINEAR;
		/** Set the scale type, LINEAR by default. */
		public function set scaleType(val:String):void
		{
			_scaleType = val;
			invalidateProperties()
			invalidateSize();
			invalidateDisplayList();
		}
		public function get scaleType():String
		{
			return _scaleType;
		}
		
		protected var _interval:Number = NaN;
		/** Set the interval between axis values. */
		public function set interval(val:Number):void
		{
			_interval = val;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get interval():Number
		{
			return _interval;
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

		/** Diagonal placement for the axis (for ex. used for the z axis). */
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
		
		// UIComponent flow
		
		/** @Private */
		override protected function createChildren():void
		{
			if (showAxis)
			{
				super.createChildren();
				surf = new Surface();
				gg = new GeometryGroup();
				gg.target = surf;
				surf.graphicsCollection.addItem(gg);
				addChild(surf);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (stylesChanged)
			{
				// Redraw gradient fill only if style changed.
				_colorGradients = getStyle("gradientColors");
				_alphaGradients = getStyle("gradientAlphas");
				
				_colorFill = getStyle("fillColor");
				_alphaFill = getStyle("fillAlpha");
				
				_colorStroke = getStyle("strokeColor");
				_alphaStroke = getStyle("strokeAlpha");
				_weightStroke = getStyle("strokeWeight");

				_fontLabel = getStyle("labelFont");
				_colorLabel = getStyle("labelColor");
				_sizeLabel = getStyle("labelSize");

				_fontLabel = getStyle("labelFont");
				_colorLabel = getStyle("labelColor");
				_sizeLabel = getStyle("labelSize");

				_colorPointer = getStyle("pointerColor");
				_sizePointer = getStyle("pointerSize");
				_weightPointer = getStyle("pointerWeight");

				stylesChanged = false;
			}

			if (colorStroke)
				stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
		}
		
		// other methods
		
		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("BaseAxis");
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

				this.pointerColor = 0x0000FF;
				this.pointerSize = 10;
				this.pointerWeight = 3;

				this.stylesChanged = true;
			} 
			StyleManager.setStyleDeclaration("BaseAxis", selector, true);
		}
		
		/** @Private
		 * Given a data value, it returns the position of the data value on the current axis.
		 * Override this method depending on the axis scaling (linear, log, category, etc).
		 */
		public function getPosition(dataValue:*):*
		{
			// to be overridden by implementing axis class (Category, Numeric, DateTime..)
			return null;
		}
		
		public function removeAllElements():void
		{
			if (gg)
			{
				gg.geometry = [];
				gg.geometryCollection.items = [];
			}
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
	}
}