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
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	 /**
	 * <p>This component is used to create area microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * <p>The dataProvider property can accept Array, ArrayCollection, String, XML, etc.
	 * The basic simple syntax to use it and create an area microchart with mxml is:</p>
	 * <p>&lt;MicroAreaChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	*/
	public class MicroAreaChart extends BasicMicroChart
	{
		private var black:String = "0x000000";
		
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
		 * Calculate the y value (position) inside the chart of the current dataProvider   
		*/
		private function sizeY(indexIteration:Number, h:Number):Number
		{
			var _sizeY:Number = data[indexIteration] / tot * h;
			return _sizeY;
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
			
			createPolygons(unscaledWidth, unscaledHeight);
			this.graphicsCollection.addItem(geomGroup);
		}
		
		/**
		* @private 
		 * Create the areas of the chart.
		*/
		private function createPolygons(w:Number, h:Number):void
		{
			var columnWidth:Number = w/data.length;
			var startY:Number = h + Math.min(min,0)/tot * h;
			var startX:Number = 0;

			// create polygons
			for (var i:Number=0; i<data.length-1; i++)
			{
				var pol:Polygon = new Polygon ()
				
				pol.data =  String(space+startX+columnWidth/2) + "," + String(space+startY) + " " +
							String(space+startX+columnWidth/2) + "," + String(space+startY-sizeY(i, h)) + " " +
							String(space+startX+columnWidth*3/2) + "," + String(space+startY-sizeY(i+1, h)) + " " +
							String(space+startX+columnWidth*3/2) + "," + String(space+startY);

				startX += columnWidth;

				if (colors != null)
					pol.fill = new SolidFill(useColor(i));
				else 
					pol.fill = new SolidFill(black);
					
				geomGroup.geometryCollection.addItem(pol);
			}
		}
	}
}