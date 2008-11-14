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
	 * Final static class with convenience methods for getting and setting feature properties.
	 * Using these methods is slightly slower than setting and getting a property on a feature directly, 
	 * but may be more convenient to type. The difference is minimal. A benchmarking of both menthods contained
	 * in a code block that looped 100,000 times, showed a difference of 20 milliseconds.
	 */
	public final class FeatureUtil
	{	
		public static function setProperty( target:IFeatureSupport , clazz:Class , prop:String , value:*) : void
		{
			clazz(target.features.getFeature( clazz.request ))[prop] = value;
		}
		
		public static function getProperty(target:IFeatureSupport , clazz:Class , prop:String) : *
		{
			return clazz(target.features.getFeature( clazz.request ))[prop];
		}
	}
}