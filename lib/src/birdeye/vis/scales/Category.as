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
 
 package birdeye.vis.scales
{
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	
	import mx.core.IFactory;
	
	[Exclude(name="scaleType", kind="property")]
	[Exclude(name="dataProvider", kind="property")]
	public class Category extends BaseScale implements ISubScale
	{
 		/** Define the category strings for category scales.*/
		override public function set dataValues(val:Array):void
		{
			_dataValues = val;
			_dataValues.sort(Array.CASEINSENSITIVE);
			dataProvider = dataValues;
		}

		/** @Private
		 * The scale type cannot be changed, since it's already "category".*/
		override public function set scaleType(val:String):void
		{}
		
		/** Elements for labeling */
		private var _dataProvider:Array = [];
		public function set dataProvider(val:Array):void
		{
			_dataProvider = val;
			invalidate();
		}
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
		
		/**
		 * Returns all the data values</br>
		 * For a numeric scale this is min and max and everything in between.</br>
		 * For a category scale this is identical to dataValues.</br>
		 */
		public function get completeDataValues():Array
		{
			return this.dataProvider;
		}
		
		private var _categoryField:String;
		/** Category field that will filter the category values from the 
		 * dataprovider.*/
		public function set categoryField(val:String):void
		{
			_categoryField = val;
			
			invalidate();
		}
		public function get categoryField():String
		{
			return _categoryField;
		}
		
		private var _initialOffset:Number = .5;
		public function set initialOffset(val:Number):void
		{
			_initialOffset = val;
			invalidate();
		} 
		
		private var _subScale:IFactory;
		public function set subScale(val:IFactory):void
		{
			_subScale = val;
		}
		
		public function get subScale():IFactory
		{
			return _subScale;
		}
		
		public function get subScalesActive():Boolean
		{
			return _subScale != null;
		}
		
		private var _subScalesSize:Number;
		public function set subScalesSize(val:Number):void
		{
			_subScalesSize = val;
			if (_subScales)
			{
				for each (var sc:IScale in _subScales)
				{
					sc.size = val;
				}
			}
			
		}
		
		public function get subScalesSize():Number
		{
			return _subScalesSize;
		}
		
		
		private var _minMax:Array;
		private var _subScales:Array;
		public function feedMinMax(minMaxData:Array):void
		{
			_minMax = minMaxData;
			invalidate();
		}
		
		public function get subScales():Array
		{
			return _subScales;
		}
		
		override public function commit():void
		{
			if (isInvalidated)
			{
				super.commit();
		
				if (subScale)
				{
					_subScales = new Array(_minMax.length);
					
					for (var c:Object in _minMax)
					{
						var s:INumerableScale = _subScale.newInstance();
						s.min = _minMax[c].min;
						s.max = _minMax[c].max;
						s.size = _subScalesSize;
						s.dimension = dimension;
						_subScales[c] = s;
						s.commit();
					}			
				}
			}
			
		}
		
		// UIComponent flow
		
		public function Category()
		{
			super();
			_scaleType = BaseScale.CATEGORY;
			_dataInterval = 1;
		}
			
		
		/** @Private
		 * Override the XYZAxis getPostion method based on the linear scaling.*/
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			
			switch (dimension)
			{
				case DIMENSION_1:
					pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					break;
				case DIMENSION_2:
					pos = size - ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					break;
				//case DIAGONAL:
				//	pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
				//		break;
			}
				
			return pos;
		}
		
		override public function resetValues():void
		{
			super.resetValues();
				
			_dataProvider = [];
		}
	}
}