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
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import flash.display.Graphics;
	import mx.core.UIComponent;
	import mx.controls.Label;


	/**
	 * This is a directed edge renderer, which draws the edges
	 * with slim ballon like curves that indicate a source.
	 * Please note that for undirected graphs, the actual direction
	 * of the edge might be arbitrary.
	 * */
	public class DirectedEdgeRenderer implements IEdgeRenderer {
		
		/* constructor does nothing and is therefore omitted
		 */
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a straight line from one node of the edge to the other.
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
			
			/* now get some current data and calculate their middle */
			var fromX:Number = fromNode.view.x + (fromNode.view.width / 2.0);
			var fromY:Number = fromNode.view.y + (fromNode.view.height / 2.0);
			var toX:Number = toNode.view.x + (toNode.view.width / 2.0);
			var toY:Number = toNode.view.y + (toNode.view.height / 2.0);	
			
			/* calculate the midpoint */
			var midX:Number = fromX + ((toX - fromX) / 2.0);
			var midY:Number = fromY + ((toY - fromY) / 2.0);
						
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
			g.beginFill(0);
			g.moveTo(fromX, fromY);
			
			/* bezier curve style */
			g.curveTo(fromX - 2, fromY - 2, midX, midY);
			g.moveTo(fromX, fromY);
			g.curveTo(fromX + 2, fromY + 2, midX, midY);
			g.moveTo(fromX, fromY);
			g.curveTo(fromX - 2, fromY + 2, midX, midY);
			g.moveTo(fromX, fromY);
			g.curveTo(fromX + 2, fromY - 2, midX, midY);
			g.moveTo(midX, midY);
			
			g.lineTo(toX, toY);
			g.endFill();
			
			if(displayLabel) {
				vedge.labelView.x = midX - (vedge.labelView.width / 2.0);
				vedge.labelView.y = midY - (vedge.labelView.height / 2.0);
				/* the following should rather be done during
				 * the EdgeRendererFactory setting, we leave it
				 * here only for the default "Label" */
				if(vedge.labelView is Label) {
					(vedge.labelView as Label).text = vedge.data.@association;
				}
				//g.drawCircle(midX,midY,10);
			}
		}
	}
}