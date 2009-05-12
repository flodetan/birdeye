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
	import com.degrafa.IGeometry;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;
	
	import birdeye.vis.scales.PolarCoordinateTransform;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;

	public class PolarPointElement extends PolarElement
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarPointElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (! itemRenderer)
				itemRenderer = CircleRenderer;
		}

		private var plot:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawElement():void
		{
			var dataFields:Array = [];

			var ttShapes:Array;
			var ttXoffset:Number = NaN, ttYoffset:Number = NaN;
		
			var angle:Number, radius:Number;
			
			if (!itemRenderer)
				itemRenderer = CircleRenderer;
			
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
				} else if (polarChart.scale1) {
					angle = polarChart.scale1.getPosition(cursor.current[dim1]);
					dataFields[0] = dim1;
				}
				
				if (scale2)
				{
					radius = scale2.getPosition(cursor.current[dim2]);
					dataFields[1] = dim2;
				} else if (polarChart.scale2) {
					radius = polarChart.scale2.getPosition(cursor.current[dim2]);
					dataFields[1] = dim2;
				}

				if (radarAxis)
				{
					angle = radarAxis.angleAxis.getPosition(cursor.current[dim1]);
					radius = INumerableScale(radarAxis.radiusAxes[
										cursor.current[radarAxis.angleCategory]
										]).getPosition(cursor.current[dim2]);
					dataFields[0] = dim1;
					dataFields[1] = dim2;
				} else if (polarChart.multiScale) {
					angle = polarChart.multiScale.angleAxis.getPosition(cursor.current[dim1]);
					radius = INumerableScale(polarChart.multiScale.radiusAxes[
										cursor.current[polarChart.multiScale.angleCategory]
										]).getPosition(cursor.current[dim2]);
					dataFields[0] = dim1;
					dataFields[1] = dim2;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, polarChart.origin); 

				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
 				var bounds:Rectangle = new Rectangle(xPos - _plotRadius, yPos - _plotRadius, _plotRadius * 2, _plotRadius * 2);

 				if (_source)
					plot = new RasterRenderer(bounds, _source);
 				else 
					plot = new itemRenderer(bounds);

				plot.fill = fill;
				plot.stroke = stroke;
				gg.geometryCollection.addItemAt(plot,0); 
 				cursor.moveNext();
			}
		}
	}
}