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
	import birdeye.vis.elements.geometry.*;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.elements.IEdgeElement;
	import birdeye.vis.interfaces.elements.IElement;
	import birdeye.vis.interfaces.elements.IGraphLayoutableElement;
	import birdeye.vis.interfaces.transforms.IGraphLayout;
	import birdeye.vis.trans.graphs.layout.ILayoutAlgorithm;
	
	import flash.display.DisplayObject;
	
	import mx.core.IFactory;
	import mx.core.UIComponent;
	
	/** 
	 * The Abstract is the base coords that implements visualizations 
	 * that are not based on polar nor cartesian coordinates. 
	 * This includes Graph by applying specific layouts.
	 * 
	 * If a graph Layout is provided and there are one or more nodes elements that use it,
	 * the Abstract will feed the layout according the relevant information found in each element 
	 * that is using the specified layout.
	 * */ 
	public class Abstract extends VisScene implements ICoordinates
	{
		protected var _defaultLayout:ILayoutAlgorithm;
		/** It's possible to define a default layout for the abstract coords. If set, it will be used 
		 * for all elements that have not a layout defined.*/
		public function set layout(val:IFactory):void
		{
			_defaultLayout = val.newInstance();
			invalidateDisplayList();
		}

		public function Abstract()
		{
			super();
			coordType = VisScene.VISUAL;
			_elementsContainer = this;

		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			for each (var element:IElement in elements)
				addChild(DisplayObject(element));
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			resetLayouts();
			prepareLayouts();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (active)
			{
				super.updateDisplayList(unscaledWidth, unscaledHeight);			
				setActualSize(unscaledWidth, unscaledHeight);
				drawLayoutableElements();
			}
		}
		
		private var validatingLayouts:Array;
		protected function prepareLayouts():void
		{
			if (!transforms && !_defaultLayout) return;
			validatingLayouts = [];
			for each (var element:IElement in elements)
			{
				if (element is IGraphLayoutableElement)
				{
					var edgeEle:IEdgeElement = IGraphLayoutableElement(element).edgeElement;
					var nodeEle:IGraphLayoutableElement = IGraphLayoutableElement(element);
					validatingLayouts.push({
						node: nodeEle,
						edge: edgeEle,
						layout: nodeEle.graphLayout
					});
					if (edgeEle)
						edgeEle.nodeElement = nodeEle;
				}
			}
			layoutsFeeded = true;
		}
		
		private function resetLayouts():void
		{
			for each (var layout:IGraphLayout in graphLayouts)
				if (layout is IGraphLayout)
					(layout as IGraphLayout).resetLayout();
		}
		
		private function drawLayoutableElements():void
		{
			for each (var validLayout:Object in validatingLayouts)
			{
 				var nodeElement:IGraphLayoutableElement = validLayout.node as IGraphLayoutableElement;
 				UIComponent(nodeElement).setActualSize(width, height);
				//nodeElement.draw();
 
			}

		}
	}
}