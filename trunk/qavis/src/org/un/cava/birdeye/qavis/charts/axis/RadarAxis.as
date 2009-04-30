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
 
package org.un.cava.birdeye.qavis.charts.axis
{
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
	
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import org.un.cava.birdeye.qavis.charts.polarCharts.PolarChart;

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

	public class RadarAxis extends Surface
	{
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
		
		private var _polarChart:PolarChart;
		public function set polarChart(val:PolarChart):void
		{
			_polarChart = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		private var _angleCategory:String;
		public function set angleCategory(val:String):void
		{
			_angleCategory = val;
			var tmpAngleAxis:CategoryAngleAxis = new CategoryAngleAxis();
			tmpAngleAxis.categoryField = val;
			angleAxis = tmpAngleAxis;
		}
		public function get angleCategory():String
		{
			return _angleCategory;
		}
		
		private var _radiusSize:Number;
		public function set radiusSize(val:Number):void
		{
			_radiusSize = val;
			invalidateDisplayList();
		}
		public function get radiusSize():Number
		{
			return _radiusSize;
		}
		
		private var _angleAxis:CategoryAngleAxis;
		public function set angleAxis(val:CategoryAngleAxis):void
		{
			_angleAxis = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get angleAxis():CategoryAngleAxis
		{
			return _angleAxis;
		}
		
		private var _radiusAxes:Array;
		public function set radiusAxes(val:Array):void
		{
			_radiusAxes = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusAxes():Array
		{
			return _radiusAxes;
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
		public function RadarAxis()
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

				fontLabel = getStyle("labelFont");
				colorLabel = getStyle("labelColor");
				sizeLabel = getStyle("labelSize");

				stylesChanged = false;
			}

			stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
			fill = new SolidFill(colorFill, alphaFill);

 			if (angleAxis && radiusAxes && _radiusSize)
				drawAxes();
		}
		
		// other methods
		
		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("RadarAxis");
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
			StyleManager.setStyleDeclaration("RadarAxis", selector, true);
		}
		
 		public function feedRadiusAxes(elementsMinMax:Array):void
		{
			if (_angleCategory && _angleAxis && _angleAxis.elements)
			{
				radiusAxes = [];
				for each (var element:String in angleAxis.elements)
				{
					radiusAxes[element] = new NumericAxis();
					NumericAxis(radiusAxes[element]).showAxis = false;
					
					if (_function != null)
						NumericAxis(radiusAxes[element]).f = _function;
					
					// if all values are positive, than we fix the base at zero, otherwise
					// the columns with minium values won't show up in the chart
					NumericAxis(radiusAxes[element]).min = Math.min(0, elementsMinMax[element].min);
					NumericAxis(radiusAxes[element]).max = elementsMinMax[element].max;
					NumericAxis(radiusAxes[element]).size = radiusSize;
					NumericAxis(radiusAxes[element]).interval = (NumericAxis(radiusAxes[element]).max 
																- NumericAxis(radiusAxes[element]).min)/5;
				}
			}
		} 
		
		private function drawAxes():void
		{
			gg.geometryCollection.items = [];
			gg.geometry = [];
			
			var line:Line;
			
			var ele:Array = angleAxis.elements;
			var interval:int = angleAxis.interval;
			var nEle:int = angleAxis.elements.length;

			for (var i:int = 0; i<nEle; i++)
			{
				NumericAxis(radiusAxes[ele[i]]).size = radiusSize;
				var angle:int = angleAxis.getPosition(ele[i]);
				var endPosition:Point = PolarCoordinateTransform.getXY(angle,radiusSize,_polarChart.origin);
				
 				line = new Line(_polarChart.origin.x, _polarChart.origin.y, endPosition.x, endPosition.y);
				line.stroke = stroke;
				gg.geometryCollection.addItem(line);

 				var radiusAxis:NumericAxis = NumericAxis(radiusAxes[ele[i]]);
 				var rad:Number;
 				
 				for (var snap:int = radiusAxis.min; snap<radiusAxis.max; snap += radiusAxis.interval)
 				{
 					rad = radiusAxis.getPosition(snap);
	 				var labelPosition:Point = PolarCoordinateTransform.getXY(angle,rad,_polarChart.origin);
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
		}
	}
}