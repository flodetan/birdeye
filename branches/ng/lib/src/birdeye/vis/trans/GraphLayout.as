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
 
package birdeye.vis.trans
{
	import birdeye.events.ElementDataItemsChangeEvent;
	import birdeye.vis.elements.Position;
	import birdeye.vis.interfaces.IEdgeElement;
	import birdeye.vis.interfaces.IGraphLayout;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	import birdeye.vis.trans.graphs.data.DataItemsGraphDataProvider;
	import birdeye.vis.trans.graphs.layout.CircularLayouter;
	import birdeye.vis.trans.graphs.layout.ConcentricRadialLayouter;
	import birdeye.vis.trans.graphs.layout.ForceDirectedLayouter;
	import birdeye.vis.trans.graphs.layout.HierarchicalLayouter;
	import birdeye.vis.trans.graphs.layout.Hyperbolic2DLayouter;
	import birdeye.vis.trans.graphs.layout.ILayoutAlgorithm;
	import birdeye.vis.trans.graphs.layout.ParentCenteredRadialLayouter;
	import birdeye.vis.trans.graphs.visual.VisualGraph;
	
	import flash.utils.Dictionary;
	
	public class GraphLayout implements IGraphLayout
	{
		public static const SINGLE_CYCLE:String = "single-cycle";
		public static const CONCENTRIC:String = "concentric";
		public static const PARENT_CENTERED:String = "parent-centered";
		public static const FORCE:String = "force";
		public static const HYPERBOLIC:String = "hyperbolic";
		public static const TREE:String = "tree";

		private var _startNodeId:String;
		private var _graphId:String;
		private var _layouter:ILayoutAlgorithm;
		private var _visualGraph:VisualGraph;
		private var _type:String;
		private var _nodeElement:IGraphLayoutableElement;
		private var _edgeElement:IEdgeElement;

		public function GraphLayout() {
		}
		
		public function get startNodeId():String {
			return _startNodeId;
		}

		public function set startNodeId(id:String):void {
			_startNodeId = id;
		}
		
		public function get graphId():String {
			return _graphId;
		}

		public function set graphId(id:String):void {
			_graphId = id;
		}

		[Inspectable(defaultValue = "single-cycle",
					 enumeration = "single-cycle,concentric,parent-centered,force,hyperbolic,tree")]
		public function set type(val:String):void {
			_type = val;
			_layouter = null;
		}

		public function get type():String {
			return _type;
		}
		 
		protected function get visualGraph():VisualGraph {
			return _visualGraph;
		}
		 
		protected function get layouter():ILayoutAlgorithm {
			if (!_layouter)
				_layouter = createLayouter();
			return _layouter;
		}

		protected function createLayouter():ILayoutAlgorithm {
			var layouter:ILayoutAlgorithm = null;
			switch (_type) {
				case SINGLE_CYCLE: layouter = new CircularLayouter(visualGraph); break;				 
				case CONCENTRIC:
					const cl:ConcentricRadialLayouter = new ConcentricRadialLayouter(visualGraph);
					cl.linkLength = 75;
					layouter = cl;
					break;				 
				case FORCE:
					const fl:ForceDirectedLayouter = new ForceDirectedLayouter(visualGraph);
//					fl.autoFitEnabled = true;
//					fl.dampingActive = false;
//					fl.linkLength = 75;
					layouter = fl;
					break;				 
				case PARENT_CENTERED:
					const pl: ParentCenteredRadialLayouter = new ParentCenteredRadialLayouter(visualGraph);
					pl.linkLength = 15;
					layouter = pl;
					break;				 
				case HYPERBOLIC: layouter = new Hyperbolic2DLayouter(visualGraph); break;				 
				case TREE:
					const hl: HierarchicalLayouter = new HierarchicalLayouter(visualGraph);
//					hl.enableSiblingSpread = false;
					hl.autoFitEnabled = true;
//					hl.breadth = 40;
//					hl.layerMargin = 40;
//					hl.honorNodeSize = true;
//					hl.siblingSpreadDistance = 100;
					layouter = hl;
					break;
			}
			layouter.disableAnimation = true;
			return layouter;
		}

		public function set applyToNode(node:IGraphLayoutableElement):void {
			node.graphLayout = this;
			_nodeElement = node; 
			_visualGraph = null;
			_nodeElement.addEventListener(ElementDataItemsChangeEvent.TYPE, nodeDataItemsChanged);
		}

		public function set applyToEdge(edge:IEdgeElement):void {
			_edgeElement = edge;
			_visualGraph = null;
			_edgeElement.addEventListener(ElementDataItemsChangeEvent.TYPE, edgeDataItemsChanged);
		}
		
		private function nodeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_visualGraph = null;
			_layouter = null;
		}
		
		private function edgeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_visualGraph = null;
			_layouter = null;
		}

		public function isNodeItemVisible(itemId:Object):Boolean {
			if (!_visualGraph) return null;
			return _visualGraph.isNodeVisible(String(itemId));
		}
		
		public function getNodeItemPosition(itemId:Object):Position {
			if (!_visualGraph) return null;
			return _visualGraph.getNodePosition(String(itemId));
		}

		protected function createVisualGraph(width:Number, height:Number):VisualGraph {
			var vg:VisualGraph;
			if (_graphId != null  &&  _nodeElement.dataItems   &&  _edgeElement.dataItems) {
				vg = new VisualGraph(
					_graphId,
					_nodeElement, _edgeElement,
					new DataItemsGraphDataProvider(_nodeElement, _edgeElement),
					width, height
				);
				if (_startNodeId !== null) {
 					vg.currentRootVNode = vg.getVisualNodeById(_startNodeId);
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
				layouter.layoutPass();
			}
		}

	}
}
