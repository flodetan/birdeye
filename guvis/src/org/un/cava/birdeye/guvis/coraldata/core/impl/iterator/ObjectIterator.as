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
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.AbstractKeyBasedIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IKeyBasedIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.IteratorError;
	
	/**
	* Iterate over the enumerable properties of an ActionScript object.
	* No particular order is given.
	* Object is converted into an Array at instantiation to prevent having to 
	* loop through the object every time next() and current() are called.
	*/
	public class ObjectIterator extends AbstractKeyBasedIterator implements IKeyBasedIterator
	{		
		/**
		* Instantiate a new iterator traversal over an object.
		* @param The object to traverse.
		*/
		public function ObjectIterator( obj:Object ) 
		{
			super( obj );
			var arr:Array = [];
			var arrKey:Array = [];
			for (var i:Object in obj)
			{
				arr.push(obj[i]);
				arrKey.push(i);
			}
			
			_collection = arr;
			_collectionKeys = arrKey;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function hasNext() : Boolean 
		{
			var collLen:int = _collection.length;
			return (_pos < collLen-1 && collLen > 0);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function next() : Object 
		{
			var collLen:int = _collection.length;
			_currObj = _collection[++_pos];
			if (_pos >= collLen) throw IteratorError.ofType( IteratorError.TRAVERSAL_OUT_OF_BOUNDS );
			return ( _currObj );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function key() : Object
		{
			if ( _pos == -1 ) throw IteratorError.ofType( IteratorError.TRAVERSAL_NOT_STARTED );
			
			return _collectionKeys[_pos];
		}
		
		/**
		 * @inheritDoc
		 */
		override public function size() : int
		{
			return _collection.length;
		}
		
	}
}