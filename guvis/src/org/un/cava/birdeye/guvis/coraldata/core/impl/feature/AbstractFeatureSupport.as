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

package org.un.cava.birdeye.guvis.coraldata.core.impl.feature
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSet;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSupport;
	
	/** 
	 * An abstract class implementing the methods of an object that supports 
	 * features. 
	 */
	public class AbstractFeatureSupport implements IFeatureSupport
	{
		/**
		* The features on this object
		*/
		protected var _features:IFeatureSet;
		
		/**
		* Abstract base class of all data structure accessors and collections.
		* This class allows for an arbitrary number and type of "feature" 
		* objects to be associated with an accessor or collection. 
		*/
		public function AbstractFeatureSupport( )
		{
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IFeatureSupport
		//////////////////////////////////////////////////////////////////
		
		/**
		* @inheritDoc
		*/
		public function get features( ) : IFeatureSet
		{
			//lazy instantiation of FeatureSet instance
			if (_features == null) _features = new FeatureSet(this);
			return _features;
		}

		
	}
}