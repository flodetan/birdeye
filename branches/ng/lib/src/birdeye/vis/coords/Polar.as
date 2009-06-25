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
 
package birdeye.vis.coords
{
	import __AS3__.vec.Vector;
	
	import birdeye.vis.VisScene;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IEnumerableScale;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.interfaces.IScale;
	import birdeye.vis.interfaces.IScaleUI;
	import birdeye.vis.interfaces.IStack;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;
	
	/** 
	 * The PolarChart is the base chart that is extended by all charts that are
	 * based on polar coordinates (PieChart, RadarChart, CoxCombo, etc). 
	 * The PolarChart serves as container for all axes and elements and coordinates the different
	 * data loading and creation of each component.
	 * 
	 * If a PolarChart is provided with an axis, this axis will be shared by all elements that have 
	 * not that same axis (angle, and/or radius). 
	 * In the same way, the PolarChart provides a dataProvider property 
	 * that can be shared with elements that have not a dataProvider. In case the PolarChart dataProvider 
	 * is used along with some elements dataProvider, than the relevant values defined be the elements fields
	 * of all these dataProviders will define the axes.
	 * 
	 * A PolarChart may have multiple and different type of elements, multiple axes and 
	 * multiple dataProvider(s).
	 * */ 
	[DefaultProperty("dataProvider")]
	public class Polar extends VisScene implements ICoordinates
	{
		protected const COLUMN:String = "column";
		protected const RADAR:String = "radar";
				
		protected var _layout:String;
		[Inspectable(enumeration="column,radar")]
		public function set layout(val:String):void
		{
			_layout = val;
			invalidateDisplayList();
		}
		
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IElement")]
        [ArrayElementType("birdeye.vis.interfaces.IElement")]
		override public function set elements(val:Array):void
		{
			_elements = val;
			var stackableElements:Array = [];

			for (var i:Number = 0; i<_elements.length; i++)
			{
				// set the chart target inside the elements to 'this'
				// in the future the elements target could be an external chart 
				if (! IElement(_elements[i]).chart)
					IElement(_elements[i]).chart = this;
				
				// count all stackable elements according their type (overlaid, stacked100...)
				// and store their position. This allows to have a general PolarChart 
				// elements that are stackable, where the type of stack used is defined internally
				// the elements itself. In case of RadarChart, is used, than
				// the elements stack type is defined directly by the chart.
				// however the following allows keeping the possibility of using stackable elements inside
				// a general polar chart
				if (_elements[i] is IStack)
				{
					if (isNaN(stackableElements[IStack(_elements[i]).elementType]) || stackableElements[IStack(_elements[i]).elementType] == undefined) 
						stackableElements[IStack(_elements[i]).elementType] = 1;
					else 
						stackableElements[IStack(_elements[i]).elementType] += 1;
					
					IStack(_elements[i]).stackPosition = stackableElements[IStack(_elements[i]).elementType]; 
				} 
			}

			// if a element is stackable, than its total property 
			// represents the number of all stackable elements with the same type inside the
			// same chart. This allows having multiple elements type inside the same chart 
			for (i = 0; i<_elements.length; i++)
				if (_elements[i] is IStack)
					IStack(_elements[i]).total = stackableElements[IStack(_elements[i]).elementType]; 
		}

		override public function set multiScale(val:MultiScale):void
		{
			super.multiScale = val;
			_multiScale.chart = this;
		}

		protected var _type:String = StackElement.STACKED100;
		/** Set the type of stack, overlaid if the element are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally), or 
		 * stacked100 if the columns are stacked one after the other (vertically).*/
		[Inspectable(enumeration="overlaid,stacked,stacked100")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get type():String
		{
			return _type;
		}

		protected var _fontSize:Number = 10;
		public function set fontSize(val:Number):void
		{
			_fontSize = val;
			invalidateDisplayList();
		}
		
		protected var labels:Surface;
		protected var gg:GeometryGroup;
		public function Polar()
		{
			super();
			coordType = VisScene.POLAR;
			_elementsContainer = this;
			addChild(labels = new Surface());

	  		_elementsContainer.addChildAt(_maskShape,0);

			gg = new GeometryGroup();
			gg.target = labels;
			labels.addChild(gg);
		}

		protected var nCursors:Number;
		/** @Private 
		 * When properties are committed, first remove all current children, second check for elements owned axes 
		 * and put them on the corresponding container (left, top, right, bottom). If no axes are defined for one 
		 * or more elements, than create the default axes and add them to the related container.
		 * Once all axes are identified (including the default ones), than we can feed them with the 
		 * corresponding data.*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			removeAllElements();
			
			nCursors = 0;
			
			if (elements)
			{
				var _stackedElements:Array = [];

 				for (var i:int = 0; i<elements.length; i++)
				{
					// if elements dataprovider doesn' exist or it refers to the
					// chart dataProvider, than set its cursor to this chart cursor (this.cursor)
					if (cursorVector && (! IElement(_elements[i]).dataProvider 
									|| IElement(_elements[i]).dataProvider == this.dataProvider))
						IElement(_elements[i]).cursorVector = cursorVector;

					// nCursors is used in feedAxes to check that all elements cursors are ready
					// and therefore check that axes can be properly feeded
					if (cursorVector || IElement(_elements[i]).cursorVector)
						nCursors += 1;

					if (!contains(DisplayObject(elements[i])))
						addChild(DisplayObject(elements[i]));

					if (IElement(elements[i]).scale2)
					{
						if (!contains(DisplayObject(IElement(elements[i]).scale2)))
							addChild(DisplayObject(IElement(elements[i]).scale2));
					} 

					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_stackedElements.push(_elements[i]);
					}
				}

				for (i = 0; i<_stackedElements.length; i++)
				{
					IStack(_stackedElements[i]).stackPosition = i;
					IStack(_stackedElements[i]).total = _stackedElements.length;
				}
			}

			if (_elements)
			{
				var _stackElements:Array = [];
			
				for (i = 0; i<_elements.length; i++)
				{
					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_stackElements.push(_elements[i])
					}
				}
			}

			// when elements are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each üolarColumnElements. The baseValues arrays will be used to know
			// the radius0 starting point for each elements values, which corresponds to 
			// the understair elements outer radius;
			if (_elements && nCursors == _elements.length)
			{
				_stackElements = [];
			
				for (i = 0; i<_elements.length; i++)
				{
					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_stackElements.push(_elements[i])
					}
				}
				
				_maxStacked100 = NaN;

				if (_type==StackElement.STACKED100)
				{
					// {indexElements: i, baseValues: Array_for_each_Elements}
					var allElementsBaseValues:Array = []; 
					for (i=0;i < _stackElements.length;i++)
						allElementsBaseValues[i] = {indexElements: i, baseValues: []};
					
					// keep index of last element been processed 
					// with the same angle field data value
					// k[xFieldDataValue] = last element processed
					var k:Array = [];
					
					// the baseValues are indexed with the angle field objects
					var j:Object;
					
					var cursIndex:uint = 0;
					var currentItem:Object;
				
					for (var s:Number = 0; s<_stackElements.length; s++)
					{
						var sCursor:Vector.<Object>;
						
						if (IElement(_stackElements[s]).cursorVector &&
							IElement(_stackElements[s]).cursorVector != cursorVector)
						{
							sCursor = IElement(_stackElements[s]).cursorVector;
							
							for (cursIndex = 0; cursIndex < sCursor.length; cursIndex++)
							{
								currentItem = sCursor[cursIndex];
								j = currentItem[IElement(_stackElements[s]).dim1];

								if (s>0 && k[j]>=0)
								{
									var maxCurrentD2:Number = getDimMaxValue(currentItem, IElement(_stackElements[k[j]]).dim2);
									allElementsBaseValues[s].baseValues[j] = 
										allElementsBaseValues[k[j]].baseValues[j] + 
										Math.max(0,maxCurrentD2);
								} else 
									allElementsBaseValues[s].baseValues[j] = 0;

								maxCurrentD2 = getDimMaxValue(currentItem, IElement(_stackElements[s]).dim2);
								
								if (isNaN(_maxStacked100))
									_maxStacked100 = 
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,maxCurrentD2);
								else
									_maxStacked100 = Math.max(_maxStacked100,
										allElementsBaseValues[s].baseValues[j] + 
										Math.max(0,maxCurrentD2));

								k[j] = s;
							}
						}
					}
					
					if (cursorVector)
					{
						for (cursIndex = 0; cursIndex < cursorVector.length; cursIndex++)
						{
							currentItem = cursorVector[cursIndex];

							// index of last element without own cursor with the same radius (dim2) data value 
							// (because they've already been processed in the previous loop)
							var t:Array = [];
							for (s = 0; s<_stackElements.length; s++)
							{
								if (! (IElement(_stackElements[s]).cursorVector &&
									IElement(_stackElements[s]).cursorVector != cursorVector))
								{
									j = currentItem[IElement(_stackElements[s]).dim1];
							
									if (t[j]>=0)
									{
										maxCurrentD2 = getDimMaxValue(currentItem, IElement(_stackElements[t[j]]).dim2, 
																	IElement(_stackElements[t[j]]).collisionType == StackElement.STACKED100);
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[t[j]].baseValues[j] + 
											Math.max(0,maxCurrentD2);
									} else 
										allElementsBaseValues[s].baseValues[j] = 0;
									
									maxCurrentD2 = getDimMaxValue(currentItem, IElement(_stackElements[s]).dim2, 
																IElement(_stackElements[s]).collisionType == StackElement.STACKED100);

									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,maxCurrentD2);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,maxCurrentD2));

									t[j] = s;
								}
							}
						}
					}
					
					// set the baseValues array for each AreaElement
					// The baseValues array will be used to know
					// the y0 starting point for each element values, 
					// which corresponds to the understair element highest y value;
					for (s = 0; s<_stackElements.length; s++)
						IStack(_stackElements[s]).baseValues = allElementsBaseValues[s].baseValues;
				}
			}

			if (multiScale && !contains(multiScale))
				addChild(multiScale);
				
			if (!contains(labels))
				addChild(labels);

			if (_elements)
			{
				var _columnElements:Array = [];
			
				for (i = 0; i<_elements.length; i++)
				{
					if (_elements[i] is IStack)
					{
						IStack(_elements[i]).stackType = _type;
						_columnElements.push(_elements[i])
					}
				}
			}
			// init all axes, default and elements owned 
			if (! axesFeeded)
			{
				resetAxes();
				feedAxes();
			}

			if (!contains(labels))
				addChild(labels);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			setActualSize(unscaledWidth, unscaledHeight);
			
			if (showAllDataTips)
				removeDataItems();
			
			_origin = new Point(unscaledWidth/2, unscaledHeight/2);
			
			if (multiScale)
			{
				multiScale.scalesSize = DisplayObject(multiScale).width  
					= Math.min(unscaledWidth, unscaledHeight)/2;
			} 
			
			for (var i:Number = 0; i<_elements.length; i++)
			{
				if (IElement(_elements[i]).scale2)
				{
					IElement(_elements[i]).scale2.size = Math.min(unscaledWidth, unscaledHeight)/2;
				
					if (IElement(_elements[i]).scale2 is IScaleUI)
					{
						switch (IScaleUI(IElement(_elements[i]).scale2).placement)
						{
							case BaseScale.HORIZONTAL_CENTER:
								DisplayObject(IElement(_elements[i]).scale2).x = _origin.x;
								DisplayObject(IElement(_elements[i]).scale2).y = _origin.y;
								break;
							case BaseScale.VERTICAL_CENTER:
								DisplayObject(IElement(_elements[i]).scale2).x = 
									_origin.x - DisplayObject(IElement(_elements[i]).scale2).width;
								DisplayObject(IElement(_elements[i]).scale2).y = 
									_origin.y - IElement(_elements[i]).scale2.size;
								break;
						}
					}
				}
			}
			
			if (_showAllDataTips)
			{
				for (i = 0; i<numChildren; i++)
				{
					if (getChildAt(i) is DataItemLayout)
						DataItemLayout(getChildAt(i)).showToolTip();
				}
			}

			if (multiScale && multiScale.scale1)
				drawLabels()

			for (i = 0; i<_elements.length; i++)
			{
				DisplayObject(_elements[i]).width = unscaledWidth;
				DisplayObject(_elements[i]).height = unscaledHeight;
				IElement(_elements[i]).drawElement();
			}
			
			if (_isMasked && _maskShape)
			{
				if (!elementsContainer.contains(_maskShape))
					elementsContainer.addChild(_maskShape);
				maskShape.graphics.beginFill(0xffffff, 1);
				maskShape.graphics.drawRect(0,0,_elementsContainer.width, _elementsContainer.height);
				maskShape.graphics.endFill();
	  			elementsContainer.setChildIndex(_maskShape, 0);
				elementsContainer.mask = maskShape;
			}

			// listeners like legends will listen to this event
			dispatchEvent(new Event("ProviderReady"));
		}

		protected var currentElement:IElement;
		private var elementsMinMax:Array;
		/** @Private
		 * Feed the axes with either elements (for ex. CategoryAxis) or max and min (for numeric axis).*/
		protected function feedAxes():void
		{
			var catElements:Array = [];
			var j:Number = 0;
			elementsMinMax = [];
			
			if (nCursors == elements.length)
			{
				var cursIndex:uint = 0;
				var currentItem:Object;
				
				// check if a default y axis exists
				if (_multiScale && _multiScale.dim1 && _multiScale.scale1)
				{
					var angleCategory:String = multiScale.dim1;
					for (var i:int = 0; i<nCursors; i++)
					{
						currentElement = IElement(_elements[i]);
						// if the element has its own data provider but has not its own
						// angleAxis, than load their elements and add them to the elements
						// loaded by the chart data provider
						if (currentElement.dataProvider 
							&& currentElement.dataProvider != dataProvider)
						{
							for (cursIndex = 0; cursIndex<currentElement.cursorVector.length; cursIndex++)
							{
								currentItem = currentElement.cursorVector[cursIndex];
								var category:String = currentItem[angleCategory];
								if (catElements.indexOf(category) == -1)
									catElements[j++] = category;
								
								if (!elementsMinMax[category])
								{
									elementsMinMax[category] = {min: int.MAX_VALUE,
																	 max: int.MIN_VALUE};
								} 

								var maxDim2:Number = getDimMaxValue(currentItem, currentElement.dim2, currentElement.collisionType == StackElement.STACKED100);
								var minDim2:Number = getDimMinValue(currentItem, currentElement.dim2);
									
								elementsMinMax[category].min = 
									Math.min(elementsMinMax[category].min, minDim2);

								elementsMinMax[category].max = 
									Math.max(elementsMinMax[category].max, maxDim2);
							}
						}
						
						if (cursorVector)
						{
							for (cursIndex = 0; cursIndex<currentElement.cursorVector.length; cursIndex++)
							{
								currentItem = currentElement.cursorVector[cursIndex];

								category = currentItem[angleCategory]
								// if the category value already exists in the axis, than skip it
								if (catElements.indexOf(category) == -1)
									catElements[j++] = category;
								
								for (var t:int = 0; t<elements.length; t++)
								{
									currentElement = IElement(_elements[t]);
									if (!elementsMinMax[category])
									{
										elementsMinMax[category] = {min: int.MAX_VALUE,
																		 max: int.MIN_VALUE};
									} 
									
									maxDim2 = getDimMaxValue(currentItem, currentElement.dim2, currentElement.collisionType == StackElement.STACKED100);
									minDim2 = getDimMinValue(currentItem, currentElement.dim2);
									
									elementsMinMax[category].min = 
										Math.min(elementsMinMax[category].min, minDim2);

									elementsMinMax[category].max = 
										Math.max(elementsMinMax[category].max, maxDim2);
								}
							}
						}
	
						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							_multiScale.scale1.dataProvider = catElements;
					} 
					
					_multiScale.feedRadiusAxes(elementsMinMax);
				}
			}

			if (nCursors == elements.length)
			{
				// init axes of all elements that have their own axes
				// since these are children of each elements, they are 
				// for sure ready for feeding and it won't affect the axesFeeded status
				for (i = 0; i<elements.length; i++)
					initElementsAxes(elements[i]);
					
				axesFeeded = true;
			}
		}

		protected function drawLabels():void
		{
			var angleScale:CategoryAngle;
			if (multiScale)
				angleScale = multiScale.scale1;
			
			var catElements:Array = angleScale.dataProvider;
			var interval:int = angleScale.scaleInterval;
			var nEle:int = catElements.length;
			var radius:int = Math.min(unscaledWidth, unscaledHeight)/2;

			if (angleScale && radius>0 && catElements && nEle>0 && !isNaN(interval))
			{
				removeAllLabels();
				for (var i:int = 0; i<nEle; i++)
				{
					var angle:int = angleScale.getPosition(catElements[i]);
					var position:Point = PolarCoordinateTransform.getXY(angle,radius,origin);
					
					var label:RasterTextPlus = new RasterTextPlus();
					label.text = String(catElements[i]);
 					label.fontFamily = "verdana";
 					label.fontSize = _fontSize;
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.fill = new SolidFill(0x000000);

					label.x = position.x - label.displayObject.width/2;
					label.y = position.y - label.displayObject.height/2;
					
					gg.geometryCollection.addItem(label);
				}

				switch (_layout)
				{
					case RADAR: 
						if (multiScale)
							createRadarLayout();
						break;
					case COLUMN:
						createColumnLayout()
						break;
				}
			}
		}
		
		private function createRadarLayout():void
		{
			var angleScale:CategoryAngle = multiScale.scale1;
			var catElements:Array = angleScale.dataProvider;
			var radiusScale:Numeric = multiScale.scales[catElements[0]];
			
			if (angleScale && radiusScale && !isNaN(radiusScale.dataInterval))
			{
				var interval:int = angleScale.scaleInterval;
				var nEle:int = catElements.length;
	
				var rMin:Number = radiusScale.min;
				var rMax:Number = radiusScale.max;
				
				var angle:int;
				var radius:int;
				var position:Point;
	
				for (radius = rMin + radiusScale.dataInterval; radius<rMax; radius += radiusScale.dataInterval)
				{
					var poly:Polygon = new Polygon();
					poly.data = "";
	
					for (var j:int = 0; j<nEle; j++)
					{
						angle = angleScale.getPosition(catElements[j]);
						position = PolarCoordinateTransform.getXY(angle, radiusScale.getPosition(radius), origin)
						poly.data += String(position.x) + "," + String(position.y) + " ";
					}
					poly.stroke = new SolidStroke(0x000000,.15);
					gg.geometryCollection.addItem(poly);
				}
			}
		}

		private function createColumnLayout():void
		{
			var rad:int = Math.min(unscaledWidth, unscaledHeight)/2;
			var circle:Circle = new Circle(origin.x, origin.y, rad-20);
			circle.stroke = new SolidStroke(0x000000);

			gg.geometryCollection.addItem(circle);
		}

		/** @Private
		 * Calculate the total of positive values to set in the percent axis and set it for each elements.*/
/* 		private function setPositiveTotalAngleValueInSeries():void
		{
			INumerableScale(scale1).totalPositiveValue = NaN;
			var tot:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = IElement(elements[i]);
				// check if the elements has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!isNaN(currentElement.totalDim1PositiveValue))
				{
					if (isNaN(INumerableScale(scale1).totalPositiveValue))
						INumerableScale(scale1).totalPositiveValue = currentElement.totalDim1PositiveValue;
					else
						INumerableScale(scale1).totalPositiveValue = 
							Math.max(INumerableScale(scale1).totalPositiveValue, 
									currentElement.totalDim1PositiveValue);
				}
			}
		}
 */

		/** @Private
		 * Init the axes owned by the element passed to this method.*/
		private function initElementsAxes(element:IElement):void
		{
			if (element.cursorVector)
			{
				var catElements:Array;
				var j:Number;

				var cursIndex:uint = 0;
				var currentItem:Object;
				
				if (element.scale1 is IEnumerableScale)
				{
					// if the scale dataProvider already exists than load it and update the index
					// in fact the same scale might be shared among several elements 
					if (IEnumerableScale(element.scale1).dataProvider)
					{
						catElements = IEnumerableScale(element.scale1).dataProvider;
						j = catElements.length;
					} else {
						j = 0;
						catElements = [];
					}

					for (cursIndex = 0; cursIndex<element.cursorVector.length; cursIndex++)
					{
						currentItem = element.cursorVector[cursIndex];
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(currentItem[IEnumerableScale(element.scale1).categoryField]) == -1)
							catElements[j++] = 
								currentItem[IEnumerableScale(element.scale1).categoryField];
					}
					
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.scale1).dataProvider = catElements;
	
				} else if (element.scale1 is INumerableScale)
				{
					// if the angle axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					// since the same scale can be shared among several elements, the precedent min and max
					// are also taken into account
					if (INumerableScale(element.scale1).scaleType != BaseScale.PERCENT)
					{
						// if the element angle axis is just numeric, than calculate get its min max data values
						if (isNaN(INumerableScale(element.scale1).max))
							INumerableScale(element.scale1).max = element.maxDim1Value;
						else 
							INumerableScale(element.scale1).max =
								Math.max(INumerableScale(element.scale1).max, element.maxDim1Value);

						if (isNaN(INumerableScale(element.scale1).min))
							INumerableScale(element.scale1).min = element.minDim1Value;
						else 
							INumerableScale(element.scale1).min =
								Math.min(INumerableScale(element.scale1).min, element.minDim1Value);
					} else {
						// if the element angle axis is percent numeric, than get the sum
						// of total positive data values from the element
						if (isNaN(INumerableScale(element.scale1).totalPositiveValue))
							INumerableScale(element.scale1).totalPositiveValue = element.totalDim1PositiveValue;
						else
							INumerableScale(element.scale1).totalPositiveValue += element.totalDim1PositiveValue;
					}
				}
	
				if (element.scale2 is IEnumerableScale)
				{
					for (cursIndex = 0; cursIndex<element.cursorVector.length; cursIndex++)
					{
						currentItem = element.cursorVector[cursIndex];
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(currentItem[IEnumerableScale(element.scale2).categoryField]) == -1)
							catElements[j++] = 
								currentItem[IEnumerableScale(element.scale2).categoryField];
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.scale2).dataProvider = catElements;
	
				} else if (element.scale2 is INumerableScale)
				{
					// if the element angle axis is just numeric, than calculate get its min max data values
					if (isNaN(INumerableScale(element.scale2).max))
						INumerableScale(element.scale2).max = element.maxDim2Value;
					else 
						INumerableScale(element.scale2).max =
							Math.max(INumerableScale(element.scale2).max, element.maxDim2Value);

					if (isNaN(INumerableScale(element.scale2).min))
						INumerableScale(element.scale2).min = element.minDim2Value;
					else 
						INumerableScale(element.scale2).min =
							Math.min(INumerableScale(element.scale2).min, element.minDim2Value);
				}
	
				if (element.colorScale)
				{
					// if the axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					element.colorScale.max =
						element.maxColorValue;
					element.colorScale.min =
						element.minColorValue;
				}

				if (element.sizeScale && !element.sizeScale.dataValues)
				{
					if (isNaN(element.sizeScale.max))
						element.sizeScale.max =
							element.maxSizeValue;
					else 
						element.sizeScale.max =
							Math.max(element.sizeScale.max, element.maxSizeValue);
					
					if (isNaN(element.sizeScale.min))
						element.sizeScale.min =
							element.minSizeValue;
					else 
						element.sizeScale.min =
							Math.min(element.sizeScale.min, element.minSizeValue);
				}
			}
		}

		private function removeAllElements():void
		{
			var i:int; 
			var child:*;
			
			for (i = 0; i<numChildren; i++)
			{
				child = getChildAt(0); 
				if (child is IScaleUI)
					IScaleUI(child).removeAllElements();
				if (child is DataItemLayout)
				{
					DataItemLayout(child).removeAllElements();
					DataItemLayout(child).geometryCollection.items = [];
					DataItemLayout(child).geometry = [];
				}
				
				if (child is MultiScale)
					MultiScale(child).removeAllElements();

				removeChildAt(0);
			}
		}
		
		private function removeAllLabels():void
		{
			if (gg)
				gg.geometryCollection.items = [];
		}

		override protected function resetAxes():void
		{
			super.resetAxes();

			for (var i:Number = 0; i<elements.length; i++)
				if (IElement(elements[i]).scale1)
					IScale(IElement(elements[i]).scale1).resetValues();

			for (i = 0; i<elements.length; i++)
				if (IElement(elements[i]).scale2)
					IScale(IElement(elements[i]).scale2).resetValues();
		}
	}
}