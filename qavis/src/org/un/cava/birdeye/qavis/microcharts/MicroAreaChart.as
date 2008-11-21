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
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	 /**
	 * <p>This component is used to create area microcharts. 
	 * The basic simple syntax to use it and create an area microchart with mxml is:</p>
	 * <p>&lt;MicroAreaChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML.
	 * It's also possible to change the colors by defining the following:</p>
	 * <p>- color: to change the default shape color;</p>
	 * 
	*/
	public class MicroAreaChart extends Surface
	{
		private var geomGroup:GeometryGroup;
		private var black:String = "0x000000";
		
		private var _colors:Array = null;
		private var _dataProvider:Array = new Array();
		
		private var min:Number, max:Number, space:Number = 0;
		private var tot:Number = NaN;

		public function set colors(val:Array):void
		{
			_colors = val;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default color of the area. 
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
		* Set the dataProvider that will feed the area chart. 
		*/
		public function get dataProvider():Array
		{
			return _dataProvider;
		}

		/**
		* @private
		 * Used to recalculate min, max and tot each time properties have to ba revalidated 
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
			minMaxTot();
		}
		
		/**
		* @private
		 * Calculate min, max and tot  
		*/
		private function minMaxTot():void
		{
			min = max = _dataProvider[0];

			tot = 0;
			for (var i:Number = 0; i < _dataProvider.length; i++)
			{
				if (min > _dataProvider[i])
					min = _dataProvider[i];
				if (max < _dataProvider[i])
					max = _dataProvider[i];
			}
			// in case all values are negative or all values are positive, the 0 is considered respectively 
			// to define the top or the bottom of the chart 
			tot = Math.abs(Math.max(max,0) - Math.min(min,0));
		}

		/**
		* @private
		 * Calculate the y value (position) inside the chart of the current dataProvider   
		*/
		private function sizeY(indexIteration:Number):Number
		{
			var _sizeY:Number = _dataProvider[indexIteration] / tot * height;
			return _sizeY;
		}

		/**
		* @private
		 * It sets the color for the current area (polygon)   
		*/
		private function useColor(indexIteration:Number):int
		{
			return _colors[indexIteration];
		}
		
		public function MicroAreaChart()
		{
			super();
		}
		
		/**
		* @private 
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// it replaces the this.graphics.clear() that doesn't work well
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i) is GeometryGroup)
						removeChildAt(i);

			geomGroup = new GeometryGroup();
			geomGroup.target = this;
			createPolygons();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		/**
		* @private 
		 * Create the areas of the chart.
		*/
		private function createPolygons():void
		{
			var columnWidth:Number = width/dataProvider.length;
			var startY:Number = height + Math.min(min,0)/tot * height;
			var startX:Number = 0;

			// create polygons
			for (var i:Number=0; i<_dataProvider.length-1; i++)
			{
				var pol:Polygon = 
					new Polygon ()
				
				pol.data =  String(space+startX+columnWidth/2) + "," + String(space+startY) + " " +
							String(space+startX+columnWidth/2) + "," + String(space+startY-sizeY(i)) + " " +
							String(space+startX+columnWidth*3/2) + "," + String(space+startY-sizeY(i+1)) + " " +
							String(space+startX+columnWidth*3/2) + "," + String(space+startY);

				startX += columnWidth;

				if (_colors != null)
					pol.fill = new SolidFill(useColor(i));
				else 
					pol.fill = new SolidFill(black);
					
				geomGroup.geometryCollection.addItem(pol);
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