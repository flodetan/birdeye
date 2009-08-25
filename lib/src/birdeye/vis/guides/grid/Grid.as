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
 
package birdeye.vis.guides.grid
{
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.guides.IGuide;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.BaseScale;
	
	import com.degrafa.GeometryComposition;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * Grid is a guide that draws a grid behind the visualization based on</br>
	 * the scales that are given to the grid.</br>
	 * The properties of the stroke that is used for the grid can easily be changed.</br>
	 */
	public class Grid extends GeometryComposition implements IGuide
	{

		public function Grid()
		{
			//autoClearGraphicsTarget = false;
			stroke = new SolidStroke(0x000000, .3, 1);
		}
		
		
		public function get position():String
		{
			return "elements";
		}
		
		private var _scale1:IScale;
		public function set scale1(val:IScale):void
		{
			_scale1 = val;
		}
		
		public function get scale1():IScale
		{
			return _scale1;	
		}
		
		private var _scale2:IScale;
		public function set scale2(val:IScale):void
		{
			_scale2 = val;	
		}
		
		public function get scale2():IScale
		{
			return _scale2;	
		}
		
		private var _scale3:IScale;
		public function set scale3(val:IScale):void
		{
			_scale3 = val;
			
		}
		
		public function get scale3():IScale
		{
			return _scale3;	
		}
		
		/**
		 * @see birdeye.vis.interfaces.guides.IGuide#coordinates
		 */
		 private var _coordinates:ICoordinates;
		 
		public function set coordinates(val:ICoordinates):void
		{
			_coordinates = val;
		}
		
		public function get coordinates():ICoordinates
		{	
			return _coordinates;
		}
		
		public function get targets():Array
		{
			return this.graphicsTarget;
		}
		
		
		private var _divideEnumerableScale:Boolean = true;
		
		/** 
		 * Indicate how the grid draws line with a enumerable (category) scale.</br>
		 * <code>true</code> indicates that the grid will be drawn <i>between</i> the category points (in the middle between two points).</br>
		 * <code>false</code> indicates that the grid will be drawn <i>on</i> the category points.</br>
		 * <b>Defaults to: </b> <code>true</code>
		 */
		[Inspectable(enumeration="true,false")]
		public function set divideEnumerableScale(val:Boolean):void
		{
			_divideEnumerableScale = val;		
		}
		
		public function get divideEnumerableScale():Boolean
		{
			return _divideEnumerableScale;
		}
	
		/** Set the grid color.*/
		public function set color(val:Object):void
		{
			if (stroke is SolidStroke)
			{
				(stroke as SolidStroke).color = val;
			}
		}
		
		public function get color():Object
		{
			if (stroke is SolidStroke)
			{
				return (stroke as SolidStroke).color;
			}
			
			return NaN;
		}


		/** Set the line grid weight.*/
		public function set weight(val:Number):void
		{
			stroke.weight = val;
		}
		
		public function get weight():Number
		{
			return stroke.weight;
		}
		
		
		public function drawGuide(bounds:Rectangle):void
		{

trace(getTimer(), "drawing grid", this.id);
			
			var nbrOfItems:Number = drawLinesBasedOnScale(scale1, bounds);
			nbrOfItems = drawLinesBasedOnScale(scale2, bounds, nbrOfItems);
			// scale3 not implemented yet, not sure about how it works
			
			clearExcessGeometries(nbrOfItems);
			
trace(getTimer(), "end drawing grid", this.id);

 		}
 		
 		private function drawLinesBasedOnScale(scale:IScale, bounds:Rectangle, startIndex:Number=0):Number
 		{
 			if (scale && scale.completeDataValues && scale.completeDataValues.length > 0)
 			{
 				var offset:Number = 0;
				if (scale is IEnumerableScale && divideEnumerableScale)
				{
					offset = scale.size/scale.completeDataValues.length/2;
				}
				
				for each (var dataLabel:Object in scale.completeDataValues)
				{
				
					var item:Line = Line(this.geometryCollection.getItemAt(startIndex++));
					var position:Number = scale.getPosition(dataLabel) + offset;
					if (!item)
					{
						trace("grid new item");
						item = new Line();
						item.stroke = stroke;
						this.geometryCollection.addItem(item);
					}
					
					
		 			if (scale.dimension == BaseScale.DIMENSION_2)
		 			{
		 				// horizontal
		 				item.y = position;
						item.y1 = position;
						item.x = 0;
						item.x1 = bounds.width; // NOT GOOD
					}
					else if (scale.dimension == BaseScale.DIMENSION_1)
					{
						// vertical
						item.x = position;
						item.x1 = position;
						item.y1 = bounds.height;
						item.y = 0;
					}	
				}
				
 			}
 			
 			return startIndex;
 		}
 		
 		private function clearExcessGeometries(nbrOfItems:Number):void
 		{
 			while (this.geometryCollection.items.length > nbrOfItems)
 			{
 				this.geometryCollection.removeItemAt(nbrOfItems++);
 			}
 		}
 		
 		public function clearAll():void
 		{
			this.geometry = [];
			this.geometryCollection.items = [];

			invalidated = true;
		}

	}
}