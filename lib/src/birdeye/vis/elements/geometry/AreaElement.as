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
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polygon;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class AreaElement extends StackElement
	{
		/** It overrides the get elementType to force the result to be "area".
		 * elementType is used to provide the possibility of using stackable element
		 * within any type of chart instead of only using them inside their own 
		 * chart type.*/
		override public function get elementType():String
		{
			return "area";
		}

		private var _baseAtZero:Boolean = true;
		/** If true, if min and max values of a element are positive (negative), 
		 * than the base of the AreaElement will be 0, instead of the min (max) value.*/
		[Inspectable(enumeration="true,false")]
		public function set baseAtZero(val:Boolean):void
		{
			_baseAtZero = val;
			invalidateProperties();
			invalidateDisplayList()
		}
		
		private var _form:String;
		/** The form defines the shape type of the element, ("curve", "line").*/
		public function set form(val:String):void
		{
			_form = val;
			invalidateDisplayList();
		}
		
		public function AreaElement()
		{
			super();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			// select the item renderer (must be an IGeomentry)
			if (! itemRenderer)
				itemRenderer = UpTriangleRenderer;

			// doesn't need to call super.commitProperties(), since it doesn't need to listen
			// to axes interval changes 
			if (stackType == STACKED100 && cursor)
			{
				if (scale2)
				{
					if (scale2 is INumerableScale)
						INumerableScale(scale2).max = maxDim2Value;
				} else {
					if (chart && chart.scale2 && chart.scale2 is INumerableScale)
						INumerableScale(chart.scale2).max = maxDim2Value;
				}
			}
		}

		private var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override protected function drawElement():void
		{
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number, zPos:Number;
			var j:Object;
			var t:Number = 0;
			
			var y0:Number = getYMinPosition();
			var y0Prev:Number;
			var dataFields:Array = [];
			// prepare data for a standard tooltip message in case the user
			// has not set a dataTipFunction
			dataFields[0] = dim1;
			dataFields[1] = dim2;
			if (dim3) 
				dataFields[2] = dim3;

			// shapes array defining the tooltip geometries
			var ttShapes:Array;
			// tooltip distance from the hitarea position
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
			
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);
			
			// move data provider cursor at the beginning
			cursor.seek(CursorBookmark.FIRST);

			while (!cursor.afterLast)
			{
				// if the Element has its own x axis, than get the x coordinate
				// position of the data value filtered by xField
				if (scale1)
					xPos = scale1.getPosition(cursor.current[dim1]);
				else if (chart.scale1) 
					// otherwise use the parent chart x axis to do that
					xPos = chart.scale1.getPosition(cursor.current[dim1]);
				
				j = cursor.current[dim1];
				// if the Element has its own y axis, than get the y coordinate
				// position of the data value filtered by yField
				if (scale2)
				{
					// if the stackType is stacked100, than the y0 coordinate of 
					// the current baseValue is added to the y coordinate of the current
					// data value filtered by yField
					if (_stackType == STACKED100)
					{
						y0 = scale2.getPosition(baseValues[j]);
						yPos = scale2.getPosition(
							baseValues[j] + Math.max(0,cursor.current[dim2]));
					} else 
						// if not stacked, than the y coordinate is given by the own y axis
						yPos = scale2.getPosition(cursor.current[dim2]);
				} else if (chart.scale2) {
					// if no own y axis than use the parent chart y axis to achive the same
					// as above
					if (_stackType == STACKED100)
					{
						y0 = chart.scale2.getPosition(baseValues[j]);
						yPos = chart.scale2.getPosition(
							baseValues[j] + Math.max(0,cursor.current[dim2]));
					} else {
						yPos = chart.scale2.getPosition(cursor.current[dim2]);
					}
				}
				
				// if stacked 100 than change the default tooltip shape to a line
				// that won't be covered by the children layering
				if (_stackType == STACKED100)
				{
						ttShapes = [];
						ttXoffset = -30;
						ttYoffset = 20;
						var line:Line = new Line(xPos, yPos, xPos + + ttXoffset/3, yPos + ttYoffset);
						line.stroke = stroke;
		 				ttShapes[0] = line;
				}
				
				var scale2RelativeValue:Number = NaN;

				if (scale3)
				{
					zPos = scale3.getPosition(cursor.current[dim3]);
					scale2RelativeValue = XYZ(scale3).height - zPos;
				} else if (chart.scale3) {
					zPos = chart.scale3.getPosition(cursor.current[dim3]);
					// since there is no method yet to draw a real z axis 
					// we create an y axis and rotate it to properly visualize 
					// a 'fake' z axis. however zPos over this y axis corresponds to 
					// the axis height - zPos, because the y axis in Flex is 
					// up side down. this trick allows to visualize the y axis as
					// if it would be a z. when there will be a 3d line class, it will 
					// be replaced
					scale2RelativeValue = XYZ(chart.scale3).height - zPos;
				}

				// create a separate GeometryGroup to manage interactivity and tooltips 
				createTTGG(cursor.current, dataFields, xPos, yPos, scale2RelativeValue, 3);
				
				// create the polygon only if there is more than 1 data value
				// there cannot be an area with only the first data value 
				if (t++ > 0) 
				{
					poly = new Polygon()
					poly.data =  String(xPrev) + "," + String(y0Prev) + " " +
								String(xPrev) + "," + String(yPrev) + " " +
								String(xPos) + "," + String(yPos) + " " +
								String(xPos) + "," + String(y0);
					poly.fill = fill;
					poly.stroke = stroke;
					gg.geometryCollection.addItemAt(poly,0);
				}
				
				if (_showItemRenderer)
				{
	 				var bounds:Rectangle = new Rectangle(xPos - _rendererSize/2, yPos - _rendererSize/2, _rendererSize, _rendererSize);
					var shape:IGeometry = new itemRenderer(bounds);
					shape.fill = fill;
					shape.stroke = stroke;
					gg.geometryCollection.addItem(shape);
				}

				// store previous data values coordinates, to rely them 
				// to the next data value coordinates
				y0Prev = y0;
				xPrev = xPos; yPrev = yPos;
				
				if (dim3)
				{
					gg.z = zPos;
					if (isNaN(zPos))
						zPos = 0;
				}
				cursor.moveNext();
			}
			if (dim3)
				zSort();
		}
		
		/** @Private 
		 * Get the x minimum position of the AreaElement (only used in case the AreaElement is drawn 
		 * vertically, i.e. the x axis is linear).*/ 
		private function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (scale1)
			{
				if (scale1 is INumerableScale)
					xPos = scale1.getPosition(minDim1Value);
			} else {
				if (chart.scale1 is INumerableScale)
					xPos = chart.scale1.getPosition(minDim1Value);
			}
			
			return xPos;
		}
		
		/** @Private 
		 * Returns the y minimum position of the AreaElement.*/ 
		private function getYMinPosition():Number
		{
			var yPos:Number;
			if (scale2 && scale2 is INumerableScale)
			{
				if (_baseAtZero)
					yPos = scale2.getPosition(0);
				else
					yPos = scale2.getPosition(minDim2Value);
			} else {
				if (chart.scale2 is INumerableScale)
				{
					if (_baseAtZero)
						yPos = chart.scale2.getPosition(0);
					else
						yPos = chart.scale2.getPosition(minDim2Value);
				}
			}
			return yPos;
		}
	}
}