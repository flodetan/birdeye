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
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	
	import birdeye.vis.VisScene;
	import birdeye.vis.scales.BaseScale;
	import birdeye.vis.scales.*;
	import birdeye.vis.elements.geometry.CartesianElement;
	import birdeye.vis.interfaces.*;
	
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
	 * for CategoryAxis, etc).
	 * 
	 * A CartesianChart may have multiple and different type of element, multiple axes and 
	 * multiple dataProvider(s).
	 * Most of available cartesian charts are also 3D. If a element specifies the zField, than the chart will
	 * be a 3D chart. By default zAxis is placed at the bottom right of the chart, for this reason it's
	 * recommended to place yAxis to the left of the chart when using 3D charts.
	 * Given the current 3D limitations of the FP platform, for which is not possible to draw
	 * real 3D graphics (moveTo, drawRect, drawLine etc don't include the z coordinate), the AreaChart 
	 * and LineChart are not 3D yet. 
	 * */ 
	[DefaultProperty("dataProvider")]
	[Exclude(name="elementsContainer", kind="property")]
	public class Cartesian extends VisScene
	{
		/** Array of elements, mandatory for any cartesian chart.
		 * Each element must implement the ICartesianElement interface which defines 
		 * methods that allow to set fields, basic styles, axes, dataproviders, renderers,
		 * max and min values, etc. Look at the ICartesianElement for more details.
		 * Each element can define its own axes, which will have higher priority over the axes
		 * that are provided by the dataProvider (a cartesian chart). In case no axes are 
		 * defined for the element, than those of the data provider are used. 
		 * The data provider (cartesian chart) axes values (min, max, etc) are calculated 
		 * based on the group of element that share them.*/
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.ICartesianElement")]
        [ArrayElementType("birdeye.vis.interfaces.ICartesianElement")]
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
				if (! ICartesianElement(_elements[i]).xAxis)
					needDefaultXAxis = true;

				// if the element doesn't have an own y axis, than
				// it's necessary to create a default y axis inside the
				// cartesian chart. This axis will be shared by all elements that
				// have no own y axis
				if (! ICartesianElement(_elements[i]).yAxis)
					needDefaultYAxis = true;
					
				// set the chart target inside the element to 'this'
				// in the future the element target could be an external chart 
				if (! ICartesianElement(_elements[i]).chart)
					ICartesianElement(_elements[i]).chart = this;
					
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

		private var _is3D:Boolean = false;
		public function get is3D():Boolean
		{
			return _is3D;
		}

		protected var needDefaultXAxis:Boolean;
		protected var needDefaultYAxis:Boolean;
		protected var _xAxis:IScaleUI;
		/** Define the x axis. If it has not defined its placement, than set it to BOTTOM*/ 
		public function set xAxis(val:IScaleUI):void
		{
			_xAxis = val;
			if (_xAxis.placement != BaseScale.BOTTOM && _xAxis.placement != BaseScale.TOP)
				_xAxis.placement = BaseScale.BOTTOM;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get xAxis():IScaleUI
		{
			return _xAxis;
		}

		protected var _yAxis:IScaleUI;
		/** Define the y axis. If it has not defined its placement, than set it to TOP*/ 
		public function set yAxis(val:IScaleUI):void
		{
			_yAxis = val;
			if (_yAxis.placement != BaseScale.LEFT && _yAxis.placement != BaseScale.RIGHT)
				_yAxis.placement = BaseScale.LEFT;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get yAxis():IScaleUI
		{
			return _yAxis;
		}

 		protected var _zAxis:IScaleUI;
		/** Define the z axis. If it has not defined its placement, than set it to DIAGONAL*/ 
		public function set zAxis(val:IScaleUI):void
		{
			_zAxis = val;
			if (_zAxis.placement != BaseScale.DIAGONAL)
				_zAxis.placement = BaseScale.DIAGONAL;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get zAxis():IScaleUI
		{
			return _zAxis;
		}

		// UIComponent flow

		public function Cartesian() 
		{
			super();
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
			needDefaultXAxis = needDefaultYAxis = false;
			
			removeAllElements();
			
			nCursors = 0;
			
			if (elements)
			{
 				for (var i:int = 0; i<elements.length; i++)
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
					var xAxis:IScaleUI = ICartesianElement(elements[i]).xAxis;
					if (xAxis)
					{
						switch (xAxis.placement)
						{
							case BaseScale.TOP:
								topContainer.addChild(DisplayObject(xAxis));
								break; 
							case BaseScale.BOTTOM:
								bottomContainer.addChild(DisplayObject(xAxis));
								break;
						}
					} else 
						needDefaultXAxis = true;
						
					var yAxis:IScaleUI = ICartesianElement(elements[i]).yAxis;
					if (yAxis)
					{
						switch (yAxis.placement)
						{
							case BaseScale.LEFT:
								leftContainer.addChild(DisplayObject(yAxis));
								break;
							case BaseScale.RIGHT:
								rightContainer.addChild(DisplayObject(yAxis));
								break;
						}
					} else 
						needDefaultYAxis = true;

					var tmpZAxis:IScaleUI = ICartesianElement(elements[i]).zAxis;
					if (tmpZAxis)
					{
						zContainer.addChild(DisplayObject(tmpZAxis));
						
						// this will be replaced by a depth property 
 						IScale(tmpZAxis).size = width; 
 						// the zAxis is in reality an yAxis which is rotated of 90 degrees
 						// on its X coordinate. This will be replaced by a real z axis, when 
 						// FP will provide methods to draw real 3d lines
						zContainer.rotationX = -90;
						
						// this adjusts the positioning of the axis after the rotation
						zContainer.z = width;
						_is3D = true;
 					}
				}
			}

			if (_zAxis)
			{
				_is3D = true;
				zContainer.addChild(DisplayObject(_zAxis));
				// this will be replaced by a depth property 
 				IScale(_zAxis).size = width; 
 				// the zAxis is in reality an yAxis which is rotated of 90 degrees
 				// on its X coordinate. This will be replaced by a real z axis, when 
 				// FP will provide methods to draw real 3d lines
				zContainer.rotationX = -90;
				// this adjusts the positioning of the axis after the rotation
				zContainer.z = width;
			}
			
			// if some elements have no own y axis, than create a default one for the chart
			// that will be used by all elements without a y axis
 			if (needDefaultYAxis)
			{
				if (!_yAxis)
					createYAxis();
					
				if (_yAxis.placement == BaseScale.RIGHT)
					rightContainer.addChild(DisplayObject(_yAxis));
				else
					leftContainer.addChild(DisplayObject(_yAxis));
			}
 			// if some elements have no own x axis, than create a default one for the chart
			// that will be used by all elements without a x axis
			if (needDefaultXAxis)
			{
				if (!_xAxis)
					createXAxis();

				if (_xAxis.placement == BaseScale.TOP)
					topContainer.addChild(DisplayObject(_xAxis));
				else
					bottomContainer.addChild(DisplayObject(_xAxis));
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
    			for (var i:int = 0; i<_elements.length; i++)
				{
					CartesianElement(_elements[i]).width = chartBounds.width;
					CartesianElement(_elements[i]).height = chartBounds.height;
				}
 	
				// listeners like legends will listen to this event
				dispatchEvent(new Event("ProviderReady"));
				
				if (_is3D)
					rotationY = 42;
				else
					transform.matrix3D = null;
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
				tmpSize += XYZAxis(leftContainer.getChildAt(i)).maxLblSize;
				IScale(leftContainer.getChildAt(i)).size = leftContainer.height;
			}
			
			leftContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<rightContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(rightContainer.getChildAt(i)).maxLblSize;
				IScale(rightContainer.getChildAt(i)).size = rightContainer.height;				
			}
			
			rightContainer.width = tmpSize;
			tmpSize = 0;

			for (i = 0; i<bottomContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(bottomContainer.getChildAt(i)).maxLblSize;
				IScale(bottomContainer.getChildAt(i)).size = bottomContainer.width;
			}
			
			bottomContainer.height = tmpSize;
			tmpSize = 0;

			for (i = 0; i<topContainer.numChildren; i++)
			{
				tmpSize += XYZAxis(topContainer.getChildAt(i)).maxLblSize;
				IScale(topContainer.getChildAt(i)).size = topContainer.width;
			}
			
			topContainer.height = tmpSize;
		}
		
		private var currentElement:ICartesianElement;
		/** @Private
		 * Feed the axes with either elements (for ex. CategoryAxis) or max and min (for numeric axis).*/
		private function feedAxes():void
		{
			if (nCursors == elements.length)
			{
				var catElements:Array = [];
				var j:Number = 0;
				
				var maxMin:Array;
				
				// check if a default y axis exists
				if (yAxis)
				{
					if (yAxis is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = ICartesianElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// yAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.yAxis)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(yAxis).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(yAxis).categoryField];
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
								if (catElements.indexOf(cursor.current[IEnumerableScale(yAxis).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(yAxis).categoryField];
								cursor.moveNext();
							}
						}

						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							IEnumerableScale(yAxis).dataProvider = catElements;
					} else {
						// if the default y axis is numeric, than calculate its min max values
						maxMin = getMaxMinYValueFromElementsWithoutYAxis();
						INumerableScale(yAxis).max = maxMin[0];
						INumerableScale(yAxis).min = maxMin[1];
					}
				} 
				
				catElements = [];
				j = 0;

				// check if a default y axis exists
				if (xAxis)
				{
					if (xAxis is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = ICartesianElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// xAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.xAxis)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(xAxis).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(xAxis).categoryField];
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
								if (catElements.indexOf(cursor.current[IEnumerableScale(xAxis).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(xAxis).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							IEnumerableScale(xAxis).dataProvider = catElements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinXValueFromElementsWithoutXAxis();
						INumerableScale(xAxis).max = maxMin[0];
						INumerableScale(xAxis).min = maxMin[1];
					}
				} 
				
				catElements = [];
				j = 0;

				// check if a default z axis exists
				if (zAxis)
				{
					if (zAxis is IEnumerableScale)
					{
						for (i = 0; i<nCursors; i++)
						{
							currentElement = ICartesianElement(_elements[i]);
							// if the elements have their own data provider but have not their own
							// zAxis, than load their elements and add them to the elements
							// loaded by the chart data provider
							if (currentElement.dataProvider 
								&& currentElement.dataProvider != dataProvider
								&& ! currentElement.zAxis)
							{
								currentElement.cursor.seek(CursorBookmark.FIRST);
								while (!currentElement.cursor.afterLast)
								{
									if (catElements.indexOf(
										currentElement.cursor.current[IEnumerableScale(zAxis).categoryField]) 
										== -1)
										catElements[j++] = 
											currentElement.cursor.current[IEnumerableScale(zAxis).categoryField];
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
								if (catElements.indexOf(cursor.current[IEnumerableScale(zAxis).categoryField]) == -1)
									catElements[j++] = 
										cursor.current[IEnumerableScale(zAxis).categoryField];
								cursor.moveNext();
							}
						}
						
						// set the elements property of the CategoryAxis
						if (catElements.length > 0)
							IEnumerableScale(zAxis).dataProvider = catElements;
					} else {
						// if the default x axis is numeric, than calculate its min max values
						maxMin = getMaxMinZValueFromElementsWithoutZAxis();
						INumerableScale(zAxis).max = maxMin[0];
						INumerableScale(zAxis).min = maxMin[1];
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
		 * Calculate the min max values for the default vertical (y) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinYValueFromElementsWithoutYAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = ICartesianElement(elements[i]);
				// check if the elements has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.yAxis && (isNaN(max) || max < currentElement.maxYValue))
					max = currentElement.maxYValue;
				// check if the Element has its own y axis and if its min value exists and 
				// is lower than the current min
				if (!currentElement.yAxis && (isNaN(min) || min > currentElement.minYValue))
					min = currentElement.minYValue;
			}
					
			return [max,min];
		}

		/** @Private
		 * Calculate the min max values for the default x (x) axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinXValueFromElementsWithoutXAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;

			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = ICartesianElement(elements[i]);
				// check if the elements has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.xAxis && (isNaN(max) || max < currentElement.maxXValue))
					max = currentElement.maxXValue;
				// check if the Element has its own x axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.xAxis && (isNaN(min) || min > currentElement.minXValue))
					min = currentElement.minXValue;
			}
					
			return [max,min];
		}
		
		
		/** @Private
		 * Calculate the min max values for the default z axis. Return an array of 2 values, the 1st (0) 
		 * for the max value, and the 2nd for the min value.*/
		private function getMaxMinZValueFromElementsWithoutZAxis():Array
		{
			var max:Number = NaN, min:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = ICartesianElement(elements[i]);
				// check if the Element has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.zAxis && (isNaN(max) || max < currentElement.maxZValue))
					max = currentElement.maxZValue;
				// check if the Element has its own z axis and if its max value exists and 
				// is higher than the current max
				if (!currentElement.zAxis && (isNaN(min) || min > currentElement.minZValue))
					min = currentElement.minZValue;
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
		private function initElementsAxes(element:ICartesianElement):void
		{
			if (element.cursor)
			{
				var catElements:Array = [];
				var j:Number = 0;

				element.cursor.seek(CursorBookmark.FIRST);
				
				if (element.xAxis is IEnumerableScale)
				{
					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.xAxis).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.xAxis).categoryField];
						element.cursor.moveNext();
					}
					
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.xAxis).dataProvider = catElements;
	
				} else if (element.xAxis is INumerableScale)
				{
					// if the x axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					INumerableScale(element.xAxis).max =
						element.maxXValue;
					INumerableScale(element.xAxis).min =
						element.minXValue;
				}
	
				catElements = [];
				j = 0;
				element.cursor.seek(CursorBookmark.FIRST);
				
				if (element.yAxis is IEnumerableScale)
				{
					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.yAxis).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.yAxis).categoryField];
						element.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.yAxis).dataProvider = catElements;
	
				} else if (element.yAxis is INumerableScale)
				{
					// if the y axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					INumerableScale(element.yAxis).max =
						element.maxYValue;
					INumerableScale(element.yAxis).min =
						element.minYValue;
				}
	
				catElements = [];
				j = 0;
				element.cursor.seek(CursorBookmark.FIRST);
				
				if (element.zAxis is IEnumerableScale)
				{
					while (!element.cursor.afterLast)
					{
						// if the category value already exists in the axis, than skip it
						if (catElements.indexOf(element.cursor.current[IEnumerableScale(element.zAxis).categoryField]) == -1)
							catElements[j++] = 
								element.cursor.current[IEnumerableScale(element.zAxis).categoryField];
						element.cursor.moveNext();
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(element.zAxis).dataProvider = catElements;
	
				} else if (element.zAxis is INumerableScale)
				{
					// if the axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					INumerableScale(element.zAxis).max =
						element.maxZValue;
					INumerableScale(element.yAxis).min =
						element.minZValue;
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
			if (xAxis && yAxis && _elementsContainer.width>0 && _elementsContainer.height>0)
			{
				if (!gridGG)
				{
					gridGG = new GeometryGroup();
				}

				if (yAxis is INumerableScale)
				{
					var minY:Number = 0;
					var maxY:Number = yAxis.size;
					
					// since the yAxis is up side down, the y interval is given by:
					var interval:Number = yAxis.getPosition(INumerableScale(yAxis).max - yAxis.interval);
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
							item = new Line(0, yValue, xAxis.size, yValue);
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
		protected function createYAxis():void
		{
				yAxis = new ConstantAxis();
				yAxis.placement = BaseScale.LEFT;
		}
		/** @Private */
		protected function createXAxis():void
		{
			xAxis = new ConstantAxis();
			xAxis.placement = BaseScale.BOTTOM;
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