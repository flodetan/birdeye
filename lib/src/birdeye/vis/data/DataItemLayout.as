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
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.DisplayObject;
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

		private var _yTTOffset:Number = 25;
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
		
		// allows to define custom shapes for the tooltip geometry
		private var shapes:Array = [];		
		/**
		* Create and position the tooltips for this ExtendedGeometryGroup. 
		*/
		public function create(item:Object, dataFields:Array /* of String */, 
								posX:Number, posY:Number, posZ:Number, radius:Number, 
								ttShapes:Array = null/* of IGeometry */, xOffSet:Number = NaN, yOffset:Number = NaN,
								isTooltip:Boolean = true, showGeometry:Boolean = true):void
		{
			this.posX = posX;
			this.posY = posY;
			this.posZ = posZ;
			
			this.currentItem = item;
			this.dataFields = dataFields;
			
			if (isTooltip)
			{
				if (showGeometry)
				{
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
				}
				
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
				
				if (showGeometry)
				{
					// hide tip geometry, they will show up only when mouse is over the hit area
					for (var i:Number = 0; i<shapes.length; i++)
						geometryCollection.addItem(IGeometry(shapes[i]));
					hideToolTipGeometry();
				}
			}
		} 
		
		/** @Private
		 * Remove all elements from the component*/
		public function removeAllElements():void
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

			tip.alpha = 0.8;
			showToolTipGeometry();
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