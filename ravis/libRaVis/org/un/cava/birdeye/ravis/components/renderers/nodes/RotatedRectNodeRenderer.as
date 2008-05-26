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
package org.un.cava.birdeye.ravis.components.renderers.nodes {
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.components.renderers.RendererIconFactory;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
		
	/**
	 * This is a simple renderer, similar to the filtered circle
	 * but renders a rectangle which is rotated according to the
	 * angle of the corresponding visualNode
	 * */
	public class RotatedRectNodeRenderer extends EffectBaseNodeRenderer  {
		
		/**
		 * Default constructor
		 * */
		public function RotatedRectNodeRenderer() {
			super();
		}
	
		/**
		 * @inheritDoc
		 * */
		override protected function initComponent(e:Event):void {
			
			var rc:UIComponent;
			
			/* initialize the upper part of the renderer */
			initTopPart();
			
			/* add a primitive rectangle
			 * as well the XML should be checked before */
			rc = RendererIconFactory.createIcon("primitive::rectangle",
				this.data.data.@nodeSize,
				this.data.data.@nodeColor);
			rc.toolTip = this.data.data.@name; // needs check
			
			/* rotate. Note that this will only rotate on init
			 * i.e. all will be triggered only on creation complete
			 * this was the same in the original vgExplorer
			 * maybe it was not intended */
			if(this.data is IVisualNode) {
				rc.rotation =  (this.data as IVisualNode).orientAngle;
			}
			
			this.addChild(rc);
			
			/* now add the filters to the circle */
			reffects.addDSFilters(rc);
			 
			/* now the link button */
			initLinkButton();
		}
	}
}