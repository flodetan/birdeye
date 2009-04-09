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
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.ToolTip;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.IInvalidating;
	import mx.events.ResizeEvent;
	import mx.managers.ToolTipManager;
	
	 /**
	 * This class is used as skeleton for most of charts in this library. It provides the common properties and methods 
	 * that can be used or overridden by several microcharts components that extend this class.
	 * It's possible to show tooltips and define functions and prefix to customize them. If no function is defined for the 
	 * tooltips, than the dataField value is taken for their content.
	 * <p> A general example of creating a microchart is:</p>
	 * <p>&lt;MicroBarChart dataProvider="{dp}" width="50%" height="50%" showDataTips="true" dataField="myValue"/></p>
	 * The dataProvider property can accept Array, ArrayCollection, String, XML, etc.
	 * If dataProvider is different from a simple Array of values, than the dataField property shouldn't be null.
	*/
	public class BasicMicroChart extends Surface
	{
		protected var geomGroup:ExtendedGeometryGroup;
		protected var tot:Number = NaN; 
		protected var min:Number, max:Number, space:Number = 0;

		private var tempColor:int = 0xbbbbbb;
		private var wasDataFieldSet:String = null;
		
		private static const YES:String = "y"
		private static const NO:String = "n"
		
		private var _colors:Array = null;
		private var _color:Number = NaN;
		private var _gradientColors:Array;
		private var _dataProvider:Object = new Object();
		private var _showDataTips:Boolean = false;
		protected var _dataField:String;
		protected var dataValue:Number; 
		protected var _dataTipFunction:Function;
		protected var _dataTipPrefix:String;
		private var _stroke:Number = NaN; 
		private var _backgroundColor:Number = NaN;
		private var _backgroundStroke:Number = NaN;
		private var _percentHeight:Number = NaN;
		private var _percentWidth:Number = NaN;
		
		protected var data:ArrayCollection;
		protected var cursor:IViewCursor;

		private var tip:ToolTip; 

		protected var tempWidth:Number, tempHeight:Number;
		private var resizeListening:Boolean = false;
		
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
		
		public function get color():Number
		{
			return _color;
		}

		public function set color(val:Number):void
		{
			_color = val;
			invalidateDisplayList();
		}
		
		public function set colors(val:Array):void
		{
			_colors = val;
			invalidateDisplayList();
		}
		
		/**
		 * This property sets the colors of the bars in the chart. If not set, a function will automatically create colors for each bar.
		*/
		public function get colors():Array
		{
			return _colors;
		}
		
		public function set backgroundColor(val:Number):void
		{
			_backgroundColor = val;
			invalidateDisplayList();
		}
		
		/**
		 * The fill color of the chart background. 
		*/
		public function get backgroundColor():Number
		{
			return _backgroundColor;
		}
		
		public function set backgroundStroke(val:Number):void
		{
			_backgroundStroke = val;
			invalidateDisplayList();
		}
		
		/**
		 * The stroke color of the chart background. 
		*/
		public function get backgroundStroke():Number
		{
			return _backgroundStroke;
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
		* Indicate the data field to be used to feed the chart. 
		*/
		public function set dataField(value:String):void
		{
			_dataField = value;
		}
		
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
		* Set the gradient colors. 
		*/
		public function set gradientColors(value:Array):void
		{
			_gradientColors = value;
		}
		
		public function set stroke(val:Number):void
		{
			_stroke = val;
			invalidateDisplayList();
		}
		
		/**
		 * This property sets the color of chart stroke. If not set, no stroke will be defined for the chart.
		*/
		public function get stroke():Number
		{
			return _stroke;
		}

		public function BasicMicroChart()
		{
			super();
		}
		
		/**
		* @private
		* load values into data
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			feedDataArrayCollection();
		}
		
		/**
		* @private
		* load values into data
		*/
		private function feedDataArrayCollection():void
		{
			if (!wasDataFieldSet) 
				wasDataFieldSet = _dataField ? YES : NO;
				
			if (dataProvider is ArrayCollection && wasDataFieldSet == YES)
				data = ArrayCollection(_dataProvider);
			else {
				data = new ArrayCollection();
				cursor = _dataProvider.createCursor();
				var i:int = 0;
				
				if (wasDataFieldSet == NO)
					dataField = "value";
				 
				while(!cursor.afterLast)
				{
					// if the dataField is null, it might be because dataProvider was a simple 
					// array and we still try to get the data right to feed the chart
					if (wasDataFieldSet == NO)
						data.addItemAt({value:Number(cursor.current)},i);
					else 
						data.addItemAt(cursor.current,i);
				    i++;
				    cursor.moveNext();      
				}
			}
		}

		/**
		* @private
		* Calculate min, max and tot  
		*/
		protected function minMaxTot():void
		{
			tot = 0;

			for (var i:Number = 0; i < data.length; i++)
			{
				if (i == 0)
					min = max = Object(data.getItemAt(0))[_dataField]; 
			
				dataValue = Object(data.getItemAt(i))[_dataField]; 

				if (min > dataValue)
					min = dataValue;
				if (max < dataValue)
					max = dataValue;
			}

			// in case all values are negative or all values are positive, the 0 is considered respectively 
			// to define the top or the bottom of the chart 
			tot = Math.abs(Math.max(max,0) - Math.min(min,0));
		}

		/**
		* @private  
		* Set background color, in case either stroke or fill are defined.
		*/
		protected function createBackground(w:Number, h:Number):void
		{
			if (!isNaN(backgroundColor) || !isNaN(backgroundStroke))
			{
				var backgroundRect:RegularRectangle = new RegularRectangle(space, space, w, h);
				if (!isNaN(backgroundColor))
					backgroundRect.fill = new SolidFill(backgroundColor);
				if (!isNaN(backgroundStroke))
					backgroundRect.stroke = new SolidStroke(backgroundStroke);
				
				geomGroup.geometryCollection.addItem(backgroundRect);
			}
		}

		/**
		* @private  
		* Set automatic colors to the bars, in case these are not provided. 
		*/
		protected function useColor(indexIteration:Number):IGraphicsFill
		{
			var fill:IGraphicsFill;

			if(_gradientColors == null)
			{
				fill = new SolidFill();
				if(_colors == null)
				{
					if (isNaN(_color))
					{
						fill = new SolidFill(tempColor);
						tempColor += 0x083456;
					}
					else
						fill = new SolidFill(_color);
				} else if (indexIteration < _colors.length)
				{
					if (_colors[indexIteration] is IGraphicsFill)
						fill = _colors[indexIteration];
					else if (_colors[indexIteration] is Number)
						fill = new SolidFill(_colors[indexIteration]);
				} else
					fill = new SolidFill(0x999999);
			} else 
			{
				fill = new LinearGradientFill();
				var g:Array = new Array();
				g.push(new GradientStop(_gradientColors[indexIteration][0]));
				g.push(new GradientStop(_gradientColors[indexIteration][1]));
				LinearGradientFill(fill).gradientStops = g;
			}

			return fill;
		}
		
		/**
		* @private 
		 * perform common actions to all microcharts of the updateDisplayList, including clearing
		 * the previous graphics objects. 
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			setActualSize(unscaledWidth, unscaledHeight);
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i))
					removeChildAt(i);

			geomGroup = new ExtendedGeometryGroup();
			geomGroup.target = this;
			graphicsCollection.addItem(geomGroup);
			
			createBackground(unscaledWidth, unscaledHeight);
		}
		
		/**
		* @private 
		 * Only called when there is a parent resize event and the chart uses autosize 
		 * values (percentWidth or percentHeight).
		*/
		private function onParentResize(e:Event):void
		{
			invalidateSize();
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
		protected function handleRollOver(e:MouseEvent):void
		{
			var extGG:ExtendedGeometryGroup = ExtendedGeometryGroup(e.target);
			var pos:Point = localToGlobal(new Point(extGG.posX, extGG.posY));
			tip = ToolTipManager.createToolTip(extGG.toolTip, 
												pos.x + 10,	pos.y + 10)	as ToolTip;

			tip.alpha = 0.7;
			setChildIndex(extGG, numChildren-1);
			extGG.showToolTipGeometry();
		}

		/**
		* @private 
		 * Destroy/hide tooltip 
		 * 
		*/
		protected function handleRollOut(e:MouseEvent):void
		{
			ToolTipManager.destroyToolTip(tip);
			ExtendedGeometryGroup(e.target).hideToolTipGeometry();
		}
	}
}