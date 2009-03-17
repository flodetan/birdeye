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
 
 package org.un.cava.birdeye.qavis.charts.data
{
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.qavis.charts.axis.XYAxis;
	import org.un.cava.birdeye.qavis.charts.series.CartesianSeries;

	public class DataItem extends UIComponent
	{
		private var _baseValue:Object;

		private var _dataValue:Object;
		public function set dataValue(val:Object):void
		{
			_dataValue = val;
			invalidateProperties();
		}
		public function get dataValue():Object
		{
			return _dataValue;
		}
		
		private var _scaleType:String;
		
		private var _series:CartesianSeries; // associated with
		private var _xAxis:XYAxis; // associated with
		private var _yAxis:XYAxis; // associated with
		
		private var _xPos:Number; // resulted from dataToXY transformation
		private var _yPos:Number; // resulted from dataToXY transformation
		
		private var _radius:Number; // resulted from dataToXY transformation in polar coordinates 
		private var _angle:Number; // resulted from dataToXY transformation in polar coordinates
		
		private var polarOriginX:Number; // polar coordinates 0,0 point
		private var polarOriginY:Number; 
		
		public function DataItem()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (_scaleType == XYAxis.CATEGORY)
				_dataValue is String;
			else 
				_dataValue is Number;
		}
		
	}
}