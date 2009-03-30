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
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.qavis.charts.interfaces.IAxisLayout;
	
	public class XYZAxis extends UIComponent implements IAxisLayout
	{
		protected var surf:Surface;
		protected var gg:GeometryGroup;
		protected var fill:SolidFill = new SolidFill(0x888888,0);
		protected var stroke:SolidStroke = new SolidStroke(0x888888,1,1);
		
		protected var readyForLayout:Boolean = false;

		/** Scale type: Linear */
		public static const LINEAR:String = "linear";
		/** Scale type: Numeric (general numeric scale that could be used for custom numeric axes)*/
		public static const NUMERIC:String = "linear";
		/** Scale type: Category */
		public static const CATEGORY:String = "category";
		/** Scale type: Logaritmic */
		public static const LOG:String = "log";
		/** Scale type: DateTime */
		public static const DATE_TIME:String = "date_time";
		
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
		
		/** Position the pointer to the specified x position. Used by a cartesian series
		 * if the current axis is x.*/
		public function set pointerX(val:Number):void
		{
			pointer.x = pointer.x1 = val;
		}
		
		/** Position the pointer to the specified y position. Used by a cartesian series
		 * if the current axis is vertical.*/
		public function set pointerY(val:Number):void
		{
			pointer.y = pointer.y1 = val;
		}

		/** @Private
		 * Set to true if the user has specified an interval for the axis.
		 * Otherwise, the interval will be calculated automatically.
		 */
		protected var isGivenInterval:Boolean = false;

		protected var _interval:Number = NaN;
		/** Set the interval between axis values. */
		public function set interval(val:Number):void
		{
			_interval = val;
			isGivenInterval = true;
			if (scaleType == CATEGORY)
				dispatchEvent(new Event("IntervalChanged"));
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get interval():Number
		{
			return _interval;
		}
		
		/** Diagonal placement for the Z axis. */
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
		
		private var _showTicks:Boolean = true;
		/** Show ticks on the axis */
		[Inspectable(enumeration="false,true")]
		public function set showTicks(val:Boolean):void
		{
			_showTicks = val;
		}
		public function get showTicks():Boolean
		{
			return _showTicks;
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
		public function XYZAxis()
		{
			super();
		}
		
		private var labelCont:Container;
		/** @Private */
		override protected function createChildren():void
		{
			super.createChildren();
			surf = new Surface();
			gg = new GeometryGroup();
			gg.target = surf;
			surf.addChild(gg);
			addChild(surf);
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
		protected var label:RasterText;
		
		private var _pointer:Line;
		public function set pointer(val:Line):void
		{
			_pointer = val;
			invalidateDisplayList();
		}
		public function get pointer():Line
		{
			return _pointer;
		}
		
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
					x0 = 0; x1 = w;
					y0 = 0; y1 = 0;
					break;
				case TOP:
					x0 = 0; x1 = w;
					y0 = h; y1 = h;
					break;
				case LEFT:
					x0 = w; x1 = w;
					y0 = 0; y1 = h;
					break;
				case RIGHT:
 				case DIAGONAL:
					x0 = 0; x1 = 0;
					y0 = 0; y1 = h;
					break;
/*  				case DIAGONAL:
					x0 = 0; x1 = w;
					y0 = h; y1 = h;
					break;
 */ 			}

			line = new Line(x0,y0,x1,y1);
			line.fill = fill;
			line.stroke = stroke;
			gg.geometryCollection.addItem(line);

		}
		
		/** @Private
		 * Override this method to draw the axis depending on its type (linear, category, etc)
		 */
		protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			// to be overridden
		}

		protected var size:Number;
		/** @Private
		 * Get the size of the axis ,i.e. either its width or height depending on the placement selected.
		 */
		protected function getSize():Number
		{
			switch (placement)
			{
				case BOTTOM:
				case TOP:
					size = width;
					break;
				case LEFT:
				case RIGHT:
				case DIAGONAL:
					size = height;
					break;
			}
			return size;
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


