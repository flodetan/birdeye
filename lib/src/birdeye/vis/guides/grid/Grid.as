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
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.BaseScale;
	
	import com.degrafa.Surface;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.SolidStroke;
	
	import flash.geom.Rectangle;
	
	import org.greenthreads.IGuideThread;
	import org.greenthreads.ThreadProcessor;
	
	/**
	 * Grid is a guide that draws a grid behind the visualization based on</br>
	 * the scales that are given to the grid.</br>
	 * The properties of the stroke that is used for the grid can easily be changed.</br>
	 */
	public class Grid extends Surface implements IGuideThread
	{
		


		public var stroke:IGraphicsStroke;
		
		public function Grid()
		{
			//autoClearGraphicsTarget = false;
			stroke = new SolidStroke(0x000000, .3, 1);
		}
		
		public function get parentContainer():Object
		{
			return parent as Object;
		}
		
		public function get priority():int
		{
			return ThreadProcessor.PRIORITY_GUIDE;
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
		
		private var _svgData:String = "";
		/** String containing the svg data to be exported.*/ 
		public function set svgData(val:String):void
		{
			_svgData = val;
		}
		public function get svgData():String
		{
			return _svgData;
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
			//return NaN;
		}
		
		private var _bounds:Rectangle;
		
		public function set bounds(b:Rectangle):void
		{
			_bounds = b;	
		}
		
		public function get bounds():Rectangle
		{
			return _bounds;
		}
		
		private var _drawingData:Object;
		
		public function initializeDrawingData():Boolean
		{
			clearAll();
			
			_drawingData = new Object();
			var scaleData:Array = new Array();
					
			_drawingData.scale1 = createLineData(scale1, bounds);
			_drawingData.scale2 = createLineData(scale2, bounds);
			
			currentScale = 0;
			index = 0;
			
			item.stroke = this.stroke;

			return true;
		}
		
		
		private var index:int = 0;
		private var totalLength:int;
		private var currentScale:int = 0;
		
		private var item:Path = new Path();
		
		public function drawDataItem():Boolean
		{	
			if (currentScale == 0)
			{
				if (_drawingData.scale1)
				{
					currentScale = 1;
				}
				else if (_drawingData.scale2)
				{
					currentScale = 2;
				}
				else
				{
					return false;
				}
			}
			
			if (currentScale == 1 && index < _drawingData.scale1.length)
			{
				item.data = _drawingData.scale1[index];
				item.draw(this.graphics, null);			
			}
			
			if (currentScale == 2 && index < _drawingData.scale2.length)
			{
				item.data = _drawingData.scale2[index];
				item.draw(this.graphics, null);
			}
			
			index++;
			
			if (currentScale == 1 && _drawingData.scale1.length == index)
			{
				if (_drawingData.scale2)
				{
					index = 0;
					currentScale++;
				}
				else
				{
					// done
					return false;
				}
			}
			
			if (currentScale == 2 && _drawingData.scale2.length == index)
			{
				// done
				return false;
			}
			
			return true;
		}
		
		private function createLineData(scale:IScale, bounds:Rectangle):Array
		{
			var toReturn:Array;
			if (scale && scale.completeDataValues && scale.completeDataValues.length > 0)
			{
				toReturn = new Array();
				
				var offset:Number = 0;
				if (scale is IEnumerableScale && divideEnumerableScale)
				{
					offset = scale.size/scale.completeDataValues.length/2;
				}
				
				for each (var dataLabel:Object in scale.completeDataValues)
				{
					
					var position:Number = scale.getPosition(dataLabel) + offset;
					
					var itemData:String = "";
					
					if (scale.dimension == BaseScale.DIMENSION_2)
					{
						// horizontal
						itemData = "M" + String(0) + " " + String(position) + " " + 
							"L" + String(bounds.width) + " " + String(position) + " ";
					} else if (scale.dimension == BaseScale.DIMENSION_1)
					{
						// vertical
						itemData = "M" + String(position) + " " + String(0) + " " + 
							"L" + String(position) + " " + String(bounds.height) + " ";
					}
					toReturn.push(itemData);
				}
			}
			
			return toReturn;
		}
		 		
 		public function clearAll():void
 		{
			this.graphics.clear();
		}

	}
}