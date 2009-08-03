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
	import birdeye.events.VGraphEvent;
	import birdeye.vis.elements.Position;
	import birdeye.vis.interfaces.IEdgeElement;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	import birdeye.vis.trans.graphs.data.IGraphDataProvider;
	import birdeye.vis.trans.graphs.layout.ILayoutAlgorithm;
	import birdeye.vis.trans.graphs.model.Graph;
	import birdeye.vis.trans.graphs.model.IEdge;
	import birdeye.vis.trans.graphs.model.IGraph;
	import birdeye.vis.trans.graphs.model.INode;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class VisualGraph extends EventDispatcher implements IVisualGraph
	{
		private static const logger:ILogger = Log.getLogger("birdeye.vis.trans.graphs.visual.VisualGraph");

		private var _width:Number;
		private var _height:Number;		
		private var _nodeElement:IGraphLayoutableElement;
		private var _edgeElement:IEdgeElement;
		private var _layouter:ILayoutAlgorithm;
		private var _graph:IGraph;
		private var _origin:Point;
		private var _visualNodes:Vector.<VisualNode>;
		private var _visualEdges:Vector.<VisualEdge>;
		private var _visualIdsToNodes:Dictionary;
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

		private var _useIntegerPositions:Boolean;

		public function VisualGraph(id:String, node:IGraphLayoutableElement, edge:IEdgeElement,
									graphDataProvider:IGraphDataProvider,
									width:Number, height:Number,
									useIntegerPositions:Boolean) {
			_nodeElement = node;
			_edgeElement = edge;
			_origin = new Point(0,0);
			_graph = new Graph(id, graphDataProvider, false);
			_width = width;
			_height = height;
			_useIntegerPositions = useIntegerPositions;
			initFromGraph();
		}

		public function get useIntegerPositions():Boolean {
			return _useIntegerPositions;
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

		public function get nodeElement():IGraphLayoutableElement {
			return _nodeElement;
		}

		public function get edgeElement():IEdgeElement {
			return _edgeElement;
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
				
				//LogUtil.debug(_LOG, "node:"+_currentRootVNode.id+" added to history");
				
				/* if we are currently limiting node visibility,
				 * update the set of visible nodes since we 
				 * have changed the root, the spanning tree has changed
				 * and thus the set of visible nodes */
//				if(_visibilityLimitActive) {
//					setDistanceLimitedNodeIds(_graph.getTree(_currentRootVNode.node).
//						getLimitedNodes(_maxVisibleDistance));
//					updateVisibility();
//				} else {
//					/* if we do not limit visibility, we still need
//					 * to force a new layout and redraw()
//					 * (in the other case, this is done by updateVisibility()) */
//					// disabled to remove implicit call to
//					// draw();
//				}
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
//						updateVisibility();
					}
				}
			}
		}
		
		/**
		 * This needs to walk through all nodes in the graph, as some nodes
		 * have become invisible and other have become visible. There may be
		 * a better way to do this, when adjusting the visibility but it is
		 * not that clear.
		 * 
		 * walk through the graph and the limitedGraph and
		 * turn off visibility for those that are not listed in
		 * both
		 * beware that the limited graph has no VItems, so 
		 * we don't really need it, we would rather need
		 * an array of node ids....
		 * */
