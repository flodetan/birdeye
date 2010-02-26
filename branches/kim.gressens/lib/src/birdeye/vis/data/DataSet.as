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
 
package birdeye.vis.data
{
	import __AS3__.vec.Vector;

	public class DataSet
	{
		private var _id:String;
		/** Set the id to be assigned to the source.*/
		public function set id(val:String):void
		{
			_id = val;
		}
		public function get id():String
		{
			return _id;
		}
		
		private var _fields:Array;
        [Inspectable(category="General", arrayType="String")]
        [ArrayElementType("String")]
		public function set fields(val:Array):void
		{
			_fields = val;
		}
		public function get fields():Array
		{
			return _fields;
		}
		
		private var _fieldsIndexes:Array;
        [Inspectable(category="General", arrayType="Number")]
        [ArrayElementType("Number")]
		public function set fieldsIndexes(val:Array):void
		{
			_fieldsIndexes = val;
		}
		public function get fieldsIndexes():Array
		{
			return _fieldsIndexes;
		}
		
		private var _dataProvider:Vector.<Object>;
		public function set dataProvider(val:Vector.<Object>):void
		{
			_dataProvider = val;
		}
		[Bindable]
		public function get dataProvider():Vector.<Object>
		{
			return _dataProvider;
		}
		
		public function DataSet()
		{
			super();
		}
	}
}