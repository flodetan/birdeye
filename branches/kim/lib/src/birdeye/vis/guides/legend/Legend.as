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
	import birdeye.vis.VisScene;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IElement;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	
	import mx.containers.Box;
	import mx.core.Application;
	import mx.core.IFactory;
	
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

		private var _items:Array; /* of LegendItem */
		/** Array of legend items, that can be added manually.*/
        [Inspectable(category="General", arrayType="birdeye.vis.guides.legend.LegendItem")]
        [ArrayElementType("birdeye.vis.guides.legend.LegendItem")]
		public function set items(val:Array):void
		{
			_items = val;
			for (var i:uint = 0; i<_items.length; i++)
				addChild(_items[i]);
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
					var child:Object = getChildAt(0);
					if (child is Surface && !(child is LegendItem))
					{
						for (var j:int = 0; j<Surface(child).numChildren; j++)
							Surface(child).removeChildAt(0);
	 					removeChildAt(0);
					}
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
						label.fill = new SolidFill(0xffffff);
					}

					var bounds:Rectangle = new Rectangle(0,0, 10,10);
					if (IElement(_dataProvider.elements[i]).itemRenderer && IElement(_dataProvider.elements[i]).displayName)
					{
/* 						var rendererClass:Class = IElement(_dataProvider.series[i]).itemRenderer;
						var renderer:IElementDataRenderer = new rendererClass();
 */
						var renderer:IFactory = IElement(_dataProvider.elements[i]).itemRenderer;

 						var geom:Geometry;
 						if (IElement(_dataProvider.elements[i]).source)
 						{
 							geom = new RasterRenderer(bounds, IElement(_dataProvider.elements[i]).source);
 						} else {
 							
 							geom = renderer.newInstance();
 							
 							if (geom is IBoundedRenderer) (geom as IBoundedRenderer).bounds = bounds;
 						}
						geom.fill = IElement(_dataProvider.elements[i]).getFill();
						geom.stroke = IElement(_dataProvider.elements[i]).getStroke();
						gg.geometryCollection.addItem(geom);

						var type:XML = describeType(geom);
						if (label.text && type.@name == "birdeye.vis.guides.renderers::TextRenderer")
						{
							label.fill = geom.fill;
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