//		protected function updateVisibility():void {
//			var n:INode;
//			var e:IEdge;
//			var edges:Array;
//			var treeparents:Dictionary;
//			var vn:IVisualNode;
//			var vno:IVisualNode;
//			
//			var newVisibleNodes:Dictionary;
//			var toInvisibleNodes:Dictionary;
//			
//			/* since a layouter that uses timer based iterations
//			 * might find itself on a changing node set, we need
//			 * to stop/reset anything before altering the node
//			 * visibility */
//			if(_layouter != null) {
//				_layouter.resetAll();
//			}
//			
//			
//			//LogUtil.debug(_LOG, "update node visibility");
//			
//			/* create a copy of the currently visible 
//			 * node set, as the set for nodes to potentially
//			 * turned invisible */
//			toInvisibleNodes = new Dictionary;
//			for each(vn in _visibleVNodes) {
//				toInvisibleNodes[vn] = vn;
//			}
//			
//			/* now populate the set of nodes which should be
//			 * turned visible, first by using the nodes  within
//			 * distance limit */
//			newVisibleNodes = new Dictionary;
//			
//			for each(vn in _nodeIDsWithinDistanceLimit) {
//				newVisibleNodes[vn] = vn;
//			}
//			
//			/* now add the history nodes to the set of new visible
//			 * nodes if the history is enabled */
//			/* Step 3: render all (new?) history nodes and nodes on the path visible (if applicable) */
//			if(_showCurrentNodeHistory) {
//		
//				/* this is mapping in the tree that provides a parent
//				 * for each single node in the tree 
//				 * we need this to find the trace to the root */
//				treeparents = _graph.getTree(_currentRootVNode.node).parents;
//				
//				for each(vn in _currentVNodeHistory) {
//					n = vn.node;		
//					/* we cannot use vn here, because it is n that is changed
//					 * in this while loop. Basically we are walking the tree
//					 * backward from the current vnode's node n to the root
//					 * for every vn in the history */
//					while(n.vnode != _currentRootVNode) {
//						
//						/* set it visible */
//						newVisibleNodes[n.vnode] = n.vnode;
//						//setNodeVisibility(n.vnode, true);
//						
//						/* move to the parent node */
//						n = treeparents[n];
//						if(n == null) {
//							throw Error("parent node was null but node was not root node");
//						}
//					}
//				}
//			}
//			
//			/* now from each set remove the common nodes, these
//			 * are the nodes that should remain visible, so they
//			 * must not be turned invisible and should also not
//			 * be turned visible again. */
//			for each(vn in toInvisibleNodes) {
//				if(newVisibleNodes[vn] != null) {
//					/* this is a common node, remove it from
//					 * both dictionaries 
//					 */
//					delete toInvisibleNodes[vn];
//					delete newVisibleNodes[vn];
//				} 
//			}
//			
//			/* now finally turn all toInvisibleNodes invisible
//			 * likewise any edge adjacent to an invisible node
//			 * will become invisible */
//			for each(vn in toInvisibleNodes) {
//				setNodeVisibility(vn, false);
//			}
//			
//			/* and all new visible nodes to visible */
//			for each(vn in newVisibleNodes) {
//				setNodeVisibility(vn, true);
//			}
//			
//			/* and now walk again to update the edges */
//			for each(vn in toInvisibleNodes) {
//				updateConnectedEdgesVisibility(vn);
//			}
//			
//			/* and all new visible nodes to visible */
//			for each(vn in newVisibleNodes) {
//				updateConnectedEdgesVisibility(vn);
//			}
//			
//			/* send an event */
//			this.dispatchEvent(new VGraphEvent(VGraphEvent.VISIBILITY_CHANGED));
//		}

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

		/**
		 * @inheritDoc
		 * */
		public function get layouter():ILayoutAlgorithm {
			return _layouter;
		}
	
		/**
		 * @private
		 * */
		public function set layouter(layout:ILayoutAlgorithm):void {
			if (layout == _layouter) {
				return;
			}
			if(_layouter != null) {
				_layouter.resetAll(); // to stop any pending animations
			}
			_layouter = layout;

			/* need to signal control components possibly */
			dispatchEvent(new VGraphEvent(VGraphEvent.LAYOUTER_CHANGED));
		}

		public function get origin():Point {
			return _origin;
		}
		
		private var _center;
		
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
		
		public function redrawEdges():void {
			for each(var vedge:IVisualEdge in _visualEdges) {
				if (vedge.visible) {
					const edge:IEdge = vedge.edge;
					const startVnode:IVisualNode = edge.node1.vnode;
					const endVnode:IVisualNode = edge.node2.vnode;
					_edgeElement.setEdgePosition(edge.id, startVnode.x, startVnode.y, endVnode.x, endVnode.y);
				}
			}
//			EdgeElement(_edgeElement).drawElement();
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

		public function getNodePosition(nodeId:String):Position {
			const vnode:VisualNode = _visualIdsToNodes[nodeId];
			if (!vnode) {
				return null;
			}
			if (useIntegerPositions) {
				return new Position(Math.round(vnode.x), Math.round(vnode.y));
			} else {
				return new Position(vnode.x, vnode.y);
			}
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

//			return new Rectangle(_canvas.width / 2, _canvas.height / 2, 0, 0);
			
			return result;
		}

		/**
		 * @inheritDoc
		 * */
		public function scroll(deltaX:Number, deltaY:Number):void {
			// TODO: implement VisualGraph.scroll() (used by ForceDirectedLayouter)
		}

		public function refresh():void {
			// TODO: implement VisualGraph.refresh()
//			/* this forces the next call of updateDisplayList() to redraw all edges */
//			_forceUpdateEdges = true;
//			invalidateDisplayList();
		}
	}
}
