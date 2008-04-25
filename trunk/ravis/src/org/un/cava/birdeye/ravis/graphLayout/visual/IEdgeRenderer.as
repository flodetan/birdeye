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
package org.un.cava.birdeye.ravis.graphLayout.visual {

	import flash.display.Graphics;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import mx.core.UIComponent;
	
	/**
	 * Interface for any Edge renderers,
	 * basically this is very simple as it just
	 * requires a draw() method.
	 * */
	public interface IEdgeRenderer {
		/**
		 * Draws an edge.
		 * The way how the colouring is currently handled, with the distinguished
		 * parameter is not appropriate, this may need to change to something more
		 * flexible.
		 * 
		 * @param g Reference to the Graphics object of the Drawing surface.
		 * @param edge The edge to draw, it needs to provide all the information required, i.e. locations.
		 * @param displayLabel If set, it displays a label in the middle of the egde, provided the edge
		 * 	has an edge renderer (UIComponent) associated with it.
		 *
		 * */
		function draw(g:Graphics,edge:IEdge,displayLabel:Boolean = false):void;
	}
}