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
 
package birdeye.vis.guides.legend
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	
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

	public class LegendItem extends Surface
	{
		private var _itemRenderer:Class;
		/** Set the itemRenderer for this LegendItem.*/
		public function set itemRenderer(val:Class):void
		{
			_itemRenderer = val;
			invalidateDisplayList();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		private var _text:String;
		/** Set the text for this LegendItem.*/
		public function set text(val:String):void
		{
			_text = val;
			invalidateDisplayList();
		}
		public function get text():String
		{
			return _text;
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

		protected var _colors:Array;

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

		protected var _sizeRenderer:uint = 10;
		/** Set the _sizeRenderer to be used for the data items.*/
		public function set sizeRenderer(val:uint):void
		{
			_sizeRenderer = val;
			invalidateDisplayList();
		}
		public function get sizeRenderer():uint
		{
			return _sizeRenderer;
		}

		private var gg:GeometryGroup;
		public function LegendItem()
		{
			gg = new GeometryGroup();
			gg.target = this;
			this.graphicsCollection.addItem(gg);
		}
		
		override protected function measure():void
		{
			super.measure();
			var w:Number = 0, h:Number = 0;
			if (_text)
			{
				label = new RasterTextPlus();
				label.text = _text;
				label.fontFamily = fontLabel;
				label.fontSize = sizeLabel;
				w = label.displayObject.width + 5 + _sizeRenderer;
				h = Math.max(label.displayObject.height, _sizeRenderer) ;
			}

			minWidth = w;
			minHeight = h;
		}
		
		private var fill:IGraphicsFill = new SolidFill(0x888888,0);
		private var stroke:IGraphicsStroke = new SolidStroke(0x888888,1,1);
		private var geometry:IGeometry;
		private var label:RasterTextPlus;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (stylesChanged)
			{
				// Redraw gradient fill only if style changed.
				_colors = getStyle("colors");

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

			if (_itemRenderer && _sizeRenderer>0)
			{
	 			var bounds:Rectangle = new Rectangle(0, 0, _sizeRenderer, _sizeRenderer);
				geometry = new itemRenderer(bounds);
				geometry.fill = fill;
				geometry.stroke = stroke;
				gg.geometryCollection.addItem(geometry);
			}

			if (_text)
			{
				label = new RasterTextPlus();
				label.text = _text;
				label.fontFamily = fontLabel;
				label.fontSize = sizeLabel;
				label.fill = new SolidFill(colorLabel);
				label.stroke = new SolidStroke(colorStroke);
 				
				label.x = _sizeRenderer + 5;
				
 				gg.geometryCollection.addItem(label);
			}
			width = Rectangle(this.getBounds(this)).width;
			height = Rectangle(this.getBounds(this)).height;
		}

		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration= StyleManager.getStyleDeclaration("LegendItem");
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
			StyleManager.setStyleDeclaration("LegendItem", selector, true);
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
	}
}