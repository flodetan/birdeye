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
	import flash.utils.Dictionary;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeature;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSet;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSupport;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.DictionaryIterator;
	
	/** 
	 * An abstract class implementing the methods of an object that supports 
	 * features. 
	 */
	public final class FeatureSet extends AbstractFeature implements IFeatureSet
	{
		/**
		* The features on this object
		*/
		protected var _features:Dictionary;
		
		/**
		* Abstract base class of all data structure accessors and collections.
		* This class allows for an arbitrary number and type of "feature" 
		* objects to be associated with an accessor or collection. 
		*/
		public function FeatureSet( target:IFeatureSupport )
		{
			super(target);
			_features = new Dictionary();
		}
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IFeatureSet
		//////////////////////////////////////////////////////////////////
		
		/**
		* @inheritDoc
		*/
		public function removeFeature( request:IFeatureRequester ) : void
		{
			delete _features[request];
		}
		
		
		/**
		* If a requested feature class is not found within the underlining 
		* feature dictionary, each item in the dictionary is checked, and if 
		* any are a subclass of the requested feature, the first occurrence  
		* is the feature that is returned. 
		* @inheritDoc
		*/
		public function getFeature( request:IFeatureRequester ) : IFeature
		{
			var feature:IFeature = _features[request] as IFeature;
			if (feature == null)
			{
				feature = request.instantiate(target);
				_features[request] = feature;
			}
			
			return feature;
		}
		
		/**
		* @inheritDoc
		*/
		public function hasFeature( request:IFeatureRequester ) : Boolean
		{
			if ( _features[request] != null )
				return true;
			return false;
		}
		
		/**
		* @inheritDoc
		*/
		public function listFeatures() : IIterator
		{
			return new DictionaryIterator(_features);
		}

		/**
		* @inheritDoc
		*/
		public function purgeFeatures() : void
		{
			_features = new Dictionary();
		}

		
	}
}