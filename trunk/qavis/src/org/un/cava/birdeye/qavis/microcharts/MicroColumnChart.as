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
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	[Inspectable("negative")]
	 /**
	 * <p>This component is used to create column microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an column microchart with mxml is:</p>
	 * <p>&lt;MicroColunmChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider can be Array, ArrayCollection, String, XML, etc... 
	 * The following public properties can also be used to: </p>
	 * <p>- spacing: to modify the spacing between columns;</p>
	 * <p>- negative: this Boolean is set to true shows the negative values using the negativeColor.</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	*/
	public class MicroColumnChart extends BasicMicroChart
	{
		private var black:SolidFill = new SolidFill("0x000000",1);

		private var _spacing:Number = 0;
		private var _negative:Boolean = true;
		private var _negativeColor:int = 0xff0000; 
		
		[Inspectable(enumeration="true,false")]
		public function set negative(val:Boolean):void
		{
			_negative = val;
		}
		
		/**
		* Indicate whether negative values have to be differentiated or not. 
		*/
		public function get negative():Boolean
		{
			return _negative;
		}
		
		public function set negativeColor(val:int):void
		{
			_negativeColor = val;
		}

		/**
		* Changes the default color for the negative values. 
		*/		
		public function get negativeColor():int
		{
			return _negativeColor;
		}
		
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
		 * Calculate the height size of the column for for the current dataProvider value   
		*/
		private function sizeY(indexIteration:Number, h:Number):Number
		{
			var _sizeY:Number = - dataValue / tot * h;
			return _sizeY;
		}

		public function MicroColumnChart()
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

			createColumns(unscaledWidth, unscaledHeight);
		}
		
		/**
		* @private 
		 * Create the columns of the chart.
		*/
		private function createColumns(w:Number, h:Number):void
		{
			var columnWidth:Number = (w - spacing * (data.length-1)) / data.length;
			var startY:Number = h + Math.min(min,0)/tot * h;
			var startX:Number = 0;

			// create columns
			for (var i:Number=0; i<data.length; i++)
			{
				dataValue = Object(data.getItemAt(i))[_dataField];
				
				var posX:Number = space+startX;
				var posY:Number = sizeY(i, h);

				var column:RegularRectangle = 
					new RegularRectangle(posX, space+startY, columnWidth, posY);
				
				startX += columnWidth + spacing;

				if (!colors)
				{
					if (negative && dataValue < 0)
						column.fill = new SolidFill(_negativeColor);
					else
					{
						if (isNaN(color))
							column.fill = black;
						else 
							column.fill = new SolidFill(color);
					}
				} else {
					if (i < colors.length) {
				        column.fill = new SolidFill(colors[i]);
				    }	
				    else {
				        // Use the last color in the array if colors size is less
				        // than the number of data points.	
				        column.fill = new SolidFill(colors[colors.length - 1]);
				    }		
				}


				if (showDataTips)
				{
					geomGroup = new ExtendedGeometryGroup();
					geomGroup.target = this;
					geomGroup.geometryCollection.addItem(column);
					geomGroup.toolTipFill = column.fill;
					
					super.initGGToolTip();
					geomGroup.createToolTip(data.getItemAt(i), _dataField, posX +columnWidth/2, space+startY + posY, 3);
				} else {
					geomGroup.geometryCollection.addItem(column);
				}
			}
		}
	}
}