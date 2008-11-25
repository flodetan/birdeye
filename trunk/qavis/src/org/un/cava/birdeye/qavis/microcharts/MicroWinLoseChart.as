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
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	 /**
	 * <p>This component is used to create win lose microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an column microchart with mxml is:</p>
	 * <p>&lt;MicroWinLoseChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider can be Array, ArrayCollection, String, XML, etc...
	 * It's also possible to change the colors by defining the following properties in the mxml declaration:</p>
	 * <p>- color: to change the default shape color;</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	 * 
	 * <p>The following public properties can also be used to: </p>
	 * <p>- spacing: to modify the spacing between columns;</p>
	*/
	public class MicroWinLoseChart extends BasicMicroChart
	{
		private var black:SolidFill = new SolidFill("0x000000",1);
		private var red:SolidFill = new SolidFill("0xff0000",1);
		
		private var _spacing:Number = 0;
		private var _referenceValue:Number = 0;
		
		public function set spacing(val:Number):void
		{
			_spacing = val;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default spacing between columns. 
		*/		
		public function get spacing():Number
		{
			return _spacing;
		}
		
		public function set referenceValue(val:Number):void
		{
			_referenceValue = val;
			invalidateDisplayList(); 
		}

		/**
		* Change the default (0) reference value that define winning or loosing values. 
		*/
		public function get referenceValue():Number
		{
			return _referenceValue; 
		}

		public function MicroWinLoseChart()
		{
			super();
		}
		
		/**
		* @private
		 * Calculate the height size of the winlose column for the current dataProvider value   
		*/
		private function sizeY(indexIteration:Number):Number
		{
			var _sizeY:Number = (data[indexIteration] >= _referenceValue) ? -height/3 : height/3;
			return _sizeY;
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
			createColumns();
			this.graphicsCollection.addItem(geomGroup);
		}
		
		override protected function createBackground(w:Number, h:Number):void
		{
			w += spacing * (data.length - 1);
			super.createBackground(w,h);
		}

		/**
		* @private 
		 * Create the winlose columns.
		*/
		private function createColumns():void
		{
			var columnWidth:Number = width/data.length;
			var startY:Number = height/2;
			var startX:Number = 0;

			// create columns
			for (var i:Number=0; i<data.length; i++)
			{
				var column:RegularRectangle = 
					new RegularRectangle(space+startX, space+startY, columnWidth, sizeY(i));
				
				startX += columnWidth + spacing;

				if (colors == null || colors.lenght == 0)
					if (data[i] < 0)
						column.fill = red;
					else
						column.fill = black;
				else
					column.fill = new SolidFill(useColor(i));

				geomGroup.geometryCollection.addItem(column);
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