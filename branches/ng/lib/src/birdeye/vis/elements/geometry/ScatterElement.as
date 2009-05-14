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
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.guides.renderers.*;
	import birdeye.vis.interfaces.IScatter;
	import birdeye.vis.interfaces.ISizableItem;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	[Exclude(name="maxRadiusValue", kind="property")]
	[Exclude(name="minRadiusValue", kind="property")]
	public class ScatterElement extends BaseElement implements IScatter 
	{
		private var _maxRadiusValue:Number = NaN;
		public function set maxRadiusValue(val:Number):void
		{
			_maxRadiusValue = val;
			invalidateDisplayList();
		}
		
		private var _minRadiusValue:Number = NaN;
		public function set minRadiusValue(val:Number):void
		{
			_minRadiusValue = val;
			invalidateDisplayList();
		}
		
		private var _radiusField:String;
		public function set radiusField(val:String):void
		{
			_radiusField = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get radiusField():String
		{
			return _radiusField;
		}
		
		public function ScatterElement()
		{
			super();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = CircleRenderer;
		}

		private var scatter:IGeometry;
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
				dataFields[2] = radiusField;
				if (dim3) 
					dataFields[3] = dim3;
	
				var xPos:Number, yPos:Number, zPos:Number = NaN;
				var dataValue:Number;
				var radius:Number;
				
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
						xPos = scale1.getPosition(cursor.current[dim1]);
					} else if (chart.scale1) {
						xPos = chart.scale1.getPosition(cursor.current[dim1]);
					}
					
					if (scale2)
					{
						yPos = scale2.getPosition(cursor.current[dim2]);
					} else if (chart.scale2) {
						yPos = chart.scale2.getPosition(cursor.current[dim2]);
					}
	
					dataValue = cursor.current[radiusField];
					radius = getRadius(dataValue);
	 				var bounds:Rectangle = new Rectangle(xPos - radius, yPos - radius, radius * 2, radius * 2);
	
					var scale2RelativeValue:Number = NaN;
	
					if (scale3)
					{
						zPos = scale3.getPosition(cursor.current[dim3]);
						scale2RelativeValue = XYZ(scale3).height - zPos;
					} else if (chart.scale3) {
						zPos = chart.scale3.getPosition(cursor.current[dim3]);
						// since there is no method yet to draw a real z axis 
						// we create an y axis and rotate it to properly visualize 
						// a 'fake' z axis. however zPos over this y axis corresponds to 
						// the axis height - zPos, because the y axis in Flex is 
						// up side down. this trick allows to visualize the y axis as
						// if it would be a z. when there will be a 3d line class, it will 
						// be replaced
						scale2RelativeValue = XYZ(chart.scale3).height - zPos;
					}
	
					// scale2RelativeValue is sent instead of zPos, so that the axis pointer is properly
					// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
					createTTGG(cursor.current, dataFields, xPos, yPos, scale2RelativeValue, 3);
	
					if (dim3)
					{
						if (!isNaN(zPos))
						{
							gg = new DataItemLayout();
							gg.target = this;
							graphicsCollection.addItem(gg);
							ttGG.z = gg.z = zPos;
						} else
							zPos = 0;
					}
					
					if (_extendMouseEvents)
						gg = ttGG;
						
	 				if (_source)
						scatter = new RasterRenderer(bounds, _source);
	 				else 
						scatter = new itemRenderer(bounds);
	  
					scatter.fill = fill;
					scatter.stroke = stroke;
					gg.geometryCollection.addItemAt(scatter,0);
					if (dim3)
					{
						gg.z = zPos;
						if (isNaN(zPos))
							zPos = 0;
					}
					cursor.moveNext();
				}
	
				if (dim3)
					zSort();
			}
		}
		
		private function getRadius(dataValue:Number):Number
		{
			var maxRadius:Number = 10;
			var minRadius:Number = 1;
			var radius:Number = 1;
			if (chart && chart is ISizableItem)
			{
				maxRadius = ISizableItem(chart).maxRadius;
				minRadius = ISizableItem(chart).minRadius;
				radius = minRadius + maxRadius * (dataValue - _minRadiusValue)/(_maxRadiusValue - _minRadiusValue);
			}
			
			return radius;
		}
	}
}