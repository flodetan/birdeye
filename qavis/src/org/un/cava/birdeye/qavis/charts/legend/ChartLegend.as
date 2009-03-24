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
 
package org.un.cava.birdeye.qavis.charts.legend
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.containers.Box;
	import mx.core.Application;
	
	import org.un.cava.birdeye.qavis.charts.cartesianCharts.CartesianChart;
	import org.un.cava.birdeye.qavis.charts.interfaces.ICartesianSeries;
	
	[DefaultProperty("dataProvider")]
	public class ChartLegend extends Box
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
		
		private var _dataProvider:CartesianChart;
		public function set dataProvider(val:CartesianChart):void
		{
			_dataProvider = val;
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function ChartLegend()
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

				for (i = 0; i<_dataProvider.series.length; i++)
				{
					var surf:Surface = new Surface();
					var gg:GeometryGroup = new GeometryGroup();
					gg.target = surf;
					
					var label:RasterText = new RasterText();
					label.x = 15;
					if (ICartesianSeries(_dataProvider.series[i]).displayName)
						label.text = ICartesianSeries(_dataProvider.series[i]).displayName;

					var bounds:RegularRectangle = new RegularRectangle(0,0, 10,10);
					if (ICartesianSeries(_dataProvider.series[i]).itemRenderer)
					{
						var renderer:Class = ICartesianSeries(_dataProvider.series[i]).itemRenderer;
						var geom:Geometry = new renderer(bounds);
						Geometry(geom).fill = ICartesianSeries(_dataProvider.series[i]).fillColor ? 
								new SolidFill(ICartesianSeries(_dataProvider.series[i]).fillColor)
								 : new SolidFill(0xdddddd);
						geom.stroke = ICartesianSeries(_dataProvider.series[i]).strokeColor ?
								new SolidStroke(ICartesianSeries(_dataProvider.series[i]).strokeColor)
								 : new SolidStroke(0x999999);
						gg.geometryCollection.addItem(geom);
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