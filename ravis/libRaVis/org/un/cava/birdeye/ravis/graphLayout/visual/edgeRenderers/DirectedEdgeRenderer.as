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
package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;


	/**
	 * This is a directed edge renderer, which draws the edges
	 * with slim ballon like curves that indicate a source.
	 * Please note that for undirected graphs, the actual direction
	 * of the edge might be arbitrary.
	 * */
	public class DirectedEdgeRenderer extends BaseEdgeRenderer {
		
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
		override public function draw(g:Graphics, vedge:IVisualEdge):void {
			
			/* first get the corresponding visual object */
			var fromNode:IVisualNode = vedge.edge.node1.vnode;
			var toNode:IVisualNode = vedge.edge.node2.vnode;
			
			var fP:Point = fromNode.viewCenter;
			
			/* calculate the midpoint used as curveTo anchor point */
			var anchor:Point = new Point(
				(fP.x + vedge.vgraph.center.x) / 2.0,
				(fP.y + vedge.vgraph.center.y) / 2.0
				);
			
			/* apply the line style */
			ERGlobals.applyLineStyle(vedge,g);
			
			/* now we actually draw */
			g.beginFill(uint(vedge.lineStyle.color));
			g.moveTo(fP.x, fP.y);			
			
			/* bezier curve style */
			g.curveTo(fP.x - 2,	fP.y - 2, anchor.x, anchor.y);
			g.moveTo(fP.x, fP.y);
			g.curveTo(fP.x + 2, fP.y + 2, anchor.x, anchor.y);
			g.moveTo(fP.x, fP.y);
			g.curveTo(fP.x - 2, fP.y + 2, anchor.x, anchor.y);
			g.moveTo(fP.x, fP.y);
			g.curveTo(fP.x + 2, fP.y - 2, anchor.x, anchor.y);
			g.moveTo(anchor.x, anchor.y);
			
			g.lineTo(toNode.viewCenter.x, toNode.viewCenter.y);
			g.endFill();
		
			
			/* if the vgraph currently displays edgeLabels, then
			 * we need to update their coordinates */
			if(vedge.vgraph.displayEdgeLabels) {
				ERGlobals.setLabelCoordinates(vedge.labelView,labelCoordinates(vedge));
			}
		}
	}
}