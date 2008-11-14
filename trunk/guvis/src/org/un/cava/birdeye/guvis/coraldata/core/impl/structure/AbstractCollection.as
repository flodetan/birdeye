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

package org.un.cava.birdeye.guvis.coraldata.core.impl.structure
{
	import flash.utils.Dictionary;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeature;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.DictionaryIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.feature.AbstractFeatureSupport;
	
	/**
	 * An abstract collection, handles basic methods present in all collections.
	 */
	public class AbstractCollection extends AbstractFeatureSupport implements ICollection
	{
		/*----------------------------------------------------------------------
		* properties
		*---------------------------------------------------------------------*/
		
		/**
		* The number of positions in this collection.
		*/
		protected var _size:int;

		/*----------------------------------------------------------------------
		* contructor
		*---------------------------------------------------------------------*/    
		public function AbstractCollection()
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
		* @inheritDoc
		*/
		public function doesContain( a:IAccessor ) : Boolean  
		{
			// Since accessors have a reference to their collection
			// the contains method can be performed very quickly.
			if (a == null) throw new Error("Supplied accessor is null.");
			
			return (a.collection === this);
		}
		
		/** 
		* @inheritDoc
		*/
		public function isEmpty() : Boolean 
		{ 
			return (size() == 0); 
		}
		
		/** 
		* @inheritDoc
		*/
		public function elements() : IIterator
		{
			throw new Error("Abstract method "+this);
		}

		/** 
		* @inheritDoc
		*/
		public function size() : int
		{
			return _size;
		}
		
		/** 
		* @inheritDoc
		*/
		public function findAccessorByElement( element:Object ) : IAccessor
		{
			throw new Error("Abstract method "+this);
		}
		

		//////////////////////////////////////////////////////////////////
		// Methods implemented from ICollection
		//////////////////////////////////////////////////////////////////
		
		/** 
		* @inheritDoc
		*/ 
		public function remove( a:IAccessor , caller:Function = null  ) : Object
		{
			throw new Error("Abstract method "+this);
		}
	  
		/** 
		* @inheritDoc
		*/ 
		public function clear() : void
		{
			throw new Error("Abstract method "+this);
		}
		
	}
}