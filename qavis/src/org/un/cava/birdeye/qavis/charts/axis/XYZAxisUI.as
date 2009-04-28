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
 
package org.un.cava.birdeye.qavis.charts.axis
{
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	
	public class XYZAxisUI extends BaseAxisUI 
	{
		protected var readyForLayout:Boolean = false;

		/** @Private
		 * Set to true if the user has specified an interval for the axis.
		 * Otherwise, the interval will be calculated automatically.
		 */
		protected var isGivenInterval:Boolean = false;

		/** Set the interval between axis values. */
		override public function set interval(val:Number):void
		{
			_interval = val;
			isGivenInterval = true;
			if (scaleType == CATEGORY)
				dispatchEvent(new Event("IntervalChanged"));
			invalidateProperties();
			invalidateDisplayList();
		}

		private var _showLabels:Boolean = true;
		/** Show labels on the axis */
		[Inspectable(enumeration="false,true")]
		public function set showLabels(val:Boolean):void
		{
			_showLabels = val;
			invalidateDisplayList();
		}
		public function get showLabels():Boolean
		{
			return _showLabels;
		}
		
		public var maxLblSize:Number = NaN;
		/** @Private 
		 * Specifies the maximum label size needed to calculate the axis size
		 **/
		protected function maxLabelSize():void
		{
			// must be overridden 
		}

		/** @Private */
		protected function calculateMaxLabelStyled():void
		{
			// calculate according font size and style
			// consider auto-size and thick size too
		}

		// UIComponent flow
		public function XYZAxisUI()
		{
			super();
		}
		
		/** @Private */
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		/** @Private */
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		/** @Private */
		override protected function measure():void
		{
			super.measure();
		}
		
		private var xMin:Number = NaN, yMin:Number = NaN, xMax:Number = NaN, yMax:Number = NaN;
		private var sign:Number = NaN
		protected var line:Line; // draw the axis line
		protected var thick:Line; 
		protected var thickWidth:Number = 5;
		protected var label:RasterTextPlus;
		/** @Private */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			setActualSize(w,h);
			
			removeAllElements();
			
			drawAxisLine(w,h)

			if (readyForLayout)
			{
				switch (placement)
				{
					case BOTTOM:
					case HORIZONTAL_CENTER:
						xMin = 0; xMax = w;
						yMin = 0; yMax = 0;
						sign = 1;
						_pointer = new Line(0,0, 0, 7);
						break;
					case TOP:
						xMin = 0; xMax = w;
						yMin = h; yMax = h;
						sign = -1;
						_pointer = new Line(0,h-7, 0, h);
						break;
					case LEFT:
					case VERTICAL_CENTER:
						xMin = w; xMax = w;
						yMin = 0; yMax = h;
						sign = -1;
						_pointer = new Line(w-7,h, w, h);
						break;
					case RIGHT:
					case DIAGONAL:
						xMin = 0; xMax = 0;
						yMin = 0; yMax = h;
						sign = 1;
						_pointer = new Line(0,h, +7, h);
						break;
				}
				drawAxes(xMin, xMax, yMin, yMax, sign);
				_pointer.stroke = new SolidStroke(0xff0000,1,3);
				_pointer.visible = false;
				gg.geometryCollection.addItem(_pointer);
			}
		}
		/** @Private
		 * Draw the axis depending on the current unscaled size and its placement
		 */
		protected function drawAxisLine(w:Number, h:Number):void
		{
			var x0:Number, x1:Number, y0:Number, y1:Number;
			
			switch (placement)
			{
				case BOTTOM:
				case HORIZONTAL_CENTER:
					x0 = 0; x1 = w;
					y0 = 0; y1 = 0;
					break;
				case TOP:
					x0 = 0; x1 = w;
					y0 = h; y1 = h;
					break;
				case LEFT:
				case VERTICAL_CENTER:
					x0 = w; x1 = w;
					y0 = 0; y1 = h;
					break;
				case RIGHT:
 				case DIAGONAL:
					x0 = 0; x1 = 0;
					y0 = 0; y1 = h;
					break;
 				case DIAGONAL:
					x0 = 0; x1 = 0;
					y0 = 0; y1 = h;
					break;
			}

			line = new Line(x0,y0,x1,y1);
			line.stroke = new SolidStroke(_lineColor, 1, _lineWeight);
			gg.geometryCollection.addItem(line);

		}
		
		/** @Private
		 * Override this method to draw the axis depending on its type (linear, category, etc)
		 */
		protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			// to be overridden
		}
 	}
}


