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
				if (scale2)
				{
					if (scale2 is INumerableScale)
						INumerableScale(scale2).max = maxDim2Value;
				} else if (polarChart && polarChart.scale2 && polarChart.scale2 is INumerableScale){
						INumerableScale(polarChart.scale2).max = maxDim2Value;
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
			if (scale1) 
				angleInterval = scale1.interval * polarChart.columnWidthRate;
			else if (polarChart.scale1)
				angleInterval = polarChart.scale1.interval * polarChart.columnWidthRate;
			else if (radarAxis)
				angleInterval = radarAxis.angleAxis.interval * polarChart.columnWidthRate;
			else if (polarChart.multiScale)
				angleInterval = polarChart.multiScale.angleAxis.interval * polarChart.columnWidthRate;
				
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
				if (scale1)
				{
					angle = scale1.getPosition(cursor.current[dim1]);
					dataFields[0] = dim1;
				} else if (polarChart.scale1) {
					angle = polarChart.scale1.getPosition(cursor.current[dim1]);
					dataFields[0] = dim1;
				}
				
				j = cursor.current[dim1];
				// if the series has its own radius axis, than get the radius coordinate
				// position of the data value filtered by dim2
				if (scale2)
				{
					// if the stackType is stacked100, than the radius0 coordinate of 
					// the current baseValue is added to the radius coordinate of the current
					// data value filtered by dim2
					if (_stackType == STACKED100)
					{
						radius0 = scale2.getPosition(baseValues[j]);
						radius = scale2.getPosition(
							baseValues[j] + Math.max(0,cursor.current[dim2]));
					} else 
						// if not stacked, than the y coordinate is given by the own y axis
						radius = scale2.getPosition(cursor.current[dim2]);

					dataFields[1] = dim2;
				} else if (polarChart.scale2) {
					// if no own y axis than use the parent chart y axis to achive the same
					// as above
					if (_stackType == STACKED100)
					{
						radius0 = polarChart.scale2.getPosition(baseValues[j]);
						radius = polarChart.scale2.getPosition(
							baseValues[j] + Math.max(0,cursor.current[dim2]));
					} else {
						radius = polarChart.scale2.getPosition(cursor.current[dim2]);
					}

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