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

package org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.feature
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.IEdge;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.feature.FeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.feature.AbstractFeature;
	
	/**
	* A feature that adds the concept of a "weight" to the edges of a graph. 
	* Weighted edges can be useful for various traversal methods.
	*/
	public class WeightedEdgeFeature extends AbstractFeature
	{
		/*----------------------------------------------------------------------
		* constants
		*---------------------------------------------------------------------*/
		/**
		* A token used to request this feature.
		*/
		public static const request:IFeatureRequester = new FeatureRequester( WeightedEdgeFeature , IEdge );
	
		/*----------------------------------------------------------------------
		* properties
		*---------------------------------------------------------------------*/
		/**
		* The weight of the edge.
		*/
		private var _weight_:int = 0;
	
		/*----------------------------------------------------------------------
		* getter / setter methods
		*---------------------------------------------------------------------*/
		public function get weight( ) : int 
		{
			return _weight_;
		}
		
		public function set weight( value:int ) : void 
		{
			_weight_ = value;
		}
	
		/*----------------------------------------------------------------------
		* constructor
		*---------------------------------------------------------------------*/
		public function WeightedEdgeFeature ( accessor:IEdge ) 
		{
			super(accessor);
		}
		
	}
}