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
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.IPositionalCollection;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IPosition;
	import org.un.cava.birdeye.guvis.coraldata.core.api.access.IAccessor;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeatureRequester;
	import org.un.cava.birdeye.guvis.coraldata.core.api.feature.IFeature;
	
	/**
	 * An abstract positional collection, handles basic methods present in all positional 
	 * collections.
	 */
	public class AbstractPositionalCollection extends AbstractCollection implements IPositionalCollection 
	{

		/*----------------------------------------------------------------------
		* public methods
		*---------------------------------------------------------------------*/
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutableCollection
		//////////////////////////////////////////////////////////////////
		
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from ICollection
		//////////////////////////////////////////////////////////////////
		

		//////////////////////////////////////////////////////////////////
		// Methods implemented from IImmutablePositionalCollection
		//////////////////////////////////////////////////////////////////
		
		/** 
		* @inheritDoc
		*/ 
		public function positions() : IIterator
		{
			throw new Error("Abstract method "+this);
		}
		
		
		//////////////////////////////////////////////////////////////////
		// Methods implemented from IPositionalCollection
		//////////////////////////////////////////////////////////////////		
		
		/** 
		* @inheritDoc
		*/ 
		public function swapElements( a:IPosition , b:IPosition ) : void
		{
			// Require that both of the swappees be in this container
			if((!super.doesContain(a)) || (!super.doesContain(b)))
			{
			  throw new Error("Positions do not belong to this container");
			}
			
			var aelt:Object = a.getElement();
			a.setElement(b.getElement());
			b.setElement(aelt);
		}
		
	}
}