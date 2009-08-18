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
package birdeye.vis.elements
{
	import mx.core.IDataRenderer;
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class RenderableElement extends BaseElement implements IDataRenderer
	{
		private var _data:Object;
		/**
		 *  @private
		 *  The data to render or edit.
		 */
		public function set data(value:Object):void
		{
			_data = value;
			invalidateDisplayList();
		}
		public function get data():Object
		{
			return _data;
		}
		
		private var _dataField:String;
		/** Define the dataField used to catch the data to be passed to the itemRenderer.*/
		public function set dataField(val:String):void
		{
			_dataField = val;
			invalidateDisplayList();
		}
		public function get dataField():String
		{
			return _dataField;
		}
		
		private var _itemRenderer:Class;
		/** Set the item renderer following the standard Flex approach. The item renderer can be
		 * any DisplayObject that could be added as child to a UIComponent.*/ 
		public function set itemRenderer(val:Class):void
		{
			_itemRenderer = val;
			invalidatingDisplay();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		public function RenderableElement()
		{
			super();
		}
		
		// Be sure to remove all children in case an item renderer is used
		override public function clearAll():void
		{
			super.clearAll();
			if (_itemRenderer)
				for (var i:uint = 0; i<numChildren; )
					removeChild(getChildAt(0));
		}
	}
}