/* 
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

package birdeye.vis.trans.graphs.model {

	import birdeye.util.LogUtil;
	import birdeye.vis.trans.graphs.data.IGraphDataProvider;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * Graph implements a graph datastructure G(V,E)
	 * with vertices V and edges E, except that we call the
	 * vertices nodes, which is here more in line with similar
	 * implementations. A graph may be associated with a 
	 * VisualGraph object, which can visualize graph components
	 * in Flash.
	 * @see VisualGraph
	 * @see Node
	 * @see Edge
	 * */
	public class Graph extends EventDispatcher implements IGraph {
		
		/**
		 * If building a spanning tree, walk only forward.
		 * (This is the default)
		 * */
		public static const WALK_FORWARD:int = 0;
		
		/**
		 * If building a spanning tree, walk only backwards.
		 * */
		public static const WALK_BACKWARDS:int = 1;
		
		/**
		 * If building a spanning tree, walk only both
		 * directions
		 * */
		public static const WALK_BOTH:int = 2;
		
		private static const _LOG:String = "birdeye.vis.trans.graphs.model.Graph";
		
		/**
		 * @internal
		 * attributes of a graph
		 * */
		protected var _id:String;

		protected var _nodes:Array;
		protected var _edges:Array;



		/* lookup by string id and by id */
		protected var _nodesByStringId:Object;
		
		/* indicator if the graph is directional or not */
		protected var _directional:Boolean;
		/* if directional we could have a walking direction for the
		 * spanning tree */
		protected var _walkingDirection:int = WALK_FORWARD;

		
		/** 
		 * @internal
		 * these two serve as id for nodes and
		 * and edges the id's will start from 1 (not 0) !!
		 * and are always increased.
		 * */
		protected var _currentNodeId:int;
		protected var _currentEdgeId:int;
		
		/**
		 * @internal
		 * these two serve as count for nodes and edges
		 * and are also decreased if nodes or edges
		 * are removed
		 * */
		protected var _numberOfNodes:int;
		protected var _numberOfEdges:int;
		
		/**
		 * @internal
		 * for several algorithms we might need
		 * BFS and DFS implementations, all related
		 * to a specific root node.
		 * */
		protected var _treeMap:Dictionary;
		
		/**
		 * @internal
		 * Provide a function to be used for sorting the
		 * graph items. This is used by GTree.
		 * */
		protected var _nodeSortFunction:Function = null;
		
		
		private var _dataProvider:IGraphDataProvider;
		
		/**
		 * Constructor method that creates the graph and can
		 * initialise it directly from an XML object, if one is specified.
		 * 
		 * @param id The id (or rather name) of the graph. Every graph has to have one.
		 * @param directional Indicator if the graph is directional or not. Directional graphs have not been tested so far.
		 * @param xmlsource an XML object that contains node and edge items that define the graph.
		 * @param xmlnames an optional Array that contains XML tag and attribute names that define the graph. 
		 * */
		public function Graph(id:String, dataProvider:IGraphDataProvider, directional:Boolean = false) {
//			if(id == null)
//				throw Error("id string must not be null")
//			if(id.length == 0)
//				throw Error("id string must not be empty")
			
			_id = id
			
			_nodes = new Array;
			_edges = new Array;
			_treeMap = new Dictionary;
			
			_nodesByStringId = new Object;
			
			_directional = directional;
			_currentNodeId = 0;
			_currentEdgeId = 0;
			_numberOfNodes = 0;
			_numberOfEdges = 0;
			
			_dataProvider = dataProvider;
			initFromDataProvider();
		}

		/**
		 * @inheritDoc
		 * */
		public function get id():String {
			return _id;
		}		
		
		/**
		 * @inheritDoc
		 * */
		public function get nodes():Array {
			return _nodes;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get edges():Array {
			return _edges;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get isDirectional():Boolean {
			return _directional;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get noNodes():int {
			return _numberOfNodes;
		}

		/**
		 * @inheritDoc
		 * */
		public function get noEdges():int {
			return _numberOfEdges;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set nodeSortFunction(f:Function):void {
			_nodeSortFunction = f;
		}
		
		/**
		 * @private
		 * */
		public function get nodeSortFunction():Function	{
			return _nodeSortFunction;
		}

		/**
		 * @inheritDoc
		 * */
		public function set walkingDirection(d:int):void {
			_walkingDirection = d;
		}
	
		/**
		 * @private
		 * */
		public function get walkingDirection():int {
			return _walkingDirection;
		}
	
		/**
		 * @inheritDoc
		 * */
		public function nodeByStringId(sid:String):INode {
			if(_nodesByStringId.hasOwnProperty(sid)) {
				return _nodesByStringId[sid];
			} else {
				return null;
			}
		}
	
		/**
		 * @inheritDoc
		 * */
		public function getTree(n:INode,restr:Boolean = false, nocache:Boolean = false):IGTree{
			/* If nocache is set, we just return a new tree */
			if(nocache) {
				return new GTree(n,this,restr);
			}
			
			if(!_treeMap.hasOwnProperty(n)) {
				_treeMap[n] = new GTree(n,this,restr);
				/* do the init now, not lazy */
				(_treeMap[n] as IGTree).initTree();
			}
			return (_treeMap[n] as IGTree);
		}
	
		/**
		 * @inheritDoc
		 * */
		public function purgeTrees():void {
			_treeMap = new Dictionary;
		}
	
	    /**
		 * @inheritDoc
		 * */
		private function initFromDataProvider():void {
			for (var i:int = 0; i < _dataProvider.numberOfNodes; i++) {
				createNode(_dataProvider.getNodeId(i), _dataProvider.getNodeTag(i));
			}
			
			for (var i:int = 0; i < _dataProvider.numberOfEdges; i++) {
				const fromNode:INode = nodeByStringId(_dataProvider.getEdgeFromNodeId(i));
				const toNode:INode = nodeByStringId(_dataProvider.getEdgeToNodeId(i));

				/* we do not throw an error here, because the data
				 * is often inconsistent. In this case we just ignore
				 * the edge */
				if (fromNode == null) {
					LogUtil.warn(_LOG, "Node id: "+_dataProvider.getEdgeFromNodeId(i)+" not found, link not done");
					continue;
				}
				if (toNode == null) {
					LogUtil.warn(_LOG, "Node id: "+_dataProvider.getEdgeToNodeId(i)+" not found, link not done");
					continue;
				}
				link(_dataProvider.getEdgeId(i), fromNode, toNode, _dataProvider.getEdgeTag(i));
			}
		}

	
		/**
		 * @inheritDoc
		 * */
		public function createNode(id:String = "", o:Object = null):INode {
			
			/* we allow to pass a string id, e.g. it can originate
			 * from the XML file.*/
			
			var myNode:Node;
			
			/* 
			 * see below when we link nodes, we cannot yet 
			 * set the visual counterpart, but we have setter/getters
			 * for the attribute, have to consider which
			 * component must be created first
			 * consider also to just pass it to the abstract graph
			 * but more likely, we initialise the abstract graph
			 * from a graphML XML file, when it is there, then we build
			 * all the visual objects 
			 */
			
			myNode = new Node(id, null, o);
			
			_nodes.unshift(myNode);
			_nodesByStringId[id] = myNode;
			++_numberOfNodes;
			
			/* a new node means all potentially existing
			 * trees in the treemap need to be invalidated */
			purgeTrees();
			
			return myNode;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeNode(n:INode):void {
			/* we check if inEdges or outEdges
			 * are not empty. This also works for
			 * non directional graphs, even though one
			 * comparison would be sufficient */
			if(n.inEdges.length != 0 || n.outEdges.length != 0) {
			   	throw Error("Attempted to remove Node: "+n.id+" but it still has Edges");
			} else {
				/* XXXX searching like this through arrays takes
				 * LINEAR time, so at one point we might want to add
				 * associative arrays (possibly Dictionaries) to map
				 * the objects back to their index... */
				var myindex:int = _nodes.indexOf(n);
				
				/* check if node was not found */
				if(myindex == -1) {
					throw Error("Node: "+n.id+" was not found in the graph's" +
					"node table while trying to delete it");
				}
				
				// HMMM we assume that the throw will abort the script
				// but I am not sure, we'll see
				//LogUtil.debug(_LOG, "PASSED Check for node in _node list");
				
				/* remove node from list */
				_nodes.splice(myindex,1);
				--_numberOfNodes;
				
				
				delete _nodesByStringId[n.id];
				
				/* we need to do something about vnodes */
				if(n.vnode != null) {
					throw Error("Node is still associated with its vnode, this leaves a dangling reference and a potential memory leak");
				}
				
				/* node should have no longer a reference now
				 * so the GarbageCollector will get it */
				
				/* invalidate trees */
				purgeTrees()
			}
		}
		
		/**
		 * @inheritDoc
		 * */
		public function link(edgeId:String, node1:INode, node2:INode, o:Object = null):IEdge {
			
			var retEdge:IEdge;
			
			if(node1 == null) {
				throw Error("link: node1 was null");
			}
			if(node2 == null) {
				throw Error("link: node2 was null");
			}
			
//			/* check if a link already exists */
//			if(node1.successors.indexOf(node2) != -1) {
//				/* we should give an error message, but
//				 * there is no need to abort the script
//				 * we should just do nothing */
//				LogUtil.warn(_LOG, "Link between nodes:"+node1.id+" and "+
//				node2.id+" already exists, returning existing edge");
//				
//				/* oh in fact, we should return the edge that was found 
//				 * this was more complicated than I thought and I am
//				 * not tooo happy with this way...
//				 * also it might not always find the edge if graph is non-directional
//				 * as most graphs are. The edge found could be the other way round.
//				 * Have to use the "othernode()" method here.
//				 */
//				var outedges:Array = node1.outEdges;
//				for each (var edge:Edge in outedges) {
//					if(edge.othernode(node1) == node2) {
//						retEdge = edge;
//						break;
//					}
//				}
//				if(retEdge == null) {
//					throw Error("We did not find the edge although it should be there");
//				}
//			} else
			{
				/* not sure where we will be able to set the visual edge
				 * as it must exist first, for now we pass null 
				 * since the attribute has also a setter */
				var newEdge:Edge = new Edge(this, null, edgeId, node1, node2, o);
				_edges.unshift(newEdge);
				++_numberOfEdges;
				
				/* now register the edge with its nodes */
				node1.addOutEdge(newEdge);
				node2.addInEdge(newEdge);
				
				/* if we are a NON directional graph we would have
				 * to add another edge also vice versa (in the other
				 * direction), but that leaves us with the question
				 * which of the edges to return.... maybe it can be
				 * handled using the same edge, if the in the directional
				 * case, the edge returns always the other node */
				//LogUtil.debug(_LOG, "Graph is directional? "+_directional.toString());
				if(!_directional) {
					node1.addInEdge(newEdge);
					node2.addOutEdge(newEdge);
					//LogUtil.debug(_LOG, "graph is not directional adding same edge:"+newEdge.id+
					//" the other way round");
				}
				retEdge = newEdge;
			}
							
			/* invalidate trees */
			purgeTrees()
			return retEdge;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function unlink(edgeId:String, node1:INode, node2:INode):void {

			/* find the corresponding edge first */
			var e:IEdge;
			
			e = getEdge(edgeId,node1,node2);
			
			if(e == null) {
				throw Error("Could not find edge, Nodes: "+node1.id+" and "
				+node2.id+" may not be linked.");
			} else {
				removeEdge(e);
			}
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getEdge(edgeId:String, n1:INode, n2:INode):IEdge {
			var outedges:Array = n1.outEdges;
			var e:IEdge = null;
			for each (var edge:Edge in outedges) {
				if (edge.othernode(n1) == n2  &&  edge.id == edgeId) {
					e = edge;
					return e;
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeEdge(e:IEdge):void {
			var n1:INode = e.node1;
			var n2:INode = e.node2;
			var edgeIndex:int = _edges.indexOf(e);
			
			if(edgeIndex == -1) {
				throw Error("Edge: "+e.id+" does not seem to exist in graph "+_id);
				// here we would need to abort the script
			}
			
			n1.removeOutEdge(e);
			n2.removeInEdge(e);
			
			/* if we are NOT directed, we also 
			 * have to remove the other way round */
			if(!_directional) {
				n1.removeInEdge(e);
				n2.removeOutEdge(e);
			}
			
			/* now remove from the list of edges */
			_edges.splice(edgeIndex,1);
			--_numberOfEdges;
			
			/* invalidate trees */
			purgeTrees()
		}
		
		/**
		 * @inheritDoc
		 * */
		public function purgeGraph():void {
			
			while(_edges.length > 0) {
				removeEdge(_edges[0]);
			}
			
			while(_nodes.length > 0) {
				removeNode(_nodes[0]);
			}
			purgeTrees();
		}						
	}
}
