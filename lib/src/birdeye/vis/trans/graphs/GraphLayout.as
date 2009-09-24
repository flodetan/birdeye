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
 
package birdeye.vis.trans.graphs
{
	import birdeye.vis.elements.events.ElementDataItemsChangeEvent;
	import birdeye.vis.interfaces.elements.IEdgeElement;
	import birdeye.vis.interfaces.elements.IGraphLayoutableElement;
	import birdeye.vis.interfaces.transforms.IGraphLayout;
	import birdeye.vis.trans.graphs.data.DataItemsGraphDataProvider;
	import birdeye.vis.trans.graphs.layout.ILayoutAlgorithm;
	import birdeye.vis.trans.graphs.visual.IVisualNode;
	import birdeye.vis.trans.graphs.visual.VisualGraph;
	
	import flash.geom.Point;
	
	public class GraphLayout implements IGraphLayout
	{
		private var _rootNodeId:String;
		private var _graphId:String;
		private var _layouter:ILayoutAlgorithm;
		private var _visualGraph:VisualGraph;
		private var _nodeElement:IGraphLayoutableElement;
		private var _edgeElement:IEdgeElement;
		private var _animate:Boolean = true;
		private var _useIntegerPositions:Boolean;

		public function GraphLayout() {
		}
		
		public function get rootNodeId():String {
			return _rootNodeId;
		}

		public function set rootNodeId(id:String):void {
			_rootNodeId = id;
		}
		
		public function get graphId():String {
			return _graphId;
		}

		public function set graphId(id:String):void {
			_graphId = id;
		}
		
		public function get animate():Boolean {
			return _animate;
		}
		
		[Bindable]
		public function set animate(value:Boolean):void {
			_animate = value;
			if (_layouter) _layouter.disableAnimation = !_animate;
		}

		public function get visualGraph():VisualGraph {
			return _visualGraph;
		}
		
		public function set rootNode(val:IVisualNode):void
		{
			if (visualGraph)
				visualGraph.currentRootVNode = val;
		}
		 
		public function get layouter():ILayoutAlgorithm {
			return _layouter;
		}

		public function set layouter(layout:ILayoutAlgorithm):void {
			_layouter = layout;
			if (_layouter) _layouter.disableAnimation = !_animate;
		}

		public function set nodeElement(node:IGraphLayoutableElement):void {
			_nodeElement = node; 
			_nodeElement.addEventListener(ElementDataItemsChangeEvent.TYPE, nodeDataItemsChanged);
		}

		public function set edgeElement(edge:IEdgeElement):void {
			_edgeElement = edge;
			_edgeElement.addEventListener(ElementDataItemsChangeEvent.TYPE, edgeDataItemsChanged);
		}
		
		private function nodeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_visualGraph = null;
		}
		
		private function edgeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_visualGraph = null;
		}

		public function isNodeItemVisible(itemId:Object):Boolean {
			if (!_visualGraph) return false;
			return _visualGraph.isNodeVisible(String(itemId));
		}
		
		public function getNodeItemPosition(itemId:Object):Point {
			if (!_visualGraph) return null;
			return _visualGraph.getNodePosition(String(itemId));
		}

		protected function createVisualGraph(width:Number, height:Number):VisualGraph {
			var vg:VisualGraph;
			if (/*_graphId != null  && */ _nodeElement.dataItems) {
				vg = new VisualGraph(
					_graphId,
					_nodeElement, _edgeElement,
					new DataItemsGraphDataProvider(_nodeElement, _edgeElement),
					width, height
				);
				if (_rootNodeId !== null) {
 					vg.currentRootVNode = vg.getVisualNodeById(_rootNodeId);
 				}
 				vg.maxVisibleDistance = 1;
			}
			return vg;	
		}

		public function apply(width:Number, height:Number):void {
			if (!_visualGraph) {
				_visualGraph = createVisualGraph(width, height);
			}
			if (_visualGraph) {
				_visualGraph.layouter = layouter;
				_visualGraph.width = width;
				_visualGraph.height = height;
				layouter.vgraph = _visualGraph;
				layouter.layoutPass();
			}
		}

		public function resetLayout():void
		{
			_visualGraph = null;
		}
	}
}
