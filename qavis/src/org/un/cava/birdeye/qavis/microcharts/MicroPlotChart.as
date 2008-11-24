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
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	[Inspectable("negative")]
	 /**
	 * <p>This component is used to create plot microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an plot microchart with mxml is:</p>
	 * <p>&lt;MicroPlotChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The following public properties can also be used to:</p> 
	 * <p>- radius: to modify the plots size;</p>
	 * <p>- negative: this Boolean if set to true shows the negative reference line colored with the same color of plots.</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	*/
	public class MicroPlotChart extends MicroChart
	{
		private var red:SolidStroke = new SolidStroke("0xff0000",1);
		private var black:SolidFill = new SolidFill("0x000000",1);
		
		private var _negative:Boolean = true;
		private var _negativeColor:Number = NaN;
		private var _radius:Number = 2;
		
		[Inspectable(enumeration="true,false")]
		public function set negative(val:Boolean):void
		{
			_negative = val;
		}
		
		/**
		* Indicate whether the negative reference line has to be drawn or not. 
		*/
		public function get negative():Boolean
		{
			return _negative;
		}
		
		public function set negativeColor(val:Number):void
		{
			_negativeColor = val;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default color of the negative line. 
		*/		
		public function get negativeColor():Number
		{
			return _negativeColor;
		}
		
		public function set radius(val:Number):void
		{
			_radius = val;
			invalidateDisplayList();
		}
		
		/**
		* Set the radius of plots for the chart. 
		*/		
		public function get radius():Number
		{
			return _radius;
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
		 * Calculate the height size of the plot for the current dataProvider value   
		*/
		private function sizeY(indexIteration:Number):Number
		{
			var _sizeY:Number = dataProvider[indexIteration] / tot * height;
			return _sizeY;
		}

		public function MicroPlotChart()
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
			for(var i:int=this.numChildren-1; i>=0; i--)
				if(getChildAt(i) is GeometryGroup)
						removeChildAt(i);

			geomGroup = new GeometryGroup();
			geomGroup.target = this;
			createBackground(width, height);
			createPlots();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		override protected function createBackground(w:Number, h:Number):void
		{
			if (!isNaN(backgroundColor) || !isNaN(backgroundStroke))
			{
				var backgroundRect:RegularRectangle = new RegularRectangle(space, space-radius, width, height+radius*3/2);
				if (!isNaN(backgroundColor))
					backgroundRect.fill = new SolidFill(backgroundColor);
				if (!isNaN(backgroundStroke))
					backgroundRect.stroke = new SolidStroke(backgroundStroke);
				
				geomGroup.geometryCollection.addItem(backgroundRect);
			}
		}
		
		/**
		* @private 
		 * Create the plots of the chart.
		*/
		private function createPlots():void
		{
			var columnWidth:Number = width/dataProvider.length;
			var startY:Number = height + Math.min(min,0)/tot * height;
			var startX:Number = 0;

			// create negative reference line
			if (negative)
			{
				var negLine:Line = new Line(space+startX, space+startY, space+width, space+startY);
				if (!isNaN(_negativeColor))
					negLine.stroke = new SolidStroke(_negativeColor);
				else
					negLine.stroke = red;
				geomGroup.geometryCollection.addItem(negLine);
			}
			
			// create columns
			for (var i:Number=0; i<dataProvider.length; i++)
			{
				var plot:Circle = 
					new Circle(space+startX+columnWidth/2, space+ startY-sizeY(i), radius);
				
				startX += columnWidth;

				if (colors != null)
					plot.fill = new SolidFill(useColor(i));
				else
					plot.fill = new SolidFill(black);
					
				geomGroup.geometryCollection.addItem(plot);
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