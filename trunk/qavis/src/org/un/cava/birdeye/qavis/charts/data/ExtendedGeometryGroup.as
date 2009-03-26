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
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	 /**
	 * This class extends the functionalities of the GeometryGroup with tooltips properties and methods.
	 * It's therefore possible to define tooltips, their functions and prefix to customize them. 
	 * If no function is defined for the tooltips, than the dataField value is taken for their content.
	 * This class allows creating and positioning the graphics associated with the tooltips.
	*/
	public class ExtendedGeometryGroup extends GeometryGroup
	{
		public var toolTip:String;
		public var posX:Number;
		public var posY:Number;
		public var posZ:Number;

		private var line:Line;		 
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
	    
		/**
		* Set the tooltip geometry fill. 
		*/
		public var toolTipFill:IGraphicsFill;

		/**
		* Set the tooltip geometry stroke. 
		*/
		public var toolTipStroke:IGraphicsStroke;
		
		private var _xTTOffset:Number = -20;
		/** Set the x offset from the tooltip to the hit area position.*/
		public function get xTTOffset():Number
		{
			return _xTTOffset;
		}

		private var _yTTOffset:Number = 20;
		/** Set the y offset from the tooltip to the hit area position.*/
		public function get yTTOffset():Number
		{
			return _yTTOffset;
		}

		public function ExtendedGeometryGroup()
		{
			super();
		}
		
		// allows to define custom shapes for the tooltip geometry
		private var shapes:Array = [];		
		/**
		* Create and position the tooltips for this ExtendedGeometryGroup. 
		*/
		public function createToolTip(item:Object, dataFields:Array /* of String */, 
										posX:Number, posY:Number, posZ:Number, radius:Number, 
										ttShapes:Array = null/* of IGeometry */, xOffSet:Number = NaN, yOffset:Number = NaN):void
		{
			this.posX = posX;
			this.posY = posY;
			this.posZ = posZ;
trace (posZ);
			
			// if no custom shapes than create the default one
			if (! ttShapes)
			{
				shapes[0] = new Circle(posX,posY,4);
				shapes[0].fill = new SolidFill(0xffffff);
				shapes[0].stroke = (toolTipStroke) ? toolTipStroke : new SolidStroke(0x999999,1);
				shapes[1] = new Circle(posX,posY,2);
				shapes[1].fill = (toolTipFill) ? toolTipFill : new SolidFill(0xffffff,1);
			} else 
				shapes = ttShapes;
			
			// if tip function is set, use it, otherwise use a default one
			if (_dataTipFunction != null)
				toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
							+ _dataTipFunction(item, dataFields);
			else 
			{
				if (_dataTipPrefix) 
					toolTip = _dataTipPrefix;
				for (i = 0; i<dataFields.length; i++)
					if (dataFields[i])
					{
						if (! _dataTipPrefix)
						{
							if (i==0)
								toolTip = String(((dataFields[i]) ? item[dataFields[i]] : Number(item)));
							else
								toolTip += "\n" + ((dataFields[i]) ? item[dataFields[i]] : Number(item)); 
						} else 
							toolTip += "\n" + ((dataFields[i]) ? item[dataFields[i]] : Number(item)); 
					}
			}
			
			// hide tip geometry, they will show up only when mouse is over the hit area
			for (var i:Number = 0; i<shapes.length; i++)
				geometryCollection.addItem(IGeometry(shapes[i]));
			hideToolTipGeometry();
		} 
		
		/** @Private
		 * Remove all elements from the component*/
		public function removeAllElements():void
		{
			for (var i:Number = 0; i<numChildren; i++)
				removeChildAt(0);
			
			for (i = 0; i<geometryCollection.items.length; i++)
				geometryCollection.removeItemAt(0);
				
			geometry = geometryCollection.items = [];
		}
		
		/**
		* Show the tooltip associated to this ExtendedGeometryGroup. 
		*/
		public function showToolTipGeometry():void
		{
			for (var i:Number = 0; i<shapes.length; i++)
				Geometry(shapes[i]).visible = true;
		}
		
		/**
		* Hide the tooltip associated to this ExtendedGeometryGroup. 
		*/
		public function hideToolTipGeometry():void
		{
			for (var i:Number = 0; i<shapes.length; i++)
				Geometry(shapes[i]).visible = false;
		}
	}
}