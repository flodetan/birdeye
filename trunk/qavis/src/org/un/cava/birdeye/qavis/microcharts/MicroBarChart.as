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
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	[Inspectable("negative")]
	 /**
	 * <p>This component is used to create bar microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an bar microchart with mxml is:</p>
	 * <p>&lt;MicroBarChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider property can accept Array, ArrayCollection, String, XML, etc.
	 * The following public properties can also be used to: </p>
	 * <p>- spacing: to modify the spacing between columns;</p>
	 * <p>- negative: this Boolean is set to true shows the negative values using the negativeColor.</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	*/
	public class MicroBarChart extends BasicMicroChart
	{
		private var black:SolidFill = new SolidFill("0x000000",1);
		
		private var _spacing:Number = 0;
		private var _negative:Boolean = true;
		private var _negativeColor:int = 0xff0000; 
		
		public function set spacing(val:Number):void
		{
			_spacing = val;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default spacing between bars. 
		*/
		public function get spacing():Number
		{
			return _spacing;
		}
		
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
		
		/**
		* @private
		 * Calculate the width size of the bar for for the current dataProvider value   
		*/
		private function sizeX(indexIteration:Number, w:Number):Number
		{
			var _sizeX:Number = dataValue / tot * w;
			return _sizeX;
		}

		public function MicroBarChart(data:Object = null)
		{
			super();
			if (data) 
				this.dataProvider = data;
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
		 * Used to create and refresh the chart.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var dataSortField:SortField = new SortField(_dataField, false, true, true);
			var numDataSort:Sort = new Sort();
			numDataSort.fields = [dataSortField];
			data.sort = numDataSort;
			data.refresh();
			createBars(unscaledWidth, unscaledHeight);
		}
		
		/**
		* @private 
		 * Create the bars of the chart.
		*/
		private function createBars(w:Number, h:Number):void
		{
			var columnWidth:Number = (h - spacing * (data.length-1)) / data.length;
			var startX:Number = - Math.min(min,0)/tot * w;
			var startY:Number = 0;

			// create bars
			for (var i:Number=0; i<data.length; i++)
			{
				dataValue = Object(data.getItemAt(i))[_dataField];
				
				var posX:Number = sizeX(i,w);

				var column:RegularRectangle = 
					new RegularRectangle(space+startX, space+startY, posX, columnWidth);
				
				startY += columnWidth + spacing;

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
					if (i < colors.length) 
					{
						if (colors[i] is IGraphicsFill)
							column.fill = colors[i];
						else if (colors[i] is Number)
							column.fill = new SolidFill(colors[i]);
					} else
						column.fill = new SolidFill(0x999999);
				}

				if (showDataTips)
				{
					geomGroup = new ExtendedGeometryGroup();
					geomGroup.target = this;
					geomGroup.geometryCollection.addItem(column);
					geomGroup.toolTipFill = column.fill;
					super.initGGToolTip();
					geomGroup.createToolTip(data.getItemAt(i), _dataField, space+startX + posX, 
						space -spacing + startY - columnWidth/2, 3);
				} else {
					geomGroup.geometryCollection.addItem(column);
				}
			}
		}
	}
}