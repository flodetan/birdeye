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
 
package org.un.cava.birdeye.qavis.microcharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import mx.collections.IViewCursor;
	
	 /**
	 * This class extends the functionalities of the GeometryGroup with tooltips properties and methods.
	 * It's therefore possible to define tooltips, their functions and prefix to customize them. 
	 * If no function is defined for the tooltips, than the dataField value is taken for their content.
	 * This class allows creating and positioning the graphics associated with the tooltips.
	*/
	public class ExtendedGeometryGroup extends GeometryGroup
	{
		public var toolTip:String;
		public var toolTipFill:IGraphicsFill;
		public var posX:Number;
		public var posY:Number;
		private var toolTipStroke:IGraphicsStroke;
		private var toolTipGeometry:Circle;
		private var whiteCircle:Circle;
		 
		private var _showDataTips:Boolean = false;
		private var _dataTipFunction:Function;
		private var _dataTipPrefix:String;
		
		/**
		* Indicate the prefix for the tooltip. 
		*/
		public function set dataTipPrefix(value:String):void
		{
			_dataTipPrefix = value;
		}
		
		public function get dataTipFunction():Function
	    {
	        return _dataTipFunction;
	    }

		/**
		* Indicate the function used to create tooltips. 
		*/
    	public function set dataTipFunction(value:Function):void
	    {
	        _dataTipFunction = value;
	    }
	    
		public function ExtendedGeometryGroup()
		{

		}
		
		/**
		* Create and position the tooltips for this ExtendedGeometryGroup. 
		*/
		public function createToolTip(item:Object, dataField:String, posX:Number, posY:Number, radius:Number):void
		{
			this.posX = posX;
			this.posY = posY;
			whiteCircle = new Circle(posX,posY,4);
			whiteCircle.fill = new SolidFill(0xffffff);
			toolTipGeometry = new Circle(posX,posY,2);
			toolTipGeometry.fill = (toolTipFill) ? toolTipFill : new SolidFill(0xffffff,1);
			whiteCircle.stroke = (toolTipStroke) ? toolTipStroke : new SolidStroke(0x999999,1);
			
			if (_dataTipFunction != null)
				toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
							+ _dataTipFunction(item);
			else
				toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
							+ ((dataField) ? item[dataField] : Number(item)); 
				
			geometryCollection.addItem(whiteCircle);
			geometryCollection.addItem(toolTipGeometry);
			hideToolTipGeometry();
		} 
		
		/**
		* Show the tooltip associated to this ExtendedGeometryGroup. 
		*/
		public function showToolTipGeometry():void
		{
			whiteCircle.visible = true;
			toolTipGeometry.visible = true;
		}
		
		/**
		* Hide the tooltip associated to this ExtendedGeometryGroup. 
		*/
		public function hideToolTipGeometry():void
		{
			whiteCircle.visible = false;
			toolTipGeometry.visible = false;
		}
	}
}