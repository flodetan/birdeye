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

package org.un.cava.birdeye.qavis.microcharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicText;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
		
	import mx.formatters.NumberFormatter;

	[Inspectable("orientation")]
	/**
	* This component is used to create BulletGraph charts.
	 * It follows very closely the real Bullet Graph specification, for example:
	 * <p>- both horizontal and vertical orientations are available; </p>
	 * <p>- if the minimum qualitative range is not 0, than the value property is represented by a dot and not a bar;</p> 
	 * <p>- it also accepts negative qualitative ranges, negative values and negative targets. </p>
	 * <p>- default colors are close to the ones defined in the specifications, but optionally they can all be changed.</p>
	 * <p></p>
	 * <p>It automatically adjusts itself accordingly.
	 * Resizing keeps the right proportions of all of its parts.
	 * The basic syntax to use and create a BulletGraph chart with mxml is:</p>
	 * <p>&lt;BulletGraph orientation="vertical"
	 * 	qualitativeRanges="{[0, 20, 40, 60, 80]}"
	 * 	target="50" value="45" title="Vertical BG"
	 * 	snapInterval="5" width="30" height="200"/></p>
	 * 
	 * <p>The qualitativeRanges property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML. 
	 * It's also possible to change colors by defining the following properties:</p>
	 * <p>- colors: array that sets the color for each range. </p>
	 * <p>- valueColor: to modify the value (bar or dot) color;</p>
	 * <p>- targetColor: to modify the target color;</p>
	 * 
	 * <p>As indicated in the BulletGraph specification, the Bullet graph shound not have more than 5 quality ranges, 
	 * and for this reason, the default colors array only contains a maximum of 5 colors. In case you need to create a bullet graph 
	 * with more ranges, than you should provide an array of colors for them and not use the default ones.
	*/
	public class MicroBulletGraph extends Surface
	{
		private var tot:Number = NaN;
		private const VERTICAL:String = "vertical";
		private const HORIZONTAL:String = "horizontal";
		
		private var geomGroup:GeometryGroup;
		private var valueShape:IGeometry;
		private var targetShape:RegularRectangle;
		private var black:SolidFill = new SolidFill("0x000000",1);
		
		private var snapLine:Line;
		private var snapLineColor:int = 0x9A9A98;
		private var snapTextFontSize:int = 8;

		private var _orientation:String;
		private var _qualitativeRanges:Array = new Array();
		private var _value:Number;
		private var _target:Number;
		private var _snapInterval:Number = NaN;
		private var _formatter:NumberFormatter = new NumberFormatter();
		private var _colors:Array = ["0x777777","0x999999","0xbbbbbb","0xcccccc","0xdddddd"];
		
		private var prevStartX:Number, prevStartY:Number, min:Number, max:Number, space:Number = 0, maxSize:Number = 10;

		/**
		* Set the orientation parameter of the BulletGraph. It can be either 'horizontal' or 'vertical'.
		*/
		public function get orientation() : String {
			return _orientation;
		}
		
		[Inspectable(enumeration="horizontal,vertical")]
		public function set orientation(val:String) : void {
			_orientation = val;
			invalidateProperties();
			invalidateDisplayList();	
		}
				
		/**
		* Set the value parameter of the BulletGraph
		*/
		public function get value() : Number {
			return _value;
		}
		
		public function set value(val:Number) : void {
			_value = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		/**
		* Set the target parameter of the BulletGraph
		*/
		public function get target() : Number {
			return _target;
		}
		
		public function set target(val:Number) : void {
			_target = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		public function set qualitativeRanges(val:Array):void
		{
			_qualitativeRanges = val;
			tot = NaN;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the qualityRanges parameter of the BulletGraph
		*/
		public function get qualitativeRanges():Array
		{
			return _qualitativeRanges;
		}
		
		/**
		* Set the snapInterval of the meter of the BulletGraph
		*/
		public function get snapInterval():int 
		{
			return _snapInterval;
		}
		
		public function set snapInterval(val:int):void 
		{
			_snapInterval = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the formatter parameter of the BulletGraph to establish the text format of the value shown in the graph meter
		*/
		public function get formatter(): NumberFormatter 
		{
			return _formatter;
		}
		
		public function set formatter(val:NumberFormatter):void 
		{
			_formatter = val;
			invalidateProperties();
			invalidateDisplayList();
		}
				
		/**
		* @private
		 * Used to recalculate min, max and tot each time properties have to ba revalidated 
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (orientation == null || orientation.length == 0)
				orientation = HORIZONTAL;
		}
		
		/**
		* @private
		 * Sort the qualitativeRanges array and calculate min, max and tot  
		*/
		private function sortMinMaxTot():void
		{
			switch (orientation)
			{
				case VERTICAL:
					_qualitativeRanges.sort(Array.DESCENDING | Array.NUMERIC);
					_colors.sort(Array.DESCENDING | Array.NUMERIC);
					break;
				case HORIZONTAL:
					_qualitativeRanges.sort(Array.NUMERIC);
					_colors.sort(Array.NUMERIC);
			}

			prevStartX = 0;
			min = max = _qualitativeRanges[0];

			tot = 0;
			for (var i:Number = 0; i < _qualitativeRanges.length; i++)
			{
				if (min > _qualitativeRanges[i])
					min = _qualitativeRanges[i];
				if (max < _qualitativeRanges[i])
					max = _qualitativeRanges[i];
			}
			tot = Math.abs(max - min);
		}

		/**
		* @private
		 * Calculate the startX position for the current qualitativeRanges value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function startX(indexIteration:Number):Number
		{
			var _startX:Number; 
			if (orientation == VERTICAL)
				_startX = 0;
			else 
				_startX = (indexIteration==0)? 0 : prevStartX;

			return _startX;
		}
		
		/**
		* @private
		 * Calculate the width size for the current qualitativeRanges value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function offsetSizeX(indexIteration:Number):Number
		{
			var _offSizeX:Number;

			if (orientation == VERTICAL)
				_offSizeX = width;
			else
			{
				if (indexIteration == 0)
				{
					_offSizeX = 0;
					prevStartX = 0;
				}
				else
					_offSizeX = (_qualitativeRanges[indexIteration]-_qualitativeRanges[indexIteration-1])* width / tot;

				prevStartX +=  _offSizeX;
			}

			return _offSizeX;
		}
		
		/**
		* @private
		 * Calculate the startY position for the current qualitativeRanges value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function startY(indexIteration:Number):Number
		{
			var _startY:Number; 
			if (orientation == HORIZONTAL)
				_startY = 0;
			else 
				_startY = (indexIteration==0)? 0 : prevStartY;
			return _startY;
		}
		
		/**
		* @private
		 * Calculate the height size for the current qualitativeRanges value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function offsetSizeY(indexIteration:Number):Number
		{
			var _offSizeY:Number;
			if (orientation == HORIZONTAL)
				_offSizeY = height;
			else
			{
				if (indexIteration == 0)
				{
					_offSizeY = 0;
					prevStartY = 0;
				}
				else
					_offSizeY = (_qualitativeRanges[indexIteration-1]-_qualitativeRanges[indexIteration])* height / tot;

				prevStartY +=  _offSizeY;
			}
			return _offSizeY;
		}
		
		/**
		* @private
		 * Calculate the x position for the actual value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function xValue():Number 
		{
			var x:Number = 0;
			if (orientation == HORIZONTAL)
			{
				if (min != 0)
					if (value > max)
						x = width;
					else 
						x = Math.abs((_value-min)/tot) * width ;

				if (value < min)
					x = -xSizeShapeValue();
			} else
				x = width * 2/5;
			
			return x;
		}
		
		/**
		* @private
		 * Calculate the y position for the actual value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function yValue():Number 
		{
			var y:Number = height - Math.abs((_value-min)/tot) * height;
			if (orientation == VERTICAL)
			{
				if (value > max)
					if (min != 0)
						y = -ySizeShapeValue();
					else
						y = 0;
					
				if (value < min)
					y = height;
			} else
				y = height * 2.5/6;
			return y;
		}

		/**
		* @private
		 * Calculate the width size for the actual value shape. It takes into account
		 * whether the orientation is horizontal or vertical and whether the min is != 0 or not,
		 * which changes the shape format and therefore its size 
		*/
		private function xSizeShapeValue():Number
		{
			var xSizeValue:Number;
			
			if (orientation == HORIZONTAL)
			{
				xSizeValue = height/6;
				if (min == 0)
					if (value > max)
						xSizeValue = width;
					else
						xSizeValue =  Math.abs(_value/tot) * width;
				
				if (value < min)
					xSizeValue = Math.min(height/6, maxSize);
			} else
				xSizeValue = width/6;

			return xSizeValue;
		}
		
		/**
		* @private
		 * Calculate the height size for the actual value shape. It takes into account
		 * whether the orientation is horizontal or vertical and whether the min is != 0 or not,
		 * which changes the shape format and therefore its size 
		*/
		private function ySizeShapeValue():Number
		{
			var ySizeValue:Number;
			
			if (orientation == VERTICAL)
			{
				if (min == 0)
					if (value > max)
						ySizeValue = height;
					else
						ySizeValue =  Math.abs(_value/tot) * height;
				else
					ySizeValue = Math.min(width/6, maxSize);
				
				if (value < min)
					ySizeValue = Math.min(width/6, maxSize);
			} else
				ySizeValue = height/6;
			
			return ySizeValue ;
		} 

		/**
		* @private
		 * Calculate the x position for the target value rectangle. It takes into account
		 * whether the orientation is horizontal or vertical 
		*/
		private function xTarget():Number 
		{
			var x:Number = 0;
			
			if (orientation == HORIZONTAL)
			{
				if (_target > max)
					x = width;
				else 
					x = Math.abs((_target-min)/tot) * width ;

				if (_target < min)
					x = -xSizeRectTarget();
			} else
				x = width/6;
				
			return x;
		}

		/**
		* @private
		 * Calculate the y position for the target value rectangle. It takes into account
		 * whether the orientation is horizontal or vertical 
		*/
		private function yTarget():Number 
		{
			var y:Number = 0;
			if (orientation == VERTICAL)
			{
				if (target > max)
					y = -ySizeRectTarget();
				else
					y = height - Math.abs((_target-min)/tot) * height;
						
				if (target < min)
					y = height;
			} else
				y = height/6;
				
			return y;
		}

		/**
		* @private
		 * Calculate the width size for the target value rectangle. It takes into account
		 * whether the orientation is horizontal or vertical 
		*/
		private function xSizeRectTarget():Number
		{
			var xSizeTarget:Number;
			if (orientation == HORIZONTAL)
				xSizeTarget = Math.min(height/6, maxSize);
			else
				xSizeTarget = width * 4/6;
			return xSizeTarget;
		}
		
		/**
		* @private
		 * Calculate the width size for the target value rectangle. It takes into account
		 * whether the orientation is horizontal or vertical 
		*/
		private function ySizeRectTarget():Number
		{
			var ySizeTarget:Number;
			if (orientation == VERTICAL)
				ySizeTarget = Math.min(width /6, maxSize);
			else
				ySizeTarget = height * 4/6;
				
			return ySizeTarget;
		}
		
		/**
		* @private  
		* Set automatic colors to the bars, in case these are not provided. 
		*/
		private function useColor(indexIteration:Number):int
		{
			return (indexIteration == 0) ? 0 : _colors[indexIteration-1];
		}
		
		public function MicroBulletGraph()
		{
			super();
		}
		
		/**
		* @private 
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			sortMinMaxTot();
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i) is GeometryGroup)
						removeChildAt(i);

			geomGroup = new GeometryGroup();
			geomGroup.target = this;
			createBulletGraph();
//			createSnap();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		/**
		* @private 
		 * Create the qualitativeRanges and value/target shapes
		*/
		private function createBulletGraph():void
		{
			// create value shape (as per the specs: (min == 0) ? rectangle : circle)
			if (min == 0)
				valueShape = new RegularRectangle(space+xValue(), space+yValue(), xSizeShapeValue(), ySizeShapeValue());
			else
				if (orientation == VERTICAL)
					valueShape = new Circle(space+width/2, space+yValue(), Math.min(xSizeShapeValue(), maxSize));
				else
					valueShape = new Circle(space+xValue(), space+height/2, Math.min(ySizeShapeValue(), maxSize)); 
			
			// create target shape
			if (orientation == VERTICAL)
				targetShape = new RegularRectangle(space+xTarget(), space+yTarget(), xSizeRectTarget(), ySizeRectTarget());
			else
				targetShape = new RegularRectangle(space+xTarget(), space+yTarget(), xSizeRectTarget(), ySizeRectTarget());
				
			valueShape.fill = black;
			targetShape.fill = black;
			
			// create qualitativeRanges
			for (var i:Number=0; i<_qualitativeRanges.length; i++)
			{
				var qualitativeShape:RegularRectangle = 
					new RegularRectangle(space+startX(i), space+startY(i), offsetSizeX(i), offsetSizeY(i));
				qualitativeShape.fill = new SolidFill(useColor(i));
				geomGroup.geometryCollection.addItem(qualitativeShape);
			}
			geomGroup.geometryCollection.addItem(valueShape);
			geomGroup.geometryCollection.addItem(targetShape);
		}
		
		/**
		* @private 
		 * Create the snap shapes and texts
		*/
		private function createSnap():void
		{
			if (orientation == VERTICAL)
			{
				if (max != min)
				{
					if (isNaN(_snapInterval))
						snapInterval = (max-min)/5;

					for (var snapValue:Number = min; snapValue <= max; snapValue+=snapInterval) 
					{
						var yCoord:Number = height - ((snapValue-min)/(max-min) * height);
						var long:int = 5;
						var thick:int = 1;
						// create snap line
						snapLine = new Line(space-long, space+yCoord, space, space+yCoord);
						snapLine.stroke = new SolidStroke(snapLineColor,1,1);
						
						// create snap text (formatted number)
						var snapText:GraphicText = new GraphicText();
						snapText.text = formatter.format(Math.round(snapValue));
						snapText.visible = true;
						snapText.autoSize = "left";
						snapText.autoSizeField = true;
						snapText.selectable = false;
						snapText.fontSize = snapTextFontSize;
						snapText.color = snapLineColor;
						snapText.y = space + yCoord-snapText.height/3;
						snapText.x = space - snapText.width;

						snapText.fill = black;
						snapText.stroke = new SolidStroke(0x000000);

						geomGroup.geometryCollection.addItem(snapLine);
						geomGroup.geometryCollection.addItem(snapText);
					}
				}
			} else {/* 
				if (max != min)
				{
					//draw meter and clear labels
					snapContainer.removeAllChildren();
					snapContainer.x = 0; 
					snapContainer.y = height;
					snapContainer.width = unscaledWidth;
					snapContainer.height = unscaledHeight;
		
					if (isNaN(_snapInterval))
					{
						snapInterval = (max-min)/5;
					}
		
					for (var snapValue:Number = min; snapValue <= max; snapValue+=snapInterval) {
						var xCoord:Number = startX + (snapValue-min)/(max-min) * totalGraphicWidth;
						long = 5;
						thick = 1;
						gH.beginFill(tickLabelColor);
						gH.drawRect(xCoord, height, thick, long);
						gH.endFill(); 
						
						var lbl:UITextField = new UITextField();
						lbl.text = formatter.format(Math.round(snapValue));
						lbl.height = 15;
						lbl.autoSize = TextFieldAutoSize.LEFT;
						lbl.selectable = false;
						
						snapContainer.addChild(lbl);
						lbl.styleName = tickStyle;
						lbl.x = xCoord - lbl.textWidth /2;
						lbl.y = 2;
					}
					_titleLabel.y = (height - _titleLabel.height)/2;
				} */
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			if (orientation == VERTICAL)
			{
				minWidth = 10;
				minHeight = 50;
			} else
			{
				minWidth = 50;
				minHeight = 10;
			}
		}
	}
}