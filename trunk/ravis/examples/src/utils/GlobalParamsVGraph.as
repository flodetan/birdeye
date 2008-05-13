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
package utils {
	
	import components.ui.controls.vgraphControls.BirdEyeZoom;
	import components.ui.controls.vgraphControls.DegreesOfSeparation;
	import components.ui.controls.vgraphControls.EdgeLabelControls;
	import components.ui.controls.vgraphControls.EdgeLabelSelector;
	import components.ui.controls.vgraphControls.EdgeRendererSelector;
	import components.ui.controls.vgraphControls.NodeRendererSelector;
	import components.ui.controls.vgraphControls.RendererControls;
	import components.ui.controls.vgraphControls.ScaleControls;
	import components.ui.controls.vgraphControls.ScaleLabels;
	import components.ui.controls.vgraphControls.ToggleEdgeLabels;
	import components.ui.controls.vgraphControls.ToggleShowHistory;
	
	
	/**
	 * This class will hold global params in static
	 * variables related to VisualGraph properties.
	 * 
	 * Basically every instantiated component will register itself
	 * with this class. graphLayout based components will have to be
	 * registered from the application (but it is basically only VisualGraph
	 * and the layouter).
	 * */
	public class GlobalParamsVGraph {
		

		/* these hold maps of the references, indexed by 
		 * their id */
		
		/**
		 * This mapping holds the BirdEyeZoom
		 * component.
		 * */
		public static var birdEyeZoomControl:BirdEyeZoom;
		
		/**
		 * This mapping holds the ScaleLabels
		 * component.
		 * */		
		public static var scaleLabelsControl:ScaleLabels;

		/**
		 * This mapping holds the DegreeOfSeparation
		 * component.
		 * */		
		public static var degreeOfSeparationControl:DegreesOfSeparation;
		
		/**
		 * This mapping holds the NodeRendererSelector
		 * component.
		 * */		
		public static var nodeRendererSelectorControl:NodeRendererSelector;

		/**
		 * This mapping holds the EdgeLabelSelector
		 * component.
		 * */		
		public static var edgeLabelSelectorControl:EdgeLabelSelector;

		/**
		 * This mapping holds the EdgeRendererSelector
		 * component.
		 * */		
		public static var edgeRendererSelectorControl:EdgeRendererSelector;

		/**
		 * This mapping holds the ToggleEdgeLabels
		 * component.
		 * */		
		public static var toggleEdgeLabelsControl:ToggleEdgeLabels;

		/**
		 * This mapping holds the ToggleShowHistory
		 * component.
		 * */		
		public static var toggleShowHistoryControl:ToggleShowHistory;

		/**
		 * This mapping holds the EdgeLabelControls
		 * component. This is a compount component of all EdgeLabel
		 * related controls.
		 * */		
		public static var edgeLabelControls:EdgeLabelControls;

		/**
		 * This mapping holds the RendererControls
		 * component. This is a compount component of all renderer
		 * related controls.
		 * */		
		public static var rendererControls:RendererControls;
		
		/**
		 * This mapping holds the ScaleControls
		 * component. This is a compount component of all scale
		 * related controls.
		 * */		
		public static var scaleControls:ScaleControls;
		
	}
}