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
	
	public class CategoryAxis extends XYAxis 
	{
		[Exclude(name="scaleType", kind="property")]
		override public function set scaleType(val:String):void
		{}
		
		/** Elements for labeling */
		private var _elements:Array = [];
		public function set elements(val:Array):void
		{
			_elements = val;
trace(_elements)			
			maxLabelSize();
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		public function get elements():Array
		{
			return _elements;
		}
		
		private var _categoryField:String;
		public function set categoryField(val:String):void
		{
			_categoryField = val;
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

			if (elements)
				interval = size/elements.length;

			if (placement && elements && interval)
				readyForLayout = true;
			else 
				readyForLayout = false;
		}
		
		// other methods
		
		override protected function maxLabelSize():void
		{
			maxLblSize = String(_elements[0]).length;
			for (var i:Number; i<_elements.length; i++)
			{
				var tmpSize:Number = String(_elements[i]).length;
				if (tmpSize > maxLblSize)
					maxLblSize = tmpSize;
			}
			super.calculateMaxLabelStyled();
		}
		
		override protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			var snap:Number, elementIndex:Number=0;
			size = getSize();
			if (xMin == xMax)
				for (snap = yMax - interval/2; snap>yMin; snap -= interval)
				{
					// create thick line
		 			thick = new Line(xMin + thickWidth * sign, snap, xMax, snap);
					thick.stroke = new SolidStroke(stroke,1,1);
					gg.geometryCollection.addItem(thick);
		
					// create label 
 					label = new RasterText();
					label.text = String(elements[elementIndex++]);
trace(label.text);
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.y = snap-label.textField.height/2;
					label.x = thickWidth; 
					label.fill = new SolidFill(0x000000);
					gg.geometryCollection.addItem(label);
				}
			else
				for (snap = xMin + interval/2; snap<xMax; snap += interval)
				{
					// create thick line
		 			thick = new Line(snap, yMin + thickWidth * sign, snap, yMax);
					thick.stroke = new SolidStroke(stroke,1,1);
					gg.geometryCollection.addItem(thick);

					// create label 
 					label = new RasterText();
					label.text = String(elements[elementIndex++]);
 					label.visible = true;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.autoSizeField = true;
					label.y = thickWidth;
					label.x = snap-label.textField.width/2; 
					label.fill = new SolidFill(0x000000);
					gg.geometryCollection.addItem(label);
				}
		}
		
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			size = getSize();
			pos = ((elements.indexOf(dataValue)+.5) / elements.length) * size;
				
			return pos;
		}
	}
}