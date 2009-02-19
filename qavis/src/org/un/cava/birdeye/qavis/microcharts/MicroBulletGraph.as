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
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.ToolTip;
	import mx.core.UITextField;
	import mx.formatters.NumberFormatter;
	import mx.managers.ToolTipManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	[Inspectable("orientation")]
	[Inspectable("noSnap")]
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
	 * 	qualitativeRanges="{[0, 20, 40, 60, 80]}" showDataTips="true"
	 * 	target="50" value="45" title="Vertical BG"
	 * 	snapInterval="5" width="30" height="200"/></p>
	 * 
	 * <p>The qualitativeRanges can accept Array, ArrayCollection, XML, XMLListCollection, etc... 
	 * It's possible to show tooltips and define functions and prefix to customize them. Since each qualitative range has 
	 * a min and max values, the tooltip graphic is relative to the maximum value, therefore appear at the extreme of each 
	 * qualitative range.
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
		
		private var geomGroup:ExtendedGeometryGroup;
		private var valueShape:IGeometry;
		private var targetShape:RegularRectangle;
		private var black:SolidFill = new SolidFill("0x000000",1);

		private var _showDataTips:Boolean = false;
		protected var _dataTipFunction:Function;
		protected var _dataTipPrefix:String;
		private var tip:ToolTip; 

		private var snapLine:Line;
		private var snapLineColor:int = 0x9A9A98;
		private var snapTextFontSize:int = 8;

		private var _orientation:String;
		private var _dataField:String;
		private var _qualitativeRanges:Object = new Object();
		private var _value:Number;
		private var _target:Number;
		private var _snapInterval:Number = NaN;
		private var _colors:Array = ["0x777777","0x999999","0xbbbbbb","0xcccccc","0xdddddd"];
		private var _noSnap:Boolean = false;
		
		private var prevStartX:Number, prevStartY:Number, min:Number, max:Number, _paddingLeft:Number = 0, _paddingTop:Number = 0;
		private var maxSize:Number = 10;
		private var snapColor:int = 0x999999, snapFontSize:int = 8, snapLong:int = 5, snapThick:int = 1;
		private var snapStyle:CSSStyleDeclaration;
		private var _formatter:NumberFormatter = new NumberFormatter();

		private var data:Array;

		/**
		* Indicate the function used to create tooltips. 
		*/
		public function set dataTipFunction(value:Function):void
		{
			_dataTipFunction = value;
		}

		/**
		* Indicate the prefix for the tooltip. 
		*/
		public function set dataTipPrefix(value:String):void
		{
			_dataTipPrefix = value;
		}

		/**
		* Indicate the data field to be used to feed the chart. 
		*/
		[Inspectable(enumeration="true,false")]
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
			invalidateDisplayList();
		}
		
		/**
		* Indicate the function used to create tooltips. 
		*/
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}

		public function set paddingLeft(val:Number):void
		{
			_paddingLeft = val;
			invalidateDisplayList();
		}
		
		/**
		* Set a space to the left of the chart to better arrange it, if needed.
		*/
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}

		public function set paddingTop(val:Number):void
		{
			_paddingTop = val;
			invalidateDisplayList();
		}
		
		/**
		* Set a space from the top of the chart to better arrange it, if needed.
		*/
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		
		/**
		* Set the orientation parameter of the BulletGraph. It can be either 'horizontal' or 'vertical'.
		*/
		public function get orientation() : String {
			return _orientation;
		}
		
		[Inspectable(enumeration="horizontal,vertical")]
		public function set orientation(val:String) : void {
			_orientation = val;
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
			invalidateDisplayList();
		}

		public function set qualitativeRanges(value:Object):void
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
				this._qualitativeRanges = new XMLListCollection(list.children());
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            this._qualitativeRanges = ICollectionView(value);
	        }else if(value is Object)
			{
				// convert to an array containing this one item
				this._qualitativeRanges = new ArrayCollection( [value] );
	  		}
	  		else
	  		{
	  			this._qualitativeRanges = new ArrayCollection();
	  		}
			invalidateDisplayList();
		}
		
		/**
		* Set the qualityRanges parameter of the BulletGraph
		*/
		public function get qualitativeRanges():Object
		{
			return _qualitativeRanges;
		}
		
		/**
		* Indicate the data field to be used to feed the chart. 
		*/
		public function set dataField(value:String):void
		{
			_dataField = value;
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
		
		[Inspectable(enumeration="true,false")]
		public function set noSnap(val:Boolean):void
		{
			_noSnap = val;
			invalidateDisplayList();
		}
		
		/**
		 * If true, than the snap is not created, recommended for repeted microcharts rendering.
		 */
		public function get noSnap():Boolean
		{
			return _noSnap;
		}

		/**
		* @private
		* 
		*/
		private function feedDataArray():void
		{
			data = new Array();
			var cursor:IViewCursor = _qualitativeRanges.createCursor();
			var i:int=0;
			
			while(!cursor.afterLast)
			{
				if (_dataField == null)
					data[i] = Number(cursor.current);
				else 
					data[i] = cursor.current[_dataField];
			    i++;
			    cursor.moveNext();      
			}
		}

		/**
		* @private
		 * load values into data, sort the qualitativeRanges array depending on the orientation 
		 * and calculate min, max and tot. 
		*/
		private function feedDataSortMinMaxTot():void
		{
			data = new Array();
			var cursor:IViewCursor = _qualitativeRanges.createCursor();
			var i:int=0;
			
			prevStartX = 0;
			min = max = Number((_dataField != null) ? cursor.current[_dataField] : cursor.current); 

			tot = 0;

			while(!cursor.afterLast)
			{
				if (_dataField == null)
					data[i] = Number(cursor.current);
				else 
					data[i] = cursor.current[_dataField];

				if (min > data[i])
					min = data[i];
				if (max < data[i])
					max = data[i];

			    i++;
			    cursor.moveNext();      
			}

			tot = Math.abs(max - min);

			switch (orientation)
			{
				case VERTICAL:
					data.sort(Array.DESCENDING | Array.NUMERIC);
					_colors.sort(Array.DESCENDING | Array.NUMERIC);
					break;
				case HORIZONTAL:
					data.sort(Array.NUMERIC);
					_colors.sort(Array.NUMERIC);
			}
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
				_offSizeX = unscaledWidth;
			else
			{
				if (indexIteration == 0)
				{
					_offSizeX = 0;
					prevStartX = 0;
				}
				else
					_offSizeX = (data[indexIteration]-data[indexIteration-1])* unscaledWidth / tot;

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
				_offSizeY = unscaledHeight;
			else
			{
				if (indexIteration == 0)
				{
					_offSizeY = 0;
					prevStartY = 0;
				}
				else
					_offSizeY = (data[indexIteration-1]-data[indexIteration])* unscaledHeight / tot;

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
						x = unscaledWidth;
					else 
						x = Math.abs((_value-min)/tot) * unscaledWidth ;

				if (value < min)
					x = -xSizeShapeValue();
			} else
				x = unscaledWidth * 2/5;
			
			return x;
		}
		
		/**
		* @private
		 * Calculate the y position for the actual value. It takes into account
		 * whether the orientation is horizontal or vertical   
		*/
		private function yValue():Number 
		{
			var y:Number = unscaledHeight - Math.abs((_value-min)/tot) * unscaledHeight;
			if (orientation == VERTICAL)
			{
				if (value > max)
					if (min != 0)
						y = -ySizeShapeValue();
					else
						y = 0;
					
				if (value < min)
					y = unscaledHeight;
			} else
				y = unscaledHeight * 2.5/6;
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
				xSizeValue = unscaledHeight/6;
				if (min == 0)
					if (value > max)
						xSizeValue = unscaledWidth;
					else
						xSizeValue =  Math.abs(_value/tot) * unscaledWidth;
				
				if (value < min)
					xSizeValue = Math.min(unscaledHeight/6, maxSize);
			} else
				xSizeValue = unscaledWidth/6;

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
						ySizeValue = unscaledHeight;
					else
						ySizeValue =  Math.abs(_value/tot) * unscaledHeight;
				else
					ySizeValue = Math.min(unscaledWidth/6, maxSize);
				
				if (value < min)
					ySizeValue = Math.min(unscaledWidth/6, maxSize);
			} else
				ySizeValue = unscaledHeight/6;
			
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
					x = unscaledWidth;
				else 
					x = Math.abs((_target-min)/tot) * unscaledWidth ;

				if (_target < min)
					x = -xSizeRectTarget();
			} else
				x = unscaledWidth/6;
				
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
					y = unscaledHeight - Math.abs((_target-min)/tot) * unscaledHeight;
						
				if (target < min)
					y = unscaledHeight;
			} else
				y = unscaledHeight/6;
				
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
				xSizeTarget = Math.min(unscaledHeight/6, maxSize);
			else
				xSizeTarget = unscaledWidth * 4/6;
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
				ySizeTarget = Math.min(unscaledWidth /6, maxSize);
			else
				ySizeTarget = unscaledHeight * 4/6;
				
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
		 * Used to recalculate min, max and tot each time properties have to ba revalidated 
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			tot = NaN;
			if (!noSnap)
			{
		        snapStyle = new CSSStyleDeclaration('snapStyle');
		        snapStyle.setStyle('color', snapColor);
		        snapStyle.setStyle('fontSize', snapFontSize);
		        StyleManager.setStyleDeclaration(".snapStyle", snapStyle, true);
			}
	
			if (orientation == null || orientation.length == 0)
				orientation = HORIZONTAL;
		}
		
		/**
		* @private 
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			feedDataSortMinMaxTot();
			for(var i:int=this.numChildren-1; i>=0; i--)
				removeChildAt(i);

			geomGroup = new ExtendedGeometryGroup();
			geomGroup.target = this;

			if (!noSnap)
				createSnap();
			createBulletGraph();
		}
		
		/**
		* @private 
		 * Create the snap shapes and texts
		*/
		private function createSnap():void
		{
			var snapText:UITextField = new UITextField();
			if (orientation == VERTICAL)
			{
				if (max != min)
				{
					if (isNaN(_snapInterval))
						snapInterval = (max-min)/5;
						
					// calculate the maxSnapWidth to arrange the graph accordignly
					for (var snapValue:Number = min; snapValue <= max; snapValue+=snapInterval) 
					{
						var yCoord:Number = unscaledHeight - ((snapValue-min)/(max-min) * unscaledHeight);

						// create snap text (formatted number)
/* 						
 						snapText = new RasterText();
						snapText.text = formatter.format(Math.round(snapValue));
 						snapText.visible = true;
						snapText.autoSize = TextFieldAutoSize.LEFT;
						snapText.autoSizeField = true;
						snapText.fontSize = snapFontSize;
						snapText.color = snapLineColor;
						snapText.y = paddingTop + yCoord-snapText.height/3;
						snapText.x = paddingLeft - snapText.width; 
						snapText.fill = black;
						snapText.draw(this.graphics, null);
						geomGroup.geometryCollection.addItem(snapText);
*/

						// create snap line
 						snapLine = new Line(_paddingLeft - snapLong, _paddingTop + yCoord, _paddingLeft, _paddingTop + yCoord);
						snapLine.stroke = new SolidStroke(snapLineColor,1,1);
						geomGroup.geometryCollection.addItem(snapLine);

						// create snap text
						snapText = new UITextField();
						snapText.text = formatter.format(Math.round(snapValue));
						snapText.autoSize = TextFieldAutoSize.LEFT;
						snapText.selectable = false;
						snapText.y = yCoord-snapText.height/3;
						snapText.x = _paddingLeft - snapText.width;
						snapText.styleName = snapStyle;

						this.addChild(snapText);
					}
				}
			} else {
				if (max != min)
				{
					if (isNaN(_snapInterval))
					{
						snapInterval = (max-min)/5;
					}

					for (snapValue = min; snapValue <= max; snapValue+=snapInterval) {
						var xCoord:Number = (snapValue-min)/(max-min) * unscaledWidth;

						// create snap line
 						snapLine = new Line(_paddingLeft + xCoord, _paddingTop + unscaledHeight, _paddingLeft + xCoord, _paddingTop + unscaledHeight + snapLong);
						snapLine.stroke = new SolidStroke(snapLineColor,1,1);
						geomGroup.geometryCollection.addItem(snapLine);

						// create snap text
						snapText = new UITextField();
						snapText.text = formatter.format(Math.round(snapValue));
						snapText.autoSize = TextFieldAutoSize.LEFT;
						snapText.selectable = false;
						snapText.y = _paddingTop + unscaledHeight + snapLong;
						snapText.x = _paddingLeft + xCoord - 5;
						snapText.styleName = snapStyle;

						this.addChild(snapText);
					}
				}
			}
		}

		/**
		* @private 
		 * Create the qualitativeRanges and value/target shapes
		*/
		private function createBulletGraph():void
		{
			// create value shape (as per the specs: (min == 0) ? rectangle : circle)
			var valueTipX:Number, valueTipY:Number;
			if (min == 0)
			{
				valueTipX = _paddingLeft+xValue() + xSizeShapeValue()/2;
				valueTipY = paddingTop+yValue() + ySizeShapeValue()/2;
				valueShape = new RegularRectangle(_paddingLeft+xValue(), _paddingTop+yValue(), xSizeShapeValue(), ySizeShapeValue());
			}
			else
			{
				if (orientation == VERTICAL)
				{
					valueTipX = _paddingLeft+unscaledWidth/2;
					valueTipY = _paddingTop+yValue();
					valueShape = new Circle(_paddingLeft+unscaledWidth/2, _paddingTop+yValue(), Math.min(xSizeShapeValue(), maxSize));
				}
				else
				{
					valueTipX = _paddingLeft+xValue() + Math.min(ySizeShapeValue(), maxSize)/4;
					valueTipY = _paddingTop+unscaledHeight/2 + Math.min(ySizeShapeValue(), maxSize)/4; 
					valueShape = new Circle(_paddingLeft+xValue(), _paddingTop+unscaledHeight/2, Math.min(ySizeShapeValue(), maxSize)); 
				}
			}
			
			// create target shape
			var targetTipX:Number, targetTipY:Number;
			if (orientation == VERTICAL)
			{
				targetTipX = _paddingLeft+xTarget() + xSizeRectTarget()/2;
				targetTipY = _paddingTop+yTarget() + ySizeRectTarget()/2;
				targetShape = new RegularRectangle(_paddingLeft+xTarget(), _paddingTop+yTarget(), xSizeRectTarget(), ySizeRectTarget());
			}
			else
			{
				targetTipX = _paddingLeft+xTarget() + xSizeRectTarget()/2
				targetTipY = _paddingTop+yTarget() + ySizeRectTarget()/2;
				targetShape = new RegularRectangle(_paddingLeft+xTarget(), _paddingTop+yTarget(), xSizeRectTarget(), ySizeRectTarget());
			}
				
			targetTipX = targetShape.x + targetShape.width/2
			targetTipY = targetShape.y + targetShape.height/2
				
			valueShape.fill = black;
			targetShape.fill = black;
			
			var posX:Number;
			var posY:Number;

			// create qualitativeRanges
			for (var i:Number=0; i<data.length; i++)
			{
				if (showDataTips)
				{
					geomGroup = new ExtendedGeometryGroup();
					geomGroup.target = this;
					geomGroup.name = "qualitative";
				}

				var qualitativeShape:RegularRectangle = 
					new RegularRectangle(_paddingLeft+startX(i), _paddingTop+startY(i), offsetSizeX(i), offsetSizeY(i));
				qualitativeShape.fill = new SolidFill(useColor(i));

				geomGroup.geometryCollection.addItem(qualitativeShape);
				
				if (orientation == VERTICAL)
				{
					posX = qualitativeShape.x + qualitativeShape.width/2;
					posY = qualitativeShape.y + 4;
				} else {
					posX = qualitativeShape.x + qualitativeShape.width -4;
					posY = qualitativeShape.y + qualitativeShape.height/2;
				}
				
				if (_showDataTips)
				{
					geomGroup.toolTipFill = qualitativeShape.fill;
					initGGToolTip();
					geomGroup.createToolTip((orientation == VERTICAL) ? data[i-1] : data[i], null, posX, posY, 3);
				} else {
					graphicsCollection.addItem(geomGroup);
				}
			}
			
			if (showDataTips)
			{
				geomGroup = new ExtendedGeometryGroup();
				geomGroup.target = this;
				geomGroup.toolTipFill = valueShape.fill;
				initGGToolTip();
				geomGroup.geometryCollection.addItem(valueShape);
				geomGroup.createToolTip(value, null, valueTipX, valueTipY, 3);

				geomGroup = new ExtendedGeometryGroup();
				geomGroup.target = this;
				geomGroup.toolTipFill = targetShape.fill;
				initGGToolTip();
				geomGroup.geometryCollection.addItem(targetShape);
				geomGroup.createToolTip(target, null, targetTipX, targetTipY, 3);
			} else
			{
				geomGroup.geometryCollection.addItem(valueShape);
				geomGroup.geometryCollection.addItem(targetShape);
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
		
		/**
		* @private 
		 * Init the GeomGroupToolTip and its listeners
		 * 
		*/
		protected function initGGToolTip():void
		{
			geomGroup.target = this;
			if (_dataTipFunction != null)
				geomGroup.dataTipFunction = _dataTipFunction;
			if (_dataTipPrefix!= null)
				geomGroup.dataTipPrefix = _dataTipPrefix;
			graphicsCollection.addItem(geomGroup);
			geomGroup.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			geomGroup.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}

		/**
		* @private 
		 * Show and position tooltip
		 * 
		*/
		private function handleRollOver(e:MouseEvent):void
		{
			var extGG:ExtendedGeometryGroup = ExtendedGeometryGroup(e.target);
			var pos:Point = localToGlobal(new Point(extGG.posX, extGG.posY));
			tip = ToolTipManager.createToolTip(extGG.toolTip, 
												pos.x + 10,	pos.y + 10)	as ToolTip;

			tip.alpha = 0.7;
			if (extGG.name == "qualitative" && numChildren >= 3 )
				setChildIndex(extGG, numChildren-3);
			extGG.showToolTipGeometry();
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		private function handleRollOut(e:MouseEvent):void
		{ 
			ToolTipManager.destroyToolTip(tip);
			ExtendedGeometryGroup(e.target).hideToolTipGeometry();
		}
	}
}