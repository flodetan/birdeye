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

package org.un.cava.birdeye.guvis.coraldata.core.api.structure.sequence
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.sequence.ISequenceNode;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.IImmutablePositionalCollection;
	
	/**
	 * Interface for a read-only sequence of nodes.
	 */
	public interface IImmutableSequence extends IImmutablePositionalCollection 
	{
	  
		/** 
		* The first position of the sequence.
		* @return The first node in the sequence
		* @throws Error if this sequence is empty
		*/
		function getFirst() : ISequenceNode ;
	

		/** 
		* The last position of the sequence.
		* @return Position of the last element in the sequence
		* @throws Error if this sequence is empty
		*/
		function getLast() : ISequenceNode ;
	
	
		/** 
		* Check if the given position is the first.
		* @param p A Position in this sequence
		* @return True if and only if the given position is the first in the 
		* sequence
		* @throws Error if <code>p</code> is not a valid position in this sequence
		*/
		function isFirst( p:ISequenceNode ) : Boolean ;
		
		
		/** 
		* Check if the given position is the last.
		* @param p A Position in this sequence
		* @return True if and only if the given position is the last in the 
		* sequence
		* @throws Error if <code>p</code> is not a valid position in this sequence
		*/
		function isLast( p:ISequenceNode ) : Boolean ;
		

		/** 
		* The position before the supplied position.
		* @param p A Position in this sequence
		* @return Position previous to parameter position <code>p</code>
		* @throws Error if <code>p</code> is not a valid position in this sequence
		* @throws Error if p is the first position of this sequence.
		*/
		function getBefore( p:ISequenceNode ) : ISequenceNode ;
		
		/** 
		* The next position in the sequence.
		* @param p A Position in this sequence.
		* @return Position after parameter position <code>p</code>
		* @throws InvalidAccessorException Thrown if <code>p</code> is 
		* not a valid position in this sequence
		* @throws Error if p is the last position of this sequence.   
		*/
		function getAfter( p:ISequenceNode ) : ISequenceNode ;
		
		
		/** 
		* Get the node in the sequence at the specified index position.
		* @param index An integer index of positions in the sequence; the
		* <code>Position</code> returned by <code>first()</code> is the
		* same as that returned by <code>getAtIndex(0)</code), and the position
		* returned by <code>last()</code> is the same as that returned by
		* <code>getAtIndex(size() - 1)</code>.
		* @return position at the specified index
		* @throws Error if index<0 or index>=size()
		**/
		function getAtIndex( index:int ) : ISequenceNode ;
		
		
		/** 
		* Determine first location of a value in list.
		* @param p A Position in this sequence
		* @return Index of that element, where first element has index 0
		* and the last has index <code>size() - 1</code>.
		* @throws Error if <code>p</code> is not a valid position in this sequence
		*/
		function indexOf( p:ISequenceNode ) : int ;
		
		
		/** 
		* Determine last location of a value in list.
		* @param p A Position in this sequence
		* @return index (0 is first node) of value, or -1.
		* @throws Error if <code>p</code> is not a valid position in this sequence
		*/
		function lastIndexOf( p:ISequenceNode ) : int ;
		
	}
}