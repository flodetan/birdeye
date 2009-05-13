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
				if (scale1)
				{
					angle = scale1.getPosition(cursor.current[dim1]);
					dataFields[0] = dim1;
				} else if (chart.scale1) {
					angle = chart.scale1.getPosition(cursor.current[dim1]);
					dataFields[0] = dim1;
				}
				
				if (scale2)
				{
					radius = scale2.getPosition(cursor.current[dim2]);
					dataFields[1] = dim2;
				} else if (chart.scale2) {
					radius = chart.scale2.getPosition(cursor.current[dim2]);
					dataFields[1] = dim2;
				}

				if (multiScale)
				{
					angle = multiScale.scale1.getPosition(cursor.current[dim1]);
					radius = INumerableScale(multiScale.scales[
										cursor.current[multiScale.dim1]
										]).getPosition(cursor.current[dim2]);
					dataFields[0] = dim1;
					dataFields[1] = dim2;
				} else if (chart.multiScale) {
					angle = chart.multiScale.scale1.getPosition(cursor.current[dim1]);
					radius = INumerableScale(chart.multiScale.scales[
										cursor.current[chart.multiScale.dim1]
										]).getPosition(cursor.current[dim2]);
					dataFields[0] = dim1;
					dataFields[1] = dim2;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, chart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, chart.origin); 

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