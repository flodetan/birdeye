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
 
package birdeye.vis.elements.collision
{
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.interfaces.IStack;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.scales.*;
	
	[Exclude(name="stackType", kind="property")] 
	[Exclude(name="total", kind="property")] 
	[Exclude(name="stackPosition", kind="property")] 
	[Exclude(name="elementType", kind="property")] 

	public class StackElement extends BaseElement implements IStack
	{
		public static const OVERLAID:String = "overlaid";
		public static const STACKED:String = "stacked";
		public static const STACKED100:String = "stacked100";
		
		protected var _stackType:String = OVERLAID;
		public function set stackType(val:String):void
		{
			_stackType = val;
			invalidateProperties();
		}
		public function get stackType():String
		{
			return _stackType;
		}
		
		protected var _baseAt:Number = 0;
		/** If not set to NaN and min and max values of an element are positive (negative), 
		 * than the base of the StackElement will be the one set, instead of the min (max) value.*/
		public function set baseAt(val:Number):void
		{
			_baseAt = val;
			invalidateProperties();
		}
		public function get baseAt():Number
		{
			return _baseAt;
		}
		
		public var _baseValues:Array;
		public function set baseValues(val:Array):void
		{
			_baseValues = val;
			invalidateProperties();
		}
		public function get baseValues():Array
		{
			return _baseValues;
		}

		public var _topValues:Array;
		public function set topValues(val:Array):void
		{
			_topValues = val;
			invalidateProperties();
		}
		public function get topValues():Array
		{
			return _topValues;
		}

		protected var _total:Number = NaN;
		public function set total(val:Number):void
		{
			_total = val;
			invalidateProperties();
		}

		protected var _stackPosition:Number = NaN;
		public function set stackPosition(val:Number):void
		{
			_stackPosition = val;
			invalidateProperties();
		}
		
		public function get elementType():String
		{
			// to be overridden
			
			return null;
		}
		
		public function StackElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function getMaxValue(field:Object):Number
		{
			var max:Number = super.getMaxValue(field);
				
			if (chart && stackType == STACKED100) 
			{
				if (collisionType == STACKED100)
					max += Math.max(max, chart.maxStacked100);
				else
					max = Math.max(max, chart.maxStacked100);
			}
					
			return max;
		}

		/** @Private 
		 * Get the x minimum position of the AreaElement (only used in case the AreaElement is drawn 
		 * vertically, i.e. the x axis is linear).*/ 
		protected function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (scale1 && scale1 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					xPos = scale1.getPosition(_baseAt);
				else
					xPos = scale1.getPosition(minDim1Value);
			}
			
			return xPos;
		}

		/** @Private 
		 * Returns the y minimum position of the AreaElement.*/ 
		protected function getYMinPosition():Number
		{
			var yPos:Number;
			if (scale2 && scale2 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					yPos = scale2.getPosition(_baseAt);
				else
					yPos = scale2.getPosition(minDim2Value);
			}
			return yPos;
		}
	}
}