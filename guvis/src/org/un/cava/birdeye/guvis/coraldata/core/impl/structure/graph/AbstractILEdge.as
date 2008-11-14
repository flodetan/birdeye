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
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IVertex;

	
	/**
	* Abstract superclass of all IncidenceList based edges.
	* This class is here basically to prevent having data members where they are not 
	* needed. The inheritance from IncidenceListNode works the magic by which an edge
	* is also a position in the global edge list.
	*/
	internal class AbstractILEdge extends IncidenceListNode implements IEdge 
	{

		/*----------------------------------------------------------------------
		* properties
		*---------------------------------------------------------------------*/    		
		/**
		* Whether this edge is directed or not. If directed the direction is 
		* from the <code>origin</code> to the <code>destination</code>.
		*/
		private var _isEdgeDirected:Boolean;
					

		/*----------------------------------------------------------------------
		* constructor
		*---------------------------------------------------------------------*/    		
		public function AbstractILEdge( collection:ICollection , elt:Object = null, isEdgeDirected:Boolean = false ) 
		{
			super( collection , elt );
			
			_isEdgeDirected = isEdgeDirected;
		}
		
		override public function toString() :String
		{
			var returnVal:String = "[object AbstractILEdge ";
			if (_isEdgeDirected) returnVal += "<origin:"+origin+", destination:"+destination+">";
			returnVal += "<"+getElement()+">]";
			return returnVal;
		}
	
		// an edge, when being removed, removes itself from
		// its endpoints' incidence lists
		public function detach() : void
		{
			throw new Error("Abstract method "+this);
		}
		
		/*override public function get next( ) : IPosition
		{
			throw new Error("Abstract method "+this);
		}
			
		override public function set next( n:IPosition ) : void
		{
			throw new Error("Abstract method "+this);
		}*/
		
		// methods dealing with the edge's place in its endpoints'
		// incidence lists.  They take a vertex to specify which
		// endpoint.
		public function getNext( whichEnd:IVertex ) : AbstractILEdge
		{
			throw new Error("Abstract method "+this);
		}
	
		
		public function setNext( whichEnd:IVertex , n:AbstractILEdge ) : void
		{
			throw new Error("Abstract method "+this);
		}

		/**
		* @inheritDoc
		*/
		public function get origin() : IVertex
		{
			throw new Error("Abstract method "+this);
		}

		/**
		* @private
		*/
		public function set origin( v:IVertex ) : void
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		* @inheritDoc
		*/
		public function get destination() : IVertex
		{
			throw new Error("Abstract method "+this);
		}

		/**
		* @private
		*/
		public function set destination( v:IVertex ) : void
		{
			throw new Error("Abstract method "+this);
		}

		/**
		* @inheritDoc
		*/
		public function swapEndpoints() : void // if directed, reverses direction
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		* @inheritDoc
		*/
		public function opposite( v:IVertex ) : IVertex
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		* @inheritDoc
		*/
		public function isEdgeDirected() : Boolean
		{
			return _isEdgeDirected;
		}
		
		/**
		* @inheritDoc
		*/
		public function makeDirected() : void
		{
			_isEdgeDirected = true;
		}
		
		/**
		* @inheritDoc
		*/
		public function makeUndirected() : void
		{
			_isEdgeDirected = false;
		}
		
		/**
		* @inheritDoc
		*/
		public function getType( endpoint:IVertex = null ) : int
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		* @inheritDoc
		*/
		public function isEdgeSelfLoop() : Boolean
		{
			throw new Error("Abstract method "+this);
		}
	}	
}