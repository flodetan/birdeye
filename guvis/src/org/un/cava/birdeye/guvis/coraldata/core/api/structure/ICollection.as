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

package org.un.cava.birdeye.guvis.coraldata.core.api.structure
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	
	/**
	* An interface enforcing collection of data that can have accessors removed.
	*/
	public interface ICollection extends IImmutableCollection
	{
		/**
		* Remove all accessors from the collection.
		*/
		function clear() : void;
		
		/**
	  	* <p>Remove an accessor from this collection. 
	  	* This and <code>accessor.destroy()</code> are the only means of 
	  	* removing an accessor from a collection. Subinterfaces may define
	  	* numerous retrieval methods that can be used to retrieve an accessor 
	  	* at a particular index, which then can be removed.</p>
	  	*
	  	* <p>This method is tightly coupled to the <code>accessor.destroy()</code> 
	  	* method. Therefore, implementing classes must define the following:
	  	* </p><p><code>if (caller != a.destroy) a.destroy(arguments.callee);</code></p>
	  	* <p>This ensures that if 
	  	* <code>collection.remove(accessor)</code> is called it notifies
	  	* <code>accessor.destroy()</code> and vice versa. 
	  	* Any class specific code needed to remove an accessor
	  	* from a particular implementation may also be added. </p>
	  	*
	  	* @param a The accessor to remove
	  	* @param caller The function that called this function, 
	  	* this is used for inter-method communication, so leave it null
	  	* @return The element stored at the accessor that is being removed
	  	* @see org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor#destroy()
	  	*/
		function remove( a:IAccessor , caller:Function = null ) : Object;
		
	}
	
}