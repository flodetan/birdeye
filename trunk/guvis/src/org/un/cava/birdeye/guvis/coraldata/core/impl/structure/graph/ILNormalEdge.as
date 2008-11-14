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
	internal class ILNormalEdge extends AbstractILEdge implements IEdge
	{	
		// endpoints: if directed, v1 is origin, v2 dest
		private var _v1:ILVertex; 
		private var _v2:ILVertex;
			
		// links in the edge lists of the two endpoints:
		private var _next1:AbstractILEdge; 
		private var _prev1:AbstractILEdge; 
		
		private var _next2:AbstractILEdge;
		private var _prev2:AbstractILEdge; 
		
		/*
		* every edge constructed knows its endpoints, and installs itself 
		* in its endpoints' incidence lists.
		*/
		public function ILNormalEdge( collection:ICollection , v1:ILVertex , v2:ILVertex , elt:Object , isEdgeDirected:Boolean = false ) 
		{
			super( collection , elt, isEdgeDirected );

			_v1 = v1;
			_v2 = v2;

			// link self into one endpoint's edge list:
			_prev1 = v1.getPlaceholderEdge();
			_next1 = AbstractILEdge(_prev1.next);
			_prev1.setNext( v1, this );
				
			// symmetric code for other endpoint:
			_prev2 = v2.getPlaceholderEdge();
			_next2 = AbstractILEdge(_prev2.next);
			_prev2.setNext( v2, this );
		}
		
		override public function toString() :String
		{
			var returnVal:String = "[object ILNormalEdge ";
			returnVal += "("+getElement()+")]";
			return returnVal;
		}
	
		
		override public function detach() : void
		{
			// unlink self from endpoints' edge lists:			
			_prev1.setNext( _v1, _next1 );
	    	_prev2.setNext( _v2, _next2 );
	    	
			// encourage explosions if a bug happens:
			_prev1 = _next1 = _prev2 = _next2 = null;
			_v1 = _v2 = null; 
		}		
		
		override public function getNext( whichEnd:IVertex ) : AbstractILEdge
		{
			var returnPos:AbstractILEdge;
			if( _v1 == whichEnd ) 
			{
				returnPos = _next1;
			}
			else if( _v2 == whichEnd )
			{
				if ( _v2 != whichEnd ) throw new Error("ILNormalEdge::getNext::Assertion failed!");
				returnPos = _next2;
			}
			
			return returnPos;
		}
		
		override public function setNext( whichEnd:IVertex , n:AbstractILEdge ) : void
		{
			whichEnd as IVertex;
			n as IEdge;
			if( _v1==whichEnd ) 
			{
				_next1 = n as AbstractILEdge;
			}
			else if( _v2 == whichEnd )
			{
				if ( _v2 != whichEnd ) throw new Error("ILNormalEdge::setNext::Assertion failed!");
				_next2 = n as AbstractILEdge;
			}
		}
		
		/**
		* @inheritDoc
		*/
		override public function get origin() : IVertex
		{
			return _v1;
		}
		
		/**
		* @inheritDoc
		*/
		override public function get destination() : IVertex
		{
			return _v2;
		}
		
		/**
		* @private
		*/
		override public function set origin( v:IVertex ) : void
		{
			if(v==_v1) return;
			if(v==_v2) swapEndpoints();
			else throw new Error( "Vertex " + v +" not an endpoint of edge " + this );
		}

		/**
		* @private
		*/
		override public function set destination( v:IVertex ) : void
		{
			if(v==_v2) return;
			if(v==_v1) swapEndpoints();
			else throw new Error( "Vertex " + v +" not an endpoint of edge " + this );
		}
		
		/**
		* @inheritDoc
		*/
		override public function opposite( v:IVertex ) : IVertex
		{
			if ( v != _v1 ) return _v1;
			else return _v2;
		}

		/**
		* @inheritDoc
		*/
		override public function getType( endpoint:IVertex = null ) : int
		{
			if ( endpoint == null ) endpoint = _v1;
			if( isEdgeDirected() == true ) 
			{
				if( endpoint == _v1 ) return EdgeType.OUT; //2
				if ( endpoint != _v2 ) throw new Error("not an endpoint");
				
				return EdgeType.IN; // 1
			}
			else 
			{
				if ( endpoint != _v1 && endpoint != _v2 ) throw new Error("not an endpoint");
			
				return EdgeType.UNDIR; //4
			}
		}
		
				
		/**
		* @inheritDoc
		*/
		override public function isEdgeSelfLoop() : Boolean 
		{
			return false; 
		}
		
		/**
		* @inheritDoc
		*/
		override public function swapEndpoints() : void
		{
			var vtemp:ILVertex = _v1 ;
			_v1 = _v2 ;
			_v2 = vtemp;

			var etemp:AbstractILEdge = _next1;
			_next1 = _next2;
			_next2 = etemp;

			etemp = _prev1;
			_prev1 = _prev2;
			_prev2 = etemp;
		}
	
	
	}
}