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
 
package birdeye.vis.elements.geometry
{
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.guides.renderers.DiamondRenderer;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Polygon;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class PolarAreaElement extends PolarElement
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarAreaElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (! itemRenderer)
				itemRenderer = DiamondRenderer;
		}

		protected var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawElement():void
		{
			var dataFields:Array = [];
			var items:Array = [];

			poly = new Polygon();
			poly.data = "";

			var angle:Number, radius:Number;

			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (angleScale)
				{
					angle = angleScale.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				} else if (polarChart.angleScale) {
					angle = polarChart.angleScale.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				}
				
				if (radiusScale)
				{
					radius = radiusScale.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				} else if (polarChart.radiusScale) {
					radius = polarChart.radiusScale.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				}

				if (radarAxis)
				{
					angle = radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = INumerableScale(radarAxis.radiusAxes[
										cursor.current[radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				} else if (polarChart.radarAxis) {
					angle = polarChart.radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = INumerableScale(polarChart.radarAxis.radiusAxes[
										cursor.current[polarChart.radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, polarChart.origin); 

				// if showdatatips than create a new GeometryGroup and set its 
				// tooltip along with the hit area and events
				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
				items.push(cursor.current);

				poly.data += String(xPos) + "," + String(yPos) + " ";

 				cursor.moveNext();
			}
			
			if (poly.data)
			{
				poly.fill = fill;
				poly.stroke = stroke;
				gg.geometryCollection.addItem(poly);
			}

			if (_showItemRenderer)
			{
 				var bounds:Rectangle = new Rectangle(xPos - _rendererSize/2, yPos - _rendererSize/2, _rendererSize, _rendererSize);
				var shape:IGeometry = new itemRenderer(bounds);
				shape.fill = fill;
				shape.stroke = stroke;
				gg.geometryCollection.addItem(shape);
			}
		}
	}
}