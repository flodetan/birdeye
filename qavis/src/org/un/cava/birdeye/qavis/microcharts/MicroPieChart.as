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
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	 /**
	 * <p>This component is used to create pie microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an Pie microchart with mxml is:</p>
	 * <p>&lt;MicroPieChart dataProvider="{myArray}" size="70"/></p>
	 * 
	 * To size the Pie chart:</p>
	 * <p>- size: to define the diameter of the chart;</p>
	 * 
	 * <p>If no colors are defined, than the Pie chart will display different colors based on the default color and a default offset color.</p>
	*/
	public class MicroPieChart extends MicroChart
	{
		private var _referenceColor:Number = NaN;
		private var _radius:Number = 2;
		private var _size:Number = NaN;

		private var prevAngleSize:Number = 0;
		
		public function set size(val:Number):void
		{
			_size = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the size of the chart (circle).  
		*/
		public function get size():Number
		{
			return _size;
		}
					
		public function MicroPieChart()
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
		* Calculate the angle size of the current value provided by the repeater. 
		*/
		private function arcAngleSize(indexIteration:Number):Number
		{
			var arcAngleSize:Number = Math.max(0,data[indexIteration] * 360 / tot); 
			if (arcAngleSize == 360)
				arcAngleSize = 359.9;
			
			prevAngleSize += arcAngleSize;
			return arcAngleSize;
		}
		
		/**
		* @private  
		* Calculate the offset angle from where the next pie will be drawn. 
		*/
		private function startAngle(indexIteration:Number):Number
		{
			var startAngle:Number = prevAngleSize + (indexIteration==0)? 0 : Math.max(0,data[indexIteration-1] * 360 / tot);
			return startAngle;
		}
		
		/**
		* @private 
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			prevAngleSize = 0;
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i) is GeometryGroup)
					removeChildAt(i);

			geomGroup = new GeometryGroup();
			geomGroup.target = this;
			createBackground(width, height);
			createPies();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		override protected function createBackground(w:Number, h:Number):void
		{
			w = size;
			h = size;
			super.createBackground(w, h);
		}

		/**
		* @private 
		 * Create the bars of the chart.
		*/
		private function createPies():void
		{
			// create pies
			for (var i:Number=0; i<data.length; i++)
			{
				var pie:EllipticalArc;
				
				if (data[i] > 0) 
				{
					pie = new EllipticalArc(space, space, size, size, prevAngleSize, arcAngleSize(i),"pie");

					pie.fill = useColor(i);
						
					if (!isNaN(stroke))
						pie.stroke = new SolidStroke(stroke);
						
					geomGroup.geometryCollection.addItem(pie);
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