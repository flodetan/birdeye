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
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.CommonLayoutControls;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.HierLayoutControls;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.LayoutSelector;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.LinkLength;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.NodeSpacing;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.OrientationSelector;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.PhiDial;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleAnimation;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleAutoFit;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleDamping;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleHonorNodeSize;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleNodeInterleaving;
	import org.un.cava.birdeye.ravis.components.ui.controls.layouterControls.ToggleSiblingSpread;
	
	
	/**
	 * This class will hold global params and object
	 * references in static variables in order to facilitate the passing of params
	 * 
	 * In this module everything concerning layouter related
	 * controls and components are registered.
	 * 
	 * See also @see GlobalParams.
	 * */
	public class GlobalParamsLayout {
		
		/**
		 * This string contains the descriptive name of the
		 * currently selected layouter.
		 * */
		public static var currentLayouterName:String;
		
		/**
		 * This mapping holds the LayoutSelecter
		 * component.
		 * */
		public static var layoutSelectorControl:LayoutSelector;
		
		/**
		 * This mapping holds the LinkLength
		 * component.
		 * */		
		public static var linkLengthControl:LinkLength;
		
		/**
		 * This mapping holds the ToggleAutoFit
		 * component.
		 * */		
		public static var autoFitControl:ToggleAutoFit;

		/**
		 * This mapping holds the ToggleAnimation
		 * component.
		 * */		
		public static var animationControl:ToggleAnimation;
		
		/**
		 * This mapping holds the ToggleDamping
		 * component.
		 * */		
		public static var dampingControl:ToggleDamping;
		
		/**
		 * This mapping holds the PhiDial
		 * component.
		 * */		
		public static var phiDialControl:PhiDial;

		/**
		 * This mapping holds the OrientationSelector
		 * component.
		 * */		
		public static var orientationControl:OrientationSelector;
		
		/**
		 * This mapping holds the NodeSpacing
		 * component.
		 * */		
		public static var nodeSpacingControl:NodeSpacing;

		/**
		 * This mapping holds the ToggleNodeInterleaving
		 * component.
		 * */		
		public static var nodeInterleavingControl:ToggleNodeInterleaving;

		/**
		 * This mapping holds the ToggleHonorNodeSize
		 * component.
		 * */		
		public static var honorNodeSizeControl:ToggleHonorNodeSize;


		/**
		 * This mapping holds the ToggleSiblingSpread
		 * component.
		 * */		
		public static var siblingSpreadControl:ToggleSiblingSpread;	
		
		/**
		 * This mapping the HierLayoutControls
		 * component, which aggregate as a compound component
		 * the OrientationSelector, NodeSpacing and SiblingSpread
		 * components.
		 * */
		public static var hierLayoutControls:HierLayoutControls;

		/**
		 * This mapping holds instantiated CommonLayoutControls
		 * components, which aggregate as a compound component
		 * all controls common to all layouters, currently 
		 * AutoFit, Animation and LinkLength.
		 * */
		public static var commonLayoutControls:CommonLayoutControls;

	}
}