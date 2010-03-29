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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.BaseDataElement;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.interfaces.coords.IValidatingCoordinates;
	import birdeye.vis.interfaces.elements.IElement;
	import birdeye.vis.interfaces.elements.IStack;
	import birdeye.vis.interfaces.guides.IGuide;
	import birdeye.vis.interfaces.interactivity.IInteractivityManager;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.BaseScale;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	
	import org.greenthreads.IGuideThread;
	import org.greenthreads.IThread;
	import org.greenthreads.ThreadProcessor;
	
	
	
	public class BaseCoordinates extends VisScene implements IValidatingCoordinates
	{
		public function BaseCoordinates(interactivityMgr:IInteractivityManager = null)
		{
			super(interactivityMgr);				
		}

		
		
		protected var _collisionType:String = StackElement.OVERLAID;
		/** Set the type of stack, overlaid if the series are shown on top of the other, 
		 * or stacked if they appear staked one after the other (horizontally), or 
		 * stacked100 if the columns are stacked one after the other (vertically).*/
		[Inspectable(enumeration="overlaid,cluster,stack")]
		public function set collisionType(val:String):void
		{
			_collisionType = val;
			axesFeeded = false;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get collisionType():String
		{
			return _collisionType;
		}
		
		
		private var _sharedScales:Boolean = false;
		/**
		 * Indicates of the scales that are used are shared over several basecoordinates.</br>
		 * If so these scales can not be reset by this coordinate system but need to be reset globally.</br>
		 * @default false
		 */
		public function set sharedScales(s:Boolean):void
		{
			_sharedScales = s;	
		}
		
		public function get sharedScales():Boolean
		{
			return _sharedScales;
		}
		
		override public function invalidateProperties() : void
		{
			super.invalidateProperties();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (active && dataItems)
			{

				nCursors = 0;
				if (guides)
				{
					_guidesChanged = false;
					placeGuides();
				}	
				// data structure to count different type of stackable elements		
				var countStackableElements:Array = [];
				
				if (elements)
				{
					_elementsChanged = false;
					placeElements();

					var nCursors:uint = initElements(countStackableElements);
					
					if (nCursors == elements.length)
					{
						invalidatedData = true;
					}
					else
					{
						invalidatedData = false;
					}
					
					placeTooltipLayer();
				}
				
				if (invalidatedData)
				{
					initStackElements(countStackableElements);
				
					if (!axesFeeded)
					{
						feedScales();
					}
				}
			}
			
			
		}
		
		
		protected var _invalidatedElements:Array = [];
		
		public function invalidateElement(element:IElement=null):void
		{
			if (!element)
			{
				_invalidatedElements = elements.slice();
			}
			else
			{
				if (_invalidatedElements.indexOf(element) == -1)
				{
					_invalidatedElements.push(element);
				}
			}
			
			invalidateDisplayList();
		}
		
		
		protected var _invalidatedGuides:Array = [];
		
		public function invalidateGuide(guide:IGuide=null):void
		{
			if (!guide)
			{
				_invalidatedGuides = guides.slice();
			}
			else if (_invalidatedGuides.indexOf(guide) == -1)
			{
				_invalidatedGuides.push(guide);
			}
				
			invalidateDisplayList();
		}
		
				
		
		/**
		 * This function loops all guides,</br>
		 * init's each guide</br>
		 * and calls the <code>placeGuide</code> function.
		 */
		protected function placeGuides():void
		{
			for each (var guide:IGuide in guides)
			{
				guide.coordinates = this;
				
				placeGuide(guide);

			}
			
			invalidateGuide();
			
		}
		
		/**
		 * At this level the guide is told to draw to the elementsContainer</br>
		 * Override this function if more detailed placement of a guide is possible.</br>
		 */		
		protected function placeGuide(guide:IGuide):void
		{
		
		}
		
		

		

		
		// temporary data structure to keep track of stacked elements
		protected var _stackedElements:Array = [];
		protected var _drawElements:Boolean = false;
		/**
		 * This functions loops all elements,</br>
		 * init's each element (by calling <code>initElement</code>)</br>
		 * and places the element (by calling <code>placeElement</code>)</br>
		 */
		protected function placeElements():void
		{
			for each (var element:IElement in elements)
			{	
				placeElement(element);
			}
			
			invalidateElement();
			
		}
		
		protected function initElements(countStackableElements:Array):uint
		{
			_stackedElements = [];
			var nCursors:uint = 0;
			for each (var element:IElement in elements)
			{
				nCursors += initElement(element, countStackableElements);
			}
			
			return nCursors;
		}
		
		
		/**
		 * This function inits the specified element.</br>
		 * Override this function if extra functionality is needed.</br> 
		 */
		protected function initElement(element:IElement, countStackableElements:Array):uint
		{
			// TODO create a better way for this
			// the element has it's validateProperties called as otherway a dataProvider inside
			// the element (different of the chart) is not converted to dataItems in time...
			UIComponent(element).validateProperties();
			// if element dataprovider doesn' exist or it refers to the
			// chart dataProvider, than set its cursor to this chart cursor (this.cursor)
			if (dataItems && (! element.dataProvider 
							|| element.dataProvider == this.dataProvider))
				element.dataItems = dataItems;
				
			if (element is IStack)
			{				
				_stackedElements.push(element);
				IStack(element).stackType = _collisionType;
				// count all stackable elements according their type (overlaid, stacked100...)
				// and store its position. This allows to have a general CartesianChart 
				// elements that are stackable, where the type of stack used is defined internally
				// the elements itself. In case BarChart, AreaChart or ColumnChart are used, than
				// the elements stack type is definde directly by the chart.
				// however the following allows keeping the possibility of using stackable elements inside
				// a general cartesian chart
				if (isNaN(countStackableElements[IStack(element).elementType]) || countStackableElements[IStack(element).elementType] == undefined) 
					countStackableElements[IStack(element).elementType] = 1;
				else 
					countStackableElements[IStack(element).elementType] += 1;
					
				IStack(element).stackPosition = countStackableElements[IStack(element).elementType] - 1; // position is current total - 1 
			}
			
			// nCursors is used in feedAxes to check that all elements cursors are ready
			// and therefore check that axes can be properly feeded
			if (dataItems || element.dataItems)
				return 1;
				
			return 0;
		}
		
		/**
		 * This function places the specified element.</br>
		 * At this level the element is placed into the elementscontainer.</br>
		 * Override this function if extra functionality if needed.
		 */
		protected function placeElement(element:IElement):void
		{
			if (!_elementsContainer.contains(DisplayObject(element)) )
			{
				_elementsContainer.addChild(DisplayObject(element));
			}
		}
		
		private var categoryMaxStacked100:Dictionary;
		/**
		 * This functions init the necessary datastructure in the stack elements</br>
		 * This function only executes if the type is stacked100.</br>
		 */
		protected function initStackElements(countStackableElements:Array):void
		{
			for each (var stackElement:IStack in _stackedElements)
			{
				// if an element is stackable, than its total property 
				// represents the number of all stackable elements with the same type inside the
				// same chart. This allows having multiple elements type inside the same chart (TODO) 
				stackElement.total = countStackableElements[stackElement.elementType];
			}
			
			// only execute the rest if the type is stacked100
			if (_collisionType != StackElement.STACKED) return;
			
			var allElementsBaseAndTopValues:Array = []; 
			for (var i:int=0;i<_stackedElements.length;i++)
				allElementsBaseAndTopValues[i] = {indexElements: i, baseValues: new Dictionary(), topValues: new Dictionary()};
			
			_maxStacked100 = NaN;
			
			// datastructure to keep track of the last processed stack element per
			// category or angle or ... 
			var lastProcessedStackElements:Array = new Array();
			var position:uint = 0;
			categoryMaxStacked100 = new Dictionary();
			for each (stackElement in _stackedElements)
			{
				initStackElement(stackElement, position++, allElementsBaseAndTopValues, lastProcessedStackElements);
			}
			
			// set the base values that we're calculated 
			for (var s:uint = 0;s<_stackedElements.length; s++)
			{
				IStack(_stackedElements[s]).baseValues = allElementsBaseAndTopValues[s].baseValues;		
				IStack(_stackedElements[s]).topValues = allElementsBaseAndTopValues[s].topValues;		
				IStack(_stackedElements[s]).maxCategoryValues = categoryMaxStacked100;		
			}
		}
		
		/**
		 * Init a specific stack element.</br>
		 * @param stackElement The stack element to init
		 * @param elementPosition The position of the stack element
		 * @param countStackableElements The total number of stack elements per elementType
		 * @param allElementsBaseValues Data structure to keep track of all the base values per element
		 * @param lastProcessedStackElements Data structure to keep track of the last processed stack element per category or angle or...
		 */
		protected function initStackElement(stackElement:IStack, elementPosition:uint, allElementsBaseAndTopValues:Array, lastProcessedStackElements:Array):void
		{
			 	
			
			var usedDataItems:Vector.<Object> = dataItems;
			
			// change the used data items if the element has other data items than the main dataitems
			if (stackElement.dataItems && stackElement.dataItems != dataItems)
			{
				usedDataItems = stackElement.dataItems;
			}
			
			if (usedDataItems == null) return;
			
			// determine which dimension is used for the index of the element
			// and which dimension is used for plotting
			var dims:Object = determineStackedDimensions(stackElement);
			
			for (var cursIndex:uint = 0; cursIndex < usedDataItems.length; cursIndex++)
			{
				var currentItem:Object = usedDataItems[cursIndex];

				// TODO: if dim is an Array, than iterate through it
				// determine the value of the index dimension
				var indexValue:Object = currentItem[stackElement[dims.indexDim]];
				
				// determine which index of stack element was processed before at this index
				var lastProcessedStackElementIndex:Number = lastProcessedStackElements[indexValue];
				
				// determine the maximum of the current element
				var maxCurrentD2:Number = getDimMaxValue(currentItem, stackElement[dims.valueDim], stackElement.collisionType == StackElement.STACKED);

				// if we are not the first and there was somebody before us
				// calculate new positions
				if (elementPosition>0 && lastProcessedStackElementIndex>=0)
				{
					// determine the previous stack element
					var lastProcessedStackElement:IStack = _stackedElements[lastProcessedStackElementIndex];
					
					// store this maximum in the basevalues of the element
					allElementsBaseAndTopValues[elementPosition].baseValues[indexValue] = allElementsBaseAndTopValues[lastProcessedStackElementIndex].topValues[indexValue];
				} 
				else
				{ 
					// no previous elements or we are first
					// set to 0
					allElementsBaseAndTopValues[elementPosition].baseValues[indexValue] = 0;
				}
				
				var localMax:Number = allElementsBaseAndTopValues[elementPosition].baseValues[indexValue] + Math.max(0,isNaN(maxCurrentD2) ? 0 : maxCurrentD2);
				allElementsBaseAndTopValues[elementPosition].topValues[indexValue] = localMax;

				categoryMaxStacked100[indexValue] = localMax;
				
				// update maxStacked100 if necessary
				if (isNaN(_maxStacked100))
				{
					_maxStacked100 = localMax;
				}
				else
				{
					_maxStacked100 = Math.max(_maxStacked100,localMax);
				}				
				// store this element's position as the last processed stack element at index j	
				lastProcessedStackElements[indexValue] = elementPosition;	
				
			}
		}
		
		/**
		 * Return an object which describes which dimension is used for looking up the index of the IStack</br>
		 * and which dimension is used to look up the plot value.</br>
		 * @return Object.indexDim is the index dimension , Object.valueDim is the plotting dimension
		 */
		protected function determineStackedDimensions(stack:IStack):Object
		{
			var toReturn:Object = new Object();
			toReturn.indexDim = "dim1";
			toReturn.valueDim = "dim2";
			
			if (stack.collisionScale == BaseDataElement.SCALE1)
			{
				toReturn.indexDim = "dim2";
				toReturn.valueDim = "dim1";		
			}
			
			return toReturn;
		}
		
		protected function feedScales():void
		{
			if (!scales) return;
			
			if (!sharedScales)
			{
				resetScales();
			}
			// init axes of all elements that have their own axes
			// since these are children of each elements, they are 
			// for sure ready for feeding and it won't affect the axesFeeded status
			var elementsMinMax:Array = [];
			for (var i:Number = 0; i<elements.length; i++)
				initElementsScales(elements[i], elementsMinMax);
			
			//if (elementsMinMax.length > 0)
			//{
				for ( i = 0;i<scales.length;i++)
				{
					if (scales[i] && scales[i] is ISubScale && (scales[i] as ISubScale).subScalesActive)
					{
						(scales[i] as ISubScale).feedMinMax(elementsMinMax);
					}
				}
			//}
			
			commitValidatingScales();
			
			axesFeeded = true;
				
		}
		
		/** @Private
		 * Init the axes owned by the Element passed to this method.*/
		protected function initElementsScales(element:IElement, elementsMinMax:Array):void
		{
			if (element.dataItems)
			{				
				if (element.scale1) updateScale(element.scale1, element, elementsMinMax, "Dim1");
				if (element.scale2) updateScale(element.scale2, element, elementsMinMax, "Dim2");
				if (element.scale3) updateScale(element.scale3, element, elementsMinMax, "Dim3");
				if (element.colorScale) updateScale(element.colorScale, element, elementsMinMax, "Color");
				if (element.sizeScale) updateScale(element.sizeScale, element, elementsMinMax, "Size");					
			}
		}
		
		
		protected function updateScale(scale:IScale, element:IElement, elementsMinMax:Array, dim:Object):void
		{	
			// nothing to update...
			if (!scale || !element) return;

			if (!scale.parent) scale.parent = this;
			
			if (dim == "Dim1")
			{
				scale.dimension = BaseScale.DIMENSION_1;
			}
			else if (dim == "Dim2")
			{
				scale.dimension = BaseScale.DIMENSION_2;	
			}
			else if (dim == "Dim3")
			{
				scale.dimension = BaseScale.DIMENSION_3;	
			}
				
			if (!scale.dataValues)
			{
				
				if (scale is IEnumerableScale)
				{
					var catElements:Array = [];
					var j:uint = 0;
					
					if (IEnumerableScale(scale).dataProvider)
					{
						catElements = IEnumerableScale(scale).dataProvider;
						j = catElements.length;
					}
						
					for (var cursIndex:uint = 0; cursIndex<element.dataItems.length; cursIndex++)
					{
						var currentItem:Object = element.dataItems[cursIndex];
						var category:Object = currentItem[IEnumerableScale(scale).categoryField];

						// if the category value already exists in the axis, than skip it
						if (category && catElements.indexOf(category) == -1)
							catElements[j++] = category;
								
						if (scale is ISubScale && (scale as ISubScale).subScalesActive)
						{
							if (!elementsMinMax[category])
							{
								elementsMinMax[category] = {min: int.MAX_VALUE, max:int.MIN_VALUE};
							}
							
							// this has a hard coded  dim2
							// this is NOT good
							var maxDim2:Number = getDimMaxValue(currentItem, element.dim2, element.collisionType == StackElement.STACKED);
							var minDim2:Number = getDimMinValue(currentItem, element.dim2);
							if (!isNaN(minDim2))
							{
								elementsMinMax[category].min = Math.min(elementsMinMax[category].min, minDim2);
							}

							if (_collisionType == StackElement.STACKED)
								elementsMinMax[category].max = categoryMaxStacked100[category];
							else 
							{
								if (!isNaN(maxDim2))
								{
									elementsMinMax[category].max = Math.max(elementsMinMax[category].max, maxDim2);
								}
							}
							
						}
					}
							
					// set the elements propery of the CategoryAxis owned by the current element
					if (catElements.length > 0)
						IEnumerableScale(scale).dataProvider = catElements;
	
				} 
				else if (scale is INumerableScale)
				{
					// if the y axis is numeric than set its maximum and minimum values 
					// if the max and min are not yet defined for the element, than they are calculated now
					// since the same scale can be shared among several elements, the precedent min and max
					// are also taken into account
					if (INumerableScale(scale).scaleType != BaseScale.PERCENT)
                    { 
                    	var maxValue:Number = element["max"+dim+"Value"];
                    	var minValue:Number = element["min"+dim+"Value"];
                    	
                    	if (!isNaN(maxValue))
                    	{
	                    	                   
							if (isNaN(INumerableScale(scale).max))
							{
								INumerableScale(scale).max = maxValue; // TODO change this to a 'cleaner' technique?
							}
							else 
							{
								INumerableScale(scale).max = Math.max(INumerableScale(scale).max, maxValue);
							}
                    	}
                    	
                    	if (!isNaN(minValue))
                    	{
							if (isNaN(INumerableScale(scale).min))
							{
								INumerableScale(scale).min = minValue;
							}	
							else
							{ 
								INumerableScale(scale).min = Math.min(INumerableScale(scale).min, minValue);
							}
                    	}
                    }
                    else
                    {
                    	var totPosValue:Number = element["total"+dim+"PositiveValue"];
                    	if (!isNaN(totPosValue))
                    	{
	                    	
	                    	if (isNaN(INumerableScale(scale).totalPositiveValue))
	                    	{
	                            INumerableScale(scale).totalPositiveValue = totPosValue;
	                    	}
	                        else
	                        {
	                            INumerableScale(scale).totalPositiveValue += totPosValue;
	                        }
                    	}
                    }
				}
			}
		}
		
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
			if (active)
			{		

trace(getTimer(), "updateDisplaylist", unscaledWidth, unscaledHeight);		
				super.updateDisplayList(unscaledWidth, unscaledHeight);				

				setActualSize(unscaledWidth, unscaledHeight);
				
				if (this._tooltipLayer)
				{	
					this._tooltipLayer.width = unscaledWidth;
					this._tooltipLayer.height = unscaledHeight;
				}
				
				var invalidated:Boolean = validateBounds(unscaledWidth, unscaledHeight);
					
				trace("Bounds are " + invalidated);
				
				if (invalidated || !chartBounds)
				{
					setBounds(unscaledWidth, unscaledHeight);
				}
					
				updateElements(unscaledWidth, unscaledHeight);

				updateGuides(unscaledWidth, unscaledHeight);
				
				if (axesFeeded && (invalidatedData || invalidated))
				{

					drawElements(unscaledWidth, unscaledHeight);

					drawGuides(unscaledWidth, unscaledHeight);

					
					// listeners like legends will listen to this event
					dispatchEvent(new Event("ProviderReady", true));
					
					setMask();
					
				}
trace(getTimer(), "END updateDisplaylist", unscaledWidth, unscaledHeight);		
			}
		}
		
		private var oldWidth:Number = 0, oldHeight:Number = 0;
		
		/**
		 * Override this function to validate bounds.</br>
		 * For example if you need place to set axes, this is the place to calculate their sizes.</br>
		 */
		protected function validateBounds(unscaledWidth:Number, unscaledHeight:Number):Boolean
		{
			var invalidated:Boolean = false;
			
			// nothing happens at this level, the whole area is used to create a visualization
			if (unscaledHeight != oldHeight)
			{
				oldHeight = unscaledHeight;
				invalidated = true;
			}
			
			if (unscaledWidth != oldWidth)
			{
				oldWidth = unscaledWidth;
				invalidated = true;
			}
			
			if (invalidated)
			{
				// invalidate all elements
				invalidateElement();
				
				// invalidate all guides
				invalidateGuide();
				
			}
			
			return invalidated;
		}
		
		/** 
		 * Override this function to set bounds.</br>
		 * For example if the sizes of the container for  the axes are calculated, here you can set,</br>
		 * other container's positions based on these sizes.</br>
		 */
		protected function setBounds(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// nothing here at this level, whole area is for visualizing!
		}
		
		protected function updateElements(unscaledWidth:Number, unscaledHeight:Number):void
		{
			for (var i:Number = 0;i<_elements.length; i++)
			{
				updateElement(_elements[i], unscaledWidth, unscaledHeight);
			}
		}
		
		protected function updateElement(element:IElement, unscaledWidth:Number, unscaledHeight:Number):void
		{
			UIComponent(element).setActualSize(unscaledWidth, unscaledHeight);
			//DisplayObject(element).width = unscaledWidth;
			//DisplayObject(element).height = unscaledHeight;
		}
		
		protected function drawElements(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var poppedElement:IThread = _invalidatedElements.pop();
			
			while (poppedElement)
			{
				drawElement(poppedElement);
				
				poppedElement = _invalidatedElements.pop();
				
			} 
		}
		
		protected function drawElement(element:IThread):void
		{
			ThreadProcessor.getInstance().addThread(element);
		}
		
		protected function updateGuides(unscaledWidth:Number, unscaledHeight:Number):void
		{
			for each (var guide:IGuide in guides)
			{
				updateGuide(guide, unscaledWidth, unscaledHeight);
			}
		}
		
		protected function updateGuide(guide:IGuide, unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
		
		protected function drawGuides(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var poppedGuide:IGuideThread = _invalidatedGuides.pop();
			
			while (poppedGuide)
			{
				drawGuide(poppedGuide, unscaledWidth, unscaledHeight);
				
				poppedGuide = _invalidatedGuides.pop();
			}
			
		}
		
		protected function drawGuide(guide:IGuideThread, unscaledWidth:Number, unscaledHeight:Number):void
		{
			addGuideToThreads(guide, new Rectangle(0,0,unscaledWidth,unscaledHeight));
		}
		
		protected function addGuideToThreads(guide:IGuideThread, bounds:Rectangle):void
		{			
			guide.bounds = bounds;

			ThreadProcessor.getInstance().addThread(guide);
		}
		
		protected function setMask():void
		{
			if (_isMasked && _maskShape && !isNaN(_elementsContainer.width) && !isNaN(_elementsContainer.height))
			{
				if (!elementsContainer.contains(_maskShape))
					elementsContainer.addChild(_maskShape);
				maskShape.graphics.beginFill(0xffffff, 1);
				maskShape.graphics.drawRect(0,0,_elementsContainer.width, _elementsContainer.height);
				maskShape.graphics.endFill();
	  			elementsContainer.setChildIndex(_maskShape, 0);
				elementsContainer.mask = maskShape;
			}
		}
		
		/**
		 * Function to remove all elements.</br>
		 * @internal This is a function that deteriorates performance. In the future this should be used as less as possible.
		 */
		protected function removeAllElements():void
		{
			if (_elementsContainer)
			{
	  			var nChildren:int = _elementsContainer.numChildren;
				for (var i:int = 0; i<nChildren; i++)
				{
					var child:DisplayObject = _elementsContainer.getChildAt(0); 
						
					if (child is IGuide)
						IGuide(child).clearAll();
						
					if (child is DataItemLayout)
					{
						DataItemLayout(child).clearAll();
						DataItemLayout(child).geometryCollection.items = [];
						DataItemLayout(child).geometry = [];
					}
					
					_elementsContainer.removeChildAt(0);
				}
			}			
		}
		
	}
}