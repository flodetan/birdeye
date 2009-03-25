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
	
	import org.un.cava.birdeye.qavis.charts.interfaces.IENumerable;
	
	public class CategoryAxis extends XYAxis implements IENumerable
	{
		/** @Private
		 * The scale type cannot be changed, since it's already "category".*/
		[Exclude(name="scaleType", kind="property")]
		override public function set scaleType(val:String):void
		{}
		
		/** Elements for labeling */
		private var _elements:Array = [];
		public function set elements(val:Array):void
		{
			_elements = val;
			invalidateSize();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get elements():Array
		{
			return _elements;
		}
		
		private var _categoryField:String;
		/** Category field that will filter the category values from the 
		 * dataprovider.*/
		public function set categoryField(val:String):void
		{
			_categoryField = val;
			invalidateSize();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get categoryField():String
		{
			return _categoryField;
		}
		 
		// UIComponent flow
		
		public function CategoryAxis()
		{
			super();
			_scaleType = XYAxis.CATEGORY;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			size = getSize();
			
			// the interval is given by the axis lenght divided the number of 
			// category elements loaded in the CategoryAxis
			if (elements && elements.length >0)
			{
				var recIsGivenInterval:Boolean = isGivenInterval;
				interval = size/elements.length;
				isGivenInterval = recIsGivenInterval;
			}
			
			// if placement is set, elements are loaded and interval calculated
			// than the axis is ready to be drawn
			if (placement && elements && interval)
				readyForLayout = true;
			else 
				readyForLayout = false;
		}
		
		override protected function measure():void
		{
			super.measure();
 			if (elements && elements.length>0 && placement)
				maxLabelSize();
 		}
 		
		// other methods
		
		/** @Private
		 * Calculate the maximum label size, necessary to define the needed 
		 * width (for vertical axes) or height (for horizontal axes) of the CategoryAxis.*/
		override protected function maxLabelSize():void
		{
			switch (placement)
			{
				case TOP:
				case BOTTOM:
					maxLblSize = 10 /* pixels for 1 char height */  + thickWidth + 10;
					height = maxLblSize;
					break;
				case LEFT:
				case RIGHT:
					maxLblSize = String(_elements[0]).length;
					for (var i:Number = 0; i<_elements.length; i++)
						maxLblSize = Math.max(maxLblSize, String(_elements[i]).length); 

					maxLblSize = maxLblSize * 5 /* pixels for 1 char width */ + thickWidth + 10;
					width = maxLblSize;
					break;
			}
			
			// calculate the maximum label size according to the 
			// styles defined for the axis 
			super.calculateMaxLabelStyled();
		}
		
		/** @Private
		 * Implement the drawAxes method to draw the axis according to its orientation.*/
		override protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			if (elements && elements.length>0)
				_interval = getSize()/elements.length;
			else 
				_interval = NaN;

			var snap:Number, elementIndex:Number=0;

			if (isNaN(maxLblSize) && elements && elements.length>0 && placement)
				maxLabelSize();

			if (_interval > 0)
			{
				// vertical orientation
				if (xMin == xMax)
				{
					for (snap = yMax - interval/2; snap>yMin; snap -= interval)
					{
						// create thick line
			 			thick = new Line(xMin + thickWidth * sign, snap, xMax, snap);
						thick.stroke = new SolidStroke(stroke,1,1);
						gg.geometryCollection.addItem(thick);
			
						// create label 
	 					label = new RasterText();
						label.text = String(elements[elementIndex++]);
	 					label.fontFamily = "verdana";
	 					label.fontSize = 9;
	 					label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.y = snap-label.textField.height/2;
						label.x = thickWidth; 
						label.fill = new SolidFill(0x000000);
						gg.geometryCollection.addItem(label);
					}
				} 
				else 
				// horizontal orientation
				{
					for (snap = xMin + interval/2; snap<xMax; snap += interval)
					{
						// create thick line
			 			thick = new Line(snap, yMin + thickWidth * sign, snap, yMax);
						thick.stroke = new SolidStroke(stroke,1,1);
						gg.geometryCollection.addItem(thick);
	
						// create label 
	 					label = new RasterText();
						label.text = String(elements[elementIndex++]);
	 					label.fontFamily = "verdana";
	 					label.fontSize = 9;
	 					label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.y = thickWidth;
						label.x = snap-label.textField.width/2; 
						label.fill = new SolidFill(0x000000);
						gg.geometryCollection.addItem(label);
					}
				}
			}
		}
		
		/** @Private
		 * Override the XYZAxis getPostion method based on the linear scaling.*/
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			size = getSize();
			
			switch (placement)
			{
				case BOTTOM:
				case TOP:
					pos = ((elements.indexOf(dataValue)+.5) / elements.length) * size;
					break;
				case LEFT:
				case RIGHT:
					pos = size - ((elements.indexOf(dataValue)+.5) / elements.length) * size;
					break;
			}
				
			return pos;
		}
	}
}