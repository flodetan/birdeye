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
	import mx.formatters.NumberFormatter;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

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
	 * <p>&lt;BulletGraph orientation="vertical"
	 * 	qualitativeRanges="{[0, 20, 40, 60, 80]}"
	 * 	target="50" value="45" title="Vertical BG"
	 * 	snapInterval="5" width="30" height="200"/></p>
	 * 
	 * <p>The qualitativeRanges property can only accept Array at the moment, but will be soon extended with ArrayCollection
	 * and XML. 
	 * It's also possible to change colors by defining the following properties:</p>
	 * <p>- colors: array that sets the color for each range. </p>
	 * <p>- valueColor: to modify the value (bar or dot) color;</p>
	 * <p>- targetColor: to modify the target color;</p>
	 * 
	 * <p>As indicated in the BulletGraph specification, the Bullet graph shound not have more than 5 quality ranges, 
	 * and for this reason, the default colors array only contains a maximum of 5 colors. In case you need to create a bullet graph 
	 * with more ranges, than you should provide an array of colors for them and not use the default ones.
	 * The title property can be used to title the chart.</p>
	*/
	public class BulletGraph extends UIComponent
	{
		private var _titleLabel:Label;
		private var tickLabelHolder:Container;
		
		private static const HORIZONTAL_DEFAULT_WIDTH:Number = 200;
		private static const HORIZONTAL_DEFAULT_HEIGHT:Number = 20;
		private static const VERTICAL_DEFAULT_WIDTH:Number = 20;
		private static const VERTICAL_DEFAULT_HEIGHT:Number = 200;
		private static const HORIZONTAL:String = "horizontal";
		private static const VERTICAL:String = "vertical";
		private static const DEFAULT_ORIENTATION:String = HORIZONTAL;
		
		private var _target:Number = NaN;
		private var _value:Number = NaN;
		private var _title:String = "No title";
		private var _orientation:String = DEFAULT_ORIENTATION;
		private var _titleWidth:Number = NaN;
		private var _formatter:NumberFormatter = new NumberFormatter();
		private var _qualitativeRanges:Array = [];
		private var _rangeColor:Array = ["0xdddddd","0xcccccc","0xaaaaaa","0x999999","0x777777"]; 
		private var _valueColor:int = 0x000000; 
		private var _targetColor:int = 0x000000; 
		private var _snapInterval:Number = NaN;

		private var tickLabelColor:int = 0x9A9A98;
		private var tickLabelFontSize:int = 8;
		private var tickStyle:CSSStyleDeclaration;
		
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
		
		[Inspectable(enumeration="horizontal,vertical")]
		public function set orientation(val:String):void 
		{
			_orientation = val;
			invalidateDisplayList();	
		}

		/**
		* Set the orientation parameter of the BulletGraph. It can be either 'horizontal' or 'vertical'.
		*/
		public function get orientation():String 
		{
			return _orientation;
		}
				
		/**
		* Set the formatter parameter of the BulletGraph to establish the text format of the value shown in the graph meter
		*/
		public function get formatter():NumberFormatter 
		{
			return _formatter;
		}
		
		public function set formatter(val:NumberFormatter):void 
		{
			_formatter = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the qualityRanges parameter of the BulletGraph
		*/
		public function get qualitativeRanges():Array 
		{
			return _qualitativeRanges;
		}
		
		public function set qualitativeRanges(val:Array):void 
		{
			_qualitativeRanges = val;
			invalidateDisplayList();	
		}

		/**
		* Set the target parameter of the BulletGraph
		*/
		public function get target():Number 
		{
			return _target;
		}
		
		public function set target(val:Number):void 
		{
			_target = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the value parameter of the BulletGraph
		*/
		public function get value():Number 
		{
			return _value;
		}
		
		public function set value(val:Number):void 
		{
			_value = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		* Set the snapInterval of the meter of the BulletGraph
		*/
		public function get snapInterval():int 
		{
			return _snapInterval;
		}
		
		public function set snapInterval(val:int):void 
		{
			_snapInterval = val;
			invalidateDisplayList();
		}
		
		/**
		* Set the title String of the BulletGraph
		*/
		public function get title():String 
		{
			return _title;
		}
		
		public function set title(val:String):void 
		{
			_title = val;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		* Set the title width parameter of the BulletGraph
		*/
		public function get titleWidth():Number 
		{
			return _titleWidth;
		}
		
		public function set titleWidth(val:Number):void 
		{
			_titleWidth = val;
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function BulletGraph()
		{
			super();
	        tickStyle = new CSSStyleDeclaration('myDynStyle');
	
	        tickStyle.setStyle('color', tickLabelColor);
	        tickStyle.setStyle('fontSize', tickLabelFontSize);

	        StyleManager.setStyleDeclaration(".tickLabelStyle", tickStyle, true);
		}
		
		/**
		* @private
		*/
		override protected function createChildren():void 
		{
			super.createChildren();
			if (_titleLabel == null) {
				_titleLabel = new Label();
				_titleLabel.text = title;
				if (orientation == VERTICAL)
					_titleLabel.setStyle("textAlign", "left");
				else
					_titleLabel.setStyle("textAlign", "right");
				_titleLabel.height = HORIZONTAL_DEFAULT_HEIGHT;
				
				addChild(_titleLabel);
			}
			
			if (tickLabelHolder == null) {
				tickLabelHolder = new Container();
				tickLabelHolder.horizontalScrollPolicy = 
					tickLabelHolder.verticalScrollPolicy = ScrollPolicy.OFF;
				addChild(tickLabelHolder);
				
			}
		}
		
		/**
		* @private
		*/
		override protected function commitProperties():void 
		{
			super.commitProperties();
			_titleLabel.styleName = getStyle("labelStyleName");
			
			_titleLabel.text = title;
			_titleLabel.validateNow();
			
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
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var g:Graphics = graphics;

			if (isNaN(titleWidth)) {
				_titleLabel.width = _titleLabel.measureText(_titleLabel.text).width + 10;
			} else {
				_titleLabel.width = getTitleWidth();
			}
			g.clear();
			if (qualitativeRanges != null) 
			{
				//sort the ranges by max val so we can draw them from back to front
				qualitativeRanges.sort(Array.DESCENDING | Array.NUMERIC); 

				var min:Number = Math.min(value, target);
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
				
		private function validateQualitativeRanges():Boolean
		{
			var noDuplicattions:Boolean = false;
			var rightNumberOfRanges:Boolean = (qualitativeRanges.length <= 6) ? true : false;
			
			for (var i:Number = 0; i<qualitativeRanges.length; i++)
				for (var j:Number = 0; j<qualitativeRanges.length; j++)
					if (i != j && qualitativeRanges[i] == qualitativeRanges[j])
						return noDuplicattions;
			return rightNumberOfRanges;
		}
		
		private function drawVerticalBulletGraph(min:Number, max:Number, 
													unscaledWidth:Number, unscaledHeight:Number):void
		{
			var gV:Graphics = graphics;
			var startX:int = _titleLabel.width/2;
			var highestY:int = _titleLabel.height + 10;
			var totalGraphicHeight:int = unscaledHeight - highestY;
			var startY:int;
			
			if (min == max)
				startY = highestY;
			else
				startY = highestY + totalGraphicHeight;
			
			// draw the quality ranges
			for (var i:Number = 0; i<qualitativeRanges.length-1; i++)
			{
				var rangeHeight:int;
				var qr:int = qualitativeRanges[i];
				rangeHeight = (qr-min)/(max-min) * totalGraphicHeight;
				gV.beginFill(_rangeColor[i]);
				gV.drawRect(startX, startY, width, -rangeHeight);
				gV.endFill();
			}
			
			var thick:int = width/4;

 			//draw the value bullet
			if (!isNaN(value)) {
				var bulletHeight:Number = (((value>=min)?value:min)-min)/(max-min) * totalGraphicHeight;
				bulletHeight = Math.min(bulletHeight, totalGraphicHeight);
				
				if (minRange == 0 && value > 0)
				{
					gV.beginFill(_valueColor);
					gV.drawRect(startX + (width-thick)/2, startY, thick, -bulletHeight);
					gV.endFill();
				} else {
					gV.beginFill(_valueColor);
					gV.drawCircle(startX + width/2,startY-(isNaN(bulletHeight)?0:bulletHeight),thick/2);
					gV.endFill();
				} 
			}
			
			//draw the target if the target exists
			if (!isNaN(target)) {
				thick = 3;
				var long:int = width*2/3;

				var targetHeight:Number = (Math.max(target,min)-min)/(max-min) * totalGraphicHeight;
				targetHeight = Math.min(targetHeight, totalGraphicHeight);
				
				gV.beginFill(_targetColor);
				gV.drawRect(startX + (width-long)/2, startY-(isNaN(targetHeight)?0:targetHeight), long, thick);
				gV.endFill();
			}
			
			//draw meter and clear labels
			if (max != min)
			{
				tickLabelHolder.removeAllChildren();
				tickLabelHolder.x = startX;
				tickLabelHolder.y = 0;
				tickLabelHolder.width = unscaledWidth - height;
				tickLabelHolder.height = unscaledHeight + 10;
					
				if (isNaN(_snapInterval))
				{
					snapInterval = (max-min)/5;
				}
				for (var tickValue:Number = min; tickValue <= max; tickValue+=snapInterval) {
					var yCoord:Number = startY - ((tickValue-min)/(max-min) * totalGraphicHeight);
					long = 5;
					thick = 1;
					gV.beginFill(tickLabelColor);
					gV.drawRect(startX-long, yCoord, long, thick);
					gV.endFill();
	
					var lbl:UITextField = new UITextField();
					lbl.text = formatter.format(Math.round(tickValue));
					lbl.height = 15;
					lbl.autoSize = TextFieldAutoSize.LEFT;
					lbl.selectable = false;
					
					tickLabelHolder.addChild(lbl);
					lbl.styleName = tickStyle;
					lbl.y = yCoord-lbl.height/3;
					lbl.x = -lbl.width;
				}
				
				_titleLabel.x = startX + (width- _titleLabel.width)/2;
			}
		}

		private function drawHorizontalBulletGraph(min:Number, max:Number, 
													unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (isNaN(titleWidth)) {
				_titleLabel.width = _titleLabel.measureText(_titleLabel.text).width + 10 ;
			} else {
				_titleLabel.width = getTitleWidth();
			}
			
			var gH:Graphics = graphics;
			var startX:int = getTitleWidth();
			var totalGraphicWidth:int;
			
			if (min == max)
				totalGraphicWidth = 0;
			else
				totalGraphicWidth = unscaledWidth - startX - 20;
			
			// draw the quality ranges
			for (var i:Number = 0; i<qualitativeRanges.length-1; i++)
			{
				var rangeWidth:int;
				var qr:int = qualitativeRanges[i];

				rangeWidth = (qr-min)/(max-min) * totalGraphicWidth;
				gH.beginFill(_rangeColor[i]);
				gH.drawRect(startX, 0, rangeWidth, height);
				gH.endFill();		
			}
			
			//draw the value bullet
			if (!isNaN(value)) {
				var bulletWidth:Number = (((value>=min)?value:min)-min)/(max-min) * totalGraphicWidth;
				bulletWidth = Math.min(bulletWidth, totalGraphicWidth);

				var thick:Number = height/4;
				
				if (minRange == 0 && value > 0)
				{
					gH.beginFill(_valueColor);
					gH.drawRect(startX, (height - thick)/2, (isNaN(bulletWidth)?0:bulletWidth), thick);
					gH.endFill();
				} else {
					gH.beginFill(_valueColor);
					gH.drawCircle(startX + (isNaN(bulletWidth)?0:bulletWidth),height/2,thick/2);
					gH.endFill();
				} 
			}
			
			//draw the target if the target exists
			if (!isNaN(target)) {
				var targetWidth:Number = (((target>=min)?target:min)-min)/(max-min) * totalGraphicWidth;
				targetWidth = Math.min(targetWidth, totalGraphicWidth);
				
				var long:int = height*2/3;
				gH.beginFill(_targetColor);
				gH.drawRect(startX + Math.min(totalGraphicWidth, (isNaN(targetWidth)?0:targetWidth)) - 2, 
							(height - long)/2, 3, long);
				gH.endFill();
			}
			 
			if (max != min)
			{
				//draw meter and clear labels
				tickLabelHolder.removeAllChildren();
				tickLabelHolder.x = 0; 
				tickLabelHolder.y = height;
				tickLabelHolder.width = unscaledWidth;
				tickLabelHolder.height = unscaledHeight;
	
				if (isNaN(_snapInterval))
				{
					snapInterval = (max-min)/5;
				}
	
				for (var tickValue:Number = min; tickValue <= max; tickValue+=snapInterval) {
					var xCoord:Number = startX + (tickValue-min)/(max-min) * totalGraphicWidth;
					long = 5;
					thick = 1;
					gH.beginFill(tickLabelColor);
					gH.drawRect(xCoord, height, thick, long);
					gH.endFill(); 
					
					var lbl:UITextField = new UITextField();
					lbl.text = formatter.format(Math.round(tickValue));
					lbl.height = 15;
					lbl.autoSize = TextFieldAutoSize.LEFT;
					lbl.selectable = false;
					
					tickLabelHolder.addChild(lbl);
					lbl.styleName = tickStyle;
					lbl.x = xCoord - lbl.textWidth /2;
					lbl.y = 2;
				}
				_titleLabel.y = (height - _titleLabel.height)/2;
			}
		}
		
		/**
		* @private
		*/
		override protected function measure():void {
			 
			this.measuredWidth =  getTitleWidth() + HORIZONTAL_DEFAULT_WIDTH;
			this.measuredHeight = 40;
		}
		
		private function getTitleWidth() : Number {
			var tlWidth:Number = _titleLabel.textWidth;
			if (!isNaN(titleWidth)) {
				tlWidth = titleWidth;
			}
			return tlWidth + 10;	
		}
	}
}