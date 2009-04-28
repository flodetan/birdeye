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
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisUI;
	
	public class BaseAxisUI extends UIComponent implements IAxisUI
	{
		protected var surf:Surface;
		protected var gg:GeometryGroup;
		
		/** Scale type: Linear */
		public static const LINEAR:String = "linear";
		/** Scale type: Percent */
		public static const PERCENT:String = "percent";
		/** Scale type: CONSTANT */
		public static const CONSTANT:String = "constant";
		/** Scale type: Numeric (general numeric scale that could be used for custom numeric axes)*/
		public static const NUMERIC:String = "linear";
		/** Scale type: Category */
		public static const CATEGORY:String = "category";
		/** Scale type: Logaritmic */
		public static const LOG:String = "log";
		/** Scale type: DateTime */
		public static const DATE_TIME:String = "date_time";
		
		protected var _size:Number;
		public function set size(val:Number):void
		{
			_size = val;
			switch (placement)
			{
				case HORIZONTAL_CENTER:
				case BOTTOM:
				case TOP:
					width = _size;
					break;
				case VERTICAL_CENTER:
				case RIGHT:
				case LEFT:
				case DIAGONAL:
					height = _size;
					break;
			}
			invalidateDisplayList();

		}
		/** @Private
		 * Get the size of the axis ,i.e. either its width or height depending on the placement selected.
		 */
		public function get size():Number
		{
			return _size;
		}

		protected var _function:Function;
		/** Set the function that will be applied to calculate the getPosition of a 
		 * data value in the axis. The function will basically define a custom 
		 * scale for the axis.*/
		public function set f(val:Function):void
		{
			_function = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		protected var _fontSize:Number = 10;
		/** Set the font size for the labels.*/
		public function set fontSize(val:Number):void
		{
			_fontSize = val;
			invalidateDisplayList();
		}
		
		protected var _fontColor:Number = 0x000000;
		/** Set the font color for the labels.*/
		public function set fontColor(val:Number):void
		{
			_fontColor = val;
			invalidateDisplayList();
		}
		
		protected var _lineColor:Number = 0x000000;
		/** Set the axis line color.*/
		public function set lineColor(val:Number):void
		{
			_lineColor = val;
			invalidateDisplayList();
		}

		protected var _lineWeight:Number = 1;
		/** Set the axis line weight.*/
		public function set lineWeight(val:Number):void
		{
			_lineWeight = val;
			invalidateDisplayList();
		}

		/** Position the pointer to the specified x position. Used by a cartesian series
		 * if the current axis is x.*/
		public function set pointerX(val:Number):void
		{
			if (pointer)
				pointer.x = pointer.x1 = val;
		}
		
		/** Position the pointer to the specified y position. Used by a cartesian series
		 * if the current axis is vertical.*/
		public function set pointerY(val:Number):void
		{
			if (pointer) 
				pointer.y = pointer.y1 = val;
		}

		protected var _pointer:Line;
		public function set pointer(val:Line):void
		{
			_pointer = val;
			invalidateDisplayList();
		}
		public function get pointer():Line
		{
			return _pointer;
		}
		
		protected var _scaleType:String = LINEAR;
		/** Set the scale type, LINEAR by default. */
		public function set scaleType(val:String):void
		{
			_scaleType = val;
			invalidateProperties()
			invalidateSize();
			invalidateDisplayList();
		}
		public function get scaleType():String
		{
			return _scaleType;
		}
		
		protected var _interval:Number = NaN;
		/** Set the interval between axis values. */
		public function set interval(val:Number):void
		{
			_interval = val;

			invalidateProperties();
			invalidateDisplayList();
		}
		public function get interval():Number
		{
			return _interval;
		}
		
		/** Diagonal placement for the axis (for ex. used for the z axis). */
		public static const DIAGONAL:String = "diagonal";
		/** TOP placement for the axis. */
		public static const TOP:String = "top";
		/** BOTTOM placement for the axis. */
		public static const BOTTOM:String = "bottom";
		/** LEFT placement for the axis. */
		public static const LEFT:String = "left";
		/** RIGHT placement for the axis. */
		public static const RIGHT:String = "right";
		/** VERTICAL_CENTER placement for the axis. */
		public static const VERTICAL_CENTER:String = "vertical_center";
		/** HORIZONTAL_CENTER placement for the axis. */
		public static const HORIZONTAL_CENTER:String = "horizontal_center";
		
		private var _placement:String;
		/** Set the placement for this axis. */
		[Inspectable(enumeration="top,bottom,left,right,vertical_center,horizontal_center,diagonal")]
		public function set placement(val:String):void
		{
			_placement = val;
			invalidateProperties()
			invalidateSize();
			invalidateDisplayList();
		}
		public function get placement():String
		{
			return _placement;
		}
		
		/** @Private */
		override protected function createChildren():void
		{
			super.createChildren();
			surf = new Surface();
			gg = new GeometryGroup();
			gg.target = surf;
			surf.graphicsCollection.addItem(gg);
			addChild(surf);
		}
		
		/** @Private
		 * Given a data value, it returns the position of the data value on the current axis.
		 * Override this method depending on the axis scaling (linear, log, category, etc).
		 */
		public function getPosition(dataValue:*):*
		{
			// to be overridden by implementing axis class (Category, Numeric, DateTime..)
			return null;
		}
		
		public function removeAllElements():void
		{
			if (gg)
			{
				gg.geometry = [];
				gg.geometryCollection.items = [];
			}
		}
	}
}