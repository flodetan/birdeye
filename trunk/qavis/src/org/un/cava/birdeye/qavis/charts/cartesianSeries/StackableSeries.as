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
 
package org.un.cava.birdeye.qavis.charts.cartesianSeries
{
	import flash.events.Event;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYZAxisUI;
	import org.un.cava.birdeye.qavis.charts.interfaces.IStack;
	
	[Exclude(name="stackType", kind="property")] 
	[Exclude(name="total", kind="property")] 
	[Exclude(name="stackPosition", kind="property")] 
	[Exclude(name="seriesType", kind="property")] 

	public class StackableSeries extends CartesianSeries implements IStack
	{
		private const OWN_VERTICAL_INTERVAL_CHANGES:String = "is_own_vertical_listening_interval_changes"; 
		private const CHART_VERTICAL_INTERVAL_CHANGES:String = "is_chart_vertical_listening_interval_changes"; 
		private const OWN_HORIZONTAL_INTERVAL_CHANGES:String = "is_own_horizontal_listening_interval_changes"; 
		private const CHART_HORIZONTAL_INTERVAL_CHANGES:String = "is_chart_horizontal_listening_interval_changes"; 
		
		private var isListening:Array = [];
		
		protected var deltaSize:Number;
		
		public static const OVERLAID:String = "overlaid";
		public static const STACKED:String = "stacked";
		public static const STACKED100:String = "stacked100";
		
		protected var _stackType:String = OVERLAID;
		public function set stackType(val:String):void
		{
			_stackType = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get stackType():String
		{
			return _stackType;
		}
		
		public var _baseValues:Array;
		public function set baseValues(val:Array):void
		{
			_baseValues = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get baseValues():Array
		{
			return _baseValues;
		}

		protected var _total:Number = NaN;
		public function set total(val:Number):void
		{
			_total = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		protected var _stackPosition:Number = NaN;
		public function set stackPosition(val:Number):void
		{
			_stackPosition = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get seriesType():String
		{
			// to be overridden
			
			return null;
		}
		
		public function StackableSeries()
		{
			super();
			
			isListening [OWN_VERTICAL_INTERVAL_CHANGES] = false;
			isListening [OWN_HORIZONTAL_INTERVAL_CHANGES] = false;
			isListening [CHART_VERTICAL_INTERVAL_CHANGES] = false;
			isListening [CHART_HORIZONTAL_INTERVAL_CHANGES] = false;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (yAxis)
			{
				if (! isListening[OWN_VERTICAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(yAxis).addEventListener("IntervalChanged", update);
					isListening[OWN_VERTICAL_INTERVAL_CHANGES] = true;
				}
				if (isListening[CHART_VERTICAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(chart.yAxis).removeEventListener("IntervalChanged", update);
				}
			} else if (chart && chart.yAxis) {
				if (! isListening[CHART_VERTICAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(chart.yAxis).addEventListener("IntervalChanged", update);
					isListening[CHART_VERTICAL_INTERVAL_CHANGES] = true;
				}
			}

			if (xAxis)
			{
				if (! isListening[OWN_HORIZONTAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(xAxis).addEventListener("IntervalChanged", update);
					isListening[OWN_HORIZONTAL_INTERVAL_CHANGES] = true;
				}
				if (isListening[CHART_HORIZONTAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(chart.xAxis).removeEventListener("IntervalChanged", update);
				}
			} else if (chart && chart.xAxis) {
				if (! isListening[CHART_HORIZONTAL_INTERVAL_CHANGES])
				{
					XYZAxisUI(chart.xAxis).addEventListener("IntervalChanged", update);
					isListening[CHART_HORIZONTAL_INTERVAL_CHANGES] = true;
				}
			}
			
			if (chart.is3D)
				deltaSize = 1/5;
			else 
				deltaSize = 3/5;
		}
		
		private function update(e:Event):void
		{
			invalidateDisplayList();
		}
	}
}