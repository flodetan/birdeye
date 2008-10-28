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

package org.un.cava.birdeye.guvis.coraldata.core.api.feature
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	
	/**
	 * Interface enforcing methods for managing a set of features.
	 * @see IFeature
	 */
	public interface IFeatureSet
	{
		/**
		* Remove a feature attached to this object.
		* @param request The feature requester for the feature.
		*/
		function removeFeature( request:IFeatureRequester ) : void;
		
		/**
		* Get a feature for this object.
		* @param request The feature requester for the feature.
		* @return The feature.
		*/
		function getFeature( request:IFeatureRequester ) : IFeature;
		
		/**
		* Whether this object has a particular feature.
		* @param request The feature requester for the feature.
		* @return <code>true</code> if the object has the feature, 
		* <code>false</code> otherwise.
		*/
		function hasFeature( request:IFeatureRequester ) : Boolean;
		
		/**
		* An iterator of features on this object.
		* @return An iterator of features on this object.
		*/
		function listFeatures() : IIterator;

		/**
		* Remove the features present on this object.
		*/
		function purgeFeatures() : void;
	}
}