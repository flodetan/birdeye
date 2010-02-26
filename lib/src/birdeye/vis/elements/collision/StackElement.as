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
 
package birdeye.vis.elements.collision
{
	import birdeye.vis.VisScene;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.interfaces.elements.IStack;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.paint.SolidFill;
	
	import flash.utils.Dictionary;
	
	[Exclude(name="stackType", kind="property")] 
	[Exclude(name="total", kind="property")] 
	[Exclude(name="stackPosition", kind="property")] 
	[Exclude(name="elementType", kind="property")] 

	public class StackElement extends BaseElement implements IStack
	{
		public static const OVERLAID:String = "overlaid";
		public static const CLUSTER:String = "cluster";
		public static const STACKED:String = "stack";
		
		protected var _stackType:String = OVERLAID;
		public function set stackType(val:String):void
		{
			_stackType = val;
			invalidateProperties();
		}
		public function get stackType():String
		{
			return _stackType;
		}
		
		protected var _baseAt:Number = 0;
		/** If not set to NaN and min and max values of an element are positive (negative), 
		 * than the base of the StackElement will be the one set, instead of the min (max) value.*/
		public function set baseAt(val:Number):void
		{
			_baseAt = val;
			invalidateProperties();
		}
		public function get baseAt():Number
		{
			return _baseAt;
		}
		
		public var _baseValues:Dictionary;
		public function set baseValues(val:Dictionary):void
		{
			_baseValues = val;
			invalidateProperties();
		}
		public function get baseValues():Dictionary
		{
			return _baseValues;
		}

		public var _topValues:Dictionary;
		public function set topValues(val:Dictionary):void
		{
			_topValues = val;
			invalidateProperties();
		}
		public function get topValues():Dictionary
		{
			return _topValues;
		}

		public var _maxCategoryValues:Dictionary;
		/** Set the maximum values for each category of the element. Used for stack100.*/
		public function set maxCategoryValues(val:Dictionary):void
		{
			_maxCategoryValues = val;
			invalidateProperties();
		}
		public function get maxCategoryValues():Dictionary
		{
			return _maxCategoryValues;
		}

		protected var _total:Number = NaN;
		public function set total(val:Number):void
		{
			_total = val;
			invalidateProperties();
		}

		protected var _stackPosition:Number = NaN;
		public function set stackPosition(val:Number):void
		{
			_stackPosition = val;
			invalidateProperties();
		}
		
		public function get elementType():String
		{
			// to be overridden
			
			return null;
		}
		
		public function StackElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}

		protected var y0:Number;
		protected var x0:Number;		
		protected var scaleResults:Object;
		protected static const POS1:String = "POS1";
		protected static const POS2:String = "POS2";
		protected static const POS3:String = "POS3";
		protected static const POS3relative:String = "POS3RELATIVE";
		protected static const SIZE:String = "size";
		protected static const COLOR:String = "color";
		protected function determinePositions(dim1:Object, dim2:Object, dim3:Object=null,color:Object=null, size:Object=null, currentItem:Object=null):Object
		{
			var scaleResults:Object = new Object();
			
			scaleResults[SIZE] = _graphicRendererSize;
			scaleResults[COLOR] = fill;

			// if the Element has its own scale1, than get the dim1 coordinate
			// position of the data value filtered by dim1 field. If it's stacked100 than 
			// it considers the last stacked value as a base value for the current one.
			if (scale1)
			{
				if (scale1 is INumerableScale && _stackType == STACKED)
				{
					x0 = scale1.getPosition(baseValues[dim2]);
					if (!isNaN(dim1 as Number))
					{
						scaleResults[POS1] = scale1.getPosition(
							baseValues[dim2] + Math.max(0,Number(dim1 as Number)));
					}
					else
					{
						scaleResults[POS1] = NaN;
					}
				} else {
					scaleResults[POS1] = scale1.getPosition(dim1);
				}
			}
					
			// if there is a multiscale than use the scale2 corresponding to the current
			// dim1 category to get the dim2 position
			if (scale1 is ISubScale && (scale1 as ISubScale).subScalesActive)
			{
				scaleResults[POS2] = (scale1 as ISubScale).subScales[dim1].getPosition(dim2);
			} 

			// if the Element has its own scale2, than get the dim2 coordinate
			// position of the data value filtered by dim2 field. If it's stacked100 than 
			// it considers the last stacked value as a base value for the current one.
			if (scale2)
			{
				// if the stackType is stacked100, than the y0 coordinate of 
				// the current baseValue is added to the y coordinate of the current
				// data value
				if (scale2 is INumerableScale && _stackType == STACKED)
				{
					y0 = scale2.getPosition(baseValues[dim1]);
					if (!isNaN(dim2 as Number))
					{
						scaleResults[POS2] = scale2.getPosition(
							baseValues[dim1] + Math.max(0,dim2 as Number));
					}
					else
					{
						scaleResults[POS2] = NaN;
					}
				} 
				else 
				{
					// if not stacked, than the dim2 coordinate is given by the scale2
					scaleResults[POS2] = scale2.getPosition(dim2);
				}
			}
					
			var scale2RelativeValue:Number = NaN;

			if (scale3)
			{
				scaleResults[POS3] = scale3.getPosition(dim3);
				// since there is no method yet to draw a real z axis 
				// we create an y axis and rotate it to properly visualize 
				// a 'fake' z axis. however zPos over this y axis corresponds to 
				// the axis height - zPos, because the y axis in Flex is 
				// up side down. this trick allows to visualize the y axis as
				// if it would be a z. when there will be a 3d line class, it will 
				// be replaced
				scaleResults[POS3relative] = scale3.size - scaleResults[POS3];
			} 
			
			if (colorScale)
			{
				var col:* = colorScale.getPosition(color);
				if (col is Number)
					scaleResults[COLOR] = new SolidFill(col);
				else if (col is IGraphicsFill)
					scaleResults[COLOR] = col;
			} 

			if (visScene.coordType == VisScene.POLAR)
			{
				var xPos:Number = PolarCoordinateTransform.getX(scaleResults[POS1], scaleResults[POS2], visScene.origin);
				var yPos:Number = PolarCoordinateTransform.getY(scaleResults[POS1], scaleResults[POS2], visScene.origin);
				scaleResults[POS1] = xPos;
				scaleResults[POS2] = yPos; 
			}

			if (sizeScale)
			{
				scaleResults[SIZE] = sizeScale.getPosition(size);
			}
			
			return scaleResults;
		}
		
		override protected function getMaxValue(field:Object):Number
		{
			var max:Number = super.getMaxValue(field);
				
			if (visScene && stackType == STACKED) 
			{
				if (collisionType == STACKED)
					max += Math.max(max, visScene.maxStacked100);
				else
					max = Math.max(max, visScene.maxStacked100);
			}
					
			return max;
		}

		/** @Private 
		 * Get the x minimum position of the AreaElement (only used in case the AreaElement is drawn 
		 * vertically, i.e. the x axis is linear).*/ 
		protected function getXMinPosition():Number
		{
			var xPos:Number;
			
			if (scale1 && scale1 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					xPos = scale1.getPosition(_baseAt);
				else
					xPos = scale1.getPosition(minDim1Value);
			}
			
			return xPos;
		}

		/** @Private 
		 * Returns the y minimum position of the AreaElement.*/ 
		protected function getYMinPosition():Number
		{
			var yPos:Number;
			if (scale2 && scale2 is INumerableScale)
			{
				if (!isNaN(_baseAt))
					yPos = scale2.getPosition(_baseAt);
				else
					yPos = scale2.getPosition(minDim2Value);
			}
			return yPos;
		}
	}
}