/*  
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 *
 * Author: Anselm Bradford (http://anselmbradford.com)
 * The coraldata data structure library was originally inspired by and adopted 
 * from JDSL (http://www.jdsl.org), any remaining similarities in architecture are 
 * credited to the respective authors in the JDSL classes.
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

/*
 * SVN propsets
 *
 * $HeadURL$
 * $LastChangedBy$
 * $Date$
 * $Revision$
 */

package org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IGraph;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IVertex;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IDirectedGraph;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.ArrayIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.IteratorMerger;
	
	/**
	 * A combinatorial graph utilizing an incidence list for storage.  Directed and
	 * undirected edges may coexist. Multiple parallel edges and
	 * self-loops are allowed.  The graph can be disconnected. 
	 *
	 * The graph is implemented via a doubly linked list of vertices and a list of edges.  
	 * The nodes of these lists are the vertices and edges of the graph, respectively. 
	 * In addition to the lists of vertices and edges stored in the graph structure, 
	 * each vertex has a "local" list of its incident edges.  Thus, each edge participates
	 * in two local lists (one for each endpoint) plus the global list.  Each
	 * vertex participates in only the global list.  Although sequential
	 * data structures are used to implement the graph, the graph
	 * conceptually consists of unordered sets; no guarantee is made
	 * about where in the various lists a given accessor appears.
	 * <p>
	 *
	 * The doubly linked lists are implemented using an internal stripped down version of the
	 * <code>DoublyLinkedList</code> class, which is only accessible from within the 
	 * graph package. Each local list includes a dummy edge to handle special cases 
	 * (empty list, iterating till end of list, inserting at beginning of list).
	 * <p>
	 * 
	 * To avoid the space overhead of having the global lists' positions
	 * point to vertex/edge objects, which would need to point back to
	 * the positions, the positions *are* the vertices/edges.
	 * This is accomplished by inheriting from the position implementation
	 * of the DoublyLinkedList (called IncidenceListNode) and using the
	 * posInsert(*) methods to put objects of the subclass into the global lists.
	 */
	
	public class IncidenceListGraph extends AbstractGraph implements IGraph, IDirectedGraph
	{
		/*----------------------------------------------------------------------
		* properties
		*---------------------------------------------------------------------*/
		
		/**
		* List of vertices in the graph.
		*/
		private var _allverts:IncidenceList;

		/**
		* List of edges in the graph.
		*/
		private var _alledges:IncidenceList;
	
		/**
		 * Creates an empty IncidenceListGraph.
		 */
		public function IncidenceListGraph() 
		{
			super();
			_allverts = new IncidenceList( );
			_alledges = new IncidenceList( );
		}
	
		/*----------------------------------------------------------------------
		* public methods
		*---------------------------------------------------------------------*/
		
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableCollection
		//////////////////////////////////////////////////////////////////
	
		/** 
		 * @inheritDoc
		 */
		 override public function doesContain( p:IAccessor ) : Boolean
		 {
			return _allverts.doesContain(p) || _alledges.doesContain(p);
		 }

		/**
		 * @inheritDoc
		 */
		override public function elements() : IIterator
		{
			return new IteratorMerger( _allverts.elements() , _alledges.elements() );
		}
		
		/** 
		* @inheritDoc
		*/
		override public function findAccessorByElement( element:Object ) : IAccessor
		{
			var returnVal:IAccessor;
			var foundVal:Object;
			var it:IIterator = positions();
			while( it.hasNext() )
			{
				foundVal = IAccessor(it.next()).getElement();
				if ( foundVal === element ) 
				{
					returnVal = IAccessor(it.current());
					break;
				}
			}
			return returnVal;
		}

		//////////////////////////////////////////////////////////////////
		// Methods implemented from ICollection
		//////////////////////////////////////////////////////////////////
	
		/**
		* @inheritDoc
		*/
		override public function clear() : void
		{
			_allverts.clear();
			_alledges.clear();			
		}

		/**
		* @inheritDoc
		*/
		override public function remove( a:IAccessor , caller:Function = null ) : Object
		{
			var returnVal:Object = a.getElement();
			if (a is IVertex) _removeVertex( ILVertex(a) );
			if (a is IEdge) _removeEdge( AbstractILEdge(a) );
			if (caller != a.destroy) a.destroy(arguments.callee);
			return returnVal;
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableGraph
		//////////////////////////////////////////////////////////////////
		
		/**
		 * @inheritDoc
		 */
		override public function numVertices() : int
		{
			return _allverts.size() ;
		}
	
		/**
		 * @inheritDoc
		 */
		override public function numEdges() : int
		{
			return _alledges.size() ;
		}
	
		/**
		 * @inheritDoc
		 */
		override public function getVertices() : IIterator
		{
			return _allverts.positions();
		}
	
		/**
		  * @inheritDoc
		  */
		override public function aVertex( e:IEdge = null ) : IVertex
		{
			var returnVal:IVertex;
			// if selecting from the whole graph
			if ( e == null )
			{
				//if (_allverts.isEmpty()) return Vertex.NONE;
				if (_allverts.isEmpty()) 
				{
					return undefined;
				}
				var size:int = _allverts.size()-1;
				var index:int = Math.round(Math.random()*(0-size))+size;
			
				returnVal = IVertex(_allverts.getAtIndex(index));
			}
			// if selecting from a particular edge
			else
			{
				switch(Math.round(Math.random()*(0-1))+1)
				{
					case 0 : 
					returnVal = getEdgeOrigin(e);
					break;
					case 1 : 
					returnVal = getEdgeDestination(e);
					break;
				}
			}
			
			return returnVal;
		}
		
		/**
		* @inheritDoc
		*/
		override public function anEdge( edgeType:int = EdgeType.ALL , v:IVertex = null ) : IEdge
		{
			_checkEdgeType( edgeType );
			var returnVal:IEdge;
			var size:int;
			var index:int;
			
			// selecting from the whole graph
			if ( v == null )
			{
				//if (_alledges.isEmpty()) return Edge.NONE;
				if (_alledges.isEmpty()) 
				{
					return undefined;
				}
				size = _allverts.size()-1;
				index = Math.round(Math.random()*(0-size))+size;
				
				returnVal = IEdge(_alledges.getAtIndex(index));
			}
			// if selecting from a particular vertex
			else
			{
				var accum:Array = new Array();
				var nullEdge:AbstractILEdge = AbstractILEdge(ILVertex(v).getPlaceholderEdge());
				var e:AbstractILEdge = AbstractILEdge(nullEdge.next);
				//var num:int;
							
				while( e != nullEdge )
				{
					var mytype:int = e.getType( v );
					if( (mytype & edgeType) != 0 )
					{
						accum.push(e);
					}
					
					e = e.getNext( v ) as AbstractILEdge;
				}
				
				size = accum.length-1;
				index = Math.round(Math.random()*(0-size))+size;
				
				returnVal = IEdge(accum[index]);
			}
			
			return returnVal;
		}
	
		/**
		 * @inheritDoc
		 */
		override public function getEdges( incidentTo:IVertex = null , edgeType:int = EdgeType.ALL ) : IIterator
		{
			_checkEdgeType(edgeType);
			var returnVal:IIterator; 
			if ( incidentTo == null )
			{
				var edges:IIterator = _alledges.positions();
				if ( edgeType == EdgeType.ALL )
				{
					returnVal = edges;
				}
				else
				{
					var accum:Array = new Array();
					var e:IEdge;
					while( edges.hasNext() ) 
					{
						e = edges.next() as IEdge;
						var mytype:int = AbstractILEdge(e).getType();
						if( (mytype & edgeType) != 0 )
						{
							accum.push(e);
						}
					}
					
					returnVal = new ArrayIterator(accum);
				}
			}
			else
			{
				returnVal = _getIncidentEdges( incidentTo , edgeType );
			}
			
			return returnVal;
		}
						
		/**
		 * @inheritDoc
		 */
		override public function isEdgeSelfLoop( e:IEdge ) : Boolean
		{
			return AbstractILEdge(e).isEdgeSelfLoop();
		}
	
		/**
		 * @inheritDoc
		 */
		override public function getEdgeType ( e:IEdge , v:IVertex = null ) : int
		{
			var origin:IVertex = AbstractILEdge(e).origin;
			var dest:IVertex = AbstractILEdge(e).destination;
			if (v == null) v = origin;
			
			if( isEdgeDirected(e) ) 
			{
				if( v == origin ) return EdgeType.OUT; //2
				if ( v != dest ) throw new Error("Not an endpoint");
				
				return EdgeType.IN; // 1
			}
			else 
			{
				if ( v != origin && v != dest ) throw new Error("not an endpoint");
			
				return EdgeType.UNDIR; //4
			}
		}
	
		/**
		 * @inheritDoc
		 */
		override public function getEdgeOrigin( e:IEdge ) : IVertex
		{
			return AbstractILEdge(_checkEdge(e)).origin;
		}
	
		/**
		 * @inheritDoc
		 */
		override public function getEdgeDestination( e:IEdge ) : IVertex
		{
			return AbstractILEdge(_checkEdge(e)).destination;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function isEdgeDirected( e:IEdge ) : Boolean
		{
			return AbstractILEdge(_checkEdge(e)).isEdgeDirected();
		}
		
		/**
		 * @inheritDoc
		 */
	  	override public function areIncident( v:IVertex , e:IEdge ) : Boolean
		{
			var evo:IVertex = getEdgeOrigin(e);
			var evd:IVertex = getEdgeDestination(e);
			return (evo == v || evd == v);
		}
		
		
		

		//////////////////////////////////////////////////////////////////
		// Methods implemented from IDirectedGraph
		//////////////////////////////////////////////////////////////////

		/**
		 * @inheritDoc
		 */
		public function reverseDirection( e:IEdge ) : void
		{
			var ile:AbstractILEdge = _checkEdge(e);
			ile.swapEndpoints();			
		}
		
		/**
		* @inheritDoc
		*/
		public function setEdgeDirection( e:IEdge , edgeType:int , v:IVertex = null ) : void
		{
			_checkEdgeType(edgeType);
			_checkVertex(v);
			_checkEdge(e);
			if (!areIncident(v,e)) throw new Error( "Vertex "+v+" is not an endpoint of "+e );	
			switch( edgeType )
			{
				case EdgeType.UNDIR : 
					AbstractILEdge(_checkEdge(e)).makeUndirected();
				break;

				case EdgeType.OUT : 
					AbstractILEdge(e).origin = v;
				break;

				case EdgeType.IN : 
					AbstractILEdge(e).destination = v;
				break;				
			}
		}
		
		

		//////////////////////////////////////////////////////////////////
		// Methods implemented from IGraph
		//////////////////////////////////////////////////////////////////
		
		/**
		 * @inheritDoc
		 */
		public function addEdge ( v1:IVertex , v2:IVertex , elt:Object = null  , edgeType:int = EdgeType.UNDIR ) : IEdge 
		{
			_checkEdgeType( edgeType );
			var ilv1:ILVertex = _checkVertex(v1);
			var ilv2:ILVertex = _checkVertex(v2);
			var e:IEdge;
			
			// insert edge of type 
			switch( edgeType )
			{
				case EdgeType.UNDIR : 
					e = _addEdge( ilv1, ilv2, elt, false) as IEdge;
				break;

				case EdgeType.OUT : 
					e = _addEdge( ilv1, ilv2, elt, true) as IEdge;
				break;

				case EdgeType.IN : 
					e = _addEdge( ilv2 , ilv1 , elt, true) as IEdge;
				break;
			}
			
			return e;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addVertex( elt:Object = null ) : IVertex
		{
			return _addVertex( elt );
		}
		

	
	
		/**
		 * @inheritDoc
		 */
		public function toString() : String
		{
			var s : String = "";
			s += "[object IncidenceListGraph:";
			var li:IIterator = elements();
			while (li.hasNext())
			{
				s += " ("+li.next()+")";
			}
			s += "]";
			return s;
		}
	
	
	
	
		/*----------------------------------------------------------------------
		* private methods
		*---------------------------------------------------------------------*/		
	
		/*********************** private helper methods ********************/
		
		/**
		* helper method for checking that the supplied edge type id is valid
		*/
		private function _checkEdgeType( type:int ) : void
		{
			
			if ( !EdgeType.isValid(type) ) 
			{
				throw new Error( "Supplied edge type is not valid!" );
			}
		}

		/**
		 * helper method for retreiving incident edges of a vertex.
		 */
		private function _getIncidentEdges( v:IVertex , edgeType:int = EdgeType.ALL ) : IIterator
		{
			_checkVertex(v);
			var accum:Array = new Array();
			var nullEdge:AbstractILEdge = AbstractILEdge(ILVertex(v).getPlaceholderEdge());
			var e:AbstractILEdge = AbstractILEdge(nullEdge.next);
			//var num:int;
						
			while( e != nullEdge )
			{
				var mytype:int = e.getType( v );
				if( (mytype & edgeType) != 0 )
				{
					accum.push(e);
				}
								
				e = e.getNext( v ) as AbstractILEdge;
			}
			
			return new ArrayIterator( accum );
		}

	
		/**
		* insert a vertex.
		*/
		private function _addVertex( elt:Object ) : ILVertex
		{
			var vert:ILVertex = new ILVertex( this, elt );
			_allverts.posInsertLast( vert );
			return vert;
		}
		
		
		/**
		* insert an edge.
		*/
		private function _addEdge( v1:ILVertex , v2:ILVertex , elt:Object , isDir:Boolean ) : AbstractILEdge
		{
			var ile:AbstractILEdge;
			
			// if both origin and destination edges are the same, create a loop edge
			if( v1 == v2 ) 
			{
				ile = new ILLoopEdge( this , v1, elt, isDir );
			}
			else 
			{
				ile = new ILNormalEdge( this , v1, v2, elt, isDir );
			}
			_alledges.posInsertLast( ile );
			
			return ile ;
		}
	
		/** 
		* Remove a vertex
		*/
		private function _removeVertex( vert:ILVertex ) : void
		{
			vert = _checkVertex( vert );
			var pe:IIterator = _getIncidentEdges( vert );
			while(pe.hasNext()) 
			{
				remove( AbstractILEdge(pe.next() ) );
			}
			_allverts.remove( vert );
		}
	
		/**
		* Remove an edge
		*/
		private function _removeEdge( edge:AbstractILEdge ) : void
		{
			edge = _checkEdge( edge );
			edge.detach();
			_alledges.remove( edge );
		}
	
		/**
		* make sure vertex is valid, and cast it to implementation type
		*/
		private function _checkVertex( v:IVertex ) : ILVertex
		{
			if ( v == null ) throw new Error( "IncidenceListGraph::_checkVertex vertex is null" );
			if ( (v is ILVertex) == false ) throw new Error( "IncidenceListGraph::_checkVertex invalid vertex class" );
			if ( _allverts.doesContain(v) == false ) throw new Error( "IncidenceListGraph::_checkVertex vertex belongs to a different graph" );
			
			return ILVertex(v);
		}
	
		/**
		* make sure edge is valid, and cast it to implementation type
		*/
		private function _checkEdge( e:IEdge ) : AbstractILEdge
		{
			if ( e == null ) throw new Error(  "IncidenceListGraph::_checkEdge edge is null" );
			if ( (e is AbstractILEdge) == false ) throw new Error( "IncidenceListGraph::_checkEdge invalid edge class" );
			if ( _alledges.doesContain(e) == false ) throw new Error( "IncidenceListGraph::_checkEdge edge belongs to a different graph" );
			
			return AbstractILEdge(e);
		}
		
	}
}