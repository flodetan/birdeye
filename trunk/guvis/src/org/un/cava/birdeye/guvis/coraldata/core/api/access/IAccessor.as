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

package org.un.cava.birdeye.guvis.coraldata.core.api.access
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeature;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSupport;
	
	/**
	 * The IAccessor interface represents a place within a data collection. 
	 * Elements of a data collection will typically not implement this 
	 * interface directly, but instead will implement one of its descendants, 
	 * either <code>ILocator</code> or <code>IPosition</code>. These two 
	 * interfaces are actually complements of each other: 
	 * an <code>ILocator</code> object stays with a specific element, even if 
	 * it changes from position to position, and an <code>IPosition</code> 
	 * object stays with a specific position, even if it changes the elements 
	 * it holds.
	 *
	 * <p>
	 * Classes implementing the <code>IPositionalCollection</code> interface use 
	 * <code>IPosition</code> accessors, and they add topological
	 * information (i.e., adjacency information) to the element-binding
	 * provided by IAccessor.  Classes implementing the 
	 * <code>KeyBasedCollection</code> interface use <code>ILocator</code> 
	 * accessors, and they add a key to <code>IAccessor</code>'s element.  
	 *
	 */
	public interface IAccessor extends IFeatureSupport
	{
		/** 
		 * The element stored at this accessor.
		 * @return The element currently stored at this accessor.
		 */
		function getElement():Object;
		
		/**
		* The collection this accessor is a member of, this can not be changed
		* after the accessor has been created.
		* @return The collection this accessor is a member of.
		*/
		function get collection() : ICollection;
		
		/**
	  	* <p>Destroy this accessor and remove it from its collection. 
	  	* This method and <code>collection.remove(accessor)</code> are the only 
	  	* means of removing an accessor from a collection. Destroying an 
	  	* accessor involves first retrieving the accessor from its collection, 
	  	* and then destroying it after retrieval.
	  	* Each collection implementation offers several methods for 
	  	* accessor retrieval at particular locations within the collection.</p>
	  	*
	  	* <p>The methods <code>accessor.destroy()</code> and 
	  	* <code>collection.remove(accessor)</code> are tightly coupled to each 
	  	* other. Calling one of these two methods will notify the other. To 
	  	* ensure this behavior, implementing classes must define the following:
	  	* </p><p><b><code>if (caller != _collection.remove) 
	  	* _collection.remove( this , arguments.callee );</code></b></p>
	  	* <p>This ensures that if 
	  	* <code>accessor.destroy()</code> is called it notifies
	  	* <code>collection.remove(accessor)</code> and vice versa. 
	  	* </p>
	  	* <p>Any class specific code needed to destroy an accessor
	  	* in a particular implementation may also be added. </p>
	  	*
	  	* @param caller The function that called this function, 
	  	* this is used for inter-method communication, so leave it null
	  	* @return The element stored at the destroyed accessor.
	  	* @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection#remove()
	  	*/
		function destroy( caller:Function = null ) : Object
		
	}
}