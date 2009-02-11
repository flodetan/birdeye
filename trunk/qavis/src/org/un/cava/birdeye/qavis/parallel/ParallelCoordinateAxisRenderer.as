///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2009 Michael VanDaniker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////

package org.un.cava.birdeye.qavis.parallel
{
	import flash.events.Event;
	import flash.text.TextLineMetrics;
	
	import mx.core.UIComponent;
	import mx.core.UITextField;

	/**
	 * A simple implementation of IParallelCoordinateAxisRenderer.
	 * 
	 * Displays the axis a vertical line centered under a text field with the axis's label.
	 */
	public class ParallelCoordinateAxisRenderer extends UIComponent implements IParallelCoordinateAxisRenderer
	{
		/**
		 * The text field used to display the axis's label
		 */
		protected var textField:UITextField;
		
		public function ParallelCoordinateAxisRenderer()
		{
			super();
		}
		
		[Bindable(event="fieldNameChange")]
		public function set fieldName(value:String):void
		{
			if(value != _fieldName)
			{
				_fieldName = value;
				invalidateDisplayList();
				dispatchEvent(new Event("fieldNameChange"));
			}
		}
		public function get fieldName():String
		{
			return _fieldName;
		}
		private var _fieldName:String;
		
		[Bindable(event="labelChange")]
		public function set label(value:String):void
		{
			if(value != _label)
			{
				_label = value;
				invalidateSize();
				invalidateDisplayList();
				dispatchEvent(new Event("labelChange"));
			}
		}
		public function get label():String
		{
			return _label;
		}
		private var _label:String;

		public function get axisOffsetLeft():Number
		{
			return _axisOffsetLeft;
		}
		private var _axisOffsetLeft:Number = 0;
		
		public function get axisOffsetRight():Number
		{
			return _axisOffsetRight;
		}
		private var _axisOffsetRight:Number = 1;
		
		public function get axisOffsetTop():Number
		{
			return _axisOffsetTop;
		}
		private var _axisOffsetTop:Number = 0;
		
		public function get axisOffsetBottom():Number
		{
			return _axisOffsetBottom;
		}
		private var _axisOffsetBottom:Number = 0;
		
		override protected function createChildren():void
		{
			super.createChildren();
			if(!textField)
			{
				textField = new UITextField();
				addChild(textField);
			}
		}
		
		// This axis renderer should measure as wide as the text for the label.
		override protected function measure():void
		{
			super.measure();
			if(textField)
			{
				textField.text = label == "" || label == null ? fieldName : label;
				var textLineMetrics:TextLineMetrics = textField.getLineMetrics(0);
				textField.setActualSize(textLineMetrics.width + 6,textLineMetrics.height + 2);
				measuredWidth = textLineMetrics.width + 6;
				
				_axisOffsetLeft = textField.width / 2;
				_axisOffsetRight = axisOffsetLeft - 1;
				_axisOffsetTop = textField.height + 5;
			}
		}

		// Draw a vertical line centered under the text field		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			textField.text = label == "" || label == null ? fieldName : label;
			textField.move(0,0);
				
			var halfTextWidth:Number = textField.width / 2;
			graphics.clear();
			graphics.lineStyle(1,0);
			graphics.moveTo(halfTextWidth,textField.height + 5);
			graphics.lineTo(halfTextWidth,height);
		}
	}
}