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
	import birdeye.vis.interfaces.data.IExportableSVG;
	import birdeye.vis.interfaces.elements.IElement;
	import birdeye.vis.interfaces.renderers.IBoundedRenderer;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	
	import mx.containers.Box;
	import mx.core.Application;
	import mx.core.IFactory;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	public class Legend extends Box
	{
		private var _svgData:String;
		public function get svgData():String
		{
			_svgData = "";
			var child:Object;
			var localOriginPoint:Point = localToGlobal(new Point(x, y)); 
			for (var i:uint = 0; i<numChildren; i++)
			{
				child = getChildAt(i);
				var ggOriginPoint:Point = localToGlobal(new Point(child.x, child.y)); 
				if (child is LegendItem)
					_svgData += LegendItem(child).svgData
				else if (child is IExportableSVG)
					_svgData += '<svg x="' + String(ggOriginPoint.x) +
									'" y="' + String(ggOriginPoint.y) + '">' + 
									'\n<g style="' +
									'fill: #000000' + 
									';fill-opacity: 1' + 
									';stroke: #000000' + 
									';stroke-opacity: 1;">' + 
									IExportableSVG(child).svgData + 
									'\n</g>' + 
								'</svg>';
				else if (child is Surface)
				{
					for (var j:int = 0; j<Surface(child).numChildren; j++)
					{
						var geomGroup:Object = Surface(child).getChildAt(j);
						if (geomGroup is GeometryGroup)
							for each (var graphicItem:Object in GeometryGroup(geomGroup).geometry)
							{
								ggOriginPoint = localToGlobal(new Point(child.x, child.y)); 
								if (graphicItem is IExportableSVG)
									_svgData += '<svg x="' + String(ggOriginPoint.x) +
													'" y="' + String(ggOriginPoint.y) + '">' + 
													'\n<g style="' +
													'fill: #000000' + 
													';fill-opacity: 1' + 
													';stroke: #000000' + 
													';stroke-opacity: 1;">' + 
													IExportableSVG(graphicItem).svgData + 
													'\n</g>' + 
												'</svg>';
							}
					}
				}
			}
			return _svgData;
		}

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
		
		private var surf:Surface;
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
					surf = new Surface();
					var gg:GeometryGroup = new GeometryGroup();
					gg.target = surf;
					
					var label:TextRenderer = new TextRenderer(15);
					label.fontSize = sizeLabel;
					label.fontFamily = fontLabel;

					if (IElement(_dataProvider.elements[i]).displayName)
					{
						label.text = IElement(_dataProvider.elements[i]).displayName;
						label.fill = new SolidFill(colorLabel);
					}

					var bounds:Rectangle = new Rectangle(0,0, 10,10);
					if (IElement(_dataProvider.elements[i]).graphicRenderer && IElement(_dataProvider.elements[i]).displayName)
					{
/* 						var rendererClass:Class = IElement(_dataProvider.series[i]).itemRenderer;
						var renderer:IElementDataRenderer = new rendererClass();
 */
						var renderer:IFactory = IElement(_dataProvider.elements[i]).graphicRenderer;

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
		
		private var stylesChanged:Boolean = false;
		initializeStyles();
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("Legend");
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			selector.defaultFactory = function():void
			{
				this.labelFont = "verdana";
				this.labelSize = 10;
				this.labelColor = 0xffffff;

					this.stylesChanged = true;
			} 
			StyleManager.setStyleDeclaration("Legend", selector, true);
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);

			
			if (styleProp == "labelFont" || styleProp == null)
			{
				if (!fontLabel && getStyle("labelFont") != this.fontLabel && getStyle("labelFont") != undefined)
				{
					this.fontLabel = getStyle("labelFont");
				}
			}
			
			if (styleProp == "labelColor" || styleProp == null)
			{
				if (isNaN(colorLabel) && getStyle("labelColor") != this.colorLabel && getStyle("labelColor") != undefined)
				{
					this.colorLabel = getStyle("labelColor");
				}
			}
			
			if (styleProp == "labelSize" || styleProp == null)
			{
				if (isNaN(sizeLabel) && getStyle("labelSize") != this.sizeLabel && getStyle("labelSize") != undefined)
				{
					this.sizeLabel = getStyle("labelSize");
				}
			}

		}
		
		protected var _fontLabel:String;
		/** Set the font label to be used for the axis.*/
		public function set fontLabel(val:String):void
		{
			_fontLabel = val;
			invalidateDisplayList();
		}
		public function get fontLabel():String
		{
			return _fontLabel;
		}
		
				protected var _sizeLabel:Number = NaN;
		/** Set the font size of the label to be used for the axis.*/
		public function set sizeLabel(val:Number):void
		{
			_sizeLabel = val;
			invalidateDisplayList();
		}
		public function get sizeLabel():Number
		{
			return _sizeLabel;
		}

		protected var _colorLabel:Number = NaN;
		/** Set the label color to be used for the axis.*/
		public function set colorLabel(val:Number):void
		{
			_colorLabel = val;
			invalidateDisplayList();
		}
		public function get colorLabel():Number
		{
			return _colorLabel;
		}
	}
}