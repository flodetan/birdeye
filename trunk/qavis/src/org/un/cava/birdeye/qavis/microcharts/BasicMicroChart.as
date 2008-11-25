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
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	
	 /**
	 * This class is used as skeleton for most of microcharts in this library. It provides the common properties and methods 
	 * that can be used or overridden by several microcharts components that extend this class.  
	 * The dataProvider property be accept Array, ArrayCollection, String, XML, etc.
	 * If dataProvider is different from a simple Array of values, than the dataField property cannot be null.
	*/
	public class BasicMicroChart extends Surface
	{
		protected var geomGroup:GeometryGroup;
		protected var tot:Number = NaN;
		protected var min:Number, max:Number, space:Number = 0;

		private var tempColor:int = 0xbbbbbb;
		
		private var _colors:Array = null;
		private var _gradientColors:Array;
		private var _dataProvider:Object = new Object();
		private var _dataField:String;
		private var _stroke:Number = NaN; 
		private var _backgroundColor:Number = NaN;
		private var _backgroundStroke:Number = NaN;
		
		protected var data:Array;
		
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
		* Indicate the data field to be used to feed the chart. 
		*/
		public function set dataField(value:String):void
		{
			_dataField = value;
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
			feedDataArray();
		}
		
		/**
		* @private
		* load values into data
		*/
		private function feedDataArray():void
		{
			data = new Array();
			var cursor:IViewCursor = _dataProvider.createCursor();
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
		* Calculate min, max and tot  
		*/
		protected function minMaxTot():void
		{
			tot = 0;
			min = max = data[0];
			
			for (var i:Number = 0; i < data.length; i++)
			{
				if (min > data[i])
					min = data[i];
				if (max < data[i])
					max = data[i];
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
			
			if(_gradientColors==null)
			{
				fill = new SolidFill();
				if(_colors==null)
				{
					fill = new SolidFill(tempColor);
					tempColor += 0x083456;
				} else
					fill = new SolidFill(_colors[indexIteration]);
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
	}
}