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
	 * <p>This component is used to create 100% Bar microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an 100% Bar microchart with mxml is:</p>
	 * <p>&lt;Micro100BarChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider property can accept Array, ArrayCollection, String, XML, etc
	 * It's also possible to change the colors by defining the following:</p>
	 * <p>- colors: array that sets the color for each bar value. The lenght has to be the same as the dataProvider.</p>
	 * <p>- stroke: Number that sets the color of the stroke of the chart.</p>
	 * 
	 * <p>If no colors are defined, than the 100 bar will display different colors based on the default color and a default offset color.</p>
	*/
	public class Micro100BarChart extends BasicMicroChart
	{
		private var prevSizeX:Number;
		/**
		* @private  
		* Calculate the total of all positive values in the dataProvider. Negative values are not considered nor rendered in the chart. 
		*/
		override protected function minMaxTot():void
		{
			tot = 0;
			for (var i:Number = 0; i < data.length; i++)
			{
				if (data[i] > 0)
					tot += data[i];
			}
		}

		/**
		* @private  
		* Calculate the width size of the current value provided by the repeater. 
		*/
		private function offsetSizeX(indexIteration:Number):Number
		{
			var _offSizeX:Number = Math.max(0,data[indexIteration] * width / tot);
			prevSizeX += _offSizeX;
			return _offSizeX;
		}
		
		/**
		* @private  
		* Calculate the offset x position from where the next bar will be drawn. 
		*/
		private function startX(indexIteration:Number):Number
		{
			var _startX:Number = (indexIteration==0)? 0 : prevSizeX;
			return _startX;
		}	
		
		public function Micro100BarChart()
		{
			super();
		}
		
		/**
		* @private 
		 * Used to recalculate the tot each time there is an invalidation of properties (for ex. dataProvider values are changed).
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			minMaxTot();
		}
		
		/**
		* @private 
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			prevSizeX = 0;
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i) is GeometryGroup)
					removeChildAt(i);

			geomGroup = new GeometryGroup();
			geomGroup.target = this;
			createBackground(width, height);
			createBars();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		/**
		* @private 
		 * Create the bars of the chart.
		*/
		private function createBars():void
		{
			// create 100% Bars
			for (var i:Number=0; i<data.length; i++)
			{
				var bar:RegularRectangle;
				
				if (data[i] > 0) 
				{
					bar = new RegularRectangle(space+startX(i), space, offsetSizeX(i), height);
					
					if (!isNaN(stroke))
						bar.stroke = new SolidStroke(stroke);
						
					bar.fill = useColor(i);
						
					geomGroup.geometryCollection.addItem(bar);
				}
			}
		}
		
		/**
		* @private 
		 * Set the minHeight and minWidth in case width and height are not set in the creation of the chart.
		*/
		override protected function measure():void
		{
			super.measure();
			minHeight = 5;
			minWidth = 10;
		}
	}
}