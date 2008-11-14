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

package org.un.cava.birdeye.guvis.coraldata.core.impl.iterator
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	
  
	/**
	* Class to merge two iterators together and treat them as though they were
	* part of a single collection for the purpose of iterating over both 
	* in one iteration.
	*/
	public class IteratorMerger implements IIterator 
	{
	
		/**
		* Merge this iterator...
		*/
		private var _it1 : IIterator;

		/**
		* ...with this iterator.
		*/
		private var _it2 : IIterator;
		
		private static const ITERATION_COMPLETE : int = 0;
		private static const IN_FIRST_ITERATOR : int = 1;
		private static const IN_SECOND_ITERATOR : int = 2;
		
		/**
		* The current process state the merged iterator is in. It can either 
		* be in the first iterator, the second iterator, or be finished with 
		* the iteration.
		*
		* @see #IN_FIRST_ITERATOR
		* @see #IN_SECOND_ITERATOR
		* @see #ITERATION_COMPLETE
		*/
		private var process_:int; 
		
		/**
		* cache for answering the no-advance queries
		*/
		private var currObj_:*;
	
		/** 
		 * Instantiate a new IteratorMerger instance.
		 * Asserts that neither iterator is null.
		 * @param it1 Merge this iterator...
		 * @param it2 ...with this iterator.
		 */
		public function IteratorMerger ( it1:IIterator , it2:IIterator ) 
		{
			if ( (it1 == null) || (it2 == null) ) throw IteratorError.ofType( IteratorError.TARGET_NULL );
			_it1 = it1;
			_it2 = it2;
			process_ = IN_FIRST_ITERATOR;
			currObj_ = undefined;
		}
	
		/**
		* note that hasNext() changes the internal state of the iterator,
		* though not in an externally visible way
		*/
		public function hasNext() : Boolean
		{
			if ( process_ == IN_FIRST_ITERATOR ) 
			{
				if ( _it1.hasNext() ) 
				{
					return true;
				}
				else 
				{
					process_ = IN_SECOND_ITERATOR;
				}
			}
			
			if ( process_ == IN_SECOND_ITERATOR ) 
			{
				if ( _it2.hasNext() ) 
				{
					return true;
				}
				else 
				{
					process_ = ITERATION_COMPLETE;
				}
			}
			
			// This shouldn't need to be asserted because process_ is controlled internally in this class.
			//Assert.condition( process_ == ITERATION_COMPLETE , "IteratorMerger::hasNext process_ is out of range" );
			
			return false;
		}
		
		/**
		* @return The next object
		*/
		public function next() : Object
		{
			if ( hasNext() == false ) 
			{
				return undefined;
			}
			
			// process_ has now been updated to an iterator that hasNext()
			switch( process_ ) 
			{
				case IN_FIRST_ITERATOR : return ( currObj_ = _it1.next() );
				case IN_SECOND_ITERATOR : return ( currObj_ = _it2.next() ); 
				default: return undefined;
			}
		}
	
		/**
		* @return The current object in the iterator, or undefined if the 
		* iterator has not been advanced to the first position using next, or
		* is beyond the elements in the iteration.
		*/
		public function current() : Object
		{			
			return currObj_;
		}
	
		/**
		 * @inheritDoc
		 */
		public function reset() : void
		{
			_it1.reset();
			_it2.reset();
			process_ = IN_FIRST_ITERATOR;
			currObj_ = undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		public function size() : int
		{
			return ( _it1.size() + _it2.size() );
		}
		
	}
}