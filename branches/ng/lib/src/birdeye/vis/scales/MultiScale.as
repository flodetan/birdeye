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
	import birdeye.vis.interfaces.ICoordinates;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
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

	public class MultiScale extends Surface
	{
		protected var invalidated:Boolean = true;

		/** Set the axis line color.*/
		protected var stroke:IGraphicsStroke;

		/** Set the axis fill color.*/
		protected var fill:IGraphicsFill;
		
		private var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		private var _chart:ICoordinates;
		public function set chart(val:ICoordinates):void
		{
			_chart = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		private var _dim1:String;
		public function set dim1(val:String):void
		{
			_dim1 = val;
			var tmpScale1:CategoryAngle = new CategoryAngle();
			tmpScale1.categoryField = val;
			scale1 = tmpScale1;
		}
		public function get dim1():String
		{
			return _dim1;
		}
		
		private var _scalesSize:Number;
		public function set scalesSize(val:Number):void
		{
			_scalesSize = val;
			invalidateDisplayList();
		}
		public function get scalesSize():Number
		{
			return _scalesSize;
		}
		
		private var _scale1:CategoryAngle;
		public function set scale1(val:CategoryAngle):void
		{
			_scale1 = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scale1():CategoryAngle
		{
			return _scale1;
		}
		
		private var _scales:Array;
		public function set scales(val:Array):void
		{
			_scales = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get scales():Array
		{
			return _scales;
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

		// UIComponent methods
		
		private var gg:GeometryGroup;
		public function MultiScale()
		{
			super();
			gg = new GeometryGroup();
			gg.target = this;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			graphicsCollection.addItem(gg);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
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

				stylesChanged = false;
			}

			stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
			fill = new SolidFill(colorFill, alphaFill);
		}
		
		// other methods
		
		private var prevWidth:Number = NaN, prevHeight:Number = NaN;
		public function draw():void
		{
			var w:Number = unscaledWidth, h:Number = unscaledHeight;
			if (prevWidth != w || prevHeight != h)
			{
				prevWidth = w;
				prevHeight = h;
				invalidated = true;
			}
			
 			if (scale1 && scales && _scalesSize)
				drawAxes();
		}
		
		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("MultiScale");
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
			StyleManager.setStyleDeclaration("MultiScale", selector, true);
		}
		
 		public function feedRadiusAxes(elementsMinMax:Array):void
		{
			if (_dim1 && _scale1 && _scale1.dataProvider)
			{
				scales = [];
				for each (var category:String in scale1.dataProvider)
				{
					scales[category] = new Numeric();
					// TODO Numeric(scales[category]).showAxis = false;
					
					if (_function != null)
						Numeric(scales[category]).f = _function;
					
					// if all values are positive, than we fix the base at zero, otherwise
					// the columns with minium values won't show up in the chart
					Numeric(scales[category]).min = Math.min(0, elementsMinMax[category].min);
					Numeric(scales[category]).max = elementsMinMax[category].max;
					Numeric(scales[category]).size = scalesSize;
					Numeric(scales[category]).dataInterval = (Numeric(scales[category]).max 
																- Numeric(scales[category]).min)/5;
				}
			}
		} 
		
		private var ggIndex:uint;
		private function drawAxes():void
		{
			if (invalidated)
			{
trace(getTimer(), "start multi scale");
				removeAllElements();
				
				invalidated = false;
				var line:Line;
				
				var catElements:Array = scale1.dataProvider;
				var interval:int = scale1.scaleInterval;
				var nEle:int = scale1.dataProvider.length;
				ggIndex = 0;
				
				for (var i:int = 0; i<nEle; i++)
				{
	 				if (graphicsCollection.items && graphicsCollection.items.length>ggIndex)
						gg = graphicsCollection.items[ggIndex];
					else
					{
						gg = new GeometryGroup();
						graphicsCollection.addItem(gg);
					}
					gg.target = this;
					ggIndex++;

					Numeric(scales[catElements[i]]).size = scalesSize;
					var angle:int = scale1.getPosition(catElements[i]);
					var endPosition:Point = PolarCoordinateTransform.getXY(angle,scalesSize,_chart.origin);
					
	 				line = new Line(_chart.origin.x, _chart.origin.y, endPosition.x, endPosition.y);
					line.stroke = stroke;
					gg.geometryCollection.addItem(line);
	
	 				var radiusAxis:Numeric = Numeric(scales[catElements[i]]);
	 				var rad:Number;
	 				
	 				for (var snap:int = radiusAxis.min; snap<radiusAxis.max; snap += radiusAxis.dataInterval)
	 				{
		 				if (graphicsCollection.items && graphicsCollection.items.length>ggIndex)
							gg = graphicsCollection.items[ggIndex];
						else
						{
							gg = new GeometryGroup();
							graphicsCollection.addItem(gg);
						}
						gg.target = this;
						ggIndex++;

	 					rad = radiusAxis.getPosition(snap);
		 				var labelPosition:Point = PolarCoordinateTransform.getXY(angle,rad,_chart.origin);
						var label:RasterTextPlus = new RasterTextPlus();
						label.text = String(snap);
		 				label.fontFamily = fontLabel;
		 				label.fontSize = sizeLabel;
		 				label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.fill = fill;
		
						label.x = labelPosition.x - label.displayObject.width/2;
						label.y = labelPosition.y;
	
						gg.geometryCollection.addItem(label);
	 				} 
				}
trace(getTimer(), "end multi scale");
			}
		}
		
		public function removeAllElements():void
		{
			if (gg)
			{
				gg.geometry = [];
				gg.geometryCollection.items = [];
			}
			
			if (graphicsCollection.items)
			{
				var nElements:int = graphicsCollection.items.length;
				if (nElements > 0)
				{
					for (var i:int = 0; i<nElements; i++)
					{
						if (graphicsCollection.items[i] is GeometryGroup)
						{
							GeometryGroup(graphicsCollection.items[i]).geometry = []; 
							GeometryGroup(graphicsCollection.items[i]).geometryCollection.items = [];
						}
					}
				} 
			}

			invalidated = true;
		}
	}
}