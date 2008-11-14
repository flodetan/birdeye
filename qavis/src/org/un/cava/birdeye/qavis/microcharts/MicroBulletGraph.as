/*
 * Derived from the work of Mcgraphix, Inc. (www.mcgraphix.com) 
 * for the BirdEye Library by the
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 *  http://cava.unog.ch
 *
 * The MIT License
 *
 * Copyright (c) 2008
 * Mcgraphix, Inc. (www.mcgraphix.com)
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
	import flash.text.TextFieldAutoSize;
	
	import mx.controls.Label;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.core.UITextField;

	[Inspectable("orientation")]
	/**
	* This component is used to create BulletGraph charts.
	 * It follows very closely the real Bullet Graph specification, for example:
	 * <p>- both horizontal and vertical orientations are available; </p>
	 * <p>- if the minimum qualitative range is not 0, than the value property is represented by a dot and not a bar;</p> 
	 * <p>- it also accepts negative qualitative ranges, negative values and negative targets. </p>
	 * <p>- default colors are close to the ones defined in the specifications, but optionally they can all be changed.</p>
	 * <p></p>
	 * <p>It automatically adjusts itself accordingly.
	 * Resizing keeps the right proportions of all of its parts.
	 * The basic syntax to use and create a BulletGraph chart with mxml is:</p>
	 * <p>&lt;MicroBulletGraph orientation="vertical"
	 * 	qualitativeRanges="{[0, 20, 40, 60, 80]}"
	 * 	target="50" value="45" 
	 * 	width="30" height="200"/></p>
	 * 
	 * <p>The qualitativeRanges property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML. 
	 * It's also possible to change colors by defining the following properties:</p>
	 * <p>- colors: array that sets the color for each range. </p>
	 * <p>- valueColor: to modify the value (bar or dot) color;</p>
	 * <p>- targetColor: to modify the target color;</p>
	 * 
	 * <p>As indicated in the BulletGraph specification, there shound not have more than 5 quality ranges, 
	 * and for this reason, the default colors array only contains a maximum of 5 colors. In case you need to create a bullet graph 
	 * with more ranges, than you should provide an array of colors for them and not use the default ones.</p>
	*/
	public class MicroBulletGraph extends UIComponent
	{	
		private static const HORIZONTAL_DEFAULT_WIDTH:Number = 30;
		private static const HORIZONTAL_DEFAULT_HEIGHT:Number = 10;
		private static const VERTICAL_DEFAULT_WIDTH:Number = 10;
		private static const VERTICAL_DEFAULT_HEIGHT:Number = 30;
		private static const HORIZONTAL:String = "horizontal";
		private static const VERTICAL:String = "vertical";
		private static const DEFAULT_ORIENTATION:String = HORIZONTAL;
		
		private var _target:Number = NaN;
		private var _value:Number = NaN;
		private var _orientation:String = DEFAULT_ORIENTATION;
		private var _qualitativeRanges:Array = [];
		private var _rangeColor:Array = ["0xdddddd","0xcccccc","0xaaaaaa","0x999999","0x777777"]; 
		private var _valueColor:int = 0x000000; 
		private var _targetColor:int = 0x000000; 

		private var minRange:Number;
				
		/**
		* Set the valueColor parameter of the BulletGraph, used to change the default color of the value. 
		*/
		public function get valueColor():int
		{
			return _valueColor;
		}
		
		public function set valueColor(val:int):void
		{
			_valueColor = val;
			invalidateDisplayList();
		}

		/**
		* Set the targetColor parameter of the BulletGraph, used to change the default color of the target. 
		*/
		public function get targetColor():int
		{
			return _targetColor;
		}
		
		public function set targetColor(val:int):void
		{
			_targetColor = val;
			invalidateDisplayList();
		}
		
		/**
		* Set the rangeColor parameter of the BulletGraph, used to change the default colors of the qualitativeRanges. 
		*/
		public function get rangeColor():Array
		{
			return _rangeColor;
		}
		
		public function set rangeColor(val:Array):void
		{
			_rangeColor = val;
			invalidateDisplayList();
			invalidateProperties();
		}
		
		/**
		* Set the orientation parameter of the BulletGraph. It can be either 'horizontal' or 'vertical'.
		*/
		public function get orientation() : String {
			return _orientation;
		}
		
		[Inspectable(enumeration="horizontal,vertical")]
		public function set orientation(val:String) : void {
			_orientation = val;
			invalidateDisplayList();	
		}
				
		/**
		* Set the qualityRanges parameter of the BulletGraph
		*/
		public function get qualitativeRanges() : Array {
			return _qualitativeRanges;
		}
		
		public function set qualitativeRanges(val:Array) : void {
			_qualitativeRanges = val;
			invalidateDisplayList();	
		}

		/**
		* Set the target parameter of the BulletGraph
		*/
		public function get target() : Number {
			return _target;
		}
		
		public function set target(val:Number) : void {
			_target = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the value parameter of the BulletGraph
		*/
		public function get value() : Number {
			return _value;
		}
		
		public function set value(val:Number) : void {
			_value = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function MicroBulletGraph ()
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

			if (orientation != VERTICAL && orientation != HORIZONTAL)
				throw new Error("Orientation " + orientation + " not valid");
				
			if (width == 0 || isNaN(width))
				switch (orientation)
				{
					case HORIZONTAL:
						width = HORIZONTAL_DEFAULT_WIDTH; break;
					case VERTICAL:
						width = VERTICAL_DEFAULT_WIDTH; break;
				} ;

			if (height == 0 || isNaN(height))
				switch (orientation)
				{
					case HORIZONTAL:
						height = HORIZONTAL_DEFAULT_HEIGHT; break;
					case VERTICAL:
						height = VERTICAL_DEFAULT_HEIGHT; break;
				} 
				measure();
		}
		
		/**
		* @private
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var g:Graphics = graphics;

			g.clear();
			if (qualitativeRanges != null) 
			{
				//sort the ranges by max val so we can draw them from back to front
				qualitativeRanges.sort(Array.DESCENDING | Array.NUMERIC); 

				var min:Number = Math.min(value,target);
				var max:Number = Math.max(value,target);
				minRange = qualitativeRanges[0];
				for each(var range:int in qualitativeRanges)
				{
					minRange = Math.min(minRange, range);
					min = Math.min(min, range);
					max = Math.max(max, range);	
				}
				
				commitProperties();
				
				switch (orientation)
				{
					case HORIZONTAL:
						drawHorizontalBulletGraph(min, max, unscaledWidth, unscaledHeight);
						break;
					case VERTICAL:
						drawVerticalBulletGraph(min, max, unscaledWidth, unscaledHeight);
				}					
			}
		}
		
		private function drawVerticalBulletGraph(min:Number, max:Number, 
													unscaledWidth:Number, unscaledHeight:Number):void
		{
			var gV:Graphics = graphics;
			var startX:int = 0;
			var startY:int = unscaledHeight;
			
			//draw the value quality ranges
			for (var i:Number = 0; i<qualitativeRanges.length-1; i++)
			{
				var rangeHeight:int;
				var qr:int = qualitativeRanges[i];
				rangeHeight = (qr-min)/(max-min) * unscaledHeight;
				gV.beginFill(_rangeColor[i]);
				gV.drawRect(startX, startY, width, -rangeHeight);
				gV.endFill();
			}
			
			var thick:int = width/4;

 			//draw the value bullet
			if (!isNaN(value)) 
			{
				var bulletHeight:Number = (((value>=min)?value:min)-min)/(max-min) * unscaledHeight;
				bulletHeight = Math.min(bulletHeight, unscaledHeight);
				
				if (minRange == 0 && value > 0)
				{
					gV.beginFill(_valueColor);
					gV.drawRect(startX + (width-thick)/2, startY, thick, (isNaN(bulletHeight))?startY:-bulletHeight);
					gV.endFill();
				} else {
					gV.beginFill(_valueColor);
					gV.drawCircle(startX + width/2,startY-bulletHeight,thick/2);
					gV.endFill();
				} 
			}
			
			//draw the target if the target exists
			if (!isNaN(target)) 
			{
				thick = 3;
				var long:int = width*2/3;
				gV.beginFill(_targetColor);
				gV.drawRect(startX + (width-long)/2, 
							Math.max(0, startY-((((target>=min)?target:min)-min)/(max-min) * unscaledHeight)), 
							long, thick);
				gV.endFill();
			}
		}

		private function drawHorizontalBulletGraph(min:Number, max:Number, 
													unscaledWidth:Number, unscaledHeight:Number):void
		{			
			var gH:Graphics = graphics;
			var startX:int = 0;
			
			//draw the value quality ranges
			for (var i:Number = 0; i<qualitativeRanges.length-1; i++)
			{
				var rangeWidth:int;
				var qr:int = qualitativeRanges[i];

				rangeWidth = (qr-min)/(max-min) * unscaledWidth;
				gH.beginFill(_rangeColor[i]);
				gH.drawRect(startX, 0, rangeWidth, height);
				gH.endFill();		
			}

			//draw the value bullet
			if (!isNaN(value)) 
			{
				var bulletWidth:Number = (((value>=min)?value:min)-min)/(max-min) * unscaledWidth;
				bulletWidth = Math.min(bulletWidth, unscaledWidth);

				var thick:Number = height/4;
				if (minRange == 0 && value > 0)
				{
					gH.beginFill(_valueColor);
					gH.drawRect(startX, (height - thick)/2, (isNaN(bulletWidth))?startX:bulletWidth, thick);
					gH.endFill();
				} else {
					gH.beginFill(_valueColor);
					gH.drawCircle(startX + bulletWidth,height/2,thick/2);
					gH.endFill();
				} 
			}
			
			//draw the target if the target exists
			if (!isNaN(target)) 
			{
				var long:int = height*2/3;
				gH.beginFill(_targetColor);
				gH.drawRect(Math.min(unscaledWidth, 
							startX + ((((target>=min)?target:min)-min)/(max-min) * unscaledWidth)) - 2, 
							(height - long)/2, 3, long);
				gH.endFill();
			}
			 
		}
	}
}