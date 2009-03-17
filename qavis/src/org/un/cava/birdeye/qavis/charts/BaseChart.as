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
 
 package org.un.cava.birdeye.qavis.charts
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;

	[DefaultProperty("dataProvider")]
	public class BaseChart extends UIComponent
	{
		protected var _dataProvider:Object=null;
		protected var _showDataTips:Boolean = false;
		protected var _dataTipFunction:Function = null;
		protected var _dataTipPrefix:String;

		protected var defaultTipFunction:Function;

		private var _percentHeight:Number = NaN;
		private var _percentWidth:Number = NaN;
		private var tempWidth:Number, tempHeight:Number;
		private var resizeListening:Boolean = false;
		
		protected var multipleAxes:Array = null; // of IAxisLayout 
		
		private var _cursor:IViewCursor;
		public function get cursor():IViewCursor
		{
			return _cursor;
		}
		
		protected var chartBounds:Rectangle;
		
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
		
		protected var _series:Array;
		public function get series():Array
		{
			return _series;
		}
		public function set series(val:Array):void 	// to be overridden
		{
		}

		override public function set percentHeight(val:Number):void
		{
			_percentHeight = val;
			invalidateSize();
		}
		/** 
		 * @private
		 */
		override public function get percentHeight():Number
		{
			return _percentHeight;
		}
		
		override public function set percentWidth(val:Number):void
		{
			_percentWidth = val;
			invalidateSize();
		}
		/** 
		 * @private
		 */
		override public function get percentWidth():Number
		{
			return _percentWidth;
		}
		
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
	  		
	  		_cursor = ICollectionView(_dataProvider).createCursor();
	  		
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
		
		/**
		* Indicate whether to show/create tooltips or not. 
		*/
		[Inspectable(enumeration="true,false")]
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
			invalidateDisplayList();
		}		
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}

		/**
		* Indicate the function used to create tooltips. 
		*/
		public function set dataTipFunction(value:Function):void
		{
			_dataTipFunction = value;
			invalidateDisplayList();
		}

		/**
		* Indicate the prefix for the tooltip. 
		*/
		public function set dataTipPrefix(value:String):void
		{
			_dataTipPrefix = value;
			invalidateDisplayList();
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
		
		public function BaseChart():void
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			// if % size is set, than listen to parent's resize events
			if (!resizeListening && (!isNaN(_percentHeight) || !isNaN(_percentWidth)))
			{
				resizeListening = true;
				parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
			}
		}

		/**
		* @private 
		 * Set the default and minimum width and height.
		 * If percentWidth/percentHeight are used than it autosize the chart according the 
		 * parent container size.
		 * If explicitWidth/explicitHeight are set, than measure won't be called anymore, 
		 * even if invalidateSize is called.
		*/
		override protected function measure():void
		{
			super.measure();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}

		/**
		* @private 
		 * Only called when there is a parent resize event and the chart uses autosize 
		 * values (percentWidth or percentHeight).
		*/
		private function onParentResize(e:Event):void
		{
			invalidateProperties();
		}
	}
}