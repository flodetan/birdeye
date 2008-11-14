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
 * $HeadURL: $
 * $LastChangedBy$
 * $Date$
 * $Revision$
 */

package org.un.cava.birdeye.guvis.coraldata.core.api.iterator
{
	
	/**
	 * Iterator over a set of objects.  No order of the objects is required  
	 * by this interface, although order may be promised or required
	 * by users of the interface.  Conceptually, the iterator starts out
	 * positioned before the first object to be considered.  With each call
	 * to <code>next()</code>, the iterator skips over another object and 
	 * returns the object skipped over, until the iterator is positioned after 
	 * the last object.
	 */
	public interface IIterator 
	{
		/** 
		 * Check for more positions in the iterator.
		 * @return <code>true</code> if there are more positions in this iteration, <code>false</code>
		 * otherwise.
		 */
		function hasNext() : Boolean;
		
		/**
		* The value of the current iterator position.
		* @return The current value.
		*/
		function next() : Object;
	
		/** 
		 * @return The object returned by the most recent next()
		 */
		function current() : Object;
	
		/** 
		 * Puts the iterator back in its initial, before-the-first state
		 */
		function reset() : void;
	
		/**
		 * The number of items in this iterator.
		 * @return The number of items in this iterator.
		 */
		function size() : int;
	}
}