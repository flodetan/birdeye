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
 
package org.un.cava.birdeye.qavis.charts
{
	import mx.core.Application;
	import mx.core.UIComponent;
	
	[DefaultProperty("dataProvider")]
	public class ChartLegend extends UIComponent
	{
		private var _legendTitle:String;
		public function set legendTitle(val:String):void
		{
			_legendTitle = val;
		}
		
		private var _legendOrientation:String = "vertical";
		public function set legendOrientation(val:String):void
		{
			_legendOrientation = val;
		}
		
		private var _legendField:String;
		public function set legendField(val:String):void
		{
			_legendField= val;
		}
		
		private var _dataProvider:CartesianChart;
		public function set dataProvider(val:CartesianChart):void
		{
			_dataProvider = val;
		}
		
		public function ChartLegend()
		{
			super();
			Application.application.addEventListener("ProviderReady",createLegend,true);
		}
		
		private function createLegend(e:Event):void
		{
			if (e.target == _dataProvider)
			{
				for (var i:Number = 0; i<numChildren-1; i++)
					removeChildAt(i);
				
				// create/add legend items					
			}
		}
	}
}