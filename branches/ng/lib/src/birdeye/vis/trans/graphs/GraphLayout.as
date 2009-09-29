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
	import __AS3__.vec.Vector;
	
	import birdeye.vis.elements.events.ElementDataItemsChangeEvent;
	import birdeye.vis.interfaces.elements.IEdgeElement;
	import birdeye.vis.interfaces.elements.IGraphLayoutableElement;
	import birdeye.vis.interfaces.transforms.IGraphLayout;
	import birdeye.vis.trans.graphs.data.DataItemsGraphDataProvider;
	import birdeye.vis.trans.graphs.layout.ILayoutAlgorithm;
	import birdeye.vis.trans.graphs.layout.IterativeBaseLayouter;
	import birdeye.vis.trans.graphs.model.Graph;
	import birdeye.vis.trans.graphs.model.IEdge;
	import birdeye.vis.trans.graphs.model.IGraph;
	import birdeye.vis.trans.graphs.model.INode;
	import birdeye.vis.trans.graphs.visual.IVisualEdge;
	import birdeye.vis.trans.graphs.visual.IVisualNode;
	import birdeye.vis.trans.graphs.visual.VisualEdge;
	import birdeye.vis.trans.graphs.visual.VisualNode;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	
	public class GraphLayout implements IGraphLayout
	{
		private static const logger:ILogger = Log.getLogger("birdeye.vis.trans.graphs.GraphLayout");

		private var _width:Number;
		private var _height:Number;		
		private var _layouter:ILayoutAlgorithm;
		private var _graph:IGraph;
		private var _origin:Point;

		private var _visualNodes:Vector.<VisualNode>;
		private var _visualEdges:Vector.<VisualEdge>;
		private var _visualIdsToNodes:Dictionary;

		private var _rootNodeId:String;
		private var _graphId:String;
		private var _nodeElement:IGraphLayoutableElement;
		private var _edgeElement:IEdgeElement;
		private var _animate:Boolean = true;

		/**
		 * This object hash contains all node ids 
		 * of nodes which are currently within the visible
		 * distance limit. This hash is typically initialised from
		 * from the Graph object. These nodes are NOT all
		 * visible nodes (since the history nodes are also
		 * visible).
		 * */
		private var _nodeIDsWithinDistanceLimit:Dictionary;
		
		/**
		 * This object contains the previuos hash of nodes
		 * within the distance. To keep this helps to avoid
		 * running through all nodes to render the olds
		 * invisible and the new ones visible.
		 * */
		private var _prevNodeIDsWithinDistanceLimit:Dictionary;
		
		/**
		 * This is the number of nodes within the distance limit.
		 **/
		private var _noNodesWithinDistance:uint;
		
		private var _maxVisibleDistance:int = 1;

		/**
		 * This property controls if any visibility limit is currently
		 * active at all. Strongly recommended for large graphs.
		 * The application will be brought to its knees if thousands of nodes
		 * should be displayed. 
		 * */
		private var _visibilityLimitActive:Boolean = true;

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

		public function set rootNode(val:IVisualNode):void
		{
			currentRootVNode = val;
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
		
		/**
		 * This is the current focused / root node. It will be
		 * used as the root for any tree computations and
		 * currently all layouters depend on this.
		 * Typically the root node is selected by double-click.
		 * */
		protected var _currentRootVNode:IVisualNode = null;
	
		/**
		 * This hash keeps track of all the past root VNodes
		 * thus being the history. If showHistory is enabled,
		 * these nodes are also visible even if they are outside
		 * the visible distance.
		 * */
		protected var _currentVNodeHistory:Array = new Array();

		/**
		 * @inheritDoc
		 * */
		[Bindable]
		public function get currentRootVNode():IVisualNode {
			return _currentRootVNode;
		}
		
		/**
		 * @private
		 * */
		public function set currentRootVNode(vn:IVisualNode):void {
			/* check for a change */
			if(_currentRootVNode != vn) {
				
				/* apply the change */
				_currentRootVNode = vn;

				/* now update the history with the new node */
				_currentVNodeHistory.unshift(_currentRootVNode);
			}
		}
		
		public function set maxVisibleDistance(maxDist:int):void {
			/* check if there was a change */
			if(_maxVisibleDistance != maxDist) {
				/* if yes, apply the change */
				_maxVisibleDistance = maxDist;
				//LogUtil.debug(_LOG, "visible distance changed to: "+md);
				
				/* if our current limits are active we create a new
				 * set of nodes within the distance and update the
				 * visibility */
				if(_visibilityLimitActive) {
					if(_currentRootVNode == null) {
						logger.warn("No root selected, not creating limited graph");
						return;
					} else {
						setDistanceLimitedNodeIds(_graph.getTree(_currentRootVNode.node).
							getLimitedNodes(_maxVisibleDistance));
					}
				}
			}
		}

		public function get maxVisibleDistance():int {
			return _maxVisibleDistance;
		}
		
		/** 
		 * 1. saves the old nodeID hash object.
		 * 2. sets the new _nodeIDsWithinDistanceLimit Object from the object
		 *    provided (typically provided from the GTree of a Graph).
		 * 3. updates the amount of nodes in that object, by linearly
		 *    counting them. This may be optimized...
		 * @param vnids Object containing a hash with all node id's currently within the distance limit.
		 * */
		protected function setDistanceLimitedNodeIds(vnids:Dictionary):void {
			var val:Boolean;
			var amount:uint;
			var vn:IVisualNode;
			var n:INode;
			
			/* reset the amount */
			amount = 0;
			
			/* save the old hash */
			_prevNodeIDsWithinDistanceLimit = _nodeIDsWithinDistanceLimit;
			
			/* set the new hash object */
			_nodeIDsWithinDistanceLimit = new Dictionary;
			
			/* walk through the hash and build the distanceLimit hash */
			for each(n in vnids) {
				vn = n.vnode;
				_nodeIDsWithinDistanceLimit[vn] = vn;
				
				/* increase the amount */
				++amount;
			}
		
			/* count all entries in this hash */
			for each(val in vnids) {
				if(val) {
					++amount;
				}
			}
			/* set the new amount */
			_noNodesWithinDistance = amount;
			
			//LogUtil.debug(_LOG, "current visible nodeids:"+_noNodesWithinDistance);
		}

		public function getVisualNodeById(id:String):IVisualNode {
			return _visualIdsToNodes[id];
		}

		public function get origin():Point {
			return _origin;
		}
		
		private var _center:Point;
		
		public function get center():Point
		{
			if (_center == null) {
				_center = new Point(_width / 2, _height / 2);
			}
			return _center;
		}
		
		public function get width():Number {
			return _width;
		}
		
		public function set width(val:Number):void {
			_width = val;
			_center = null;
		}
		
		public function get height():Number {
			return _height;
		}
		
		public function set height(val:Number):void {
			_height = val;
			_center = null;
		}
		
		public function get graph():IGraph
		{
			return _graph;
		}
		
		public function get nodes():Vector.<IVisualNode> {
			return Vector.<IVisualNode>(_visualNodes);
		}
		
		public function get edges():Vector.<IVisualEdge> {
			return Vector.<IVisualEdge>(_visualEdges);
		}
		
		private function nodeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_graph = null;
		}
		
		private function edgeDataItemsChanged(event:ElementDataItemsChangeEvent):void {
			_graph = null;
		}

		public function isNodeItemVisible(itemId:Object):Boolean {
			if (!_graph) return false;
			return isNodeVisible(String(itemId));
		}
		
		public function getNodeItemPosition(itemId:Object):Point {
			if (!_graph) return null;
			return getNodePosition(String(itemId));
		}

		public function apply(width:Number, height:Number):void {
			_width = width;
			_height = height;
			_center = null;
			
			if (!_graph)
			{
				_origin = new Point(0,0);
				_graph = new Graph(_graphId, 
								new DataItemsGraphDataProvider(_nodeElement, _edgeElement), 
								false);
				initFromGraph();
				if (!currentRootVNode && _rootNodeId !== null) 
	 				currentRootVNode = getVisualNodeById(_rootNodeId);
				layouter.graphLayout = this;
			}

			if (_graph.nodes && _graph.nodes.length > 0) {
				// if the layouter is Iterative it needs to be reset
				// in order to invalidate its stability, that otherwise
				// it would be considered as stable
				if (layouter is IterativeBaseLayouter) layouter.resetAll();
 				layouter.layoutPass();
			} 
		}

		/**
		 * This initialises a VGraph from a Graph object.
		 * I.e. it crates a VNode for every Node found in
		 * the Graph and a VEdge for every Edge in the Graph.
		 * Careful, this currently does not check if the VGraph
		 * was already initialised and it does not purge anything.
		 * Things could break of used on an already initialized VGraph.
		 * */
		protected function initFromGraph():void {
			
			_visualNodes = new Vector.<VisualNode>();
			_visualIdsToNodes = new Dictionary();
			_visualEdges = new Vector.<VisualEdge>();
			
			var node:INode;
			var edge:IEdge;

			/* create the vnode from the node */
			for each(node in _graph.nodes) {
				const vnode:VisualNode = createVisualNode(node);
				_visualNodes.push(vnode);
				_visualIdsToNodes[node.id] = vnode;
			}
			
			/* we also create the edge objects, since they
			 * may carry additional label information or something
			 * like that, but they do not have a view */
			for each(edge in _graph.edges) {
				_visualEdges.push(createVEdge(edge));
			}
		}


		public function redrawEdges(_edges:Array = null):void {
			var _visEdges:Vector.<VisualEdge> = new Vector.<VisualEdge>();
			if (!_edges)
				_visEdges = _visualEdges;
			else
				for each (var e:Object in _edges)
				{
					if (e is IEdge)
						_visEdges.push((e as IEdge).vedge);
						
				}
			
			for each(var vedge:IVisualEdge in _visEdges) {
				if (vedge.visible) {
					const edge:IEdge = vedge.edge;
					const startVnode:IVisualNode = edge.node1.vnode;
					const endVnode:IVisualNode = edge.node2.vnode;
					_edgeElement.setEdgePosition(edge.id, startVnode.x, startVnode.y, endVnode.x, endVnode.y);
				}
			}
		}
		
		/**
		 * Creates VNode and requires a Graph node to associate
		 * it with. Originally also created the view, but we no
		 * longer do that directly but only on demand.
		 * @param n The graph node to be associated with.
		 * @return The created VisualNode.
		 * */
		protected function createVisualNode(node:INode):VisualNode {
			/* as an id we use the id of the graph node for simplicity
			 * for now, it is not really used separately anywhere
			 * we also use the graph data object as our data object.
			 * the view is set to null and remains so. */
			var vnode:VisualNode = new VisualNode(this, node, true);
			vnode.x = (_width - vnode.width) / 2;
			vnode.y = (_height - vnode.height) / 2;
			vnode.visible = true;
			node.vnode = vnode;
			return vnode;
		}

		/**
		 * Creates a VEdge from a graph Edge.
		 * @param e The Graph Edge.
		 * @return The created VEdge.
		 * */
		protected function createVEdge(e:IEdge):IVisualEdge {
			var vedge:IVisualEdge;
			var n1:INode;
			var n2:INode;
		
			vedge = new VisualEdge(this, e);
			
			/* set the VisualEdge reference in the graph edge */
			e.vedge = vedge;
			
			/* check if the edge is supposed to be visible */
			n1 = e.node1;
			n2 = e.node2;
			
			/* if both nodes are visible, the edge should
			 * be made visible, which may also create a label
			 */
			if (n1.vnode.visible && n2.vnode.visible) {
				vedge.visible = true;
			}
			
			/* add to tracking hash */
//			_vedges[vedge] = vedge;
			
			return vedge;
		}


		public function isNodeVisible(nodeId:String):Boolean {
			const vnode:VisualNode = _visualIdsToNodes[nodeId];
			if (!vnode) {
				return false;
			}
			return vnode.visible;
		}

		public function getNodePosition(nodeId:String):Point {
			const vnode:VisualNode = _visualIdsToNodes[nodeId];
			if (!vnode) {
				return null;
			}
			return new Point(vnode.x, vnode.y);
		}

		public function getNodeDisplayObject(nodeId:String):DisplayObject {
			return _nodeElement.getItemDisplayObject(nodeId);
		}

		public function getEdgeDisplayObject(edgeId:String):DisplayObject {
			return _edgeElement.getItemDisplayObject(edgeId);
		}

		/**
		 * @inheritDoc
		 * */
		public function calcNodesBoundingBox():Rectangle {
			var result:Rectangle;
			
			/* get all children of our canvas, these should only
			 * be node views and the edge drawing surface. */
			
			/* init the rectangle with some large values. 
			 * Originally I wanted to use Number.MAX_VALUE / Number.MIN_VALUE but
			 * ran into serious numerical problems, thus 
			 * we use +/- 999999 for now, although this is 
			 * more like a hack.
			 * Note that the coordinates are reversed, i.e. the origin of the rectangle
			 * has been pushed to the far bottom right, and the height and width
			 * are negative */
			result = new Rectangle(999999, 999999, -999999, -999999);

			for each(var vnode:VisualNode in _visualNodes) {
				if (vnode.visible) {
					result.left = Math.min(result.left, vnode.x);
					result.right = Math.max(result.right, vnode.x + vnode.width);
					result.top = Math.min(result.top, vnode.y);
					result.bottom = Math.max(result.bottom, vnode.y+vnode.height);
				}
			}

			return result;
		}

		/**
		 * @inheritDoc
		 * */
		public function scroll(deltaX:Number, deltaY:Number):void {
			// TODO: implement VisualGraph.scroll() (used by ForceDirectedLayouter)
		}

		/**
		 * @inheritDoc
		 * */
		public function draw(flags:uint = 0):void {	
			
			/* then force a layout pass in the layouter */
			if(_layouter && 
				_currentRootVNode &&
				(_graph.noNodes > 0) &&
				(this.width > 0) &&
				(this.height > 0)
				) {
				_layouter.layoutPass();
			}
		}

		public function resetLayout():void
		{
			currentRootVNode = null;
			_graph = null;
		}
	}
}
