/* 
 * The MIT License
 *
 * Copyright (c) 2007 The SixDegrees Project Team
 * (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
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
 
package birdeye.vis.trans.graphs.layout
{
	public interface ILayoutAlgorithm
	{
		/**
		 * This is the main method of the layouter, that actually
		 * implements the calculation of the layout. It will be called
		 * by the VisualGraph on any significant change that will
		 * require a layout to be recomputed.
		 * @return true if something was done successfully, false otherwise.
		 * */
		function layoutPass():Boolean;
		
		/**
		 * This should reset all parameters of the layouter,
		 * which might not be needed for all layouters, and it is
		 * up to each layouter to do something with it.
		 * It would also stop any existing layouting loops/timers.
		 * */
		function resetAll():void;
		
		function set disableAnimation(value:Boolean):void;

		function get disableAnimation():Boolean;

	}
}
