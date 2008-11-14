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
	/**
	* Errors thrown from iterator classes.
	*/
	public class IteratorError extends Error
	{
		public static const TARGET_NULL:int = 0;
		public static const TRAVERSAL_OUT_OF_BOUNDS:int = 1;
		public static const TRAVERSAL_NOT_STARTED:int = 2;
		
		public function IteratorError( message:String, errorID:int ) 
		{
			super(message, errorID);
		}
		
		public static function ofType( errorID:int ) : IteratorError
		{
			var msg:String = "";
			switch( errorID )
			{
				case TARGET_NULL : 
				msg += "The target object of an iterator cannot be null.";
				break;
				
				case TRAVERSAL_OUT_OF_BOUNDS : 
				msg += "Call to next() attempted at end of the traversal.";
				break;
				
				case TRAVERSAL_NOT_STARTED : 
				msg += "The iteration traversal has not been started. A call ";
				msg += "to current() or key() attempted before a call to next()"; 
				break;
			}
			
			return( new IteratorError(msg,errorID) );
		}
	}
}