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
 
package birdeye.vis.interfaces.elements
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.renderers.IRasterRenderer;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.IFactory;

	public interface IElement extends IRasterRenderer, IEventDispatcher
	{
		/** Set the visualization target. This allows to share axes, layouts and other properties
		 * of the visualization among several elements, even among different visualization .*/
		function set visScene(val:ICoordinates):void;
		function get visScene():ICoordinates;

		/** Set the colorField to filter horizontal data values.*/
		function set colorField(val:String):void;
		function get colorField():String;

		/** Set the color axis.*/
		function set colorScale(val:IScale):void;
		function get colorScale():IScale;
		//function get maxColorValue():Number;
		//function get minColorValue():Number;

		/** Set the sizeField to filter horizontal data values.*/
		function set sizeField(val:Object):void;
		function get sizeField():Object;

		/** Set/get the collision type if the element includes several dimN.*/
		function set collisionType(val:String):void;
		function get collisionType():String;

		/** Set the size axis.*/
		function set sizeScale(val:INumerableScale):void;
		function get sizeScale():INumerableScale;
		function get maxSizeValue():Number;
		function get minSizeValue():Number;

		/** Set the data provider of a cartesian Element, which must be a CartesianChart.*/
		function set dataProvider(val:Object):void;
		function get dataProvider():Object;

		/** Set the dim1 to filter horizontal data values.*/
		function set dim1(val:Object):void;
		function get dim1():Object;

		/** Set the dim2 to filter vertical data values.*/
		function set dim2(val:Object):void;
		function get dim2():Object;

		/** Set the dim3 to filter vertical data values.*/
		function set dim3(val:String):void;
		function get dim3():String;

		/** Set the scale for dim1.*/
		function set scale1(val:IScale):void;
		function get scale1():IScale;

		/** Set the scale for dim2.*/
		function set scale2(val:IScale):void;
		function get scale2():IScale;

		/** Set the scale for dim3.*/
		function set scale3(val:IScale):void;
		function get scale3():IScale;

		function get maxDim1Value():Number;
		function get minDim1Value():Number;

		function get maxDim2Value():Number;
		function get minDim2Value():Number;

		function get maxDim3Value():Number;
		function get minDim3Value():Number;

		function get totalDim1PositiveValue():Number;

		/** Set the fill color.*/
		function getFill():IGraphicsFill;

		/** Set the stroke color.*/
		function getStroke():IGraphicsStroke;

		/** Set the graphic renderer used for the layout of data values.*/
		function set graphicRenderer(val:IFactory):void;
		function get graphicRenderer():IFactory;

		/** Set the cursor vector used by the Element. It can either derive from the Element own 
		 * dataProvider or from the chart dataProvider.*/
		function set dataItems(val:Vector.<Object>):void;
		function get dataItems():Vector.<Object>;
		
		function getItemDisplayObject(itemId:Object):DisplayObject;

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

		/** Implement the element drawing in the creation phase.*/
		function draw():void;

		/** Update the data items status. This means that the dataProvider is still the same
		 * but we want to update it with new values for a single field (for ex. color field).
		 * - updatedDataItems is the new data provider for the element, in fact if the 
		 * data provider is not updated and the refresh involves 1 or more properties changes
		 * the next display invalidation will consider the original data provider, without considering 
		 * all the changes performed by the refresh.
		 * - field is the field whose values are to be updated.
		 * - fieldID is the field that can be used to uniquely identify 
		 * adata item in the polygon (for ex. if the polygon is a country, 
		 * than it's ISO code, or country name). 
		 * - colorFieldValues is the array with the new values to be assigned to the 
		 * field represented by fieldID
		 * */
		function refresh(updatedDataItems:Vector.<Object>, field:Object = null, colorFieldValues:Array = null, fieldID:Object = null):void;

		/** Element must provide the clear all graphics items when refreshed, thus insuring
		 * both display refresh and memory clearing..*/
		function clearAll():void;
		
		/** Return the svg data corresponding to this element.*/
		function get svgData():String;

		/** Return the x position of this guide.*/
		function get x():Number;
		/** Return the y position of this guide.*/
		function get y():Number;
	}
}
