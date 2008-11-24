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
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;

	 /**
	 * This class is used as a skeleton for most of microcharts in this library. It provides the commong properties and methods 
	 * that can be used or overridden by all other microcharts components, extending this class.  
	 * The dataProvider property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML.
	 * 
	*/
	public class MicroChart extends Surface
	{
		protected var geomGroup:GeometryGroup;
		protected var tot:Number = NaN;
		protected var min:Number, max:Number, space:Number = 0;

		private var tempColor:int = 0xbbbbbb;
		
		private var _colors:Array = null;
		private var _dataProvider:Array = new Array();
		private var _stroke:Number = NaN; 
		private var _backgroundColor:Number = NaN;
		private var _backgroundStroke:Number = NaN;
		
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
		
		public function set dataProvider(val:Array):void
		{
			_dataProvider = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Array
		{
			return _dataProvider;
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

		public function MicroChart()
		{
			super();
		}

		/**
		* @private
		 * Calculate min, max and tot  
		*/
		protected function minMaxTot():void
		{
			min = max = dataProvider[0];

			tot = 0;
			for (var i:Number = 0; i < dataProvider.length; i++)
			{
				if (min > dataProvider[i])
					min = dataProvider[i];
				if (max < dataProvider[i])
					max = dataProvider[i];
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
		protected function useColor(indexIteration:Number):int
		{
			if (colors != null && colors.length > 0)
				tempColor = colors[indexIteration];
			else
				tempColor += 0x123456; 

			return tempColor;
		}
	}
}