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
	import birdeye.vis.guides.renderers.TextRenderer;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
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

		private var label:TextRenderer;
		private var plot:IGeometry;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout() && _invalidatedDisplay)
			{
				super.drawElement();
				removeAllElements();
				var dataFields:Array = [];
				// prepare data for a standard tooltip message in case the user
				// has not set a dataTipFunction
				dataFields[0] = dim1;
				dataFields[1] = dim2;
				dataFields[2] = sizeField;
				if (dim3) 
					dataFields[3] = dim3;
	
				var pos1:Number, pos2:Number, pos3:Number = NaN;
				
				if (!itemRenderer)
					itemRenderer = CircleRenderer;
				
				if (graphicsCollection.items && graphicsCollection.items.length>0)
					gg = graphicsCollection.items[0];
				else
				{
					gg = new DataItemLayout();
					graphicsCollection.addItem(gg);
				}
				gg.target = this;
				ggIndex = 1;
	
				cursor.seek(CursorBookmark.FIRST);
				while (!cursor.afterLast)
				{
					if (scale1)
					{
						pos1 = scale1.getPosition(cursor.current[dim1]);
					} 
					
					if (scale2)
					{
						pos2 = scale2.getPosition(cursor.current[dim2]);
					} 
	
					var scale2RelativeValue:Number = NaN;
	
					if (scale3)
					{
						pos3 = scale3.getPosition(cursor.current[dim3]);
						scale2RelativeValue = XYZ(scale3).height - pos3;
					} 
	
					if (multiScale)
					{
						pos1 = multiScale.scale1.getPosition(cursor.current[dim1]);
						pos2 = INumerableScale(multiScale.scales[
											cursor.current[multiScale.dim1]
											]).getPosition(cursor.current[dim2]);
					} else if (chart.multiScale) {
						pos1 = chart.multiScale.scale1.getPosition(cursor.current[dim1]);
						pos2 = INumerableScale(chart.multiScale.scales[
											cursor.current[chart.multiScale.dim1]
											]).getPosition(cursor.current[dim2]);
					}

					if (colorScale)
					{
						var col:* = colorScale.getPosition(cursor.current[colorField]);
						if (col is Number)
							fill = new SolidFill(col);
						else if (col is IGraphicsFill)
							fill = col;
					} 
	
					if (chart.coordType == VisScene.POLAR)
					{
						var xPos:Number = PolarCoordinateTransform.getX(pos1, pos2, chart.origin);
						var yPos:Number = PolarCoordinateTransform.getY(pos1, pos2, chart.origin);
						pos1 = xPos;
						pos2 = yPos; 
					}

					if (sizeScale)
					{
						_size = sizeScale.getPosition(cursor.current[sizeField]);
					}

					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(cursor.current, dataFields, pos1, pos2, scale2RelativeValue, _size);
	
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
					
	 				var bounds:Rectangle = new Rectangle(pos1 - _size, pos2 - _size, _size * 2, _size * 2);
	
					if (_extendMouseEvents)
						gg = ttGG;

					if (_size > 0)
					{
		 				if (_source)
							plot = new RasterRenderer(bounds, _source);
		 				else 
							plot = new itemRenderer(bounds);
		  				
						plot.fill = fill;
						plot.stroke = stroke;
						gg.geometryCollection.addItemAt(plot,0); 
					}

					if (labelField)
					{
						label = new TextRenderer(null);
						if (cursor.current[labelField])
							label.text = cursor.current[labelField];
						else
							label.text = labelField;
							
						label.fill = fill;
						label.fontSize = sizeLabel;
						label.fontFamily = fontLabel;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						label.x = pos1 - label.displayObject.width/2;
						label.y = pos2 - label.displayObject.height/2;
						ttGG.geometryCollection.addItemAt(label,0); 
					}

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

				_invalidatedDisplay = false;
			}
		}
	}
}