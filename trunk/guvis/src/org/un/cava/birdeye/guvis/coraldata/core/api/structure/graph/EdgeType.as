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
	 * Static final class containing constants for specifying which edges are desired in
	 * graph-query methods. Note that constants can be OR'd together using bitwise operations 
	 * in any combination. For example, <code>EdgeType.UNDIR | EdgeType.SELFLOOP</code> specifies 
	 * all undirected and self-loop edges.
	 *
	 * Unlike most of the <code>coraldata.core.api</code> package, this is a concrete class as 
	 * opposed to an interface because constants can not be added to an interface.
	 * 
	 * @example The following code returns all the undirected and self-loop edges incident to 
	 * a randomly retrieved vertex.
	 * <listing version="3.0" > 
	 * 
	 * var it:IIterator = graph.getEdges( graph.aVertex() , (EdgeType.UNDIR | EdgeType.SELFLOOP) );
	 * 
	 * </listing>
	 */
	public final class EdgeType
	{
		/**
		* The edge is directed and is incoming in relation to a particular vertex.
		*/
		public static const IN : int = 1;

		/**
		* The edge is directed and is outgoing in relation to a particular vertex.
		*/
		public static const OUT : int = 2;

		/**
		* The edge is undirected and is both incoming and outgoing in relation to a particular 
		* vertex.
		*/
		public static const UNDIR : int = 4;

		/**
		* The edge is a self-loop, meaning it has the same beginning and ending vertex. In practice 
		* it is equivalent to an undirected edge, as it can be both incoming and outgoing on the 
		* same vertex.
		*/
		public static const SELF_LOOP : int = 8;
		
		/**
		* Provides a way to specify all edge types for bitwise operations.
		*/
		public static const ALL : int = 15;
		
		/**
		* @param type An edge type ID (see constants in this class)
		* @return <code>true</code> if the supplied edge type ID exists, 
		* <code>false</code> otherwise.
		*/
		public static function isValid( type:int ) : Boolean
		{
			if ( (type & EdgeType.IN) != 0 || 
				(type & EdgeType.OUT) != 0 || 
				(type & EdgeType.UNDIR) != 0 || 
				(type & EdgeType.SELF_LOOP) != 0 || 
				(type & EdgeType.ALL) != 0
				)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}