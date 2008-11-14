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

package org.un.cava.birdeye.guvis.coraldata.core.impl.access
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.ICollection;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.feature.AbstractFeatureSupport;
	
	/** 
	 * An abstract class implementing the methods of an accessor, 
	 * the predecessor of a position and a locator. 
	 */
	public class AbstractAccessor extends AbstractFeatureSupport implements IAccessor
	{
		
		/**
		* @private
		*/
		protected var _element:Object;
		
		/**
		 * @private
		 */
		protected var _collection:ICollection;
		
		/**
		* Create a new AbstractAccessor instance. While this class 
	 	* does not contain any methods that throw errors if not overridden, it
	 	* should not be instantiated directly but instead should be subclassed.
		*/
		public function AbstractAccessor( collection:ICollection , element:Object )
		{
			_collection = collection;
			_element = element;
			//_features = new FeatureSet();
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IAccessor
		//////////////////////////////////////////////////////////////////		
		/**
		* @inheritDoc
		*/
		public function getElement() : Object 
		/*throws InvalidAccessorException*/
		{
			return _element;
		}
		
		/**
		* @inheritDoc
		*/
		public function get collection() : ICollection
		{
			return _collection;
		}
		
		/**
		* @inheritDoc
		*/
		public function destroy( caller:Function = null ) : Object
		{
			var returnVal:Object = _element;
			//trace( "destroying..." , this );
			if (caller != _collection.remove) _collection.remove( this , arguments.callee );
			_collection = null;
			_element = null;
			_features = null;
			return returnVal;
		}
	}
}