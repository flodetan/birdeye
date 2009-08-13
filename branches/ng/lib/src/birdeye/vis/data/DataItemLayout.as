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
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	
	import flash.geom.Point;
	
	import mx.controls.ToolTip;
	import mx.managers.ToolTipManager;
	
	 /**
	 * This class extends the functionalities of the GeometryGroup with tooltips properties and methods.
	 * It's therefore possible to define tooltips, their functions and prefix to customize them. 
	 * If no function is defined for the tooltips, than the dataField value is taken for their content.
	 * This class allows creating and positioning the graphics associated with the tooltips.
	*/
	public class DataItemLayout extends GeometryGroup
	{
		public var toolTip:String;
		public var posX:Number;
		public var posY:Number;
		public var posZ:Number;
		
		public var collisionTypeIndex:Number = NaN;

		private var line:Line;		 
		private var _showDataTips:Boolean = false;
		private var _dataTipFunction:Function;
		private var _dataTipPrefix:String;
		
		private var _hitMouseArea:IGeometry;
		public function set hitMouseArea(val:IGeometry):void
		{
			_hitMouseArea = val;
			geometryCollection.addItem(_hitMouseArea);
		}
		public function get hitMouseArea():IGeometry
		{
			return _hitMouseArea;
		}
		
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

		private var _yTTOffset:Number = 40;
		/** Set the y offset from the tooltip to the hit area position.*/
		public function get yTTOffset():Number
		{
			return _yTTOffset;
		}

		private var _currentItem:Object;
		/**
		* Set the current data item. 
		*/
    	public function set currentItem(value:Object):void
	    {
	        _currentItem = value;
	    }
		public function get currentItem():Object
		{
			return _currentItem;
		}
		
		// allows to define custom shapes for the tooltip geometry
		public var shapes:Array;

		private var _dataFields:Array;
		/**
		* Set the current data item. 
		*/
    	public function set dataFields(value:Array):void
	    {
	        _dataFields = value;
	    }
		public function get dataFields():Array
		{
			return _dataFields;
		}

		public function DataItemLayout()
		{
			super();
		}
		
		/**
		* Create and position the tooltips for this ExtendedGeometryGroup. 
		*/
		public function create(item:Object, dataFields:Array /* of String */, 
								posX:Number, posY:Number, posZ:Number, radius:Number,
								collisionIndex:Number = NaN, 
								ttShapes:Array = null/* of IGeometry */, xOffSet:Number = NaN, yOffset:Number = NaN,
								isTooltip:Boolean = true, showGeometry:Boolean = true):void
		{
			this.posX = posX;
			this.posY = posY;
			this.posZ = posZ;
			
			this.collisionTypeIndex = collisionIndex;
			
			this.currentItem = item;
			this.dataFields = dataFields;
			
			this.shapes = ttShapes;
			
			if (isTooltip)
			{
				// if tip function is set, use it, otherwise use a default one
				if (_dataTipFunction != null)
					toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
								+ _dataTipFunction(item, dataFields);
				else 
					prepareDefaultTipString(_dataTipPrefix, dataFields, item)
			}
		} 
		
		private function prepareDefaultTipString(_dataTipPrefix:String, dataFields:Array, item:Object):void
		{
			if (_dataTipPrefix) 
				toolTip = _dataTipPrefix;
			
			var dimNames:Array = ["dim1", "dim2", "dim3", "colorField", "sizeField"];
			for each (var dim:String in dimNames)
			{
				if (dataFields[dim])
				{
					if (! _dataTipPrefix)
					{
						if (dim=="dim1")
							toolTip = String(((dataFields[dim]) ? dataFields[dim] + ": " + item[dataFields[dim]] : Number(item)));
						else
							toolTip += "\n" + ((dataFields[dim]) ? dataFields[dim] + ": " + item[dataFields[dim]] : Number(item)); 
					} else 
						toolTip += "\n" + ((dataFields[dim]) ? dataFields[dim] + ": " + item[dataFields[dim]] : Number(item)); 
				}
			}
		}
		
		/** @Private
		 * Remove all elements from the component*/
		public function clearAll():void
		{
 			// Iterating backwards here is essential, because during the 
 			// iteration we are modifying the collection we are iterating over.
 			var i:int;
			for (i = geometryCollection.items.length - 1; i >= 0; i--) {
				geometryCollection.removeItemAt(i);
			}
			for (i = numChildren - 1; i >= 0; i--) {
				removeChildAt(i);
			}

			geometry = geometryCollection.items = [];
		}

		/**
		* Show the tooltip shape associated to this DataItemLayout. 
		*/
		public function showToolTipGeometry():void
		{
			for (var i:Number = 0; i<shapes.length; i++)
				Geometry(shapes[i]).visible = true;
		}
		
		/**
		* Hide the tooltip shape associated to this DataItemLayout. 
		*/
		public function hideToolTipGeometry():void
		{
			for (var i:Number = 0; i<shapes.length; i++)
				Geometry(shapes[i]).visible = false;
		}
		
		private var tip:ToolTip; 
		/**
		* Show the tooltip of this DataItemLayout. 
		*/
		public function showToolTip():void
		{
			var pos:Point = localToGlobal(new Point(posX, posY));
			tip = ToolTipManager.createToolTip(toolTip, 
												pos.x + xTTOffset,	pos.y + yTTOffset) as ToolTip;
		}
		
		/**
		* Hide the tooltip of this DataItemLayout. 
		*/
		public function hideToolTip():void
		{
			try {
				ToolTipManager.destroyToolTip(tip);
			} catch (e:Error) {}
		}
		
		/*
		TODO: Make width and height return the width of the bounding box.
		      The following code doesn't work because the geometryCollection is
		      always empty to the moment when boundingBox() is called. 
		
		public override function get width():Number {
			return boundingBox().width;
		}
		
		public override function get height():Number {
			return boundingBox().height;
		}
		
		public function boundingBox():Rectangle {
			return calcBoundingBox(geometryCollection, new Rectangle(NaN, NaN, NaN, NaN));
		}
				
		private static function calcBoundingBox(geoms:GeometryCollection, result:Rectangle):Rectangle {
			for each(var geom:IGeometry in geoms) {
				if (geom is GeometryCollection) {
					calcBoundingBox(geom as GeometryCollection, result);
				} else if (geom is IGraphic) {
					const graphic:IGraphic = (geom as IGraphic);
					
					result.left = isNaN(result.left) ? graphic.x : Math.min(result.left, graphic.x);
					result.right = isNaN(result.right) ? graphic.x + graphic.width : Math.max(result.right, graphic.x + graphic.width);
					result.top = isNaN(result.top) ? graphic.y : Math.min(result.top, graphic.y);
					result.bottom = isNaN(result.bottom) ? result.bottom : Math.max(result.bottom, graphic.y + graphic.height);
				}
			}
			return result;
		}
		*/

	}
}