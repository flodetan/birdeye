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
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.interfaces.INumerableScale;
	import birdeye.vis.recipes.polarCharts.CoxComb;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.EllipticalArc;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class PolarColumnElement extends PolarStackElement
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarColumnElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (! itemRenderer)
				itemRenderer = UpTriangleRenderer;

			// doesn't need to call super.commitProperties(), since it doesn't need to listen
			// to axes interval changes 

			if (stackType == STACKED100 && cursor)
			{
				if (radiusAxis)
				{
					if (radiusAxis is INumerableScale)
						INumerableScale(radiusAxis).max = maxRadiusValue;
				} else if (polarChart && polarChart.radiusAxis && polarChart.radiusAxis is INumerableScale){
						INumerableScale(polarChart.radiusAxis).max = maxRadiusValue;
				} 
			}
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawElement():void
		{
			var dataFields:Array = [];
			var j:Object;

			var angle:Number, radius:Number, radius0:Number;
			
			var arcSize:Number = NaN;
			
			var angleInterval:Number;
			if (angleAxis) 
				angleInterval = angleAxis.interval * polarChart.columnWidthRate;
			else if (polarChart.angleAxis)
				angleInterval = polarChart.angleAxis.interval * polarChart.columnWidthRate;
			else if (radarAxis)
				angleInterval = radarAxis.angleAxis.interval * polarChart.columnWidthRate;
			else if (polarChart.radarAxis)
				angleInterval = polarChart.radarAxis.angleAxis.interval * polarChart.columnWidthRate;
				
			switch (_stackType)
			{
				case STACKED:
					arcSize = angleInterval/_total;
					break;
				case OVERLAID:
				case STACKED100:
					arcSize = angleInterval;
					break;
			}
				
			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (angleAxis)
				{
					angle = angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				} else if (polarChart.angleAxis) {
					angle = polarChart.angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				}
				
				j = cursor.current[angleField];
				// if the series has its own radius axis, than get the radius coordinate
				// position of the data value filtered by radiusField
				if (radiusAxis)
				{
					// if the stackType is stacked100, than the radius0 coordinate of 
					// the current baseValue is added to the radius coordinate of the current
					// data value filtered by radiusField
					if (_stackType == STACKED100)
					{
						radius0 = radiusAxis.getPosition(baseValues[j]);
						radius = radiusAxis.getPosition(
							baseValues[j] + Math.max(0,cursor.current[radiusField]));
					} else 
						// if not stacked, than the y coordinate is given by the own y axis
						radius = radiusAxis.getPosition(cursor.current[radiusField]);

					dataFields[1] = radiusField;
				} else {
					// if no own y axis than use the parent chart y axis to achive the same
					// as above
					if (_stackType == STACKED100)
					{
						radius0 = polarChart.radiusAxis.getPosition(baseValues[j]);
						radius = polarChart.radiusAxis.getPosition(
							baseValues[j] + Math.max(0,cursor.current[radiusField]));
					} else {
						radius = polarChart.radiusAxis.getPosition(cursor.current[radiusField]);
					}

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

				var arcCenterX:Number = polarChart.origin.x - radius;
				var arcCenterY:Number = polarChart.origin.y - radius;
				var startAngle:Number; 
				switch (_stackType) 
				{
					case STACKED:
						startAngle = angle - angleInterval/2 +arcSize*_stackPosition;
						break;
					case OVERLAID:
					case STACKED100:
						startAngle = angle - angleInterval/2;
						break;
				}
				var wSize:Number, hSize:Number;
				wSize = hSize = radius*2;

				var xPos:Number = PolarCoordinateTransform.getX(startAngle+arcSize/2, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(startAngle+arcSize/2, radius, polarChart.origin); 

				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
				if (ttGG && _extendMouseEvents)
					gg = ttGG;
					
				var arc:IGeometry;
				
				if (stackType == STACKED100)
					arc = 
						new ArcPath(Math.max(0, radius0), radius, startAngle, arcSize, polarChart.origin);
				else
					arc = 
						new EllipticalArc(arcCenterX, arcCenterY, wSize, hSize, startAngle, arcSize, "pie");

				arc.fill = fill;
				arc.stroke = stroke;
				gg.geometryCollection.addItemAt(arc,0); 

				if (_showItemRenderer)
				{
	 				var bounds:Rectangle = new Rectangle(xPos - _rendererSize/2, yPos - _rendererSize/2, _rendererSize, _rendererSize);
					var shape:IGeometry = new itemRenderer(bounds);
					shape.fill = fill;
					shape.stroke = stroke;
					gg.geometryCollection.addItem(shape);
				}
 				cursor.moveNext();
			}
		}

		override protected function getMaxValue(field:String):Number
		{
			var max:Number = super.getMaxValue(field);
			if (polarChart && polarChart is CoxComb && stackType == STACKED100) 
				max = Math.max(max, CoxComb(polarChart).maxStacked100);
				
			return max;
		}
	}
}