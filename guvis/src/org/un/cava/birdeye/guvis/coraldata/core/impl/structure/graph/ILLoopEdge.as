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
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IVertex;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;

	
	/**
	 * Edges that have two distinct endpoints.  
	 * See AbstractILEdge for specifications of methods.
	 *
	 * @see AbstractILEdge
	 * @see IncidenceListGraph
	 */
	internal class ILLoopEdge extends AbstractILEdge implements IEdge
	{	
		// only one end vertex, because origin and destination are the same.
		private var _v:ILVertex;
		private var _next:AbstractILEdge;
		private var _prev:AbstractILEdge;
		
		/*
		* every edge constructed knows its endpoints, and installs itself 
		* in its endpoints' incidence lists.
		*/
		public function ILLoopEdge( collection:ICollection , v:ILVertex , elt:Object , isEdgeDirected:Boolean = false ) 
		{
			super( collection , elt, isEdgeDirected );

			_v = v;
			
			_prev = v.getPlaceholderEdge();
			_next = AbstractILEdge(_prev.next);
			_prev.setNext( v, this );
		}
		
		override public function toString() :String
		{
			var returnVal:String = "[object ILLoopEdge ";
			returnVal += "("+getElement()+")]";
			return returnVal;
		}
	
		
		override public function detach() : void
		{
			_prev.setNext( _v , _next );
			_prev = _next = null;
			_v =  null; 
		}		
		
		override public function getNext( whichEnd:IVertex ) : AbstractILEdge
		{
			var returnPos:AbstractILEdge;
			if( _v == whichEnd ) 
			{
				if ( _v != whichEnd ) throw new Error("ILLoopEdge::getNext::Assertion failed!");
				returnPos = _next;
			}
			
			return returnPos;
		}
		
		override public function setNext( whichEnd:IVertex , n:AbstractILEdge ) : void
		{
			whichEnd as IVertex;
			n as IEdge;
			if( _v==whichEnd ) 
			{
				if ( _v != whichEnd ) throw new Error("ILLoopEdge::setNext::Assertion failed!");
				_next = n as AbstractILEdge;
			}
		}
		
		/**
		* @inheritDoc
		*/
		override public function get origin() : IVertex
		{
			return _v;
		}
		
		/**
		* @inheritDoc
		*/
		override public function get destination() : IVertex
		{
			return _v;
		}
		
		/**
		* @private
		*/
		override public function set origin( v:IVertex ) : void
		{
			if( v != _v ) throw new Error( "Vertex " + v + " not an endpoint of edge " + this );
		}

		/**
		* @private
		*/
		override public function set destination( v:IVertex ) : void
		{
			if( v != _v ) throw new Error( "Vertex " + v + " not an endpoint of edge " + this );
		}
		
		/**
		* @inheritDoc
		*/
		override public function opposite( v:IVertex ) : IVertex
		{
			return _v;
		}

		/**
		* @inheritDoc
		*/
		override public function getType( endpoint:IVertex = null ) : int
		{
			return EdgeType.SELF_LOOP; //8
		}
		
				
		/**
		* @inheritDoc
		*/
		override public function isEdgeSelfLoop() : Boolean 
		{
			return true;
		}
		
		/**
		* @inheritDoc
		*/
		override public function swapEndpoints() : void
		{
			// end points are the same, so no implementation needed
		}
	
	
	}
}