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
	import birdeye.vis.elements.collision.*;
	import birdeye.vis.guides.renderers.UpTriangleRenderer;
	import birdeye.vis.scales.*;
	import birdeye.vis.trans.projections.Projection;
	
	import com.degrafa.geometry.Polygon;
	
	import mx.collections.CursorBookmark;

	public class PolygonElement extends BaseElement
	{
		private var _targetLatProjection:Projection;
		public function set targetLatProjection(val:Projection):void {
			_targetLatProjection = val;
		}
		public function get targetLatProjection():Projection {
			return _targetLatProjection;
		}

		private var _targetLongProjection:Projection;
		public function set targetLongProjection(val:Projection):void {
			_targetLongProjection = val;
		}
		public function get targetLongProjection():Projection {
			return _targetLongProjection;
		}

		public function PolygonElement()
		{
			super();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			dim1 = dim2 = "no dim required";
			// select the item renderer (must be an IGeomentry)
			if (! itemRenderer)
				itemRenderer = UpTriangleRenderer;
		}

		protected var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the element is ready for layout.*/
		override public function drawElement():void
		{
			if (isReadyForLayout())
			{
				removeAllElements();
				var xPrev:Number, yPrev:Number;
				var pos1:Number, pos2:Number;
				var t:uint = 0;
				
				poly = new Polygon();
				poly.data = "";
	
				if (graphicsCollection.items && graphicsCollection.items.length>0)
					gg = graphicsCollection.items[0];
				else
				{
					gg = new DataItemLayout();
					graphicsCollection.addItem(gg);
				}
				gg.target = this;
				ggIndex = 1;
				
				// move data provider cursor at the beginning
				cursor.seek(CursorBookmark.FIRST);
				var pairs:Array;
				
				while (!cursor.afterLast)
				{
					pairs = cursor.current as Array;
					// if the Element has its own scale1, than get the pos1 coordinate
					// position of the data value filtered by dim1
					if (scale1)
						pos1 = scale1.getPosition(pairs);
					
					// if the Element has its own scale2, than get the pos2 coordinate
					// position of the data value filtered by dim2
					if (scale2)
						pos2 = scale2.getPosition(pairs);
					
					// create a separate GeometryGroup to manage interactivity and tooltips 
					createTTGG(cursor.current, [], pos1, pos2, NaN, 3);
					
					// create the polygon only if there is more than 1 data value
					// there cannot be an area with only the first data value 
					if (chart.coordType == VisScene.CARTESIAN)
						if (t++ > 0) 
						{
							poly = new Polygon()
							poly.data =  String(xPrev) + "," + String(yPrev) + " " +
										String(pos1) + "," + String(pos2) + " ";
							poly.fill = fill;
							poly.stroke = stroke;
							gg.geometryCollection.addItemAt(poly,0);
						}
					
					// store previous data values coordinates, to rely them 
					// to the next data value coordinates
					xPrev = pos1; yPrev = pos2;
					
					cursor.moveNext();
				}
			}
		}
	}
}