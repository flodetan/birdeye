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
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.text.TextFieldAutoSize;

	public class NumericAxis extends XYAxis
	{
		private var minFormatted:Boolean = false;
		private var _min:Number = NaN;
		/** The minimum value of the axis (if the axis is shared among more series, than
		 * this is the minimun value among all series. */
		public function set min(val:Number):void
		{
			_min = val;
			minFormatted = false;
			formatMin();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get min():Number
		{
			return _min;
		}
		
		private var maxFormatted:Boolean = false;
		private var _max:Number = NaN;
		/** The maximum value of the axis (if the axis is shared among more series, than
		 * this is the maximum value among all series. */
		public function set max(val:Number):void
		{
			_max = val;
			maxFormatted = false;
			formatMax();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get max():Number
		{
			return _max;
		}
		
		private var _baseAtZero:Boolean = false;
		/** Set the base of the axis at zero. If all values of the axis are positive (or negative), than the 
		 * lowest base will be zero, even if the minimum value is higher (or lower). */
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidateProperties()
			invalidateDisplayList();
		}
		public function get baseAtZero():Boolean
		{
			return _baseAtZero;
		}
		
		// UIComponent flow
		
		public function NumericAxis()
		{
			super();
			scaleType = XYAxis.LINEAR;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (!isNaN(max) && !isNaN(min) && !isGivenInterval)
			{
				if (baseAtZero)
				{
					if (max > 0)
						_interval = max / 5;
					else
						_interval = -min / 5;
				} else {
					interval = Math.abs((max - min) / 5)
				}
			}
			
			if (placement && !isNaN(max) && !isNaN(min) && interval)
				readyForLayout = true;
			else 
				readyForLayout = false;
		}
		
		// other methods
		
		override protected function maxLabelSize():void
		{
			maxLblSize = Math.max(String(min).length, String(max).length);
			
			super.calculateMaxLabelStyled();
		}

		override protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			var snap:Number;
			size = getSize();
			if (xMin == xMax)
				for (snap = min; snap<max; snap += interval)
				{
					// create thick line
		 			thick = new Line(xMin + thickWidth * sign, getPosition(snap), xMax, getPosition(snap));
					thick.stroke = new SolidStroke(stroke,1,1);
					gg.geometryCollection.addItem(thick);
		
					// create label 
 					label = new RasterText();
					label.text = String(Math.round(snap));
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.y = getPosition(snap)-label.textField.height/2;
					label.x = thickWidth * sign; 
					label.fill = new SolidFill(0x000000);
					gg.geometryCollection.addItem(label);
				}
			else
				for (snap = min; snap<max; snap += interval)
				{
					// create thick line
		 			thick = new Line(getPosition(snap), yMin + thickWidth * sign, getPosition(snap), yMax);
					thick.stroke = new SolidStroke(stroke,1,1);
					gg.geometryCollection.addItem(thick);

					// create label 
 					label = new RasterText();
					label.text = String(Math.round(snap));
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.y = thickWidth;
					label.x = getPosition(snap)-label.textField.width/2; 
					label.fill = new SolidFill(0x000000);
					gg.geometryCollection.addItem(label);
				}
		}
		
		private function formatMax():void
		{
			if (!maxFormatted && !isNaN(max))
			{
				var sign:Number = 1;
				var tempMax:Number = Math.ceil(max);
				if (max<0)
					sign = -1;
				var maxLenght:Number = String(Math.abs(tempMax)).length;
				tempMax /= Math.pow(10, maxLenght-1);
				tempMax = Math.ceil(tempMax);
				tempMax *= Math.pow(10, maxLenght-1);
				_max = tempMax * sign;
				maxFormatted = true; 
trace ("vert ax: ", _max);
			}
		}

		private function formatMin():void
		{
			if (!minFormatted && !isNaN(min))
			{
				var tempMin:Number;
				var minLenght:Number;
				tempMin = Math.floor(Math.abs(min));
				 
				if (min<0)
				{
					minLenght = String(tempMin).length;
					tempMin /= Math.pow(10, minLenght-1);
					tempMin = Math.ceil(tempMin);
					tempMin *= Math.pow(10, minLenght-1);
					_min = - tempMin;
					maxFormatted = true;
				} else {
					minLenght = String(tempMin).length;
					tempMin /= Math.pow(10, minLenght);
					tempMin = Math.floor(tempMin);
					tempMin *= Math.pow(10, minLenght);
					_min = tempMin;
					maxFormatted = true;
				} 
			}
		}
	}
}