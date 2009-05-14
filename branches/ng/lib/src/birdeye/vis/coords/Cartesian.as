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
	import birdeye.vis.VisScene;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.interfaces.*;
	import birdeye.vis.scales.*;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	
	/** A CartesianChart can be used to create any 2D or 3D cartesian charts available in the library
	 * apart from those who might have specific features, like stackable element or data-sizable items.
	 * Those specific features are managed directly by charts that extends the CartesianChart 
	 * (AreaChart, BarChart, ColumnChart for stackable element and ScatterPlot, BubbleChart for 
	 * data-sizable items.
	 * The CartesianChart serves as container for all axes and element and coordinates the different
	 * data loading and creation of each component.
	 * If a CartesianChart is provided with an axis, this axis will be shared by all element that have 
	 * not that same axis (x, y or z). In the same way, the CartesianChart provides a dataProvider property 
	 * that can be shared with element that have not a dataProvider. In case the CartesianChart dataProvider 
	 * is used along with some element dataProvider, than the relevant values defined be the element fields
	 * of all these dataProviders will define the axes (min, max for NumericAxis elements 
	 * for CategorScale2, etc).
	 * 
	 * A CartesianChart may have multiple and different type of element, multiple axes and 
	 * multiple dataProvider(s).
	 * Most of available cartesian charts are also 3D. If a element specifies the zField, than the chart will
	 * be a 3D chart. By default zAxis is placed at the bottom right of the chart, for this reason it's
	 * recommended to place Scale2 to the left of the chart when using 3D charts.
	 * Given the current 3D limitations of the FP platform, for which is not possible to draw
	 * real 3D graphics (moveTo, drawRect, drawLine etc don't include the z coordinate), the AreaChart 
	 * and LineChart are not 3D yet. 
	 * */ 
	[DefaultProperty("dataProvider")]
	[Exclude(name="elementsContainer", kind="property")]
	public class Cartesian extends VisScene implements ICoordinates, ISizableItem
	{
		protected var _type:String = StackElement.OVERLAID;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally), or 
		 * stacked100 if the columns are stacked one after the other (vertically).*/
		[Inspectable(enumeration="overlaid,stacked,stacked100")]
		public function set type(val:String):void
		{
			_type = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		protected var _maxStacked100:Number = NaN;
		/** @Private
		 * The maximum value among all series stacked according to stacked100 type.
		 * This is needed to "enlarge" the related axis to include all the stacked values
		 * so that all stacked100 series fit into the chart.*/
		public function get maxStacked100():Number
		{
			return _maxStacked100;
		}

		private var _maxRadius:Number = 10;
		/** @Private
		 * Set the maximum radius value for the scatter plot.*/
		public function set maxRadius(val:Number):void
		{
			_maxRadius = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get maxRadius():Number
		{
			return _maxRadius;
		}

		private var _minRadius:Number = 10;
		/** @Private
		 * Set the minimum radius value for the scatter plot.*/
		public function set minRadius(val:Number):void
		{
			_minRadius = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get minRadius():Number
		{
			return _minRadius;
		}

		/** Array of elements, mandatory for any cartesian chart.
		 * Each element must implement the IElement interface which defines 
		 * methods that allow to set fields, basic styles, axes, dataproviders, renderers,
		 * max and min values, etc. Look at the IElement for more details.
		 * Each element can define its own axes, which will have higher priority over the axes
		 * that are provided by the dataProvider (a cartesian chart). In case no axes are 
		 * defined for the element, than those of the data provider are used. 
		 * The data provider (cartesian chart) axes values (min, max, etc) are calculated 
		 * based on the group of element that share them.*/
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IElement")]
        [ArrayElementType("birdeye.vis.interfaces.IElement")]
		override public function set elements(val:Array):void
		{
			_elements = val;
			var stackableElements:Array = [];
			for (var i:Number = 0, j:Number = 0, t:Number = 0; i<_elements.length; i++)
			{
				// if the element doesn't have an own x axis, than
				// it's necessary to create a default x axis inside the
				// cartesian chart. This axis will be shared by all elements that
				// have no own x axis
				if (! IElement(_elements[i]).scale1)
					needDefaultScale1 = true;

				// if the element doesn't have an own y axis, than
				// it's necessary to create a default y axis inside the
				// cartesian chart. This axis will be shared by all elements that
				// have no own y axis
				if (! IElement(_elements[i]).scale2)
					needDefaultScale2 = true;
					
				// set the chart target inside the element to 'this'
				// in the future the element target could be an external chart 
				if (! IElement(_elements[i]).chart)
					IElement(_elements[i]).chart = this;
					
				// count all stackable elements according their type (overlaid, stacked100...)
				// and store its position. This allows to have a general CartesianChart 
				// elements that are stackable, where the type of stack used is defined internally
				// the elements itself. In case BarChart, AreaChart or ColumnChart are used, than
				// the elements stack type is definde directly by the chart.
				// however the following allows keeping the possibility of using stackable elements inside
				// a general cartesian chart
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
			// same chart. This allows having multiple elements type inside the same chart (TODO) 
			for (j = 0; j<_elements.length; j++)
				if (_elements[j] is IStack)
					IStack(_elements[j]).total = stackableElements[IStack(_elements[j]).elementType]; 
						
			invalidateProperties();
			invalidateDisplayList();
		}

		override public function set multiScale(val:MultiScale):void
		{
			_multiScale.chart = this;
			super.multiScale = val;
		}

		private var _is3D:Boolean = false;
		public function get is3D():Boolean
		{
			return _is3D;
		}

		// UIComponent flow

		public function Cartesian() 
		{
			super();
			coordType = VisScene.CARTESIAN;
		}
		
		private var leftContainer:Container, rightContainer:Container;
		private var topContainer:Container, bottomContainer:Container;
		private var zContainer:Container;
		/** @Private
		 * Crete and add all containers that define the chart structure.
		 * The elementsContainer will contain all chart elements. Remove scrolling and clip the content 
		 * to true for each of them.*/ 
		override protected function createChildren():void
		{
			super.createChildren();
			addChild(leftContainer = new HBox());
			addChild(rightContainer = new HBox());
			addChild(topContainer = new VBox());
			addChild(bottomContainer = new VBox());
			addChild(zContainer = new HBox());
			addChild(_elementsContainer);
			
			zContainer.verticalScrollPolicy = "off";
			zContainer.clipContent = false;
			zContainer.horizontalScrollPolicy = "off";
			zContainer.setStyle("horizontalAlign", "left");

			leftContainer.verticalScrollPolicy = "off";
			leftContainer.clipContent = false;
			leftContainer.horizontalScrollPolicy = "off";
			leftContainer.setStyle("horizontalAlign", "right");

			rightContainer.verticalScrollPolicy = "off";
			rightContainer.clipContent = false;
			rightContainer.horizontalScrollPolicy = "off";
			rightContainer.setStyle("horizontalAlign", "left");

			topContainer.verticalScrollPolicy = "off";
			topContainer.clipContent = false;
			topContainer.horizontalScrollPolicy = "off";
			topContainer.setStyle("verticalAlign", "bottom");

			bottomContainer.verticalScrollPolicy = "off";
			bottomContainer.clipContent = false;
			bottomContainer.horizontalScrollPolicy = "off";
			bottomContainer.setStyle("verticalAlign", "top");
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
			needDefaultScale1 = needDefaultScale2 = false;
			
			removeAllElements();
			
			nCursors = 0;
			
			if (elements)
			{
 				for (i = 0; i<elements.length; i++)
				{
					// if element dataprovider doesn' exist or it refers to the
					// chart dataProvider, than set its cursor to this chart cursor (this.cursor)
					if (cursor && (! IElement(_elements[i]).dataProvider 
									|| IElement(_elements[i]).dataProvider == this.dataProvider))
						IElement(_elements[i]).cursor = cursor;

					// nCursors is used in feedAxes to check that all elements cursors are ready
					// and therefore check that axes can be properly feeded
					if (cursor || IElement(_elements[i]).cursor)
						nCursors += 1;

					_elementsContainer.addChild(DisplayObject(elements[i]));
					var scale1:IScale = IElement(elements[i]).scale1;
					if (scale1)
					{
						switch (scale1.placement)
						{
							case BaseScale.TOP:
								topContainer.addChild(DisplayObject(scale1));
								break; 
							case BaseScale.BOTTOM:
								bottomContainer.addChild(DisplayObject(scale1));
								break;
						}
					} else 
						needDefaultScale1 = true;
						
					var scale2:IScale = IElement(elements[i]).scale2;
					if (scale2)
					{
						switch (scale2.placement)
						{
							case BaseScale.LEFT:
								leftContainer.addChild(DisplayObject(scale2));
								break;
							case BaseScale.RIGHT:
								rightContainer.addChild(DisplayObject(scale2));
								break;
						}
					} else 
						needDefaultScale2 = true;

					var tmpScale3:IScale = IElement(elements[i]).scale3;
					if (tmpScale3 && tmpScale3 is IScaleUI)
					{
						zContainer.addChild(DisplayObject(tmpScale3));
						
						// this will be replaced by a depth property 
 						IScale(tmpScale3).size = width; 
 						// the Scale3 is in reality an Scale2 which is rotated of 90 degrees
 						// on its X coordinate. This will be replaced by a real z axis, when 
 						// FP will provide methods to draw real 3d lines
						zContainer.rotationX = -90;
						
						// this adjusts the positioning of the axis after the rotation
						zContainer.z = width;
						_is3D = true;
 					}
				}
			}

			if (_scale3 && _scale3 is IScaleUI)
			{
				_is3D = true;
				zContainer.addChild(DisplayObject(_scale3));
				// this will be replaced by a depth property 
 				IScale(_scale3).size = width; 
 				// the scale3 is in reality an Scale2 which is rotated of 90 degrees
 				// on its X coordinate. This will be replaced by a real z axis, when 
 				// FP will provide methods to draw real 3d lines
				zContainer.rotationX = -90;
				// this adjusts the positioning of the axis after the rotation
				zContainer.z = width;
			}
			
			// if some elements have no own y axis, than create a default one for the chart
			// that will be used by all elements without a y axis
 			if (needDefaultScale2)
			{
				if (!_scale2)
					createScale2();
					
				if (_scale2.placement == BaseScale.RIGHT)
					rightContainer.addChild(DisplayObject(_scale2));
				else
					leftContainer.addChild(DisplayObject(_scale2));
			}
 			// if some elements have no own x axis, than create a default one for the chart
			// that will be used by all elements without a x axis
			if (needDefaultScale1)
			{
				if (!_scale1)
					createScale1();

				if (_scale1.placement == BaseScale.TOP)
					topContainer.addChild(DisplayObject(_scale1));
				else
					bottomContainer.addChild(DisplayObject(_scale1));
			}
			
			// when elements are loaded, set their stack type to the 
			// current "type" value. if the type is STACKED100
			// calculate the maxStacked100 value, and load the baseValues
			// arrays for each Column. The baseValues arrays will be used to know
			// the y0 starting point for each element values, which corresponds to 
			// the understair element highest y value;

			if (_elements && nCursors == _elements.length)
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
				
				_maxStacked100 = NaN;

				if (_type==StackElement.STACKED100)
				{
					// {indexSeries: i, baseValues: Array_for_each_element}
					var allElementsBaseValues:Array = []; 
					for (i=0;i<_stackElements.length;i++)
						allElementsBaseValues[i] = {indexElements: i, baseValues: []};
					
					// keep index of last element been processed 
					// with the same xField data value
					// k[xFieldDataValue] = last Elements processed
					var k:Array = [];
					
					var j:Object;
					for (var s:Number = 0; s<_stackElements.length; s++)
					{
						var sCursor:IViewCursor;
						
						if (IElement(_stackElements[s]).cursor &&
							IElement(_stackElements[s]).cursor != cursor)
						{
							sCursor = IElement(_stackElements[s]).cursor;
							sCursor.seek(CursorBookmark.FIRST);
							
							while (!sCursor.afterLast)
							{
								if (IStack(_stackElements[s]).collisionScale == BaseElement.VERTICAL)
								{
									j = sCursor.current[IElement(_stackElements[s]).dim1];
	
									if (s>0 && k[j]>=0)
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[k[j]].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[k[j]]).dim2]);
									else 
										allElementsBaseValues[s].baseValues[j] = 0;
	
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[s]).dim2]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[s]).dim2]));
								} else if (IStack(_stackElements[s]).collisionScale == BaseElement.HORIZONTAL)
								{
									j = sCursor.current[IElement(_stackElements[s]).dim2];
									if (s>0 && k[j]>=0)
										allElementsBaseValues[s].baseValues[j] = 
											allElementsBaseValues[k[j]].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[k[j]]).dim1]);
									else 
										allElementsBaseValues[s].baseValues[j] = 0;
	
									if (isNaN(_maxStacked100))
										_maxStacked100 = 
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[s]).dim1]);
									else
										_maxStacked100 = Math.max(_maxStacked100,
											allElementsBaseValues[s].baseValues[j] + 
											Math.max(0,sCursor.current[IElement(_stackElements[s]).dim1]));
								}

								sCursor.moveNext();
								k[j] = s;
							}
						}
					}
					
					if (cursor)
					{
						cursor.seek(CursorBookmark.FIRST);
						while (!cursor.afterLast)
						{
							// index of last Elements without own cursor with the same xField data value 
							// (because they've already been processed in the previous loop)
							var t:Array = [];
							for (s = 0; s<_stackElements.length; s++)
							{
								if (! (IElement(_stackElements[s]).cursor &&
									IElement(_stackElements[s]).cursor != cursor))
								{
									if (IStack(_stackElements[s]).collisionScale == BaseElement.VERTICAL)
									{
										j = cursor.current[IElement(_stackElements[s]).dim1];
								
										if (t[j]>=0)
											allElementsBaseValues[s].baseValues[j] = 
												allElementsBaseValues[t[j]].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[t[j]]).dim2]);
										else 
											allElementsBaseValues[s].baseValues[j] = 0;
										
										if (isNaN(_maxStacked100))
											_maxStacked100 = 
												allElementsBaseValues[s].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[s]).dim2]);
										else
											_maxStacked100 = Math.max(_maxStacked100,
												allElementsBaseValues[s].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[s]).dim2]));
									} else if (IStack(_stackElements[s]).collisionScale == BaseElement.HORIZONTAL)
									{
										j = cursor.current[IElement(_stackElements[s]).dim2];
										if (s>0 && t[j]>=0)
											allElementsBaseValues[s].baseValues[j] = 
												allElementsBaseValues[t[j]].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[t[j]]).dim1]);
										else 
											allElementsBaseValues[s].baseValues[j] = 0;
		
										if (isNaN(_maxStacked100))
											_maxStacked100 = 
												allElementsBaseValues[s].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[s]).dim1]);
										else
											_maxStacked100 = Math.max(_maxStacked100,
												allElementsBaseValues[s].baseValues[j] + 
												Math.max(0,cursor.current[IElement(_stackElements[s]).dim1]));
									}
	
									t[j] = s;
								}
							}
							cursor.moveNext();
						}
					}
					
					// set the baseValues array for each Column
					// The baseValues array will be used to know
					// the y0 starting point for each element values, 
					// which corresponds to the understair element highest y value;
					for (s = 0; s<_stackElements.length; s++)
						IStack(_stackElements[s]).baseValues = allElementsBaseValues[s].baseValues;
				}
			}

			var scatterElements:Array = [];
			// load all scatter Elements (there might be Elements that are not IScatter 
			// in the ScatterPlot chart)
			for (var i:Number = 0; i<_elements.length; i++)
				if (_elements[i] is IScatter)
					scatterElements.push(_elements[i]);
			
			if (scatterElements.length > 0)
			{
				var maxRadiusValues:Array = [];
				var minRadiusValues:Array = [];
				
				for (i = 0; i<scatterElements.length; i++)
				{
					if (IElement(scatterElements[i]).cursor)
					{
						IElement(scatterElements[i]).cursor.seek(CursorBookmark.FIRST);
						while (! IElement(scatterElements[i]).cursor.afterLast)
						{
							if (maxRadiusValues[i] == null)
								maxRadiusValues[i] = IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								maxRadiusValues[i] = Math.max(maxRadiusValues[i],
															IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField]);
							if (minRadiusValues[i] == null)
								minRadiusValues[i] = IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								minRadiusValues[i] = Math.min(minRadiusValues[i],
															IElement(scatterElements[i]).cursor.current[IScatter(scatterElements[i]).radiusField]);
						
							IElement(scatterElements[i]).cursor.moveNext();
						}						
					} else if (cursor) {
						cursor.seek(CursorBookmark.FIRST);
						
						// calculate the min and max radius values for each scatter Elements
						while (! cursor.afterLast)
						{
							if (maxRadiusValues[i] == null)
								maxRadiusValues[i] = cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								maxRadiusValues[i] = Math.max(maxRadiusValues[i],
															cursor.current[IScatter(scatterElements[i]).radiusField]);
							if (minRadiusValues[i] == null)
								minRadiusValues[i] = cursor.current[IScatter(scatterElements[i]).radiusField];
							else
								minRadiusValues[i] = Math.min(minRadiusValues[i],
															cursor.current[IScatter(scatterElements[i]).radiusField]);

							cursor.moveNext();
						}
					}
				}
				
				// set the min and max radius values for each scatter Elements
				// this will needed by the scatter Elements when calculating the
				// sizes for each data value
				for (i = 0; i<scatterElements.length; i++)
				{
					IScatter(scatterElements[i]).maxRadiusValue = maxRadiusValues[i];
					IScatter(scatterElements[i]).minRadiusValue = minRadiusValues[i];
				}
			}

			// init all axes, default and elements owned 
			if (! axesFeeded)
				feedAxes();
		}
		
		override protected function measure():void
		{
			super.measure();
		}
		
		private var notTurnedYet:Boolean = true;
		/** @Private
		 * In order to calculate the space left for data visualization (elementsContainer) 
		 * we must validate all other containers sizes, which in turn depend on the axes sizes.
		 * So, we first calculate the size needed by each axes container and finally 
		 * set the available size and position for the elementsContainer.*/
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			setActualSize(w,h);
			
			validateBounds();
			leftContainer.y = rightContainer.y = topContainer.height;
			bottomContainer.x = topContainer.x = leftContainer.width;
			leftContainer.x = 0;
			topContainer.y = 0; 
			bottomContainer.y = h - bottomContainer.height;
			rightContainer.x = w - rightContainer.width;

			chartBounds = new Rectangle(leftContainer.x + leftContainer.width, 
										topContainer.y + topContainer.height,
										w - (leftContainer.width + rightContainer.width),
										h - (topContainer.height + bottomContainer.height));
										
			topContainer.width = bottomContainer.width 
				= chartBounds.width;
			leftContainer.height = rightContainer.height 
				= chartBounds.height;
			
			// the z container is placed at the right of the chart
  			zContainer.x = int(chartBounds.width + leftContainer.width);
			zContainer.y = int(chartBounds.height);

			if (showGrid)
				drawGrid();
				
			if (axesFeeded && (_elementsContainer.x != chartBounds.x ||
				_elementsContainer.y != chartBounds.y ||
				_elementsContainer.width != chartBounds.width ||
				_elementsContainer.height != chartBounds.height))
			{
				_elementsContainer.x = chartBounds.x;
				_elementsContainer.y = chartBounds.y;
  				_elementsContainer.width = chartBounds.width;
				_elementsContainer.height = chartBounds.height;
 	
				// listeners like legends will listen to this event
				dispatchEvent(new Event("ProviderReady"));
				
				if (_is3D)
					rotationY = 42;
				else
					transform.matrix3D = null;
 			}
 			for (var i:int = 0; i<_elements.length; i++)
			{
				Surface(_elements[i]).width = chartBounds.width;
				Surface(_elements[i]).height = chartBounds.height;
				IElement(_elements[i]).drawElement();
			}
		}
		
		// other methods
		
		/** @Private
		 * Validate border containers sizes, that depend on the axes sizes that they contain.*/
		private function validateBounds():void
		{
			var tmpSize:Number = 0;
			for (var i:Number = 0; i<leftContainer.numChildren; i++)
			{
				tmpSize += XYZ(leftContainer.getChildAt(i)).maxLblSize;
				IScale(leftContainer.getChildAt(i)).size = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYZ(rightContainer.getChildAt(i)).maxLblSize;
				IScale(rightContainer.getChildAt(i)).size = rightContainer.height;				
			}
			
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYZ(bottomContainer.getChildAt(i)).maxLblSize;
				IScale(bottomContainer.getChildAt(i)).size = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYZ(topContainer.getChildAt(i)).maxLblSize;
				IScale(topContainer.getChildAt(i)).size = topContainer.width;
			}
			
			topContainer.height = tmpSize;
		}
		
		private var currentElement:IElement;
		/** @Private
		 * Feed the axes with either elements (for ex. CategorScale2) or max and min (for numeric axis).*/
		private function feedAxes():void
		{
			if (nCursors == elements.length)
			{
				var catElements:Array = [];
				var j:Number = 0;
				
				var maxMin:Array;
				
				// check if a default y axis exists
				if (scale2)
				{
					if (scale2 is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = IElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// Scale2, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.scale2)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(scale2).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(scale2).categoryField];
									currentElement.cursor.moveNext();
								}
							}
						}
						
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (catElements.indexOf(cursor.current[IEnumerableScale(scale2).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(scale2).categoryField];
								cursor.moveNext();
							}
						}

						// set the elements property of the CategorScale2
						if (catElements.length > 0)
							IEnumerableScale(scale2).dataProvider = catElements;
					} else {
						// if the default y axis is numeric, than calculate its min max values
						maxMin = getMaxMinYValueFromElementsWithoutScale2();
						INumerableScale(scale2).max = maxMin[0];
						INumerableScale(scale2).min = maxMin[1];
					}
				} 
				
				catElements = [];
				j = 0;

				// check if a default y axis exists
				if (scale1)
				{
					if (scale1 is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = IElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// Scale1, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.scale1)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(scale1).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(scale1).categoryField];
									currentElement.cursor.moveNext();
								}
							}
						}
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (catElements.indexOf(cursor.current[IEnumerableScale(scale1).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(scale1).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategorScale2
						if (catElements.length > 0)
							IEnumerableScale(scale1).dataProvider = catElements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinXValueFromElementsWithoutScale1();
						INumerableScale(scale1).max = maxMin[0];
						INumerableScale(scale1).min = maxMin[1];
					}
				} 
				
				catElements = [];
				j = 0;

				// check if a default z axis exists
				if (scale3)
				{
					if (scale3 is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = IElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// scale3, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.scale3)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(scale3).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(scale3).categoryField];
									currentElement.cursor.moveNext();
								}
							}
						}
						if (cursor)
						{
							cursor.seek(CursorBookmark.FIRST);
							while (!cursor.afterLast)
							{
								// if the category value already exists in the axis, than skip it
								if (catElements.indexOf(cursor.current[IEnumerableScale(scale3).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(scale3).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategorScale2
						if (catElements.length > 0)
							IEnumerableScale(scale3).dataProvider = catElements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinZValueFromElementsWithoutScale3();
						INumerableScale(scale3).max = maxMin[0];
						INumerableScale(scale3).min = maxMin[1];
					}
				} 

				// check if a default color axis exists
				if (colorAxis)
				{
						// if the default color axis is numeric, than calculate its min max values
						maxMin = getMaxMinColorValueFromElementsWithoutColorAxis();
						colorAxis.max = maxMin[0];
						colorAxis.min = maxMin[1];
				} 
				
				// init axes of all elements that have their own axes
				// since these are children of each elements, they are 
				// for sure ready for feeding and it won't affect the axesFeeded status
				for (var i:Number = 0; i<elements.length; i++)
					initElementsAxes(elements[i]);
					
				axesFeeded = true;
			}
		}
		
		/** @Private
		 * Calculate the min max values for the default x (x) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinXValueFromElementsWithoutScale1():Array
		{
			var max:Number = NaN, min:Number = NaN;

			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = IElement(elements[i]);
				// check if the elements has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.scale1 && (isNaN(max) || max < currentElement.maxDim1Value))
					max = currentElement.maxDim1Value;
				// check if the Element has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.scale1 && (isNaN(min) || min > currentElement.minDim1Value))
					min = currentElement.minDim1Value;
			}
					
			return [max,min];
		}
		
		
		/** @Private
		 * Calculate the min max values for the default vertical (y) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinYValueFromElementsWithoutScale2():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = IElement(elements[i]);
				// check if the elements has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.scale2 && (isNaN(max) || max < currentElement.maxDim2Value))
					max = currentElement.maxDim2Value;
				// check if the Element has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!currentElement.scale2 && (isNaN(min) || min > currentElement.minDim2Value))
					min = currentElement.minDim2Value;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default z axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinZValueFromElementsWithoutScale3():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = IElement(elements[i]);
				// check if the Element has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.scale3 && (isNaN(max) || max < currentElement.maxDim3Value))
					max = currentElement.maxDim3Value;
				// check if the Element has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.scale3 && (isNaN(min) || min > currentElement.minDim3Value))
					min = currentElement.minDim3Value;
			}
					
			return [max,min];
		}
		
		/** @Private
		 * Calculate the min max values for the default color axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinColorValueFromElementsWithoutColorAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = elements[i];
				if (currentElement.colorField)
				{
					// check if the Element has its own color axis and if its max value exists and 
					// is higher than the current max
					if (!currentElement.colorAxis && (isNaN(max) || max < currentElement.maxColorValue))
						max = currentElement.maxColorValue;
					// check if the Element has its own color axis and if its min value exists and 
					// is lower than the current min
					if (!currentElement.colorAxis && (isNaN(min) || min > currentElement.minColorValue))
						min = currentElement.minColorValue;
				}
			}
					
			return [max,min];
		}

		
		/** @Private
		 * Init the axes owned by the Element passed to this method.*/
		private function initElementsAxes(element:IElement):void
		{
			if (element.cursor)
			{
				var catElements:Array;
				var j:Number;

				element.cursor.seek(CursorBookmark.FIRST);
				
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
						
					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.scale1).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.scale1).categoryField];
						element.cursor.moveNext();
					}
					
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.scale1).dataProvider = catElements;
	
				} else if (element.scale1 is INumerableScale)
				{
					// if the x axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
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
				}
	
				element.cursor.seek(CursorBookmark.FIRST);
				
				if (element.scale2 is IEnumerableScale)
				{
					if (IEnumerableScale(element.scale2).dataProvider)
					{
						catElements = IEnumerableScale(element.scale2).dataProvider;
						j = catElements.length;
					} else {
						j = 0;
						catElements = [];
					}
						
					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.scale2).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.scale2).categoryField];
						element.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.scale2).dataProvider = catElements;
	
				} else if (element.scale2 is INumerableScale)
				{
					// if the y axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					// since the same scale can be shared among several elements, the precedent min and max
					// are also taken into account
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
	
				element.cursor.seek(CursorBookmark.FIRST);
				
				if (element.scale3 is IEnumerableScale)
				{	
					// if the scale dataProvider already exists than load it and update the index
					// in fact the same scale might be shared among several elements 
					if (IEnumerableScale(element.scale3).dataProvider)
					{
						catElements = IEnumerableScale(element.scale3).dataProvider;
						j = catElements.length;
					} else {
						j = 0;
						catElements = [];
					}

					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.scale3).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.scale3).categoryField];
						element.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.scale3).dataProvider = catElements;
	
				} else if (element.scale3 is INumerableScale)
				{
					// since the same scale can be shared among several elements, the precedent min and max
					// are also taken into account
					if (isNaN(INumerableScale(element.scale3).max))
						INumerableScale(element.scale3).max = element.maxDim3Value;
					else 
						INumerableScale(element.scale3).max =
							Math.max(INumerableScale(element.scale2).max, element.maxDim3Value);
					
					if (isNaN(INumerableScale(element.scale3).min))
						INumerableScale(element.scale3).min = element.minDim3Value;
					else 
						INumerableScale(element.scale3).min =
							Math.min(INumerableScale(element.scale3).min, element.minDim3Value);
				}

				if (element.colorAxis)
				{
					// if the axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					element.colorAxis.max =
						element.maxColorValue;
					element.colorAxis.min =
						element.minColorValue;
				}
			}
		}
		
		private var gridGG:GeometryGroup;
		protected function drawGrid():void
		{
			if (scale1 && scale2 && _elementsContainer.width>0 && _elementsContainer.height>0)
			{
				if (!gridGG)
				{
					gridGG = new GeometryGroup();
				}

				if (scale2 is INumerableScale)
				{
					var minY:Number = 0;
					var maxY:Number = scale2.size;
					
					// since the yAxis is up side down, the y interval is given by:
					var interval:Number = scale2.getPosition(INumerableScale(scale2).max - scale2.interval);
					var i:Number = 0;
					
					for (var yValue:Number = minY; yValue < maxY; yValue += interval)
					{
						var item:Line = Line(gridGG.geometryCollection.getItemAt(i));
						if (item)
						{
							item.x = 0;
							item.y = yValue;
							item.x1 = _elementsContainer.width;
							item.y1 = yValue;
						} else {
							item = new Line(0, yValue, scale1.size, yValue);
							item.stroke = new SolidStroke(_gridColor, _gridAlpha, _gridWeight)
							gridGG.geometryCollection.addItem(item);
						}
						i++;
					}
					
					var n:Number = gridGG.geometryCollection.items.length;
					if (i<n)
						for (var j:Number = n; j>=i; j--)
							gridGG.geometryCollection.removeItemAt(j);

					gridGG.target = _elementsContainer;
					_elementsContainer.graphicsCollection.addItem(gridGG);
				}
			}
		}
		
		/** @Private
		 * The creation of default axes can be overrided so that it's possible to 
		 * select a specific default setup. For example, for the bar chart the default 
		 * y axis is a category axis and the x one is linear.
		 * However if CartesianChart is used to build the chart, than a constant axis is used, 
		 * since the user might want to have a single axis only for the chart. 
		 * In this case the constant axis, returning a constant value for any input data,
		 * allows to have all shapes (plots, scatters, etc) aligned on the other remaining 
		 * axis's positions. */
		protected function createScale2():void
		{
				scale2 = new Constant();
				scale2.placement = BaseScale.LEFT;
		}
		/** @Private */
		protected function createScale1():void
		{
			scale1 = new Constant();
			scale1.placement = BaseScale.BOTTOM;
		}

		private function removeAllElements():void
		{
			var i:int; 
			var child:*;
			
			if (leftContainer)
			{
				for (i = 0; i<leftContainer.numChildren; i++)
				{
					child = leftContainer.getChildAt(0); 
					if (child is IScaleUI)
						IScaleUI(child).removeAllElements();
				}
				leftContainer.removeAllChildren();
			}

			if (rightContainer)
			{
				for (i = 0; i<rightContainer.numChildren; i++)
				{
					child = rightContainer.getChildAt(0); 
					if (child is IScaleUI)
						IScaleUI(child).removeAllElements();
				}
				rightContainer.removeAllChildren();
			}
			
			if (topContainer)
			{
				for (i = 0; i<topContainer.numChildren; i++)
				{
					child = topContainer.getChildAt(0); 
					if (child is IScaleUI)
						IScaleUI(child).removeAllElements();
				}
				topContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IScaleUI)
						IScaleUI(child).removeAllElements();
				}
				bottomContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IScaleUI)
						IScaleUI(child).removeAllElements();
				}
				bottomContainer.removeAllChildren();
			}

			if (_elementsContainer)
			{
	  			var nChildren:int = _elementsContainer.numChildren;
				for (i = 0; i<nChildren; i++)
				{
					child = _elementsContainer.getChildAt(0); 
					if (child is IElement)
						IElement(child).removeAllElements();
					_elementsContainer.removeChildAt(0);
				}
			}
		}
	}
}