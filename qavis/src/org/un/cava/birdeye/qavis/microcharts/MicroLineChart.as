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
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	[Inspectable("negative")]
	 /**
	 * <p>This component is used to create line microcharts and extends the MicroChart class, thus inheriting all its 
	 * properties (backgroundColor, backgroundStroke, colors, stroke, dataProvider, etc) and methods (minMaxTot, 
	 * useColor, createBackground).
	 * The basic simple syntax to use it and create an column microchart with mxml is:</p>
	 * <p>&lt;MicroLineChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * It's also possible to change the colors by defining the following properties in the mxml declaration:</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	 * <p>- referenceColor: to set a reference line color different from the negative one;</p>
	 * 
	 * <p>The following public properties can also be used to: </p>
	 * <p>- spacing: to modify the spacing between columns;</p>
	 * <p>- referenceValue: to set a reference line different from the negative one;</p>
	 * <p>- negative: this Boolean is set to true shows the negative values using the negativeColor.</p>
	*/
	public class MicroLineChart extends MicroChart
	{
		private var black:SolidStroke = new SolidStroke("0x000000",1);
		
		private var _referenceColor:Number = 0x000000;
		private var _referenceValue:Number = NaN;
		private var _radius:Number = 2;
		private var _negative:Boolean = true;
		private var _negativeColor:int = 0xff0000; 
		
		public function set referenceColor(val:Number):void
		{
			_referenceColor = val;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default colors for the reference line. 
		*/		
		public function get referenceColor():Number
		{
			return _referenceColor;
		}
		
		public function set referenceValue(val:Number):void
		{
			_referenceValue = val;
			invalidateDisplayList();
		}
		
		/**
		* Set the reference value to create the reference line. 
		*/		
		public function get referenceValue():Number
		{
			return _referenceValue;
		}
		
		/**
		* Set the plots radius value. 
		*/		
		public function set radius(val:Number):void
		{
			_radius = val;
			invalidateDisplayList();
		}
		
		public function get radius():Number
		{
			return _radius;
		}

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
		private function sizeY(indexIteration:Number):Number
		{
			var _sizeY:Number = data[indexIteration] / tot * height;
			return _sizeY;
		}

		public function MicroLineChart()
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
			createLines();
			this.graphicsCollection.addItem(geomGroup);
		}
				
		/**
		* @private 
		 * Create the lines of the chart.
		*/
		private function createLines():void
		{
			var columnWidth:Number = width/data.length;
			var startY:Number = height + Math.min(min,0)/tot * height;
			var startX:Number = 0;

			// create reference line
			if (!isNaN(_referenceValue))
			{
				var refY:Number = startY - _referenceValue/tot * height;
				refY = Math.min(height, refY);
				refY = Math.max(0, refY);
				
				var refLine:Line = new Line(space+startX, space+refY, space+width, space+refY);
				refLine.stroke = new SolidStroke(_referenceColor);
				geomGroup.geometryCollection.addItem(refLine);
			}
			
			// create negative ref line
			if (_negative)
			{
				var negLine:Line = new Line(space+startX, space+startY, space+width, space+startY);
				negLine.stroke = new SolidStroke(_negativeColor);
				geomGroup.geometryCollection.addItem(negLine);
			}

			// create value lines
			for (var i:Number=0; i<data.length-1; i++)
			{
				var line:Line = 
					new Line(space+startX+columnWidth/2, space+startY-sizeY(i), space+startX + columnWidth*3/2, space+startY-sizeY(i+1));
				
				startX += columnWidth;

				if (colors != null)
					line.stroke = new SolidStroke(useColor(i));
				else 
					line.stroke = new SolidStroke(black);
					
				geomGroup.geometryCollection.addItem(line);
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