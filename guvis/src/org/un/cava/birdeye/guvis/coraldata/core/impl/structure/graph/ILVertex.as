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
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.ArrayIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IVertex;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	
	/**
	 * Vertices of <code>IncidenceListGraph</code>.  The inheritance
	 * from FNSNode works the magic by which a vertex is also
	 * a position in the global vertex list.  The vertex keeps a circularly
	 * linked list of its incident edges.  The edges themselves contain
	 * the links that implement the list (and since each edge has two
	 * endpoints, it must have two sets of links).  The vertex starts
	 * out with a dummy edge in order to avoid special-casing on
	 * empty lists and ends of lists.
	 *
	 * @see IncidenceListGraph
	 */
	internal class ILVertex extends IncidenceListNode implements IVertex 
	{
		/**
		* vertex holds circularly linked list of edges, with one null placeholder edge
		* always present
		*/
		private var _nullEdge:ILNullEdge;
	
	
		/**
		 * Create a new isolated vertex.
		 *
		 * @param collection  The graph
		 * @param elt   The element associated with this position
		 */
		public function ILVertex( collection:ICollection, elt:Object ) 
		{
			super( collection , elt );
			_nullEdge = new ILNullEdge( collection );
		}
	
		// used by a newly inserted edge to install itself in
		// its endpoints' incidence lists:
		public function getPlaceholderEdge() : ILNullEdge 
		{
			return _nullEdge; 
		}
	
		override public function toString() : String
		{
			//return jdsl.graph.ref.ToString.stringfor(this);
			return "[object ILVertex ("+super.getElement()+") ]";
		}
	
	} // class ILVertex
	
}