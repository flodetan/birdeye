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
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.elements.Position;
	import birdeye.vis.guides.renderers.LineRenderer;
	import birdeye.vis.interfaces.IBoundedRenderer;
	import birdeye.vis.interfaces.IPositionableElement;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	
	import flash.geom.Rectangle;
	
	public class EdgeElement extends BaseElement
	{
		public function EdgeElement()
		{
			super();
		}

		private var _dimStart:String;
		
		public function set dimStart(val:String):void
		{
			_dimStart = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get dimStart():String
		{
			return _dimStart;
		}

		private var _dimEnd:String;
		
		public function set dimEnd(val:String):void
		{
			_dimEnd = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get dimEnd():String
		{
			return _dimEnd;
		}

		private var _node:IPositionableElement;

		public function set node(val:IPositionableElement):void {
			_node = val;
			invalidateProperties();
			invalidateDisplayList();
		}

		protected function createItemRenderer(bounds:Rectangle):IGeometry {
			var renderer:IGeometry;
 			if (itemRenderer)
 			{
				renderer = itemRenderer.newInstance();
				if (renderer is IBoundedRenderer) (renderer as IBoundedRenderer).bounds = bounds;
 			}
 			else
			{
				renderer = new LineRenderer(bounds);
			}	
			renderer.fill = fill;
			renderer.stroke = stroke;
			return renderer;
		}

		private function bounds(x1:int, y1:int, x2:int, y2:int):Rectangle {
			return new Rectangle(x1, y1, x2, y2);
		}

		override public function drawElement():void {
			super.drawElement();
			
			prepareForItemGeometriesCreation();
			
			const dataItems = dataItems;
			
			if (dataItems){
				dataItems.forEach(function(item:Object, itemIndex:int, items:Vector.<Object>):void {
					var pos1:Number = NaN, pos2:Number = NaN, pos3:Number = NaN;
	
					const start:Position = _node.getItemPosition(item[_dimStart]);
					const end:Position = _node.getItemPosition(item[_dimEnd]);

					if (start  &&  end) {
						var group:GeometryGroup = createItemGeometryGroup();
						group.geometry = [
							createItemRenderer(bounds(start.pos1, start.pos2, end.pos1, end.pos2))
						];
					}
				});
			}
		}
	}
}
