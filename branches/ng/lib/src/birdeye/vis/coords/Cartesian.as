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
	import birdeye.vis.guides.axis.Axis;
	import birdeye.vis.interfaces.*;
	import birdeye.vis.interfaces.guides.IAxis;
	import birdeye.vis.interfaces.guides.IGuide;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	/** A CartesianChart can be used to create any 2D or 3D cartesian charts available in the library
	 * apart from those who might have specific features, like stackable element or data-sizable items.
	 * Those specific features are managed directly by charts that extends the CartesianChart 
	 * (AreaChart, BarChart, ColumnChart for stackable element and ScatterPlot, BubbleChart for 
	 * data-sizable items.
	 * The CartesianChart serves as container for all axes and element and coordinates the different
	 * data loading and creation of each component.
	 * If a CartesianChart is provided with an axis, this axis will be shared by all element that have 
	 * not that same axis (x, y or z). In the same way, the CartesianChart provides a dataProvider property 
	 * that can be shared with element that have not a dataProvider. In case the CartesianChart dataProvider 
	 * is used along with some element dataProvider, than the relevant values defined be the element fields
	 * of all these dataProviders will define the axes (min, max for NumericAxis elements 
	 * for CategorScale2, etc).
	 * 
	 * A CartesianChart may have multiple and different type of element, multiple axes and 
	 * multiple dataProvider(s).
	 * Most of available cartesian charts are also 3D. If a element specifies the zField, than the chart will
	 * be a 3D chart. By default zAxis is placed at the bottom right of the chart, for this reason it's
	 * recommended to place Scale2 to the left of the chart when using 3D charts.
	 * Given the current 3D limitations of the FP platform, for which is not possible to draw
	 * real 3D graphics (moveTo, drawRect, drawLine etc don't include the z coordinate), the AreaChart 
	 * and LineChart are not 3D yet. 
	 * */ 
	[Exclude(name="elementsContainer", kind="property")]
	public class Cartesian extends BaseCoordinates implements ICoordinates
	{

		private var _is3D:Boolean = false;
		public function get is3D():Boolean
		{
			return _is3D;
		}

		// UIComponent flow

		public function Cartesian() 
		{
			super();
			coordType = VisScene.CARTESIAN;
		}
		
		private var leftContainer:Container, rightContainer:Container;
		private var topContainer:Container, bottomContainer:Container;
		private var zContainer:Container;
		/** @Private
		 * Crete and add all containers that define the chart structure.
		 * The elementsContainer will contain all chart elements. Remove scrolling and clip the content 
		 * to true for each of them.*/ 
		override protected function createChildren():void
		{
			super.createChildren();
			
			addChild(leftContainer = new HBox());
			addChild(rightContainer = new HBox());
			addChild(topContainer = new VBox());
			addChild(bottomContainer = new VBox());
			addChild(zContainer = new HBox());
			addChild(_elementsContainer);
						
			zContainer.verticalScrollPolicy = "off";
			zContainer.clipContent = false;
			zContainer.horizontalScrollPolicy = "off";
			zContainer.setStyle("horizontalAlign", "left");
			
			leftContainer.verticalScrollPolicy = "off";
			leftContainer.clipContent = false;
			leftContainer.horizontalScrollPolicy = "off";
			leftContainer.setStyle("horizontalAlign", "right");
			leftContainer.setStyle("horizontalGap", 0);
			leftContainer.setStyle("verticalGap", 0);

			rightContainer.verticalScrollPolicy = "off";
			rightContainer.clipContent = false;
			rightContainer.horizontalScrollPolicy = "off";
			rightContainer.setStyle("horizontalAlign", "left");
			rightContainer.setStyle("horizontalGap", 0);
			rightContainer.setStyle("verticalGap", 0);

			topContainer.verticalScrollPolicy = "off";
			topContainer.clipContent = false;
			topContainer.horizontalScrollPolicy = "off";
			topContainer.setStyle("verticalAlign", "bottom");
			topContainer.setStyle("horizontalGap", 0);
			topContainer.setStyle("verticalGap", 0);

			bottomContainer.verticalScrollPolicy = "off";
			bottomContainer.clipContent = false;
			bottomContainer.horizontalScrollPolicy = "off";
			bottomContainer.setStyle("horizontalGap", 0);
			bottomContainer.setStyle("verticalGap", 0);
			
		}
		
		override protected function placeGuide(guide:IGuide):void
		{
			if (guide.position == "sides")
			{
				if (guide is IAxis)
				{
					var axis:IAxis = guide as IAxis;
					switch (axis.placement)
					{
						case Axis.TOP:
							if(axis is DisplayObject && !topContainer.contains(DisplayObject(axis)) && !DisplayObject(axis).parent)
							{
								topContainer.addChild(DisplayObject(axis));
							}
							else
							{
								axis.targets.push(topContainer);
							}
							break; 
						case Axis.BOTTOM:
							if(axis is DisplayObject && !bottomContainer.contains(DisplayObject(axis)) && !DisplayObject(axis).parent)
							{
								bottomContainer.addChild(DisplayObject(axis));
							}
							else
							{
								axis.targets.push(bottomContainer);
							}
							break;
							
						case Axis.LEFT:
							if(axis is DisplayObject && !leftContainer.contains(DisplayObject(axis)) && !DisplayObject(axis).parent)
							{
								leftContainer.addChild(DisplayObject(axis));
							}
							else
							{
								axis.targets.push(leftContainer);
							}
							break;
						case Axis.RIGHT:
							if(axis is DisplayObject && !rightContainer.contains(DisplayObject(axis)) && !DisplayObject(axis).parent)
							{
								rightContainer.addChild(DisplayObject(axis));
							}
							else
							{
								axis.targets.push(rightContainer);
							}
							break;
					}
				}
			}
			else if (guide.position == "elements")
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
		}
		
		override protected function initElement(element:IElement, countStackableElements:Array):uint
		{
			var nCursors:uint = super.initElement(element, countStackableElements);

			var tmpScale3:IScale = element.scale3 as IScale;
			if (tmpScale3)
			{
					
				// this will be replaced by a depth property 
 				IScale(tmpScale3).size = width; 
 				// the Scale3 is in reality an Scale2 which is rotated of 90 degrees
 				// on its X coordinate. This will be replaced by a real z axis, when 
 				// FP will provide methods to draw real 3d lines
				zContainer.rotationX = -90;
				
				// this adjusts the positioning of the axis after the rotation
				zContainer.z = width;
				_is3D = true;
 			}
 			
 			return nCursors;
				
		}
			
		// other methods
		
		override protected function setBounds(unscaledWidth:Number, unscaledHeight:Number):void
		{
			leftContainer.move(0, topContainer.height);
			topContainer.move(leftContainer.width, 0);
			bottomContainer.move(leftContainer.width, unscaledHeight - bottomContainer.height);
			rightContainer.move(unscaledWidth - rightContainer.width, topContainer.height);

			chartBounds = new Rectangle(leftContainer.x + leftContainer.width, 
										topContainer.y + topContainer.height,
										unscaledWidth - (leftContainer.width + rightContainer.width),
										unscaledHeight - (topContainer.height + bottomContainer.height));
										
			topContainer.width = bottomContainer.width = chartBounds.width;

			leftContainer.setActualSize(leftContainer.width, chartBounds.height);
			rightContainer.setActualSize(rightContainer.width, chartBounds.height);			
			
			// the z container is placed at the right of the chart
  			zContainer.move(int(chartBounds.width + leftContainer.width), int(chartBounds.height));
				
			if (axesFeeded && 
				(_elementsContainer.x != chartBounds.x ||
				_elementsContainer.y != chartBounds.y ||
				_elementsContainer.width != chartBounds.width ||
				_elementsContainer.height != chartBounds.height))
			{
				_elementsContainer.move(chartBounds.x, chartBounds.y);
				_elementsContainer.setActualSize(chartBounds.width, chartBounds.height);
 	
				if (_is3D)
					rotationY = 42;
				else
					transform.matrix3D = null;
 			}
		}
		
		override protected function updateElement(element:IElement, unscaledWidth:Number, unscaledHeight:Number):void
		{
			Surface(element).width = chartBounds.width;
			Surface(element).height = chartBounds.height;
			
			var scale1:IScale = element.scale1;
			var scale2:IScale = element.scale2;
			
			if (scale1)
			{
				scale1.size = chartBounds.width;
			}
			
			if (scale2)
			{
				scale2.size = chartBounds.height;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateGuide(guide:IGuide, unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (guide is IAxis)
			{
				var axis:IAxis = guide as IAxis;
			
				switch (axis.placement)
				{
					case Axis.BOTTOM:
						axis.size = chartBounds.width;
						break;
					case Axis.TOP:
						axis.size = chartBounds.width;
						break;
					case Axis.LEFT:
						axis.size = chartBounds.height;
						break;
					case Axis.RIGHT:
						axis.size = chartBounds.height;
				}
			}
			
		}
		
		override protected function drawGuide(guide:IGuide, unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (guide is IAxis)
			{
				var axis:IAxis = guide as IAxis;
			
				switch (axis.placement)
				{
					case Axis.BOTTOM:
						axis.drawGuide(new Rectangle(0,0, bottomContainer.width, bottomContainer.height));
						break;
					case Axis.TOP:
						axis.drawGuide(new Rectangle(0,0, topContainer.width, topContainer.height));
						break;
					case Axis.LEFT:
						axis.drawGuide(new Rectangle(0,0, leftContainer.width, leftContainer.height));
						break;
					case Axis.RIGHT:
						axis.drawGuide(new Rectangle(0,0, rightContainer.width, rightContainer.height));
				}
							
			}
			else
			{
				guide.drawGuide(chartBounds);
			}
		}
		
		/** @Private
		 * Validate border containers sizes, that depend on the axes sizes that they contain.*/
		override protected function validateBounds(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// validate bounds logic has changed as axes are not always added to containers
			// they can draw to containers, without being added to them
			// so this logic is reformed to loop axes and not containers containing them
			var leftSize:Number = 0;
			var rightSize:Number = 0;
			var topSize:Number = 0;
			var bottomSize:Number = 0;
			
			for each (var guide:IGuide in guides)
			{
				if (guide is IAxis)
				{
					var axis:IAxis = guide as IAxis;
					var axisUI:UIComponent = guide as UIComponent;
										
					switch (axis.placement)
					{
						case Axis.BOTTOM:
							bottomSize += axisUI.minHeight;
							break;
						case Axis.TOP:
							topSize += axisUI.minHeight;
							break;
						case Axis.RIGHT:
							rightSize += axisUI.minWidth;
							break;
						case Axis.LEFT:
							leftSize += axisUI.minWidth;
							break;
					}
				}
			}
			
			leftContainer.width = leftSize;
			rightContainer.width = rightSize;
			bottomContainer.height = bottomSize;
			topContainer.height = topSize;
		}

		/**
		 * @inheritDoc
		 */
		override protected function removeAllElements():void
		{
			super.removeAllElements();
			var i:int; 
			var child:*;
			
			if (leftContainer)
			{
				for (i = 0; i<leftContainer.numChildren; i++)
				{
					child = leftContainer.getChildAt(0); 
					if (child is IAxis)
						IAxis(child).clearAll();
				}
				leftContainer.removeAllChildren();
			}

			if (rightContainer)
			{
				for (i = 0; i<rightContainer.numChildren; i++)
				{
					child = rightContainer.getChildAt(0); 
					if (child is IAxis)
						IAxis(child).clearAll();
				}
				rightContainer.removeAllChildren();
			}
			
			if (topContainer)
			{
				for (i = 0; i<topContainer.numChildren; i++)
				{
					child = topContainer.getChildAt(0); 
					if (child is IAxis)
						IAxis(child).clearAll();
				}
				topContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IAxis)
						IAxis(child).clearAll();
				}
				bottomContainer.removeAllChildren();
			}

			if (bottomContainer)
			{
				for (i = 0; i<bottomContainer.numChildren; i++)
				{
					child = bottomContainer.getChildAt(0); 
					if (child is IAxis)
						IAxis(child).clearAll();
				}
				bottomContainer.removeAllChildren();
			}

		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone(cloneObj:Object=null):*
		{
			if (cloneObj && cloneObj is Cartesian)
			{
				var cartClone:Cartesian = cloneObj as Cartesian;
				
				cartClone.collisionType = _collisionType;
				
				return cartClone;
			}
			else if (!cloneObj)
			{
				cloneObj = new Cartesian();
				cloneObj = super(cloneObj);
				return clone(cloneObj);
			}
			
			return null;
		}
	}
}