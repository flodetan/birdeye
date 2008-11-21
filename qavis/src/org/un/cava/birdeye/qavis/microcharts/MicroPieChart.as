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
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	 /**
	* <p>This component is used to create Pie microcharts. 
	 * The basic simple syntax to use it and create an Pie microchart with mxml is:</p>
	 * <p>&lt;MicroPieChart dataProvider="{myArray}" size="70"/></p>
	 * 
	 * <p>The dataProvider property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML. To size the Pie chart:</p>
	 * <p>- size: to define the diameter of the chart;</p>
	 * 
	 * <p>It's also possible to change the colors by defining the following Array of int:</p>
	 * <p>- colors: array that sets the color for each bar value. The lenght has to be the same as the dataProvider.</p>
	 * 
	 * <p>If no colors are defined, than the Pie chart will display different colors based on the default color and a default offset color.</p>
	*/
	public class MicroPieChart extends Surface
	{
		private var geomGroup:GeometryGroup;
		private var tempColor:int = 0xbbbbbb;

		private var _colors:Array = null;
		private var _stroke:Number = NaN;
		private var _referenceColor:Number = NaN;
		private var _dataProvider:Array = new Array();
		private var _radius:Number = 2;
		private var _size:Number = NaN;

		private var prevAngleSize:Number = 0, min:Number, max:Number, space:Number = 0;
		private var tot:Number = NaN;

		public function set colors(val:Array):void
		{
			_colors = val;
			invalidateDisplayList();
		}
		
		/**
		 * <p>Set the colors of the pies in the chart. If not set, a function will automatically create colors for each bar.</p>
		*/
		public function get colors():Array
		{
			return _colors;
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
		
		public function set dataProvider(val:Array):void
		{
			_dataProvider = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		 * This property is used to set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Array
		{
			return _dataProvider;
		}

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
			setTot();
		}
		
		/**
		* @private  
		* Calculate the total of all positive values in the dataProvider. Negative values are not considered nor rendered in the chart. 
		*/
		private function setTot():void
		{
			tot = 0;
			for (var i:Number = 0; i < _dataProvider.length; i++)
			{
				if (_dataProvider[i] > 0)
					tot += _dataProvider[i];
			}
		}

		/**
		* @private  
		* Calculate the angle size of the current value provided by the repeater. 
		*/
		private function arcAngleSize(indexIteration:Number):Number
		{
			var arcAngleSize:Number = Math.max(0,_dataProvider[indexIteration] * 360 / tot); 
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
			var startAngle:Number = prevAngleSize + (indexIteration==0)? 0 : Math.max(0,_dataProvider[indexIteration-1] * 360 / tot);
			return startAngle;
		}
		
		/**
		* @private  
		* Set automatic colors to the pies, in case these are not provided. 
		*/
		private function useColor(indexIteration:Number):int
		{
			if (colors != null && colors.length > 0)
				tempColor = colors[indexIteration];
			else
				tempColor += 0x123456; 

			return tempColor;
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
			createPies();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		/**
		* @private 
		 * Create the bars of the chart.
		*/
		private function createPies():void
		{
			// create pies
			for (var i:Number=0; i<_dataProvider.length; i++)
			{
				var pie:EllipticalArc;
				
				if (_dataProvider[i] > 0) 
				{
					pie = new EllipticalArc(space, space, size, size, prevAngleSize, arcAngleSize(i),"pie");
					if (_colors.length != 0)
						pie.fill = new SolidFill(useColor(i));
						
					if (!isNaN(_stroke))
						pie.stroke = new SolidStroke(_stroke);
						
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