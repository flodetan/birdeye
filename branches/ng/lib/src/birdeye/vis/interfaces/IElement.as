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
 
package birdeye.vis.interfaces
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	
	import flash.events.MouseEvent;
	
	import mx.collections.IViewCursor;
	
	public interface IElement extends IRasterRenderer
	{
		/** Set the colorField to filter horizontal data values.*/
		function set colorField(val:String):void;
		function get colorField():String;

		/** Set the color axis.*/
		function set colorAxis(val:INumerableScale):void;
		function get colorAxis():INumerableScale;
		function get maxColorValue():Number;
		function get minColorValue():Number;

		/** Remove all elements from the Element (Surface component).*/
		function removeAllElements():void;
		
		/** Set the data provider of a cartesian Element, which must be a CartesianChart.*/
		function set dataProvider(val:Object):void;
		function get dataProvider():Object;

		/** Set the fill color.*/
		function getFill():IGraphicsFill;

		/** Set the stroke color.*/
		function getStroke():IGraphicsStroke;

		/** Set the itemRenderer used for the layout of data values.*/
		function set itemRenderer(val:Class):void;
		function get itemRenderer():Class;

		/** Set the cursor used by the Element. It can either derive from the Element own 
		 * dataProvider or from the chart dataProvider.*/
		function set cursor(val:IViewCursor):void;
		function get cursor():IViewCursor;

		/** Set the name to display (legends..).*/
		function set displayName(val:String):void;
		function get displayName():String;
		
		/** Set the function that should be used when a mouse double click event is triggered.*/
		function set mouseDoubleClickFunction(val:Function):void;
		function get mouseDoubleClickFunction():Function;

		/** Set the function that should be used when a mouse click event is triggered.*/
		function set mouseClickFunction(val:Function):void;
		function get mouseClickFunction():Function;
		
		/** Implement function to manage mouse click events.*/
		function onMouseClick(e:MouseEvent):void;

		/** Implement function to manage mouse double click events.*/
		function onMouseDoubleClick(e:MouseEvent):void;
	}
}