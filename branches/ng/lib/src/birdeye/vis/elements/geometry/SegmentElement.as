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

package birdeye.vis.elements.geometry
{
	import birdeye.vis.elements.BaseElement;

	public class SegmentElement extends BaseElement
	{
		protected var _dimStart:String;
		public function set dimStart(val:String):void {
			_dimStart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dimStart():String {
			return _dimStart;
		}

		protected var _dimEnd:String;
		public function set dimEnd(val:String):void	{
			_dimEnd = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dimEnd():String {
			return _dimEnd;
		}
		
		protected var _sizeStart:Number;
		public function set sizeStart(val:Number):void {
			_sizeStart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get sizeStart():Number {
			return _sizeStart;
		}

		protected var _sizeEnd:Number;
		public function set sizeEnd(val:Number):void	{
			_sizeEnd = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get sizeEnd():Number {
			return _sizeEnd;
		}
		
		public function SegmentElement()
		{
			super();
		}
		
	}
}