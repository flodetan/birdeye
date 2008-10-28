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

package org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph
{	

	/**
	 * An interface enforcing the methods needed to add vertices and edges to a
	 * graph.
	 */
	public interface IGraph extends IModifiableGraph 
	{
		/*----------------------------------------------------------------------
		* public methods
		*---------------------------------------------------------------------*/    		
		/**
		* Inserts a new isolated vertex.
		* @param element the object to be stored in the new vertex
		* @return the new vertex
		*/
		function insertVertex( element:Object = null ) : IVertex;
				
		/**
		* Inserts a new edge between two existing vertices.
		* 	
		* @param v1 the first endvertex
		* @param v2 the second endvertex
		* @param element the object to be stored in the new edge
		* @param ofType The type of edge to insert, use EdgeType.UNDIR, EdgeType.IN, or 
		* EdgeType.OUT. Default is EdgeType.UNDIR.
		* (static constant from <code>EdgeType</code> is not used because interfaces do not support  
		* references to static constants of classes unfortunately.)
		* @return the new edge
		*/
		function insertEdge( v1:IVertex , v2:IVertex , element:Object = null , ofType:int = 4 /*EdgeType.UNDIR*/ ) : IEdge ;		
	}
}