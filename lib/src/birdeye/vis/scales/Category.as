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
			invalidate();
		}
		
		public function get subScale():IFactory
		{
			return _subScale;
		}
		
		
		private var _shareSubScale:Boolean = false;
		/**
		 * Set this to true if one min and max is needed for the whole multiaxis.
		 * Defaults to <code>false</code>
		 */
		public function set shareSubScale(val:Boolean):void
		{
			_shareSubScale = val;
		}
		
		public function get shareSubScale():Boolean
		{
			return _shareSubScale;
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
		
		
		private var _subScalesNumberOfIntervals:Number = 5;
		/**
		 * Set the number of intervals the subcales need to have.</br>
		 * @default 5
		 */
		public function set subScalesNumberOfIntervals(val:Number):void
		{
			_subScalesNumberOfIntervals = val;
			if (_subScales)
			{
				for each (var sc:BaseScale in _subScales)
				{
					if (sc)
					{
						sc.numberOfIntervals = _subScalesNumberOfIntervals;
					}
				}
			}
		}
		
		public function get subScalesNumberOfIntervals():Number
		{
			return _subScalesNumberOfIntervals;	
		}
		
		
		private var _minMax:Array;
		private var _subScales:Array;
		public function feedMinMax(minMaxData:Array):void
		{
			mergeMinMaxData(minMaxData);
			invalidate();
		}
		
		private function mergeMinMaxData(minMaxData:Array):void
		{
			if (!_minMax)
			{
				_minMax = minMaxData;
			}
			else
			{
				for (var cat:Object in minMaxData)
				{
					if (!_minMax[cat])
					{
						_minMax[cat] = minMaxData[cat];
					}
					else
					{
						trace(_minMax[cat].max, "max is now ", Math.max(_minMax[cat].max, minMaxData[cat].max)); 
						_minMax[cat].max = Math.max(_minMax[cat].max, minMaxData[cat].max);
						_minMax[cat].min = Math.min(_minMax[cat].min, minMaxData[cat].min);
					}
				}
			}
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
		
				if (subScale && _minMax)
				{
					_subScales = new Array(_minMax.length);
					
					if (!shareSubScale)
					{
						for (var c:Object in _minMax)
						{
							var s:INumerableScale = _subScale.newInstance();
							s.min = _minMax[c].min;
							s.max = _minMax[c].max;
							s.size = _subScalesSize;
							s.dimension = dimension;
							if (s is BaseScale)
							{
								(s as BaseScale).numberOfIntervals = _subScalesNumberOfIntervals;
							}
							_subScales[c] = s;
							s.commit();
						}			
					}
					else
					{
						s = _subScale.newInstance();
						s.size = _subScalesSize;
						s.dimension = dimension;
						s.min = Number.MAX_VALUE;
						s.max = Number.MIN_VALUE;
						if (s is BaseScale)
						{
							(s as BaseScale).numberOfIntervals = _subScalesNumberOfIntervals;
						}
						for (c in _minMax)
						{
							if (s.min > _minMax[c].min)
							{
								s.min = _minMax[c].min;
							} 	
							
							if (s.max < _minMax[c].max)
							{
								s.max = _minMax[c].max;
							}
							
							_subScales[c] = s;
						}
						
						
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
					if (direction == BaseScale.POSITIVE || direction == null || direction == "")
					{
						pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					}
					else if (direction == BaseScale.NEGATIVE)
					{
						pos = size - ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					}
					break;
				case DIMENSION_2:
					if (direction == BaseScale.POSITIVE || direction == null || direction == "")
					{
						pos = size -((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					}
					else if (direction == BaseScale.NEGATIVE)
					{
						pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					}
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
			
			if (!dataValues)
				_dataProvider = [];
		}
	}
}