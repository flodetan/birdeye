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
 
package birdeye.vis.coords
{
	import birdeye.vis.VisScene;
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.guides.axis.Axis;
	import birdeye.vis.interfaces.ICoordinates;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.interfaces.guides.IAxis;
	import birdeye.vis.interfaces.guides.IGuide;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	import birdeye.vis.scales.*;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/** 
	 * The PolarChart is the base chart that is extended by all charts that are
	 * based on polar coordinates (PieChart, RadarChart, CoxCombo, etc). 
	 * The PolarChart serves as container for all axes and elements and coordinates the different
	 * data loading and creation of each component.
	 * 
	 * If a PolarChart is provided with an axis, this axis will be shared by all elements that have 
	 * not that same axis (angle, and/or radius). 
	 * In the same way, the PolarChart provides a dataProvider property 
	 * that can be shared with elements that have not a dataProvider. In case the PolarChart dataProvider 
	 * is used along with some elements dataProvider, than the relevant values defined be the elements fields
	 * of all these dataProviders will define the axes.
	 * 
	 * A PolarChart may have multiple and different type of elements, multiple axes and 
	 * multiple dataProvider(s).
	 * */ 
	[DefaultProperty("dataProvider")]
	public class Polar extends BaseCoordinates implements ICoordinates
	{
		protected const COLUMN:String = "column";
		protected const RADAR:String = "radar";
				
		protected var _layout:String;
		[Inspectable(enumeration="column,radar")]
		public function set layout(val:String):void
		{
			_layout = val;
			invalidateDisplayList();
		}

		protected var _fontSize:Number = 10;
		public function set fontSize(val:Number):void
		{
			_fontSize = val;
			invalidateDisplayList();
		}

		public function Polar()
		{
			super();
			coordType = VisScene.POLAR;
			_elementsContainer = this;

		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			_origin = new Point(unscaledWidth/2, unscaledHeight/2);	
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
		}
		
		override protected function placeGuide(guide:IGuide):void
		{
			if (guide is DisplayObject)
			{
			
				if (!elementsContainer.contains(DisplayObject(guide)))
				{
					if (!DisplayObject(guide).parent)
					{
						elementsContainer.addChild(DisplayObject(guide));
					}
					else if (guide.targets.lastIndexOf(elementsContainer) == -1)
					{
						guide.targets.push(elementsContainer);
					}
				}
			}
			else
			{
				if (guide.targets.lastIndexOf(elementsContainer) == -1)
				{
					guide.targets.push(elementsContainer);
				}
			}	
		}

		override protected function updateScale(scale:IScale, element:IElement, elementsMinMax:Array, dim:Object):void
		{
			super.updateScale(scale, element,elementsMinMax, dim);
			
			
			// every scale it dimension 1 in polar
			scale.dimension = BaseScale.DIMENSION_1;

		}
		
		override protected function feedScales():void
		{
			if (!scales) return;
			
			resetScales();
			
			// init axes of all elements that have their own axes
			// since these are children of each elements, they are 
			// for sure ready for feeding and it won't affect the axesFeeded status
			var elementsMinMax:Array = [];
			for (var i:Number = 0; i<elements.length; i++)
				initElementsScales(elements[i], elementsMinMax);
			
			//if (elementsMinMax.length > 0)
			//{
				for ( i = 0;i<scales.length;i++)
				{
					if (scales[i] && scales[i] is ISubScale && (scales[i] as ISubScale).subScalesActive)
					{
						(scales[i] as ISubScale).feedMinMax(elementsMinMax);
					}
				}
			//}
			
			commitValidatingScales();
			
			axesFeeded = true;
				
		}
		

		override protected function updateGuide(guide:IGuide, unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (guide is IAxis)
			{
				var axis:IAxis = guide as IAxis;
				axis.size = Math.min(unscaledWidth, unscaledHeight)/2;
				
				if (axis is DisplayObject)
				{
					switch (axis.placement)
					{
						case Axis.HORIZONTAL_CENTER:
							DisplayObject(axis).x = _origin.x;
							DisplayObject(axis).y = _origin.y;
							break;
						case Axis.VERTICAL_CENTER:
							DisplayObject(axis).x = _origin.x - DisplayObject(axis).width;
							DisplayObject(axis).y = _origin.y - axis.size;
							break;
						default:
							DisplayObject(axis).x = 0;
							DisplayObject(axis).y = 0;
							DisplayObject(axis).width = unscaledWidth;
							DisplayObject(axis).height = unscaledHeight;
							break;
					}
				}
			}	
			
			
			super.updateGuide(guide, unscaledWidth, unscaledHeight);
		}
		
		override protected function updateElement(element:IElement, unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateElement(element, unscaledWidth, unscaledHeight);
			// TODO update this!
			if (element.scale2)
			{
				element.scale2.size = Math.min(unscaledWidth, unscaledHeight)/2;
			}
			
			if ( element.scale1 is ISubScale) 
			{
				(element.scale1 as ISubScale).subScalesSize =  Math.min(unscaledWidth, unscaledHeight)/2;
			}
		}
			
			

		/** @Private
		 * Calculate the total of positive values to set in the percent axis and set it for each elements.*/
/* 		private function setPositiveTotalAngleValueInSeries():void
		{
			INumerableScale(scale1).totalPositiveValue = NaN;
			var tot:Number = NaN;
			for (var i:Number = 0; i<elements.length; i++)
			{
				currentElement = IElement(elements[i]);
				// check if the elements has its own y axis and if its max value exists and 
				// is higher than the current max
				if (!isNaN(currentElement.totalDim1PositiveValue))
				{
					if (isNaN(INumerableScale(scale1).totalPositiveValue))
						INumerableScale(scale1).totalPositiveValue = currentElement.totalDim1PositiveValue;
					else
						INumerableScale(scale1).totalPositiveValue = 
							Math.max(INumerableScale(scale1).totalPositiveValue, 
									currentElement.totalDim1PositiveValue);
				}
			}
		}
 */
		/**
		 * @inheritDoc
		 */
		override public function clone(cloneObj:Object=null):*
		{
			if (cloneObj && cloneObj is Polar)
			{
				var polClone:Polar = cloneObj as Polar;
				
				polClone.layout = _layout;
				polClone.type = _type;
				polClone.fontSize = _fontSize;
				
				return polClone;
			}
			else if (!cloneObj)
			{
				cloneObj = new Polar();
				cloneObj = super(cloneObj);
				return clone(cloneObj);
			}
			
			return null;
		}
	}
	
}