///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2009 Michael VanDaniker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////

package org.un.cava.birdeye.qavis.parallel
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;

	/**
	 * A parallel coordinate plot.
	 * 
	 * See http://en.wikipedia.org/wiki/Parallel_coordinates for details
	 */
	public class ParallelCoordinatePlot extends UIComponent
	{
		public function ParallelCoordinatePlot()
		{
			super();
			itemUpStroke = new Stroke(0xff,1);
			itemOverStroke = new Stroke(0xff0000,3,.5);
			itemSelectedStroke = new Stroke(0xff0000,3);
			addEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);
			addEventListener(MouseEvent.CLICK,handleMouseClick);
		}
		
		/**
		 * A UIComponent to hold the axis renderers
		 */
		protected var axesContainer:UIComponent;
		
		/**
		 * A BitmapData that PCP lines that are in the default "up" state will be drawn to.
		 */
		protected var upBitmapData:BitmapData;
		
		/**
		 * A BitmapData that PCP lines that are rolled over will be drawn to.
		 */
		protected var overBitmapData:BitmapData;
		
		/**
		 * A BitmapData that PCP lines that are selected will be drawn to.
		 */
		protected var selectedBitmapData:BitmapData;

		/**
		 * This BitmapData is used for hit detection. Each distinct line drawn on the
		 * Parallel Coordinate Plot is drawn in a different color in this BitmapData.
		 * By mapping the color under the mouse in this BitmapData, we can determine
		 * which line the mouse is over.   
		 */
		protected var hitTestBitmapData:BitmapData;
		
		/**
		 * An array of Objects extracted from the dataProvider
		 */
		protected var items:Array = [];
		
		/**
		 * A flag indicating that the axes renderers need to be recreated
		 */
		protected var axisRenderersDirty:Boolean = true;
		
		/**
		 * A flag indicating that the dataProvider has changed
		 */
		protected var dataProviderDirty:Boolean = true;
		
		/**
		 * The previous value of the width property
		 */
		protected var oldWidth:Number;
		
		/**
		 * The previous value of the height property
		 */
		protected var oldHeight:Number;
		
		/**
		 * A flag indicating that the upBitmapData needs to be updated
		 */
		protected var upBitmapDataDirty:Boolean = true;
		
		/**
		 * A flag indicating that the overBitmapData needs to be updated
		 */
		protected var overBitmapDataDirty:Boolean = true;
		
		/**
		 * A flag indicating that the selectedBitmapData needs to be updated
		 */
		protected var selectedBitmapDataDirty:Boolean = true;
		
		/**
		 * A hash mapping fieldNames to the minimum value of that field within the dataProvider
		 */
		protected var minHash:Object = new Object();
		
		/**
		 * A hash mapping fieldNames to the maximum value of that field within the dataProvider
		 */
		protected var maxHash:Object = new Object();
		
		protected var colorHash:FieldValuePairColorHash = new FieldValuePairColorHash();

		protected function set rolledOverParallelCoordinateItems(value:Array):void
		{
			var valueToAssign:Array = value == null ? [] : value;
			if(valueToAssign.toString() != _rolledOverParallelCoordinateItems)
			{
				_rolledOverParallelCoordinateItems = valueToAssign;
				overBitmapDataDirty = true;
				invalidateDisplayList();
			}
		}
		protected function get rolledOverParallelCoordinateItems():Array
		{
			return _rolledOverParallelCoordinateItems;
		}
		private var _rolledOverParallelCoordinateItems:Array;
		
		[Bindable(event="selectedItemsChange")]
		public function set selectedItems(value:Array):void
		{
			if(_selectedItems != value)
			{
				_selectedItems = value;
				selectedBitmapDataDirty = true;
				invalidateDisplayList();
				dispatchEvent(new Event("selectedItemsChange"));
			}
		}
		public function get selectedItems():Array
		{
			return _selectedItems;
		}
		private var _selectedItems:Array = [];
		
		[Bindable(event="axisRenderersChange")]
		/**
		 * An array of IParallelCoordinateAxisRenderers containing, from left to right, the axis renderers.
		 */
		public function set axisRenderers(value:Array):void
		{
			if(value != _axisRenderers)
			{
				_axisRenderers = value;
				axisRenderersDirty = true;
				invalidateProperties();
				invalidateSize();
				invalidateDisplayList();
				invalidateAllBitmapData();
				dispatchEvent(new Event("axisRenderersChange"));
			}
		}
		public function get axisRenderers():Array
		{
			return _axisRenderers;
		}
		private var _axisRenderers:Array = [];
		
		[Bindable(event="dataProviderChange")]
		/**
		 * An ArrayCollection of Objects to render on this ParallelCoordinatePlot
		 */
        public function get dataProvider():ArrayCollection
        {
			return _dataProvider;
        }
		public function set dataProvider(value:ArrayCollection):void
		{
			if(_dataProvider != value)
			{
				if (_dataProvider)
					_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
				_dataProvider = value;
				if(_dataProvider)
	            	_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
	            dispatchEvent(new Event("dataProviderChange"));
	            dataProviderDirty = true;
	            invalidateProperties();
	            invalidateAllBitmapData();
			}
        }
        private var _dataProvider:ArrayCollection;
        
        [Bindable(event="itemUpStrokeChange")]
		public function set itemUpStroke(value:IStroke):void
		{
			if(value != _itemUpStroke)
			{
				_itemUpStroke = value;
				upBitmapDataDirty = true;
				invalidateDisplayList();
				dispatchEvent(new Event("itemUpStrokeChange"));
			}
		}
		public function get itemUpStroke():IStroke
		{
			return _itemUpStroke;
		}
		private var _itemUpStroke:IStroke;
		
		[Bindable(event="itemOverStrokeChange")]
		public function set itemOverStroke(value:IStroke):void
		{
			if(value != _itemOverStroke)
			{
				_itemOverStroke = value;
				overBitmapDataDirty = true;
				invalidateDisplayList();
				dispatchEvent(new Event("itemOverStrokeChange"));
			}
		}
		public function get itemOverStroke():IStroke
		{
			return _itemOverStroke;
		}
		private var _itemOverStroke:IStroke;
		
		[Bindable(event="itemSelectedStrokeChange")]
		public function set itemSelectedStroke(value:IStroke):void
		{
			if(value != _itemSelectedStroke)
			{
				_itemSelectedStroke = value;
				selectedBitmapDataDirty = true;
				invalidateDisplayList();
				dispatchEvent(new Event("itemSelectedStrokeChange"));
			}
		}
		public function get itemSelectedStroke():IStroke
		{
			return _itemSelectedStroke;
		}
		private var _itemSelectedStroke:IStroke;
        
        protected function handleCollectionChange(event:CollectionEvent):void
        {
        	dataProviderDirty = true;
        	invalidateProperties();
        }
        
        override protected function createChildren():void
        {
        	super.createChildren();
        	if(!axesContainer)
        	{
        		axesContainer = new UIComponent();
        		addChild(axesContainer);
        	}
        } 
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			// The array of axis renderers has changed. Just throw out all the old ones and regenerate.
			if(axisRenderersDirty)
			{
				dataProviderDirty = true;
				while(axesContainer.numChildren > 0)
				{
					axesContainer.removeChildAt(0);
				}
				for each(var axisRenderer:IParallelCoordinateAxisRenderer in axisRenderers)
				{
					 axesContainer.addChild(DisplayObject(axisRenderer));
				}
				axisRenderersDirty = false;
			}
						
			if(dataProviderDirty)
			{
				if(dataProvider)
					items = dataProvider.toArray();
				
				updateAxisExtremeValues();
				updateColorHash();
				invalidateAllBitmapData();
				dataProviderDirty = false;
			}
		}
		
		/**
		 * Update the max an min values of each axis if they haven't been set already
		 */
		private function updateAxisExtremeValues():void
		{
			for each(var axisRenderer:IParallelCoordinateAxisRenderer in axisRenderers)
			{
				computeExtremeValues(dataProvider,axisRenderer.fieldName);
			}
		}
		
		private function updateColorHash():void
		{
			var currColor:int = 1;
			colorHash.clear();
			
			for each(var item:Object in _dataProvider)
			{
				var len:int = axisRenderers.length;
				for(var a:int = 0; a < len - 1; a++)
				{
					var currAxisRenderer:IParallelCoordinateAxisRenderer = axisRenderers[a];
					var nextAxisRenderer:IParallelCoordinateAxisRenderer = axisRenderers[a + 1];
					
					var currFieldName:String = currAxisRenderer.fieldName;
					var nextFieldName:String = nextAxisRenderer.fieldName;
					
					if(!colorHash.contains(currFieldName, item[currFieldName], nextFieldName, item[nextFieldName]))
					{
						colorHash.assignColor(
							currColor,
							currFieldName,
							item[currFieldName],
							nextFieldName,
							item[nextFieldName]);
						currColor += 100;
					}
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);

			layoutAxisRenderers();
			
			if(width != oldWidth || height != oldHeight)
			{
				resetAllBitmapData();
				
				upBitmapDataDirty = true;
				overBitmapDataDirty = true;
				selectedBitmapDataDirty = true;
				
				oldWidth = width;
				oldHeight = height;
			}
			
			graphics.clear();
			if(upBitmapDataDirty)
			{
				updateBitmapData(upBitmapData,items,false,itemUpStroke);
				updateBitmapData(hitTestBitmapData,items,true);
				upBitmapDataDirty = false;
			}
			
			if(overBitmapDataDirty)
			{
				updateBitmapData(overBitmapData,rolledOverParallelCoordinateItems,false,itemOverStroke);
				overBitmapDataDirty = false;
			}
			
			if(selectedBitmapDataDirty)
			{
				updateBitmapData(selectedBitmapData,selectedItems,false,itemSelectedStroke);
				selectedBitmapDataDirty = false;
			}
			
			//drawBitmapDataToGraphics(graphics,hitTestBitmapData);
			drawBitmapDataToGraphics(graphics,upBitmapData);
			drawBitmapDataToGraphics(graphics,overBitmapData);
			drawBitmapDataToGraphics(graphics,selectedBitmapData);
		}
		
		protected function invalidateAllBitmapData():void
		{
			upBitmapDataDirty = true;
            overBitmapDataDirty = true;
            selectedBitmapDataDirty = true;
            invalidateDisplayList();
		}
		
		/**
		 * Disposes of the three BitmapDatas and recreates them at the current width and height of the component.
		 */
		protected function resetAllBitmapData():void
		{
			if(upBitmapData)
				upBitmapData.dispose();
			upBitmapData = new BitmapData(width,height,true,0x00000000);
			
			if(overBitmapData)
				overBitmapData.dispose();
			overBitmapData = new BitmapData(width,height,true,0x00000000);
			
			if(selectedBitmapData)
				selectedBitmapData.dispose();
			selectedBitmapData = new BitmapData(width,height,true,0x00000000);
			
			if(hitTestBitmapData)
				hitTestBitmapData.dispose();
			hitTestBitmapData = new BitmapData(width,height,true,0x00000000);
		}
		
		protected function updateBitmapData(bitmapData:BitmapData,items:Array,useColorHash:Boolean,stroke:IStroke = null):void
		{
			if(!useColorHash && stroke == null)
			{
				trace("that's not going to fly");
				return;
			}
			
			var graphicsHolder:Shape = new Shape();
			
			if(!useColorHash)
				stroke.apply(graphicsHolder.graphics);
				
			for each(var item:Object in items)
			{
				// For each sequential pair of axes render this item as line between them
				// based on the field percentages for the two axes. 
				var len:int = axisRenderers.length;
				for(var a:int = 0; a < len - 1; a++)
				{
					var currAxisRenderer:IParallelCoordinateAxisRenderer = axisRenderers[a];
					var nextAxisRenderer:IParallelCoordinateAxisRenderer = axisRenderers[a + 1];
					
					var currAxisHeight:Number = currAxisRenderer.height - 
						currAxisRenderer.axisOffsetTop - currAxisRenderer.axisOffsetBottom;
						
					var nextAxisHeight:Number = nextAxisRenderer.height - 
						nextAxisRenderer.axisOffsetTop - nextAxisRenderer.axisOffsetBottom;
					
					var x1:Number = currAxisRenderer.x + currAxisRenderer.width - currAxisRenderer.axisOffsetRight;
					var x2:Number = nextAxisRenderer.x + nextAxisRenderer.axisOffsetLeft;
					
					var topLeft:Number = currAxisRenderer.y + currAxisRenderer.axisOffsetTop;
					var topRight:Number = nextAxisRenderer.y + nextAxisRenderer.axisOffsetTop;
					
					var currFieldName:String = currAxisRenderer.fieldName;
					var nextFieldName:String = nextAxisRenderer.fieldName;
					var leftPercent:Number = getFieldPercentage(currFieldName,item[currFieldName]);
					var rightPercent:Number = getFieldPercentage(nextFieldName,item[nextFieldName]);
					
					var y1:Number = topLeft + leftPercent * currAxisHeight;
					var y2:Number = topRight + rightPercent * nextAxisHeight;
					
					if(useColorHash)
					{
						var color:Number = colorHash.getColorForKey(
							currFieldName,
							item[currFieldName],
							nextFieldName,
							item[nextFieldName]);
							
						graphicsHolder.graphics.lineStyle(5,color);
					}
					graphicsHolder.graphics.moveTo(x1,y1);
					graphicsHolder.graphics.lineTo(x2,y2);
				}
			}
			bitmapData.fillRect(new Rectangle(0,0,width,height),0);
			bitmapData.draw(graphicsHolder);
		}
		
		protected function getFieldPercentage(fieldName:String,value:Number):Number
		{
			return 1 - (maxHash[fieldName] - value) / (maxHash[fieldName] - minHash[fieldName]);
		}
		
		protected function drawBitmapDataToGraphics(g:Graphics,bitmapData:BitmapData):void
		{
			g.beginBitmapFill(bitmapData);
			g.drawRect(0,0,bitmapData.width,bitmapData.height);
			g.endFill();
		}
		
		/**
		 * Space the axis renderers evenly along the width of the component
		 */
		protected function layoutAxisRenderers():void
		{
			if(axisRenderers.length == 0)
				return;

			axesContainer.move(0,0);
			axesContainer.setActualSize(width,height);
			
			var availableWidth:Number = width - axisRenderers[axisRenderers.length - 1].measuredWidth + 
				axisRenderers[axisRenderers.length - 1].axisOffsetLeft;
			var numAxisRenderers:Number = axisRenderers.length;
			for(var a:int = 0; a < numAxisRenderers; a++)
			{
				var axisRenderer:IParallelCoordinateAxisRenderer = IParallelCoordinateAxisRenderer(axisRenderers[a]);
				var axisX:Number;
				if(a == 0)
				{
					axisX = 0;
				}
				else if(a < numAxisRenderers - 1)
				{
					axisX = availableWidth * a / (numAxisRenderers - 1);
					axisX -= axisRenderer.measuredWidth / 2;
				}
				else
				{
					axisX = width - axisRenderer.measuredWidth;
				}
				axisRenderer.move(axisX,0);
				axisRenderer.setActualSize(axisRenderer.measuredWidth,height);
			}
		}
		
		protected function computeExtremeValues(collection:ArrayCollection,fieldName:String):void
		{
			if(collection && collection.length > 0)
			{
				var len:int = collection.length;
				var min:Number = collection[0][fieldName];
				var max:Number = collection[0][fieldName];
				for(var a:int = 1; a < len; a++)
				{
					var value:Number = collection[a][fieldName];
					min = min > value ? value : min; 
					max = max < value ? value : max;
				}
				minHash[fieldName] = min;
				maxHash[fieldName] = max;
			}
			else
			{
				minHash[fieldName] = NaN;
				maxHash[fieldName] = NaN;
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			if(!hitTestBitmapData)
				return;
				
			var colorUnderCursor:int = hitTestBitmapData.getPixel(event.localX,event.localY);
			rolledOverParallelCoordinateItems = colorHash.getItemsWithColor(items,colorUnderCursor);
		}
		
		protected function handleMouseClick(event:MouseEvent):void
		{
			if(!hitTestBitmapData)
				return;
				
			var colorUnderCursor:int = hitTestBitmapData.getPixel(event.localX,event.localY);
			selectedItems = colorHash.getItemsWithColor(items,colorUnderCursor);
		}
	}
}
	
