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
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.access.AbstractPosition;
	
	/**
	* This class represents one node in a doubly linked list. Each node 
	* contains a value and maintains a reference to the next and previous node
	* in the list.
	*/	
	internal class IncidenceListNode extends AbstractPosition implements IPosition
	{
		/**
		* @private
		* The reference to preceeding node.
		*/
		protected var _next_ : IncidenceListNode;
		
		/**
		* Instantiate IncidenceListNode.
		*
		* @param value The value to be referenced by this node. Default value is null.
		* @param next A reference to the next node in the list. Default value is null.
		* @param previous A reference to the previous node in the list. Default value is null.
		*/
		public function IncidenceListNode( collection:ICollection , element:Object = null , next:IncidenceListNode = null /*, prev:IncidenceListNode = null*/ )
		{
			super( collection , element );
			
			_next_ = next;
		}
	
		/**
		* @inheritDoc
		*/
		public function get next() : IPosition
		{
			return _next_;
		}
		/**
		* @private
		*/
		public function set next( next:IPosition ) :void
		{
			_next_ = next as IncidenceListNode;
		}
		
		/**
		* A string represention of this node and its element.
		* @return A string representation of this node and its element.
		*/
		public function toString() : String
		{
			return "[object IncidenceListNode <"+super.getElement()+">]";
		}
	}	
}
