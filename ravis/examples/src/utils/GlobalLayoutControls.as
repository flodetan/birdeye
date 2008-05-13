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
	
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.layout.CircularLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ConcentricRadialLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.DirectPlacementLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ForceDirectedLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.HierarchicalLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.Hyperbolic2DLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ISOMLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ParentCenteredRadialLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.PhylloTreeLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.CircularEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.HyperbolicEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.OrthogonalEdgeRenderer;
	
	/**
	 * This class will hold global static methods
	 * necessary to control the layouter behaviour of the
	 * VGraph.
	 * */
	public class GlobalLayoutControls {
		
 		/**
		 * Set/Activate the layouter set in the corresponding
		 * global parameter.
		 * XXX Historically we had this as part of the layout selector,
		 * but actually the layouter can be specified independently of
		 * a combo-box selector and would still need to be applied
		 * thus we externalise the method to a global one.
		 * */
		public static function applyLayouter():void {
			
			var vgraph:IVisualGraph = GlobalParams.vgraph;
			var layouter:ILayoutAlgorithm;
			
			/* kill off animation in old layouter if present */
			if(GlobalParams.layouter != null) {
				GlobalParams.layouter.resetAll();
				/* remove also existing references thus
				 * destroying the object (maybe this is not needed?) */
				GlobalParams.layouter = null;
			}
			
			/* careful ... */
			if(vgraph != null) {
				vgraph.layouter = null;
			} else {
				trace("No valid vgraph object in GlobalParams, cannot continue");
				return;	
			}
			
			/* Prior to selection of a new layouter, 
			 * we disable all layouter specific controls.
			 * After, we enable only those relevant for the
			 * specific layouter.
			 */
			disableLayouterControls();

			/* now choose the selected layouter */
			switch(GlobalParamsLayout.currentLayouterName) {
				case "ConcentricRadial":
					layouter = new ConcentricRadialLayouter(vgraph);
					break;
				case "ParentCenteredRadial":
					layouter = new ParentCenteredRadialLayouter(vgraph);
					setComponentEnabled(GlobalParamsLayout.phiDialControl, true);
					GlobalParamsLayout.phiDialControl.updatePhi();
					break;
				case "SingleCycleCircle":
					layouter = new CircularLayouter(vgraph);
					vgraph.edgeRenderer = new CircularEdgeRenderer();
					/* set the hyperbolic edge renderer type *
					vgraph.edgeRenderer = new CircularEdgeRenderer();
					vgraph.scrollBackgroundInDrag = false;
					vgraph.moveNodeInDrag = false;
					absoluteScaling = true;
					updateScale();
					*/
					break;
				case "Hyperbolic":
					layouter = new Hyperbolic2DLayouter(vgraph);
					/*
					vgraph.edgeRenderer = new HyperbolicEdgeRenderer((layouter as Hyperbolic2DLayouter).projector);
					vgraph.scrollBackgroundInDrag = false;
					vgraph.moveNodeInDrag = false;
					absoluteScaling = false;
					*/
					break;
				case "Hierarchical":
					layouter = new HierarchicalLayouter(vgraph);
					setComponentEnabled(GlobalParamsLayout.hierLayoutControls, true);
					GlobalParamsLayout.hierLayoutControls.applyValues();
					/* apply the current values of all controls to the layouter */
					break;
				case "ForceDirected":
					layouter = new ForceDirectedLayouter(vgraph);
					setComponentEnabled(GlobalParamsLayout.dampingControl, true);
					GlobalParamsLayout.dampingControl.toggleDamping();
					/* apply the damping value to the layouter */
					break;
				case "ISOM":
					layouter = new ISOMLayouter(vgraph);
					break;
				case "DirectPlacement":
					layouter = new DirectPlacementLayouter(vgraph);
					vgraph.edgeRenderer = new OrthogonalEdgeRenderer();
					/* set some layouter specific values, i.e. create a control
					 * for these first, also they could be prepopulated from
					 * XML data
					(layouter as DirectPlacementLayouter).relativeHeight = 400;
					(layouter as DirectPlacementLayouter).relativeWidth = 400;
					 */
					/*
					/* set the orthogonal edge renderer type *
					vgraph.edgeRenderer = new OrthogonalEdgeRenderer();
					vgraph.scrollBackgroundInDrag = true;
					vgraph.moveNodeInDrag = true;
					absoluteScaling = true;
					updateScale();
					*/
					break;
				case "Phyllotactic":
					layouter = new PhylloTreeLayouter(vgraph);
					setComponentEnabled(GlobalParamsLayout.phiDialControl, true);
					GlobalParamsLayout.phiDialControl.updatePhi();
					/* apply the current phidial value to the layouters .phi property */
					break;
				default:
					trace("Illegal Layouter selected, defaulting to ConcentricRadial"+
						GlobalParamsLayout.currentLayouterName);
					layouter = new ConcentricRadialLayouter(vgraph);
					break;
			}
			GlobalParams.layouter = layouter;
			vgraph.layouter = layouter;
			
			/* now re-enable all common layouter Controls */
			enableCommonLayouterControls();
			GlobalParamsLayout.commonLayoutControls.applyValues();

			/* and make sure we draw right away to reflect the change */		
			vgraph.draw();	
		}
		
		/**
		 * Go through all registered layouter controls and
		 * set their enabled state to false.
		 * This may not be the best way to do it, but we start
		 * trying this way.
		 * */
		public static function disableLayouterControls():void {
			setComponentEnabled(GlobalParamsLayout.layoutSelectorControl, false);
			setComponentEnabled(GlobalParamsLayout.linkLengthControl, false);
			setComponentEnabled(GlobalParamsLayout.autoFitControl, false);
			setComponentEnabled(GlobalParamsLayout.animationControl, false);
			setComponentEnabled(GlobalParamsLayout.dampingControl, false);
			setComponentEnabled(GlobalParamsLayout.phiDialControl, false);
			setComponentEnabled(GlobalParamsLayout.orientationControl, false);
			setComponentEnabled(GlobalParamsLayout.nodeSpacingControl, false);
			setComponentEnabled(GlobalParamsLayout.siblingSpreadControl, false);
			setComponentEnabled(GlobalParamsLayout.hierLayoutControls, false);
			setComponentEnabled(GlobalParamsLayout.commonLayoutControls, false);
		}

		/**
		 * Go through all COMMON registered layouter controls and
		 * set their enabled state to true.
		 * */
		public static function enableCommonLayouterControls():void {	
			setComponentEnabled(GlobalParamsLayout.layoutSelectorControl, true);
			setComponentEnabled(GlobalParamsLayout.linkLengthControl, true);
			setComponentEnabled(GlobalParamsLayout.autoFitControl, true);
			setComponentEnabled(GlobalParamsLayout.animationControl, true);
			setComponentEnabled(GlobalParamsLayout.commonLayoutControls, true);
		}


		/**
		 * This sets the enabled property of all these UIComponents to the
		 * specified value. The main benefit is basically that it makes
		 * sure the passed object exists (and is not null).
		 * 
		 * @param uicomp An UIComponent to be enabled or disabled. 
		 * @param value The boolean value to set the UIComponents to.
		 * */
		private static function setComponentEnabled(uicomp:UIComponent, value:Boolean):void {
			if(uicomp != null) {
				uicomp.enabled = value;
			}
		}
	}
}