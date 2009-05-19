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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.interfaces.IScale;
	import birdeye.vis.scales.MultiScale;
	import birdeye.vis.trans.projections.Projection;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.IInvalidating;

	[DefaultProperty("dataProvider")]
	public class VisScene extends Surface
	{
		public static const CARTESIAN:String="cartesian";
		public static const POLAR:String="polar";
		
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
		
		private var _projection:Projection;
		public function set projection(val:Projection):void
		{
			_projection = val;
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
		
		private var _scales:Array; /* of IScale */
		/** Array of scales, each element will take a scale target from this scale list.*/
        [Inspectable(category="General", arrayType="birdeye.vis.interfaces.IScale")]
        [ArrayElementType("birdeye.vis.interfaces.IScale")]
		public function set scales(val:Array):void
		{
			_scales = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		protected var _multiScale:MultiScale;
		public function set multiScale(val:MultiScale):void
		{
			_multiScale = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get multiScale():MultiScale
		{
			return _multiScale;
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

		private var _showGrid:Boolean = true;
		/** Draw the grid lines of the chart (only default chart axes and not elements having own axes).*/
		[Inspectable(enumeration="true,false")]
		public function set showGrid(val:Boolean):void
		{
			_showGrid = val;
			invalidateDisplayList();
		}
		public function get showGrid():Boolean
		{
			return _showGrid;
		}
		
		protected var _gridColor:Number = 0x000000;
		/** Set the grid color.*/
		public function set gridColor(val:Number):void
		{
			_gridColor = val;
			invalidateDisplayList();
		}

		protected var _gridWeight:Number = 1;
		/** Set the line grid weight.*/
		public function set gridWeight(val:Number):void
		{
			_gridWeight = val;
			invalidateDisplayList();
		}

		protected var _gridAlpha:Number = .3;
		/** Set the grid alpha.*/
		public function set gridAlpha(val:Number):void
		{
			_gridAlpha = val;
			invalidateDisplayList();
		}
		
		private var _columnWidthRate:Number = 3/5;
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
		public function get cursor():IViewCursor
		{
			return _cursor;
		}
		
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
		
		public var axesFeeded:Boolean = true;
		protected var _dataProvider:Object=null;
		public function set dataProvider(value:Object):void
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
	  		
		  		axesFeeded = false;
		  		invalidateSize();
		  		invalidateProperties();
				invalidateDisplayList();
	  		}
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
		
		// UIComponent flow
		
		public function VisScene():void
		{
			super();
			doubleClickEnabled = true;
		}
		
		protected var rectBackGround:RegularRectangle;
		protected var ggBackGround:GeometryGroup;
		override protected function createChildren():void
		{
			super.createChildren();
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
		
		protected function resetAxes():void
		{
			if (_scales)
				for (var i:Number = 0; i<_scales.length; i++)
					IScale(_scales[i]).resetValues();
		}
	}
}