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
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.IPositionalCollection;
	
	/**
	  * A positional container whose elements
	  * are linearly organized. It is a generalization of stacks, queues,
	  * linked lists, and arrays.</P>
	  *   
	  * <P>For a Sequence, methods <code>InspectableContainer.elements()</code>
	  * and <code>InspectablePositionalContainer.positions()
	  * are guaranteed to return iterators in first-to-last order.</P>
	  *   
	  * @version JDSL 2.1.1 
	 * @author Mark Handy (mdh)
	 * @author Luca Vismara (lv)
	 * @author Andrew Schwerin (schwerin)
	  * @see InspectableSequence
	  * @see PositionalContainer
	  */
	public interface ISequence extends IImmutableSequence, IPositionalCollection 
	{
	  
	  // Five insertion methods that take an Object element, and return
	  // the position of the element after inserting it into the sequence.
	  
	  /** 
		* Inserts an object as <i>first</i> element of the sequence
		* @param element Any java.lang.Object
		* @return The <code>Position</code> containing that <code>element</code>, 
		* which is now the first position in the sequence.
		*/
	  function addFirst ( element:Object ) : ISequenceNode;
	
	  
	  /** 
		* Inserts an object as <i>last</i> element of the sequence.
		* @param element Any java.lang.Object
		* @return The <code>Position</code> containing that <code>element</code>, 
		* which is now the last in the sequence.
		*/
	  function addLast ( element:Object ) : ISequenceNode;
	
	  
	  /**  Inserts an object <i>before</i> a position in the sequence.
		* @param p Position in this sequence before which to insert an 
		* element.
		* @param element Any java.lang.Object<br>
		* @return Position containing <code>element</code> and before
		* <code>Position p</code>.
		* @exception InvalidAccessorException Thrown if <code>p</code> is 
		* not a valid position in this sequence
		*/
	  function addBefore ( p:ISequenceNode , element:Object ) : ISequenceNode 
	  /*throws InvalidAccessorException*/;
	
	  
	  /** 
		* Inserts an object <i>after</i> a position in the sequence.  
		* @param p Position in this sequence after which to insert an
		* element.
		* @param element Any java.lang.Object<br>
		* @return Position containing <code>element</code> and after
		* <code>Position p</code>.
		* @exception InvalidAccessorException Thrown if <code>p</code> is 
		* not a valid position in this sequence
		*/
	  function addAfter ( p:ISequenceNode , element:Object ) : ISequenceNode
	  /*throws InvalidAccessorException*/;
	
		/** 
		* Inserts based on an integer rank similar to array indices.
		* The first element in the sequence has rank 0, and the last has rank
		* <code>size() - 1</code>.  It is valid to insert at any rank greater
		* than or equal to zero and less than or equal to <code>size()</code>.
		*
		* @param rank Rank that <code>element</code> should have after insertion.
		* @param element Any java.lang.Object<br>
		* @return Position of <code>element</code> in the sequence.
		* @exception BoundaryViolationException if <code>rank</code> exceeds
		* <code>size()</code> or if 0 exceeds <code>rank</code>
		*/
	  function addAtIndex ( index:int , element:Object ) : ISequenceNode /*throws BoundaryViolationException*/;
	

	}
}