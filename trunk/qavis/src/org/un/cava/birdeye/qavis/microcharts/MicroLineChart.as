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
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import mx.core.UIComponent;

	[Inspectable("negative")]
	 /**
	* <p>This component is used to create line microcharts. 
	 * The basic simple syntax to use it and create an line microchart with mxml is:</p>
	 * <p>&lt;MicroLineChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML.
	 * It's also possible to change the colors by defining the following properties in the mxml declaration:</p>
	 * <p>- color: to change the default shape color;</p>
	 * <p>- backgroundColor: to change the default background color of the chart;</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	 * <p>- negative: this Boolean if set to true shows the negative reference line colored with the negativeColor.</p>
	*/
	public class MicroLineChart extends UIComponent
	{
		private static const DEFAULT_WIDTH:Number = 200;
		private static const DEFAULT_HEIGHT:Number = 50;
		private static const DEFAULT_COLOR:int = 0x000000;

		private var _dataProvider:Array = [];
		private var _backgroundColor:Number = NaN;
		private var _color:int;  
		private var _negativeColor:int = 0xff0006; 
		private var _negative:Boolean = true;

		private var graph:Shape = new Shape();
		
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
		
		public function set negativeColor(val:int):void
		{
			_negativeColor = val;
		}
		
		/**
		* Changes the default color for the negative reference line. 
		*/		
		public function get negativeColor():int
		{
			return _negativeColor;
		}

		/**
		* Changes the default color of the line. 
		*/		
		public function get color():int{
			return _color;
		}
		
		public function set color(value:int):void
		{
			_color = value;
			invalidateDisplayList();
		}
		
		/**
		* Changes the default background color of the chart. 
		*/		
		public function get backgroundColor():int{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:int):void
		{
			_backgroundColor = value;
			invalidateDisplayList();
		}
		
		/**
		* Set the dataProvider that will feed the chart. 
		*/		
		public function get dataProvider():Array 
		{
			return _dataProvider;
		}
		
		public function set dataProvider(val:Array):void 
		{
			_dataProvider = val;
			invalidateDisplayList();	
		}

		public function MicroLineChart()
		{
			super();
		}
		
		/**
		* @private 
		*/
		override protected function createChildren():void 
		{
			super.createChildren();
		}
		
		/**
		* @private 
		*/
		override protected function commitProperties():void 
		{
			super.commitProperties();

			if (width == 0 || isNaN(width))
				width = DEFAULT_WIDTH; 
			
			if (height == 0 || isNaN(height))
				height = DEFAULT_HEIGHT;

			measure();
		}
		
		/**
		* @private 
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var g:Graphics = graph.graphics;

			g.clear();
			if (dataProvider != null) 
			{
				var min:Number = dataProvider[0];
				var max:Number = dataProvider[0];
				for each(var value:int in dataProvider)
				{
					min = Math.min(min, value);
					max = Math.max(max, value);	
				}
				commitProperties();
				drawMicroLineChart(min, max, unscaledWidth, unscaledHeight);
			}
		}
				
		private function drawMicroLineChart(min:Number, max:Number, unscaledWidth:Number, unscaledHeight:Number):void
		{
			var g:Graphics = graph.graphics;

			var startY:int = unscaledHeight + ((min>0)?0:min)/(max-min) * unscaledHeight;
			
			startY = (startY>=0)? startY : 0; 
			
			var columnWidth:Number = unscaledWidth/dataProvider.length;
			var startX:int = columnWidth/2;
			
			if (!isNaN(_backgroundColor))
			{
				g.beginFill(_backgroundColor,1);
				g.drawRect(0,0, columnWidth*(dataProvider.length), unscaledHeight+1);
				g.endFill();
			}
			
			if (negative && min < 0 && max >= 0)
			{
				g.moveTo(startX, startY);
				g.lineStyle(1,_negativeColor);
				g.lineTo(startX + columnWidth*(dataProvider.length-1), startY);
			}
			
			for (var i:Number = 0; i < dataProvider.length - 1; i++)
			{
				var value:Number = dataProvider[i];
				var startValueHeight:int = 	(value)/(((max>=0)?max:0)-((min>0)?0:min)) * unscaledHeight;
				
				g.moveTo(startX, startY-startValueHeight);

				var endX:int = startX + columnWidth;
				
				var endValueHeight:int = (dataProvider[i+1])/(((max>=0)?max:0)-((min>0)?0:min)) * unscaledHeight;
				g.lineStyle(1,_color);
				g.lineTo(endX, startY-endValueHeight);
				
				startX = endX;
			}

			addChild(graph)
		}
	}
}