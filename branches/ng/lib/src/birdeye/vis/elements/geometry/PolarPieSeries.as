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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.ArcPath;
	import birdeye.vis.guides.renderers.CircleRenderer;
	import birdeye.vis.interfaces.IScale;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	
	import flash.text.TextFieldAutoSize;
	
	import mx.collections.CursorBookmark;

	public class PolarPieSeries extends PolarStackElement
	{
		private var _innerRadius:Number;
		public function set innerRadius(val:Number):void
		{
			_innerRadius = val;
			invalidateDisplayList();
		}
		
		private var _radiusLabelOffset:Number;
		public function set radiusLabelOffset(val:Number):void
		{
			_radiusLabelOffset = val;
			invalidateDisplayList();
		}		

		private var _plotRadius:Number = 10;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		[Inspectable(enumeration="overlaid,stacked100")]
		override public function set stackType(val:String):void
		{
			super.stackType = val;
		}
		
		public function PolarPieSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (_stackType != OVERLAID || _stackType != STACKED100)
				_stackType = STACKED100;

			if (! itemRenderer)
				itemRenderer = CircleRenderer;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawElement():void
		{
			var c:uint = 0;
			
			var dataFields:Array = [];

			var angle:Number, radius:Number = NaN;
			
			var startAngle:Number = 0; 
			
			var arcSize:Number = NaN;
			
			switch (_stackType)
			{
				case STACKED100:
					break;
				case OVERLAID:
					break;
			}
				
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			if (radiusScale)
			{
				radius = radiusScale.size;
				dataFields[1] = radiusField;
			} else if (polarChart.radiusScale) {
				radius = polarChart.radiusScale.size;
				dataFields[1] = radiusField;
			}
			
			var tmpRadius:Number = radius;
			if (_total>0)
			{
				_innerRadius = radius/_total * _stackPosition; 
				tmpRadius = _innerRadius + radius/_total * polarChart.columnWidthRate;
			}

			var arcCenterX:Number = polarChart.origin.x - radius;
			var arcCenterY:Number = polarChart.origin.y - radius;

			var wSize:Number, hSize:Number;
			wSize = hSize = radius*2;

			var aAxis:IScale;
			if (angleScale)
				aAxis = angleScale;
			else if (polarChart.angleScale)
				aAxis = polarChart.angleScale;

			dataFields[0] = angleField;

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				angle = aAxis.getPosition(cursor.current[angleField]);
				
				var xPos:Number = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius, polarChart.origin); 

				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
 				if (ttGG && _extendMouseEvents)
					gg = ttGG;
 				
				var arc:IGeometry;
				
				if (_innerRadius > tmpRadius)
					_innerRadius = tmpRadius;

				arc = new ArcPath(Math.max(0, _innerRadius), tmpRadius, startAngle, angle, polarChart.origin);
	
				var tempColor:int;
				
				if (colorField)
				{
					if (colorAxis)
					{
						colorFill = colorAxis.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					} else if (polarChart.colorAxis) {
						colorFill = polarChart.colorAxis.getPosition(cursor.current[colorField]);
						fill = new SolidFill(colorFill);
					}
				} else if (_colors)
				{
					if (c < _colors.length)
						fill = new SolidFill(_colors[c]);
					else
						fill = new SolidFill(_colors[_colors.length]);
					
					c++;
				} else if (randomColors)
				{
					tempColor = Math.random() * 255 * 255 * 255;
					arc.fill = new SolidFill(tempColor);
				}
				
				if (fill)
				{
					arc.fill = fill;
				}

				arc.stroke = stroke;

				gg.geometryCollection.addItemAt(arc,0); 
				
				if (labelField)
				{
					var xLlb:Number = xPos, yLlb:Number = yPos;
					if (!isNaN(_radiusLabelOffset))
					{
						xLlb = PolarCoordinateTransform.getX(startAngle + angle/2, tmpRadius + _radiusLabelOffset, polarChart.origin);
						yLlb = PolarCoordinateTransform.getY(startAngle + angle/2, tmpRadius + _radiusLabelOffset, polarChart.origin);
					}
					var label:RasterTextPlus = new RasterTextPlus();
					label.text = cursor.current[labelField];
					label.fontFamily = "verdana";
					label.fontWeight = "bold";
					label.autoSize = TextFieldAutoSize.LEFT;
					label.fill = new SolidFill(0x000000);
					label.x = xLlb- label.displayObject.width/2;
					label.y = yLlb - label.displayObject.height/2;
					gg.geometryCollection.addItem(label); 
				}

				startAngle += angle;

 				cursor.moveNext();
			}
			
			if (displayName && aAxis && aAxis.size < 360)
			{
				label = new RasterTextPlus();
				label.text = displayName;
				label.fontFamily = "verdana";
				label.fontWeight = "bold";
				label.autoSize = TextFieldAutoSize.LEFT;
				label.fill = new SolidFill(0x000000);
				label.x = PolarCoordinateTransform.getX(0, _innerRadius, polarChart.origin);
				label.y = PolarCoordinateTransform.getY(0, _innerRadius, polarChart.origin);
				gg.geometryCollection.addItem(label); 
			}
		}
	}
}