internal class FieldValuePairColorHash
{
	private var colorToKeyHash:Object = new Object();
	
	private var keyToColorHash:Object = new Object();
	
	public function clear():void
	{
		colorToKeyHash = new Object();
		keyToColorHash = new Object();
	}
	
	public function contains(field1:String,value1:Number,field2:String,value2:Number):Boolean
	{
		var key:String = makeKey(field1,value1,field2,value2);
		return colorToKeyHash[key] != null;
	}
	
	public function assignColor(color:int,field1:String,value1:Number,field2:String,value2:Number):void
	{
		var key:String = makeKey(field1,value1,field2,value2);
		colorToKeyHash[color] = key;
		keyToColorHash[key] = color;
	}
	
	public function getColorForKey(field1:String,value1:Number,field2:String,value2:Number):int
	{
		return keyToColorHash[makeKey(field1,value1,field2,value2)];
	}
	
	public function getItemsWithColor(sourceItems:Array,color:int):Array
	{
		var fpvKey:String = colorToKeyHash[color];
		
		if(fpvKey == null)
			return [];
		
		var splitKey:Array = fpvKey.split("_");
		var field1:String = splitKey[0];
		var value1:Number = parseFloat(splitKey[1]);
		var field2:String = splitKey[2];
		var value2:Number = parseFloat(splitKey[3]);
		
		var toReturn:Array = new Array();
		for each(var item:Object in sourceItems)
		{
			if(item[field1] == value1 && item[field2] == value2)
				toReturn.push(item);
		}
		return toReturn;
	}
	
	private function makeKey(field1:String,value1:Number,field2:String,value2:Number):String
	{
		return field1+"_"+value1+"_"+field2+"_"+value2;
	}
}