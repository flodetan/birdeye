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
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.ArrayIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.AbstractPositionalCollection;

	
	/**
	 * This is a stripped down SinglyLinkedList implementation that is 
	 * provided only for use by the IncidenceListGraph. Because of missing
	 * methods the expected ISequence interface is not enforced on this class.
	 * Unlike the true SinglyLinkedList, positions are added to the 
	 * collection through externally created instances of IncidenceListNode, 
	 * an error being thrown otherwise. This class exists for special scenarios
	 * such as that used by IncidenceListGraph, whose vertices and edges are 
	 * instances of IncidenceListNode, but cannot be created from within 
	 * IncidenceList.
	 * 
	 * @see org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.IncidenceListGraph
	 */
	internal class IncidenceList extends AbstractPositionalCollection /*implements ISequence*/
	{
		/*----------------------------------------------------------------------
		* properties
		*---------------------------------------------------------------------*/		
		/**
		 * Reference to _head of list.
		 */
		protected var _head : IncidenceListNode;
		/**
		 * Reference to _tail of list.
		 */
		//protected var _tail : IncidenceListNode;
		
		/**
		* Cache for positions and elements; discarded upon modification
		*/
		protected var _positions:Array/*<IPosition>*/ = null;
		protected var _elements:Array/*<Object>*/ = null;
		
		/*----------------------------------------------------------------------
		* constructor
		*---------------------------------------------------------------------*/
		/**
		 * Constructs an empty list.
		 *
		 * @param aliasCollection The collection positions of this list are 
		 * treated as being a part of.
		 * 
		 */
		public function IncidenceList()
		{
			super();
		}
	
		/*----------------------------------------------------------------------
		* public methods
		*---------------------------------------------------------------------*/

		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableCollection
		//////////////////////////////////////////////////////////////////

		/**
		 * contains needs to be overridden with a slower implementation than 
		 * SinglyLinkedList, since accessors can be injected into this collection
		 * they could be labeled as part of this collection before they actually
		 * are. Because of this the contains method cannot just depend on 
		 * checking the <code>collection</code> property of a particular accessor.
		 * @param The accessor to check for.
		 * @inheritDoc
		 */
		override public function doesContain( pos:IAccessor ) : Boolean
		{
			// old style check of whether this accessor is in this collection.
			var finger:IncidenceListNode = _head;
			while ( (finger != null) && !(finger === pos) )
			{
				finger = finger.next as IncidenceListNode;
			}	
			return finger != null;
		}

		/**
		* @inheritDoc
		*/
		override public function elements() : IIterator
		{
			// if the cache is invalid, create it
			if(_elements == null) 
			{
				_elements = new Array(_size);
				var cur:IncidenceListNode = _head;
				for(var i:int=0; i<_size; i++) 
				{
					_elements[i] = cur.getElement();
					cur = cur.next as IncidenceListNode;
				}
			}
			return new ArrayIterator(_elements);
		}

		//////////////////////////////////////////////////////////////////
		// Methods implemented from ICollection
		//////////////////////////////////////////////////////////////////
	
		/**
		 * @inheritDoc
		 */
		override public function clear() : void
		{
			//_head = _tail = null;
			_head = null;
			_size = 0;
			
			// clear the caches
			_elements = null;
			_positions = null;
		}

		/**
		 * @inheritDoc
		 */
		override public function remove( a:IAccessor , caller:Function = null ) : Object
		{
			var returnVal:Object = a.getElement();
			var finger : IncidenceListNode = _head;
			var previous : IncidenceListNode = null;
			
			while (finger != null && !(finger === a) )
			{
				previous = finger;
				finger = finger.next as IncidenceListNode;
			}
			// finger points to target value
			if (finger != null) 
			{
				// we found element to remove
				if (previous == null) // it is first
				{
					_head = finger.next as IncidenceListNode;
				} 
				else 
				{              
					// it is not first
					previous.next = finger.next;
				}
				_size--;
				// clear caches
				_elements = null;
				_positions = null;
			}
			
			// callback not required as the accessor is destroyed in the 
			// incidence graph, not here
			//if (caller != a.destroy) a.destroy(arguments.callee);
			
			return returnVal;
		}
		
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutablePositionalCollection
		//////////////////////////////////////////////////////////////////

		/**
		 * @inheritDoc
		 */
		override public function positions() : IIterator
		{
			// if the cache is invalid, create it
			if(_positions == null) 
			{
				_positions = new Array(_size);
				var cur:IncidenceListNode = _head;
				for(var i:int = 0 ; i < _size ; i++) 
				{
					_positions[i] = cur;
					cur = cur.next as IncidenceListNode;
				}
			}
			return new ArrayIterator(_positions);
		}

		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableSequence
		//////////////////////////////////////////////////////////////////		
		
		
		/**
		 * Get value at location i.
		 *
		 * @pre 0 <= i < size()
		 * @post returns object found at that location
		 *
		 * @param i position of value to be retrieved.
		 * @return value retrieved from location i (returns null if i invalid)
		 */
		public function getAtIndex( i:int ) : IPosition
		{
			if (i >= size()) return null;
			var finger : IncidenceListNode = _head;
			// search for nth element or end of list
			while (i > 0)
			{
				finger = finger.next as IncidenceListNode;
				i--;
			}
			return finger;
		}
		
	
		/**
		* Make toInsert the last position of this sequence
		* @param toInsert Position of a compatible type for this sequence
		* @exception InvalidAccessorException If toInsert is already
		* contained or is of an incompatible type
		* This method also clears the position cache.
		* O(1) time
		*/
		public function posInsertLast( toInsert:IncidenceListNode ) : void
		{
			if ( isEmpty() == true )
			{
				_posInsertOnly(toInsert);
			}
			else
			{
				_posInsertAfter( IncidenceListNode(getAtIndex(_size-1)) , toInsert);
			}
		}


	  	/**
		* This method inserts a position into an empty Sequence.
		* It also clears the position cache
		* @param toInsert The Position to Insert
		* O(1) time
		*/
		private function _posInsertOnly( toins:IncidenceListNode ) : void
		{
			_head = toins;
			_size = 1;
			_positions = null;
			_elements = null;
		}
		
		
		/**
		* Make toInsert the successor of willBePredecessor
		* @param willBePredecessor a position in this sequence
		* @param toInsert Position of a compatible type for this sequence
		* @exception InvalidAccessorException If toInsert is already
		* contained or is of an incompatible type, or if willBePredecessor
		* is invalid for one of the usual invalid-position reasons
		* This method also clears the position cache.
		* O(1) time
		*/
		private function _posInsertAfter( willBePredecessor:IncidenceListNode , toInsert:IncidenceListNode ) : void
		{
			// clear the caches
			_positions = null;
			_elements = null;
			
			willBePredecessor.next = toInsert;
			_size++;
		}
	
		/**
		 * Construct a string representation of list.
		 * @return A string representing elements of list.
		 */
		public function toString() : String
		{
			var s : String = "";
			s += "[object IncidenceList:";
			var li:IIterator = elements();
			while (li.hasNext())
			{
				s += " ("+li.next()+")";
			}
			s += "]";
			return s;
		}
		
	}
}
