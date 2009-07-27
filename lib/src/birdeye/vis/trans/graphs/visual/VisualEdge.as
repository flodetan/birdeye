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

package birdeye.vis.trans.graphs.visual
{
	import birdeye.vis.trans.graphs.model.IEdge;
	
	import flash.display.DisplayObject;
	
	public class VisualEdge implements IVisualEdge
	{
		private var _edge:IEdge;
		private var _visible:Boolean;
		private var _visualGraph:IVisualGraph;

		public function VisualEdge(visualGraph:IVisualGraph, edge:IEdge)
		{
			_visualGraph = visualGraph;
			_edge = edge;
		}

		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(visible:Boolean):void
		{
			_visible = visible;
		}

		public function get edge():IEdge {
			return _edge;
		}
		
		public function get view():DisplayObject {
			return _visualGraph.getEdgeDisplayObject(_edge.id);
		}
	}
}
