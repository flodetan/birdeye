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
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IImmutableGraph;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IVertex;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.AbstractPositionalCollection;
	
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.ArrayIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.IteratorMerger;

	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;


	/**
	  * An implementation of many of the methods of IncidenceListGraph in terms
	  * of a few primitives.  Note that that says "IncidenceListGraph," not "Graph,"
	  * but that this class extends AbstractPositionalContainer, which
	  * implements replaceElements(.).  All the methods implemented here
	  * belong to IncidenceListGraph.
	  * <p>
	  * The implementor must define the primitives called by the
	  * functions here.  In addition, the implementor must define any
	  * primitives needed for <code>AbstractPositionalContainer</code>
	  * not defined here.
	  * <p>
	  * In several places when the AbstractGraph calls a method that the
	  * implementer must define, the AbstractGraph is relying on the
	  * implementer also checking the input vertex or edge for validity.
	  * <p>
	  * The complexities of the methods implemented here depend on
	  * the complexities of the underlying methods.  Therefore, the
	  * complexity documented for each method below is based on
	  * suppositions about the underlying implementation.
	  *
	 * @author Mark Handy
	 * @author Benoit Hudson
	  * @version JDSL 2.1.1 
	  */
	public class AbstractGraph extends AbstractPositionalCollection implements IImmutableGraph
	{
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableCollection
		//////////////////////////////////////////////////////////////////

		/**
		 * Built on numVertices() and numEdges().
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IImmutableGraph#numVertices();
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IImmutableGraph#numEdges();
		 * @inheritDoc
		 */
		override public function size() : int
		{
			return numVertices()+numEdges();
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from ICollection
		//////////////////////////////////////////////////////////////////
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutablePositionalCollection
		//////////////////////////////////////////////////////////////////
		
		/**
		 * Built on getVertices() and edges().
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IImmutableGraph#getVertices()
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IImmutableGraph#edges()
		 * @inheritDoc
		 */
		override public function positions() : IIterator
		{
			return new IteratorMerger( getVertices(), getEdges() );
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableGraph
		//////////////////////////////////////////////////////////////////
				
		/**
		 * @inheritDoc
		 */
		public function aVertex( e:IEdge = null ) : IVertex
		{
			throw new Error("Abstract method "+this);
		}

		/**
		 * @inheritDoc
		 */
		public function anEdge( ofType:int = EdgeType.ALL , v:IVertex = null ) : IEdge
		{
			throw new Error("Abstract method "+this);
		}
				
		/**
		 * @inheritDoc
		 */
		public function getEdges( incidentTo:IVertex = null , edgeType:int = EdgeType.ALL ) : IIterator
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function isEdgeSelfLoop( e:IEdge ) : Boolean
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function isEdgeDirected ( e:IEdge ) : Boolean
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
	  	public function areIncident( v:IVertex , e:IEdge ) : Boolean
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function numEdges() : int
		{
			throw new Error("Abstract method "+this);
		}

		/**
		 * @inheritDoc
		 */		
		public function numVertices() : int
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getEdgeOrigin ( e:IEdge ) : IVertex
		{
			throw new Error("Abstract method "+this);
		}

		/**
		 * @inheritDoc
		 */
		public function getEdgeDestination ( e:IEdge ) : IVertex 
		{
			throw new Error("Abstract method "+this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getEdgeType ( e:IEdge , v:IVertex = null ) : int 
		{
			throw new Error("Abstract method "+this);
		}

		/**
		 * @inheritDoc
		 */
		public function getVertices() : IIterator
		{
			throw new Error("Abstract method "+this);
		}
		
		
	}
}