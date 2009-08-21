package birdeye.vis.guides.axis
{
	import birdeye.vis.elements.events.ElementRollOutEvent;
	import birdeye.vis.elements.events.ElementRollOverEvent;
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.guides.IAxis;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.PolarCoordinateTransform;
	
	import com.degrafa.GeometryComposition;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polyline;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	/**
	 * This is an axis which accepts a category scale and another scale.</br>
	 * For each category in the category scale the subscale will be used to draw an axis at the specified</br>
	 * angle of the categoryScale.
	 */
	public class MultiAxis extends GeometryComposition implements IAxis
	{
		
		public function MultiAxis()
		{
			super();

			stroke = new SolidStroke(0x000000, 1, 1);
			fill = new SolidFill(0x000000, 1);
		}
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#position
		 */
		public function get position():String
		{
			return "elements";
		}
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#targets
		 */
		public function get targets():Array
		{
			return this.graphicsTarget;
		}
		
		public function set targets(t:Array):void
		{
			this.graphicsTarget = t;
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
			return Axis.VERTICAL_CENTER;	
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
		
		/**
		 * @see birdeye.vis.interfaces.guides.IAxis#maxLabelSize
		 */
		public function get maxLabelSize():Number { return NaN; } 
		
		/** 
		 * @see birdeye.vis.interfaces.guides.IAxis#removeAllElements 
		 */
		public function clearAll():void
		{
			this.geometry = [];
			this.geometryCollection.items = [];

			invalidated = true;
		}
		 
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
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#drawGuide
		 */
		public function drawGuide(bounds:Rectangle):void
		{
			//if (invalidated)
			//{
			if (_subScale && _subScale.completeDataValues && _subScale.completeDataValues.length > 0)
			{
				clearAll();
				
				stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
				fill = new SolidFill(colorFill, alphaFill);
				
				invalidated = false;
				var line:Line;
				
				var categories:Array = _subScale.completeDataValues;
				var nbrCategories:int = _subScale.completeDataValues.length;
				
				var web:Array = new Array();
				
				for (var i:int = 0; i<nbrCategories; i++)
				{
					var subSc:IScale = _subScale.subScales[categories[i]];
	
					var angle:int = _subScale.getPosition(categories[i]);
					var endPosition:Point = PolarCoordinateTransform.getXY(angle,_size,coordinates.origin);
					
					// draw a line a bit shorter to allow the label of the axis to be seen
					// TODO set the label a bit further instead of shortening the line?
					var endLinePosition:Point = PolarCoordinateTransform.getXY(angle,_size-5,coordinates.origin);
	 				line = new Line(coordinates.origin.x, coordinates.origin.y, endLinePosition.x, endLinePosition.y);
					line.stroke = new SolidStroke(0x000000, 1,1);					
					this.geometryCollection.addItem(line);
					
					if (showPointer)
					{
						_pointer = new Line();
						_pointer.stroke = new SolidStroke(colorPointer, 1, weightPointer);
						_pointer.visible = false;
						this.geometryCollection.addItem(_pointer);
					}
										
					
					// add 0,20,40,...,100
					for (var j:int=0;j<(subSc.completeDataValues.length - 1);j++)
					{
						var dataLabel:Object = subSc.completeDataValues[j];
						var pos:Number = subSc.getPosition(dataLabel);
		
		 				var labelPosition:Point = PolarCoordinateTransform.getXY(angle,pos,coordinates.origin);
		 				
		 				if (!web[j])
		 				{
		 					web[j] = "";
		 				}
		 				web[j] += String(labelPosition.x) + "," + String(labelPosition.y) + " ";

						label = new RasterText();
						if (dataLabel is Number)
	 					{
	 						label.text = String(Math.round(dataLabel as Number));
	 					}
	 					else
	 					{
	 						label.text = String(dataLabel);
	 					}
	 					
		 				label.fontFamily = fontLabel;
		 				label.fontSize = sizeLabel;
		 				label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.stroke = stroke;
						label.fill = new SolidFill(colorLabel);
		
						label.x = labelPosition.x - (label.textWidth + 4)/2;
						label.y = labelPosition.y;
	
						this.geometryCollection.addItem(label);
						
	 				} 
	 				
	 				// add axis' name					
					var label:RasterText = new RasterText();
					label.text = String(categories[i]);
 					label.fontFamily = fontLabel;
 					label.fontSize = sizeLabel;
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(colorLabel);

					label.x = endPosition.x - (label.textWidth + 4)/2;
					label.y = endPosition.y - (label.fontSize + 4)/2;
					
					this.geometryCollection.addItem(label);
				}
				
				// draw lines between axes (the web)
				var webStroke:SolidStroke = new SolidStroke(0x000000, .15);
				for (i=0;i<web.length;i++)
				{
						var poly:Polyline = new Polyline();
						poly.autoClose = true;
						poly.data = web[i];
						poly.stroke = webStroke;
						poly.fill = new SolidFill(0x000000, 0);					
						this.geometryCollection.addItem(poly);
				}
			//}
			}
		}
		
		private function onElementRollOver(e:ElementRollOverEvent):void
		{
			
			if (_pointer)
			{
				
				var angle:Number = subScale.getPosition(e.pos1);
				var pos2:Number = subScale.subScales[e.pos1].getPosition(e.pos2);
				var pos2pt:Point = PolarCoordinateTransform.getXY(angle,pos2, coordinates.origin);

				
				var posMinPt:Point =  PolarCoordinateTransform.getXY((angle+90)%360,_sizePointer/2,pos2pt);
				var posMaxPt:Point = PolarCoordinateTransform.getXY((angle-90)%360,_sizePointer/2, pos2pt);
				
				_pointer.x = posMinPt.x;
				_pointer.y = posMinPt.y;
				_pointer.x1 = posMaxPt.x;
				_pointer.y1 = posMaxPt.y;
				
				_pointer.visible = true;
			}
		}
		
		private function onElementRollOut(e:ElementRollOutEvent):void
		{
			_pointer.visible = false;
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

		private var _colorFill:uint;
		/** Set the fill color to be used for the axis.*/
		public function set colorFill(val:uint):void
		{
			_colorFill = val;
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
		}
		public function get colorLabel():uint
		{
			return _colorLabel;
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
		
				/**
		 * @inheritDoc
		 */
		public function clone(cloneObj:Object=null):*
		{
			//  TODO implement
			if (cloneObj && cloneObj is Axis)
			{
				var axisClone:Axis = cloneObj as Axis;
				
				axisClone.alphaFill = this.alphaFill;
				axisClone.alphaStroke = this.alphaStroke;
				axisClone.alphaGradients = this.alphaGradients;
				axisClone.colorFill = this.colorFill;
				axisClone.colorGradients = this.colorGradients;
				axisClone.colorLabel = this.colorLabel;
				//axisClone.colorPointer = this.colorPointer;
				axisClone.colorStroke = this.colorStroke;
				axisClone.fontLabel = this.fontLabel;
				axisClone.placement = this.placement;
				//axisClone.pointer = this.pointer;
				//axisClone.rotateLabels = this._rotateLabels;
				//axisClone.scale = this.scale;
				//axisClone.scaleInterval = this.scaleInterval;
				//axisClone.showAxis = this.showAxis;
				//axisClone.showLabels = this.showLabels;
				//axisClone.showPointer = this.showPointer;
				axisClone.sizeLabel = this.sizeLabel;
				//axisClone.sizePointer = this.sizePointer;
				//axisClone.weightPointer = this.weightPointer;
				axisClone.weightStroke = this.weightStroke;
				
				return axisClone;
			}
			else if (!cloneObj)
			{
				cloneObj = new Axis();
				return clone(cloneObj);
			}
			
			return null;
		}
	}
}