package birdeye.vis.guides.axis
{
	import birdeye.vis.elements.events.ElementRollOutEvent;
	import birdeye.vis.elements.events.ElementRollOverEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.guides.IAxis;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.PolarCoordinateTransform;
	
	import com.degrafa.GeometryComposition;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import org.greenthreads.IGuideThread;
	import org.greenthreads.ThreadProcessor;

	/**
	 * This is an axis which accepts a category scale and another scale.</br>
	 * For each category in the category scale the subscale will be used to draw an axis at the specified</br>
	 * angle of the categoryScale.
	 */
	public class MultiAxis extends Surface implements IAxis, IGuideThread
	{
		protected var gg:GeometryComposition;
		
		/** Set the axis line color.*/
		protected var stroke:IGraphicsStroke;

		/** Set the axis fill color.*/
		protected var fill:IGraphicsFill;

		
		public function MultiAxis()
		{
			super();

			styleName = "MultiAxis";
			stroke = new SolidStroke(0x000000, 1, 1);
			fill = new SolidFill(0x000000, 1);
			
			stdLabel.fontFamily = fontLabel;
			stdLabel.fontSize = sizeLabel;
			stdLabel.autoSize = TextFieldAutoSize.LEFT;
			stdLabel.autoSizeField = true;
			
			stdCircle.stroke = new SolidStroke(0x000000, .15);
			stdCircle.fill = null;
			
			stdPoly.stroke = new SolidStroke(0x000000, .15);
			stdPoly.fill = null;

		}
		
		public function get parentContainer():Object
		{
			return parent as Object;
		}
		
		
		public function get priority():int
		{
			return ThreadProcessor.PRIORITY_GUIDE;
		}
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#position
		 */
		public function get position():String
		{
			return "elements";
		}
		
		private var _gridType:String = "web";
		public static const GRID_WEB:String = "web";
		public static const GRID_CIRCLE:String = "circle";
		
		[Inspectable(enumeration="web,circle", defaultValue="web")]
		public function set gridType(gt:String):void
		{
			_gridType = gt;	
		}
		
		public function get gridType():String
		{
			return _gridType;
		}
		
		private var _subScale:ISubScale;
		private var _subScaleInterface:IScale;
		private var _subScalesArray:Array;
		
		/**
		 */
		public function set subScale(val:ISubScale):void
		{
			_subScale = val;

		}
		
		public function get subScale():ISubScale
		{
			return _subScale;	
		}
		
		
		/** 
		 * Impossible to indicate. A MultiAxis is always placed in the center.
		 * @see birdeye.vis.interfaces.guides.IAxis#placement
		 */
		public function set placement(val:String):void {}
		
		public function get placement():String
		{
			return "";	
		}

		/**
		 * @see birdeye.vis.interfaces.guides.IAxis#size
		 */
		private var _size:Number; 
		 
		public function set size(val:Number):void 
		{
			_size = val;
		}
		public function get size():Number { 
			return _size; 
		}
		
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

		/**
		 * @see birdeye.vis.interfaces.guides.IAxis#maxLabelSize
		 */
		public function get maxLabelSize():Number { return NaN; } 
		
		/** 
		 * @see birdeye.vis.interfaces.guides.IAxis#removeAllElements 
		 */
		public function clearAll():void
		{
			this.graphics.clear();
		}
		 
		private var _coordinates:ICoordinates; 
		public function set coordinates(val:ICoordinates):void
		{	
			_coordinates = val;
		}
		
		public function get coordinates():ICoordinates
		{
			return _coordinates;
		}
		
		private var _bounds:Rectangle;
		
		public function set bounds(b:Rectangle):void
		{
			_bounds = b;	
		}
		
		public function get bounds():Rectangle
		{
			return this._bounds;	
		}
		
		
		protected var _labelFormatterFunction:Function;
		/**
		 * Set the function that is used to format the label on the axis
		 */
		public function set labelFormatterFunction(f:Function):void
		{
			_labelFormatterFunction = f;
		}
		
		public function get labelFormatterFunction():Function
		{
			return _labelFormatterFunction;
		}
		
		
		private var _drawingData:Array;
		
		public function preDraw():Boolean
		{	
			index = 0;
			subIndex = 0;
			
			if (isNaN(_size) || size <= 0 || !coordinates || !coordinates.origin) return false;
			
			if (_subScale && _subScale.completeDataValues && _subScale.completeDataValues.length > 0)
			{			
				// there is a subscale
				// create two data arrays
				// one to describe all the scales
				// one to describe the data lines
				_drawingData = new Array();
				web =  new Array();
				var categories:Array = _subScale.completeDataValues;
				var nbrCategories:int = _subScale.completeDataValues.length;
				
				
				for (var i:int = 0; i<nbrCategories; i++)
				{
					var subSc:IScale = _subScale.subScales[categories[i]];
					
					var angle:int = _subScale.getPosition(categories[i]);
					var endPosition:Point = PolarCoordinateTransform.getXY(angle,_size,coordinates.origin);
					var endLinePosition:Point = PolarCoordinateTransform.getXY(angle,_size-5,coordinates.origin);
					
					var data:Object = new Object();
										
					data.end = endLinePosition;
					data.label = categories[i];
					
					var innerCategories:Array = new Array();
					
					for (var j:int=0;j<(subSc.completeDataValues.length - 1);j++)
					{
						var dataLabel:Object = subSc.completeDataValues[j];
						var pos:Number = subSc.getPosition(dataLabel);
						
						var labelPosition:Point = PolarCoordinateTransform.getXY(angle,pos,coordinates.origin);
						
						var innerData:Object = new Object();
						
						innerData.radius = pos;
						innerData.point = labelPosition;
						innerData.label = dataLabel;
						
						innerCategories.push(innerData);
					}
					
					data.categories = innerCategories;
					
					_drawingData.push(data);
				}
				
				return true;
			}
			
			return false;
		}
		
		private var index:int = 0;
		private var subIndex:int = 0;
		
		private var stdLine:Line = new Line();
		private var stdLabel:RasterText = new RasterText();
		private var stdCircle:Circle = new Circle();
		private var stdPoly:Polygon = new Polygon();
		
		
		protected var web:Array = new Array();
		public function drawDataItem():Boolean
		{
			if (index < _drawingData.length)
			{
				var data:Object = _drawingData[index];
				var categories:Array= data.categories;
				
				if (subIndex == 0)
				{
					// draw the axis line
					stdLine.x = coordinates.origin.x;
					stdLine.y = coordinates.origin.y;
					stdLine.x1 = data.end.x;
					stdLine.y1 = data.end.y;
					stdLine.stroke = new SolidStroke(colorStroke, 1,1);
					
					stdLine.draw(this.graphics, null);
					
					// add axis' name					
					stdLabel.text = data.label;
					stdLabel.x = data.end.x - (stdLabel.textWidth + 4)/2;
					stdLabel.y = data.end.y - (stdLabel.fontSize + 4)/2;
					
					stdLabel.draw(this.graphics, null);
					
					subIndex++;
				}
				else if ((subIndex - 1) < categories.length )
				{
					
					
					var d:Object = categories[(subIndex - 1)];
					// draw the web or circle
					if (_gridType == MultiAxis.GRID_WEB)
					{
						if (!web[(subIndex - 1)])
						{
							web[(subIndex - 1)] = "";
						}
						web[(subIndex - 1)] += String(d.point.x) + "," + String(d.point.y) + " ";			
					}
					else if (_gridType == MultiAxis.GRID_CIRCLE && index == 0)
					{
						stdCircle.radius = d.radius;
						stdCircle.centerX = coordinates.origin.x;
						stdCircle.centerY = coordinates.origin.y;
						
						stdCircle.draw(this.graphics, null);
					}		
					
					
					if (index == 0 || !subScale.shareSubScale)
					{
						// draw the labels on the axis
						var dataLabel:Object = d.label;
						
						stdLabel.text = _labelFormatterFunction != null ? _labelFormatterFunction.call(null, dataLabel) : String(dataLabel);
						
						stdLabel.x = d.point.x - (stdLabel.textWidth + 4);
						stdLabel.y = d.point.y - stdLabel.height / 2;
						
						stdLabel.draw(this.graphics, null);
					}
					
					
					subIndex++;
				}
				else
				{
					index++;
					subIndex = 0;
				}
				
				
				return true;
			}
			
			return false;
		}
		
		public function endDraw() : void
		{
			// draw lines between axes (the web)
			if (_gridType == MultiAxis.GRID_WEB)
			{
				for (var i:int=0;i<web.length;i++)
				{
					stdPoly.data = web[i];
					stdPoly.draw(this.graphics, null);
				}
			}
		}
		
		private var _alphaFill:Number;
		/** Set the fill alpha.*/
		public function set alphaFill(val:Number):void
		{
			_alphaFill = val;
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
		}
		public function get alphaStroke():Number
		{
			return _alphaStroke;
		}

		private var _colorFill:Number;
		/** Set the fill color to be used for the axis.*/
		public function set colorFill(val:Number):void
		{
			_colorFill = val;
		}
		public function get colorFill():Number
		{
			return _colorFill;
		}

		protected var _colorStroke:Number;
		/** Set the stroke color to be used for the axis.*/
		public function set colorStroke(val:Number):void
		{
			_colorStroke = val;
		}
		public function get colorStroke():Number
		{
			return _colorStroke;
		}
		
		protected var _weightStroke:uint;
		/** Set the stroke weigth  to be used for the axis.*/
		public function set weightStroke(val:uint):void
		{
			_weightStroke = val;
		}
		public function get weightStroke():uint
		{
			return _weightStroke;
		}
		
		protected var _colorPointer:uint = 0xFF0000;
		/** Set the pointer color used in the axis.*/
		public function set colorPointer(val:uint):void
		{
			_colorPointer = val;
		}
		public function get colorPointer():uint
		{
			return _colorPointer;
		}
		
		protected var _sizePointer:Number = 12;
		/** Set the pointer size used in the axis.*/
		public function set sizePointer(val:Number):void
		{
			_sizePointer = val;
		}
		public function get sizePointer():Number
		{
			return _sizePointer;
		}

		protected var _weightPointer:Number = 3;
		/** Set the pointer weight used in the axis.*/
		public function set weightPointer(val:Number):void
		{
			_weightPointer = val;
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

		protected var _pointer:Line;

		protected var _colorGradients:Array;
		/** Set the gradientColors to be used for the the axis.*/
		public function set colorGradients(val:Array):void
		{
			_colorGradients = val;
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
			stdLabel.fontFamily = val;
		}
		public function get fontLabel():String
		{
			return _fontLabel;
		}

		protected var _sizeLabel:Number;
		/** Set the font size of the label to be used for the axis.*/
		public function set sizeLabel(val:Number):void
		{
			_sizeLabel = val;
			stdLabel.fontSize = sizeLabel;
		}
		public function get sizeLabel():Number
		{
			return _sizeLabel;
		}

		protected var _colorLabel:Number;
		/** Set the label color to be used for the axis.*/
		public function set colorLabel(val:Number):void
		{
			_colorLabel = val;
			stdLabel.fill = new SolidFill(val);
		}
		public function get colorLabel():Number
		{
			return _colorLabel;
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
		
		private var stylesChanged:Boolean = true;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("MultiAxis");
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
			StyleManager.setStyleDeclaration("MultiAxis", selector, true);
		}

	}
}