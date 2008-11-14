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

	 /**
	* <p>This component is used to create column microcharts. 
	 * The basic simple syntax to use it and create an column microchart with mxml is:</p>
	 * <p>&lt;MicroWinLoseChart dataProvider="{myArray}" width="20" height="70"/></p>
	 * 
	 * <p>The dataProvider property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML.
	 * It's also possible to change the colors by defining the following properties in the mxml declaration:</p>
	 * <p>- color: to change the default shape color;</p>
	 * <p>- backgroundColor: to change the default background color of the chart;</p>
	 * <p>- negativeColor: to set or change the reference line which delimites negative values;</p>
	 * 
	 * <p>The following public properties can also be used to: </p>
	 * <p>- spacing: to modify the spacing between columns;</p>
	*/
	public class MicroWinLoseChart extends UIComponent
	{
		private static const DEFAULT_WIDTH:Number = 200;
		private static const DEFAULT_COLOR:int = 0x000000;
		private static const DEFAULT_HEIGHT:Number = 50;
		
		private var _dataProvider:Array = [];
		private var _backgroundColor:Number = NaN;
		private var _color:int;
		private var _negativeColor:int = 0xff0006; 
		private var _spacing:int = 0;
		private var _reference:int = 0;

		private var graph:Shape = new Shape();
		
		public function set reference(val:int):void
		{
			_reference = val;
		}
		
		/**
		* Change the default (0) reference value that define winning or loosing values. 
		*/
		public function get reference():int
		{
			return _reference;
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
		* Changes the default spacing between columns. 
		*/		
		public function get spacing():int
		{
			return _spacing;
		}
		
		public function set spacing(value:int):void
		{
			_spacing = value;
			invalidateDisplayList();
			invalidateSize();
		}

		/**
		* Changes the default color of columns. 
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
		public function get dataProvider() : Array {
			return _dataProvider;
		}
		
		public function set dataProvider(val:Array) : void {
			_dataProvider = val;
			invalidateDisplayList();	
		}

		public function MicroWinLoseChart()
		{
			super();
		}
		
		/**
		* @private 
		*/
		override protected function createChildren():void {
			super.createChildren();
		}
		
		/**
		* @private 
		*/
		override protected function commitProperties():void {
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
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var g:Graphics = graph.graphics;

			g.clear();
			if (dataProvider != null) 
			{
				commitProperties();
				drawMicroWinLoseChart(unscaledWidth, unscaledHeight);
			}
		}
				
		private function drawMicroWinLoseChart(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var g:Graphics = graph.graphics;
			var startX:int = 0;
			var startY:int = unscaledHeight/2;
			var columnWidth:Number = unscaledWidth/(2*dataProvider.length);

			if (!isNaN(_backgroundColor))
			{
				g.beginFill(_backgroundColor, 1);
				g.drawRect(0,0, (columnWidth+spacing)*dataProvider.length-spacing, unscaledHeight);
				g.endFill();
			}
						
			var valueHeight:int;
			valueHeight = unscaledHeight/3;

			for each (var value:Number in dataProvider)
			{
				var c:int;
				if (value < _reference)
				{
					g.beginFill(_negativeColor);
					g.drawRect(startX, (startY>=0)?startY:0, columnWidth,valueHeight);
					g.endFill();
					startX = startX + columnWidth + spacing;					
				} else {
					g.beginFill(_color);
					g.drawRect(startX, (startY>=0)?startY:0, columnWidth,-valueHeight);
					g.endFill();
					startX = startX + columnWidth + spacing;					
				}
			}
			addChild(graph)
		}
	}
}