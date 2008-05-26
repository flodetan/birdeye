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
	
	import flexlib.containers.WindowShade;
	
	import mx.controls.CheckBox;
	import mx.controls.Text;
	
	import org.un.cava.birdeye.ravis.components.ui.dataPresentation.CenteredNodeLabel;
	import org.un.cava.birdeye.ravis.components.ui.dataPresentation.NoVisNodesLabel;
	import org.un.cava.birdeye.ravis.components.ui.dataPresentation.NodeDetailLabel;
	import org.un.cava.birdeye.ravis.components.ui.dataPresentation.SeachFilterGrid;
	
	/**
	 * This class will hold global params in static
	 * variables related to all data presentation
	 * controls and components.
	 * */
	public class GlobalParamsData {
		
		
		/**
		 * This mapping holds the SearchFilterGrid
		 * component.
		 * */		
		public static var searchFilterGrid:SeachFilterGrid;
		
		/**
		 * This holds the compound component to display
		 * all details of a selected node. Be aware that this
		 * is NOT necessarily the root node of the graph.
		 * */
		public static var selectedNodeDetail:NodeDetailLabel;	
		
		/**
		 * This holds the current title text of a selected
		 * node, it can be used to be bound to various variables.
		 * */
		[Bindable]
		public static var nodeDetailTitle:String;
		
		/**
		 * This holds the current description text of a selected
		 * node, it can be used to be bound to various variables.
		 * */
		[Bindable]
		public static var nodeDetailDesc:String;
		
		
		/**
		 * This holds a label to display the current number of
		 * visible nodes.
		 * */
		public static var noVisVnodesLabel:NoVisNodesLabel;
			
		/**
		 * This holds a label to display the current root node.
		 * */
		public static var curRootNodeLabel:CenteredNodeLabel;	
	

	
		/* some components in Visualize.mxml that have to 
		 * communicate with the icon renderer to handle mouse events */
		//public static var visualLeftAccordion:Accordion;
		
		
		public static var visualDetailContinent:Text;
		public static var visualDetailCountry:Text;
		public static var visualDetailCapital:Text;
		public static var visualDetailGovernment:Text;
		public static var visualDetailDoI:Text;
		public static var visualDetailGDP:Text;
		public static var visualDetailInflation:Text;
		public static var visualDetailIM:Text;
		public static var visualDetailPopGrowth:Text;
		public static var visualDetailPop:Text;
		
		public static var visualNodeLabel:CheckBox;
		
		public static var visualShade:WindowShade;
		
	}
}