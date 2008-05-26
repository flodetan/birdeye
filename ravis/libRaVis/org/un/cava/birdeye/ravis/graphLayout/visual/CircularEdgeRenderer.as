/* 
 * The MIT License
 *
 * Copyright (c) 2008 The SixDegrees Project Team
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
	
	import flash.display.DisplayObject;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.utils.GraphicUtils;
	
	import flash.display.Graphics;
	import mx.core.UIComponent;
	import mx.controls.Label;


	/**
	 * This is the edge renderer for circular layout, which draws the edges
	 * as curved lines from one node to another.
	 * */
	public class CircularEdgeRenderer implements IEdgeRenderer {
		
		/* constructor does nothing and is therefore omitted
		 */
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a curved line from one node of the edge to the other.
		 * The colour is determined by the "disting" parameter and
		 * a set of edge parameters, which are stored in an edge object.
		 * 
		 * @inheritDoc
		 * */
		public function draw(g:Graphics, edge:IEdge, displayLabel:Boolean = false):void {
			
			/* first get the corresponding visual object */
			var vedge:IVisualEdge = edge.vedge;
			var fromNode:IVisualNode = edge.node1.vnode;
			var toNode:IVisualNode = edge.node2.vnode;
			var disp:DisplayObject = vedge.vgraph as DisplayObject;			
			
			/* now get some current data and calculate their middle */
			var fromX:Number = fromNode.view.x + (fromNode.view.width / 2.0);
			var fromY:Number = fromNode.view.y + (fromNode.view.height / 2.0);
			var toX:Number = toNode.view.x + (toNode.view.width / 2.0);
			var toY:Number = toNode.view.y + (toNode.view.height / 2.0);	
			
			/* calculate the centre of the circle */
			var centreX:Number = GraphicUtils.getCenter(disp).x;
			var centreY:Number = GraphicUtils.getCenter(disp).y;
			
			/* calculate the midpoint used as curveTo anchor point */
			var midX:Number = (fromX + centreX) / 2.0;
			var midY:Number = (fromY + centreY) / 2.0;
			
			/* apply the style to the drawing */
			if(vedge.lineStyle != null) {
				g.lineStyle(
					Number(vedge.lineStyle.thickness),
					uint(vedge.lineStyle.color),
					Number(vedge.lineStyle.alpha),
					Boolean(vedge.lineStyle.pixelHinting),
					String(vedge.lineStyle.scaleMode),
					String(vedge.lineStyle.caps),
					String(vedge.lineStyle.joints),
					Number(vedge.lineStyle.miterLimits)
				);
			}
			
			/* now we actually draw */
			g.moveTo(fromX, fromY);
			
			//g.curveTo(centreX, centreY, toX, toY);
			g.curveTo(midX, midY, toX, toY);
		}
	}
}