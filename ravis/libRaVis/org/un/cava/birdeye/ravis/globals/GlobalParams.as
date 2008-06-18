/*
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
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
package org.un.cava.birdeye.ravis.globals {
	
	import org.un.cava.birdeye.ravis.components.ui.VGAccordion;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	
	/**
	 * This class will hold global params in static
	 * variables in order to facilitate the passing of params
	 * and to avoid issues with parentDocument and/or 
	 * parentApplication (and other issues)
	 * 
	 * This is essential for the proper functioning of
	 * all the provided control components for the graphLayout
	 * features. This is the main communication interface.
	 * 
	 * Basically every instantiated component will register itself
	 * with this class. graphLayout based components will have to be
	 * registered from the application (but it is basically only VisualGraph
	 * and the layouter).
	 * */
	public class GlobalParams {
		
		/*
		 * Core objects for VisualGraph.
		 * */
		 
		/**
		 * This is the global instance of the VisualGraph
		 * object. Currently there can only be one right now.
		 * In a future time, this could be generalized, but then
		 * ALL other components registered here, have to be parametrized
		 * for each VisualGraph instance.
		 * */
		[Bindable]
		public static var vgraph:IVisualGraph;
		
		/**
		 * This flag is set to true if the vgraph is initialised
		 * correctly. It needs to be reset if the
		 * vgraph assignment changes....
		 * */
		public static var vgraphInitOk:Boolean = false;
		
		/*
		 * Other parameter modules 
		 */
		
		
		/**
		 * This holds the static class that contains all
		 * relevant references to the data presentation related controls
		 * This allows to delegate/modularise the global
		 * parameters
		 * */
		public static var dataComponents:Class = GlobalParamsData;
		
		/* top tier parameters */
		
		/**
		 * Holds a reference to the main navigation accordion
		 * */
		public static var vgAccordion:VGAccordion;
		
		
		
		/** 
		 * zoom factor for rendered items */
		//	public static var zoom:VSlider;
		/* scale factor for rendered items */
		public static var scaleFactor:Number = 1;
		

		
	}
}