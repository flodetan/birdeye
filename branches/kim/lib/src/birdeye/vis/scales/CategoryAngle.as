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
	
	public class CategoryAngle extends Category
	{
		override public function get scaleInterval():Number
		{
			if (isNaN(_scaleInterval))
				_scaleInterval = (_scaleValues[1] - _scaleValues[0]) / dataProvider.length
			
			return _scaleInterval;
		}
		
		override public function set size(val:Number):void
		{
			_size = val;
		}

		public function CategoryAngle():void
		{
			scaleValues = [0,360];
			_scaleInterval = NaN;
		}

		override public function getPosition(dataValue:*):*
		{
			if (_scaleValues && dataProvider && dataProvider.indexOf(dataValue) != -1)
			{
				_scaleInterval = _size/ dataProvider.length;

				if (_function == null)
					return dataProvider.indexOf(dataValue) * _scaleInterval;
				else 
					return  _function(dataValue, _scaleValues[0], _scaleValues[1], _scaleInterval);
			}
		}
	}
}