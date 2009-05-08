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
 
package birdeye.vis.guides.legend
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Box;
	import mx.core.Application;
	
	import birdeye.vis.VisScene;
	import birdeye.vis.interfaces.IElement;
	import birdeye.vis.guides.renderers.RasterRenderer;
	
	public class Legend extends Box
	{
		private var _legendTitle:String;
		public function set legendTitle(val:String):void
		{
			_legendTitle = val;
		}
		
		private var _legendOrientation:String = "vertical";
		public function set legendOrientation(val:String):void
		{
			_legendOrientation = val;
		}
		
		private var _legendField:String;
		public function set legendField(val:String):void
		{
			_legendField= val;
		}
		
		private var _dataProvider:VisScene;
		public function set dataProvider(val:VisScene):void
		{
			_dataProvider = val;
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function Legend()
		{
			super();
			
			verticalScrollPolicy = "off";
			clipContent = false;
			horizontalScrollPolicy = "off";
			Application.application.addEventListener("ProviderReady",createLegend,true);
		}
		
		private function createLegend(e:Event):void
		{
			if (e.target == _dataProvider)
			{
				var nC:Number = numChildren;
				for (var i:Number = 0; i<nC; i++)
				{
					if (getChildAt(0) is Surface)
						for (var j:int = 0; j<Surface(getChildAt(0)).numChildren; j++)
							Surface(getChildAt(0)).removeChildAt(0);
 					removeChildAt(0);
				}

				for (i = 0; i<_dataProvider.elements.length; i++)
				{
					var surf:Surface = new Surface();
					var gg:GeometryGroup = new GeometryGroup();
					gg.target = surf;
					
					var label:RasterTextPlus = new RasterTextPlus();
					label.fontFamily = "verdana";
					label.x = 15;

					if (IElement(_dataProvider.elements[i]).displayName)
					{
						label.text = IElement(_dataProvider.elements[i]).displayName;
						label.fill = new SolidFill(0x000000);
					}

					var bounds:Rectangle = new Rectangle(0,0, 10,10);
					if (IElement(_dataProvider.elements[i]).itemRenderer && IElement(_dataProvider.elements[i]).displayName)
					{
/* 						var rendererClass:Class = IElement(_dataProvider.series[i]).itemRenderer;
						var renderer:IElementDataRenderer = new rendererClass();
 */
						var renderer:Class = IElement(_dataProvider.elements[i]).itemRenderer;

 						var geom:Geometry;
 						if (IElement(_dataProvider.elements[i]).source)
 						{
 							geom = new RasterRenderer(bounds, IElement(_dataProvider.elements[i]).source);
 						} else {
 							geom = new renderer(bounds);
 						}
						Geometry(geom).fill = IElement(_dataProvider.elements[i]).getFill() != null ? 
								IElement(_dataProvider.elements[i]).getFill()
								 : new SolidFill(0xdddddd);
						geom.stroke = IElement(_dataProvider.elements[i]).getStroke() != null ?
								IElement(_dataProvider.elements[i]).getStroke() 
								 : new SolidStroke(0x999999);
						gg.geometryCollection.addItem(geom);

						if (label.text && getQualifiedClassName(renderer) == 
								"birdeye.vis.guides.renderers::TextRenderer")
						{
							label.fill = Geometry(geom).fill;
						}
					}

					if (label.text)
						gg.geometryCollection.addItem(label);
						
					if (geom || label.text)
					{
						surf.graphicsCollection.addItem(gg);
						surf.width = Rectangle(surf.getBounds(surf)).width;
						surf.height = Rectangle(surf.getBounds(surf)).height;
						addChild(surf);
					}
				}
				
				// create/add legend items					
			}
		}
	}
}