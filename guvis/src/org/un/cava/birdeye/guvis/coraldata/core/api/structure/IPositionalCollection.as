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

package org.un.cava.birdeye.guvis.coraldata.core.api.structure
{

	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition

	/** 
	* Positional collections (for example, sequences, trees, and graphs)
	* are collections in which elements are related to each other through
	* adjacency information.
	* <p>
	* A positional collection stores elements at its positions and defines
	* adjacency relationships between the positions (for example,
	* before/after in a sequence, parent/child in a tree).  Thus, the model of
	* storage is topological -- i.e., a positional collection is a graph, or some 
	* restricted version of a graph. This means that the position at which an
	* element is stored is decided by the user and is arbitrary from
	* the point of view of the collection.
	*/
	public interface IPositionalCollection extends IImmutablePositionalCollection, ICollection
	{
		/** 
		 * Swaps the elements associated with
		 * the two positions, leaving
		 * the positions themselves where they were.  
		 * @param a First <code>IPosition</code> to swap
		 * @param b Second <code>IPosition</code> to swap
		 */
		function swapElements ( a:IPosition , b:IPosition ) : void;
	}
}