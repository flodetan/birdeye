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
	import birdeye.vis.VisScene;
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.guides.renderers.RasterRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class PointElement extends BaseElement
	{
		public function PointElement()
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
		override public function drawElement():void
		{
			if (isReadyForLayout())
			{
				removeAllElements();
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim1;
				dataFields[1] = dim2;
				if (dim3) 
					dataFields[2] = dim3;
	
				var pos1:Number, pos2:Number, pos3:Number = NaN;
				
				if (!itemRenderer)
					itemRenderer = CircleRenderer;
				
				if (ggElements && ggElements.length>0)
					gg = ggElements[0];
				else
				{
					gg = new DataItemLayout();
					gg.target = this;
					graphicsCollection.addItem(gg);
				}
				ggIndex = 1;
	
				cursor.seek(CursorBookmark.FIRST);
				while (!cursor.afterLast)
				{
					if (scale1)
					{
						pos1 = scale1.getPosition(cursor.current[dim1]);
					} else if (chart.scale1) {
						pos1= chart.scale1.getPosition(cursor.current[dim1]);
					}
					
					if (scale2)
					{
						pos2 = scale2.getPosition(cursor.current[dim2]);
					} else if (chart.scale2) {
						pos2 = chart.scale2.getPosition(cursor.current[dim2]);
					}
	
					var scale2RelativeValue:Number = NaN;
	
					if (scale3)
					{
						pos3 = scale3.getPosition(cursor.current[dim3]);
						scale2RelativeValue = XYZ(scale3).height - pos3;
					} else if (chart.scale3) {
						pos3 = chart.scale3.getPosition(cursor.current[dim3]);
						// since there is no method yet to draw a real z axis 
						// we create an y axis and rotate it to properly visualize 
						// a 'fake' z axis. however zPos over this y axis corresponds to 
						// the axis height - zPos, because the y axis in Flex is 
						// up side down. this trick allows to visualize the y axis as
						// if it would be a z. when there will be a 3d line class, it will 
						// be replaced
						scale2RelativeValue = XYZ(chart.scale3).height - pos3;
					}
	
					if (colorAxis)
					{
						colorFill = colorAxis.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					} else if (chart.colorAxis) {
						colorFill = chart.colorAxis.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					}
	
					if (chart.coordType == VisScene.POLAR)
					{
						var xPos:Number = PolarCoordinateTransform.getX(pos1, pos2, chart.origin);
						var yPos:Number = PolarCoordinateTransform.getY(pos1, pos2, chart.origin);
						pos1 = xPos;
						pos2 = yPos; 
					}
	
					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(cursor.current, dataFields, pos1, pos2, scale2RelativeValue, _plotRadius);
	
					if (dim3)
					{
						if (!isNaN(pos3))
						{
							gg = new DataItemLayout();
							gg.target = this;
							graphicsCollection.addItem(gg);
							ttGG.z = gg.z = pos3;
						} else
							pos3 = 0;
					}
					
	 				var bounds:Rectangle = new Rectangle(pos1 - _plotRadius, pos2 - _plotRadius, _plotRadius * 2, _plotRadius * 2);
	
	 				if (_source)
						plot = new RasterRenderer(bounds, _source);
	 				else 
						plot = new itemRenderer(bounds);
	  				
					plot.fill = fill;
					plot.stroke = stroke;
					gg.geometryCollection.addItemAt(plot,0); 
					if (dim3)
					{
						gg.z = pos3;
						if (isNaN(pos3))
							pos3 = 0;
					}
	 				cursor.moveNext();
				}
				
				if (dim3)
					zSort();
			}
		}
	}
}