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
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeature;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureSupport;
	
	/**
	 * This class represents the key in a decoration added to an accessor.
	 * All it provides is a label to differentiate one Attribute from another.
	 */
	public class FeatureRequester implements IFeatureRequester
	{	
		/**
		* The class of the Feature associated with this FeatureRequester.
		*/
		private var _clazz:Class;
		
		/**
		* A class that the associated feature applies to.
		*/
		private var _appliesTo:Class;
		
		/**
		* Instantiate a new FeatureRequester.
		* @param clazz The class of the feature that is being requested.
		* @param appliesTo The accessor classes that this feature applies to.
		*/
		public function FeatureRequester( clazz:Class , appliesTo:Class = null ) 
		{
			_clazz = clazz;
			if (appliesTo == null) _appliesTo = IFeatureSupport;
			else _appliesTo = appliesTo;
		}
		
		/**
		* @inheritDoc
		*/
		/*public function isApplicable( to:IFeatureSupport ) : Boolean
		{
			// if length of the appliesTo array equals 0, the associated 
			// feature applies to all accessors, return true
			if ( _appliesTo.length == 0 ) return true;
			// if the class of the passed accessor is in the list of viable 
			// accessors return true
			for each( var acc:Class in _appliesTo )
			{
				if (to is acc) return true;
			}
			return false;
		}*/
		
		/**
		* @inheritDoc
		*/
		public function accepts( clazz:Class ) : Boolean
		{
			//if (_appliesTo.indexOf(clazz) != -1) return true;
			if (_appliesTo === clazz) return true;
			return false;
		}
		
		/**
		* @inheritDoc
		*/
		public function get featureClass() : Class
		{
			return _clazz;
		}
		
		/**
		* @inheritDoc
		*/
		public function instantiate( target:IFeatureSupport ) : IFeature
		{
			return new _clazz(target);
		}
		
		/**
		* A string representing this object.
		* @return A string representation of this object.
		*/
		public function toString() : String
		{
			return "[object FeatureRequester (" + _clazz + ")]";
		}
	}
}