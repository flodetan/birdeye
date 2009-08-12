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
 
 package birdeye.vis
{
	import __AS3__.vec.Vector;
	
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.IProjection;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.ITransform;
	import birdeye.vis.interfaces.guides.IGuide;
	import birdeye.vis.interfaces.validation.IValidatingChild;
	import birdeye.vis.interfaces.validation.IValidatingParent;
	import birdeye.vis.interfaces.validation.IValidatingScale;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.IInvalidating;

	[Exclude(name="projections", kind="property")]
	[Exclude(name="graphLayouts", kind="property")]

	[DefaultProperty("dataProvider")]
	public class VisScene extends Surface implements IValidatingParent
	{
		public static const CARTESIAN:String="cartesian";
		public static const POLAR:String="polar";
		
		
		
		// IMPLEMENTATION OF IVALIDATINGPARENT
		
		private var invalidateChilds:Array = new Array();
		private var invalidateScales:Array = new Array();
		
		public function invalidate(child:IValidatingChild):void
		{
			if (child is IValidatingScale)
			{
				if (invalidateScales.lastIndexOf(child) == -1)
				{
					invalidateScales.push(child);
				}
			}
			else
			{
				if (invalidateChilds.lastIndexOf(child) == -1)
				{
					invalidateChilds.push(child);
					invalidateProperties();
				}	
			}
		}
		
		// END IMPLEMENTATION
		
		protected var _active:Boolean = true;
		/** If set to false, the chart is removed and won't be drawn till active becomes true.*/
		[Inspectable(enumeration="true,false")]
		public function set active(val:Boolean):void
		{
			_active = val;
			if (_active)
			{
				invalidateProperties();
				invalidateDisplayList();
			} else 
				clearAll();
		}
		public function get active():Boolean
		{
			return _active;
		}
		
		protected var _isMasked:Boolean = false;
		public function set isMasked(val:Boolean):void
		{
			_isMasked = val;
			invalidateDisplayList();
		}
		
		private var _coordType:String;
		public function set coordType(val:String):void
		{
			_coordType = val;
			invalidateDisplayList();
		}
		public function get coordType():String
		{
			return _coordType;
		}
		
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.ITransform")]
        [ArrayElementType("birdeye.vis.interfaces.ITransform")]
		public function set transforms(val:Array):void
		{
			var _transforms:Array = val;
			var p:uint = 0, l:uint = 0;
			for (var i:Number = 0; i<_transforms.length; i++)
			{
				if (_transforms[i] is IProjection)
				{
					if (!_projections)
						_projections = [];
					_projections[p++] = _transforms[i];
				} else if (_transforms[i] is IGraphLayout) {
					if (!_graphLayouts)
						_graphLayouts = [];
					_graphLayouts[l++] = _transforms[i];
				}
			}
		}

		private var _projections:Array;

        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IProjection")]
        [ArrayElementType("birdeye.vis.interfaces.IProjection")]
		public function set projections(val:Array):void
		{
			_projections = val;
		}

		private var _graphLayouts:Array

        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IGraphLayout")]
        [ArrayElementType("birdeye.vis.interfaces.IGraphLayout")]
		public function set graphLayouts(val:Array):void
		{
			_graphLayouts = val;
		}

		protected var _maxStacked100:Number = NaN;
		/** @Private
		 * The maximum value among all elements stacked according to stacked100 type.
		 * This is needed to "enlarge" the related axis to include all the stacked values
		 * so that all stacked100 elements fit into the chart.*/
		public function get maxStacked100():Number
		{
			return _maxStacked100;
		}
		
		protected var _scales:Array; /* of IScale */
		/** Array of scales, each element will take a scale target from this scale list.*/
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IScale")]
        [ArrayElementType("birdeye.vis.interfaces.scales.IScale")]
		public function set scales(val:Array):void
		{
			_scales = val;
			
			// Implementation of IValidatingParent!
			for each (var valChild:IValidatingChild in _scales)
			{
				if (valChild)
				{
					valChild.parent = this;
				}
			}
			
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get scales():Array
		{
			return _scales;
		}
		
		
		protected var _guides:Array; /* of IGuide */
		/** Array of guides. */
		[Inspectable(category="General", arrayType="birdeye.vis.interfaces.IGuide")]
		[ArrayElementType("birdeye.vis.interfaces.guides.IGuide")]
		public function set guides(val:Array):void
		{
			_guides = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get guides():Array
		{
			return _guides;
		}
		
		protected var _origin:Point;
		public function set origin(val:Point):void
		{
			_origin = val;
			invalidateDisplayList();
		}
		public function get origin():Point
		{
			return _origin;
		}

		private var _colorAxis:INumerableScale;
		/** Define an axis to set the colorField for data items.*/
		public function set colorAxis(val:INumerableScale):void
		{
			_colorAxis = val;
			invalidateDisplayList();
		}
		public function get colorAxis():INumerableScale
		{
			return _colorAxis;
		}

		private var _sizeScale:INumerableScale;
		/** Define a scale to set the sizeDim for data items.*/
		public function set sizeScale(val:INumerableScale):void
		{
			_sizeScale = val;
			invalidateDisplayList();
		}
		public function get sizeScale():INumerableScale
		{
			return _sizeScale;
		}


		
		private var _columnWidthRate:Number = 0.6;
		public function set columnWidthRate(val:Number):void
		{
			_columnWidthRate = val;
			invalidateDisplayList();
		}
		public function get columnWidthRate():Number
		{
			return _columnWidthRate;
		}
		
		private var _customTooltTipFunction:Function;
		public function set customTooltTipFunction(val:Function):void
		{
			_customTooltTipFunction = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get customTooltTipFunction():Function
		{
			return _customTooltTipFunction;
		}

		protected var defaultTipFunction:Function;

		private var _cursor:IViewCursor = null;
		
		protected var chartBounds:Rectangle;

		protected var _elementsContainer:Surface = new Surface();
		public function get elementsContainer():Surface
		{
			return _elementsContainer;
		}

		protected var _lineColor:Number = NaN;
		public function set lineColor(val:Number):void
		{
			_lineColor = val;
			invalidateDisplayList();
		}
		
		protected var _lineAlpha:Number = 1;
		public function set lineAlpha(val:int):void
		{
			_lineAlpha = val;
			invalidateDisplayList();
		}		
		
		protected var _lineWidth:Number = 1;
		public function set lineWidth(val:int):void
		{
			_lineWidth = val;
			invalidateDisplayList();
		}		

		protected var _fillAlpha:Number = 1;
		public function set fillAlpha(val:int):void
		{
			_fillAlpha = val;
			invalidateDisplayList();
		}		

		protected var _fillColor:Number = NaN;
		public function set fillColor(val:Number):void
		{
			_fillColor = val;
			invalidateDisplayList();
		}
		
		protected var _elements:Array; // of IElement
		public function get elements():Array
		{
			return _elements;
		}
		public function set elements(val:Array):void 	// to be overridden
		{
		}

		private var _percentHeight:Number = NaN;
		override public function set percentHeight(val:Number):void
		{
			_percentHeight = val;
			var p:IInvalidating = parent as IInvalidating;
			if (p) {
				p.invalidateSize();
				p.invalidateDisplayList();
			}
		}
		/** 
		 * @private
		 */
		override public function get percentHeight():Number
		{
			return _percentHeight;
		}
		
		private var _percentWidth:Number = NaN;
		override public function set percentWidth(val:Number):void
		{
			_percentWidth = val;
			var p:IInvalidating = parent as IInvalidating;
			if (p) {
				p.invalidateSize();
				p.invalidateDisplayList();
			}
		}
		/** 
		 * @private
		 */
		override public function get percentWidth():Number
		{
			return _percentWidth;
		}
		
		private var _dataItems:Vector.<Object>;
		public function get dataItems():Vector.<Object>
		{
			return _dataItems;
		}
		
		protected var invalidatedData:Boolean = false;
		public var axesFeeded:Boolean = true;
		protected var _dataProvider:Object=null;
		public function set dataProvider(value:Object):void
		{
			if (value is Vector.<Object>)
			{
	  			_dataItems = Vector.<Object>(value);

			} else {
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
					this._dataProvider = new XMLListCollection(list.children());
				}
				//if already a collection dont make new one
		        else if(value is ICollectionView)
		        {
		            this._dataProvider = ICollectionView(value);
		        }else if(value is Object)
				{
					// convert to an array containing this one item
					this._dataProvider = new ArrayCollection( [value] );
		  		}
		  		else
		  		{
		  			this._dataProvider = new ArrayCollection();
		  		}
		  		
		  		if (ICollectionView(_dataProvider).length > 0)
		  		{
		  			_cursor = ICollectionView(_dataProvider).createCursor();
		  		}
			}
	  			
  			axesFeeded = false;
  			invalidatedData = true;
	  		invalidateSize();
	  		invalidateProperties();
			invalidateDisplayList();
		}		
		/**
		* Set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		protected var _showDataTips:Boolean = true;
		/**
		* Indicate whether to show/create tooltips or not. 
		*/
		[Inspectable(enumeration="true,false")]
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
			invalidateProperties();
			invalidateDisplayList();
		}		
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}

		protected var _showAllDataTips:Boolean = false;
		/**
		* Indicate whether to show/create tooltips or not. 
		*/
		[Inspectable(enumeration="true,false")]
		public function set showAllDataTips(value:Boolean):void
		{
			_showAllDataTips = value;
			invalidateProperties();
			invalidateDisplayList();
		}		
		public function get showAllDataTips():Boolean
		{
			return _showAllDataTips;
		}

		protected var _dataTipFunction:Function = null;
		/**
		* Indicate the function used to create tooltips. 
		*/
		public function set dataTipFunction(value:Function):void
		{
			_dataTipFunction = value;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dataTipFunction():Function
		{
			return _dataTipFunction;
		}

		protected var _dataTipPrefix:String;
		/**
		* Indicate the prefix for the tooltip. 
		*/
		public function set dataTipPrefix(value:String):void
		{
			_dataTipPrefix = value;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dataTipPrefix():String
		{
			return _dataTipPrefix;
		}

		protected var _tipDelay:Number;
		/**
		* Indicate the delay for the tooltip to show up. 
		*/
		public function set tipDelay(value:Number):void
		{
			_tipDelay = value;
			invalidateDisplayList();
		}
		
		/**
		 * Return the mask needed to hide elements that draws outside the elementContainer boundaries.*/
		public function get maskShape():Shape
		{
			return _maskShape;
		}
		
		// UIComponent flow
		
		
		public function VisScene():void
		{
			super();
			doubleClickEnabled = true;

		}
		
		protected var rectBackGround:RegularRectangle;
		protected var ggBackGround:GeometryGroup;
		protected var _maskShape:Shape; 
		override protected function createChildren():void
		{
			super.createChildren();
			
			_maskShape = new Shape();
			_elementsContainer.addChildAt(_maskShape, 0);
			
			ggBackGround = new GeometryGroup();
			addChildAt(ggBackGround, 0);
			ggBackGround.target = this;
			rectBackGround = new RegularRectangle(0,0,0, 0);
			rectBackGround.fill = new SolidFill(0x000000,0);
			ggBackGround.geometryCollection.addItem(rectBackGround);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			

			
			if (elements && invalidatedData && _cursor)
				loadElementsValues();
			
			commitValidatingChilds();	

		}
		
		protected function commitValidatingChilds():void
		{
			// IMPLEMENTATION IVALIDATINGPARENT
			
			if (invalidateChilds && invalidateChilds.length > 0)
			{
				while(invalidateChilds.length > 0)
				{
					(invalidateChilds.pop() as IValidatingChild).commit();
				}
			}
			
			// END IMPLEMENTATION
		}
		
		protected function commitValidatingScales():void
		{
			if (invalidateScales && invalidateScales.length > 0)
			{
				while (invalidateScales.length > 0)
				{
					(invalidateScales.pop() as IValidatingScale).commit();
				}
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (ggBackGround)
			{
				rectBackGround.width = unscaledWidth;
				rectBackGround.height = unscaledHeight;

				if (!contains(ggBackGround))
					addChildAt(ggBackGround, 0);
			}
			
			if (showAllDataTips)
			{
				removeDataItems();
				for (var i:uint = 0; i<numChildren; i++)
				{
					if (getChildAt(i) is DataItemLayout)
						DataItemLayout(getChildAt(i)).showToolTip();
				}
			}

 			applyGraphLayouts(unscaledWidth, unscaledHeight);
		}
		
		// Other methods

		private function loadElementsValues():void
		{
			_cursor.seek(CursorBookmark.FIRST);
			_dataItems = new Vector.<Object>;
			var j:uint = 0;
			while (!_cursor.afterLast)
			{
				_dataItems[j++] = (_cursor.current);
				_cursor.moveNext();
			}
			
		}

		protected function applyGraphLayouts(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (_graphLayouts && _graphLayouts.length>0) {
				for each (var t:IGraphLayout in _graphLayouts) t.apply(unscaledWidth, unscaledHeight);
			}
		}

		
		protected function getDimMaxValue(item:Object, dims:Object, stacked:Boolean = false):Number
		{
			if (dims is String)
				return item[dims];
			else if (dims is Array)
			{
				var dimsA:Array = dims as Array;
				var max:Number = NaN;
				for (var i:Number = 0; i<dimsA.length; i++)
				{ 
					if (isNaN(max))
						max = item[dimsA[i]];
					else {
						if (stacked)
							max += item[dimsA[i]];
						else
							max = Math.max(max, item[dimsA[i]]);
					}
				}
				return max;
			}
			return NaN;
		}

		protected function getDimMinValue(item:Object, dims:Object):Number
		{
			if (dims is String)
				return item[dims];
			else if (dims is Array)
			{
				var dimsA:Array = dims as Array;
				var min:Number = NaN;
				for (var i:Number = 0; i<dimsA.length; i++)
				{ 
					if (isNaN(min))
						min = item[dimsA[i]];
					else 
						min = Math.min(min, item[dimsA[i]]);
				}
				return min;
			}
			return NaN;
		}
		
		protected function removeDataItems():void
		{
			var i:int; 
			var child:*;
			
			for (i = numChildren-1; i>=0; i--)
			{
				child = getChildAt(i); 
				if (child is DataItemLayout)
				{
					DataItemLayout(child).hideToolTip();
					DataItemLayout(child).removeAllElements();
					removeChildAt(i);
				}
			}
			
			var nItems:Number = graphicsCollection.items.length;
			for (i = 0; i<nItems; i++)
			{
				child = graphicsCollection.getItemAt(i);
				if (child is DataItemLayout)
				{
					DataItemLayout(child).hideToolTip();
					DataItemLayout(child).removeAllElements();
				}
			}
			graphicsCollection.items = [];
		}
		
		protected function resetScales():void
		{
			if (_scales)
				for (var i:Number = 0; i<_scales.length; i++)
					IScale(_scales[i]).resetValues();
					
			if (_elements)
			{
				for ( i = 0; i<_elements.length; i++)
				{
					resetScale(IElement(_elements[i]).scale1);
					resetScale(IElement(_elements[i]).scale2);
					resetScale(IElement(_elements[i]).scale3);
					resetScale(IElement(_elements[i]).colorScale);
					resetScale(IElement(_elements[i]).sizeScale);
				}	
			}
		}
		
		private function resetScale(scale:IScale):void
		{
			if (scale) scale.resetValues();
		}
		
		public function refresh():void
		{
			for (var i:Number = 0; i<elements.length; i++)
				IElement(elements[i]).refresh();
		}
		
	    protected function clearAll():void
	    {
	            if (elements && elements.length > 0)
	                    for (var i:uint = 0; i<elements.length; i++)
	                            IElement(elements[i]).removeAllElements();
	            if (guides && guides.length > 0)
	            {
	            	for (i=0;i<guides.length;i++)
	            	{
	            		if (guides[i] is IGuide)
	            		{
	            			(guides[i] as IGuide).removeAllElements();
	            		}
	            	}
	            }
	    }
		
		public function clone(cloneObj:Object=null):*
		{
			if (cloneObj && cloneObj is VisScene)
			{
				var visClone:VisScene = cloneObj as VisScene;
				
				visClone.colorAxis = colorAxis;
				visClone.columnWidthRate = columnWidthRate;
				visClone.coordType = coordType;
				visClone.customTooltTipFunction = customTooltTipFunction;
				visClone.dataTipFunction = dataTipFunction;
				visClone.dataTipPrefix = dataTipPrefix;
				visClone.fillAlpha = _fillAlpha;
				visClone.fillColor = _fillColor;
				visClone.graphLayouts = _graphLayouts;
				visClone.isMasked = _isMasked;
				visClone.lineAlpha = _lineAlpha;
				visClone.lineColor = _lineColor;
				visClone.lineWidth = _lineWidth;
				visClone.origin = origin;
				visClone.percentHeight = percentHeight;
				visClone.percentWidth = percentWidth;
				visClone.projections = _projections;
				visClone.showAllDataTips = showAllDataTips;
				visClone.showDataTips = showDataTips;
				visClone.tipDelay = _tipDelay;
			
				return visClone;
			}
			
			return null;
			
		}
	}  
}