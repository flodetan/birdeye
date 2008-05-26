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
	import flash.geom.Point;
	
	import mx.controls.Label;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.utils.Geometry;


	/**
	 * This is a flow edge renderer. It relys on a "flow"
	 * attribute in the edges XML data object.
	 * It uses the flow value, put in relation with some
	 * parameters of the renderer to have an initial edge
	 * thickness. At the target the edge will coverge to a point.
	 * The flow is drawn in the shape of a teardrop with the thick
	 * end near the source and relative to the amount of the flow.
	 * */
	public class FlowEdgeRenderer implements IEdgeRenderer {
		
		
		/**
		 * This property describes the relation or scale 
		 * for the specified edge flow values. It is assumed
		 * to be a maximum and the drawing thickness will be
		 * oriented on that value. This does not mean that not
		 * larger values can be specified, but they may look ugly.
		 * @default 1000
		 * */
		public var relativeEdgeMagnitude:Number;
		
		/**
		 * This property describes the default maximum base width of the flow.
		 * It should be oriented on the size of the node labels.
		 * @default 100
		 * */
		public var maxBaseWidth:Number;
	
		
		/**
		 * The constructor just initialises some default values.
		 * */
		public function FlowEdgeRenderer():void {
			relativeEdgeMagnitude = 1000;
			maxBaseWidth = 100;
		}
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a straight line from one node of the edge to the other.
		 * The colour is determined by a set of edge parameters,
		 * which are stored in an edge object.
		 * @inheritDoc
		 * */
		public function draw(g:Graphics, edge:IEdge, displayLabel:Boolean = false):void {

			var vedge:IVisualEdge;
			var fromNode:IVisualNode;
			var toNode:IVisualNode;
			
			var source:Point;
			var target:Point;
			var base1:Point;
			var base2:Point;	
			var mid:Point;
			
			var flow:Number;
			var tdirectionAngle:Number;
			var basedirectionAngle:Number;
			var baseWidth:Number;
			
			/* first get the corresponding visual object */
			vedge = edge.vedge;
			fromNode = edge.node1.vnode;
			toNode = edge.node2.vnode;
			
			if((edge.data as XML).attribute("flow").length() > 0) {
				flow = edge.data.@flow;
			} else {
				throw Error("Edge: "+edge.id+" does not have flow attribute.");
			}
			
			/* now get some current coordinates and calculate the middle 
			 * of the node's view */
			source = new Point(fromNode.view.x + (fromNode.view.width / 2.0),
				fromNode.view.y + (fromNode.view.height / 2.0));
			target = new Point(toNode.view.x + (toNode.view.width / 2.0),
				toNode.view.y + (toNode.view.height / 2.0));	
			
			/* calculate the midpoint */
			mid = new Point(
				source.x + ((target.x - source.x) / 2.0),
				source.y + ((target.y - source.y) / 2.0)
			);
			
			/* for the source, we now need to establish actually two points
			 * which are orthogonal to the direction of the target
			 * and have a distance that matches the flow parameter */
			
			/* calculate the angle of the direction of the target */
			tdirectionAngle = Geometry.polarAngle(target.subtract(source));
			//trace("target direction:"+Geometry.rad2deg(tdirectionAngle)+" degrees");
			
			/* calculate the angle of the direction of the base, which is
			 * always 90 degrees (PI/2) of tdirection */
			basedirectionAngle = Geometry.normaliseAngle(tdirectionAngle + (Math.PI / 2));
			//trace("base direction:"+Geometry.rad2deg(basedirectionAngle)+" degrees");
			
			/* now calculate the width of the base in relation to the flow */
			baseWidth = (flow * (maxBaseWidth / relativeEdgeMagnitude));
			//trace("flow:"+flow+" base width:"+baseWidth);
			
			/* now calculate the first base point, which is half the width in
			 * positive base direction */
			base1 = source.add(Point.polar((baseWidth / 2), basedirectionAngle));
			//trace("base1:"+base1.toString());
			
			/* the second is the same but in negative direction (or negative angle,
			 * that should not make a difference */
			base2 = source.add(Point.polar(-(baseWidth / 2), basedirectionAngle));
			//trace("base1:"+base1.toString());

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
			
			/* now we draw the first curve with base 1 to target */
			g.beginFill(uint(vedge.lineStyle.color));
			g.moveTo(source.x, source.y);
			g.curveTo(
				base1.x,
				base1.y,
				target.x,
				target.y
			);
			g.endFill();
			
			/* and the second curve using base 2 as control point */
			g.beginFill(uint(vedge.lineStyle.color));
			g.moveTo(source.x, source.y);			
			g.curveTo(
				base2.x,
				base2.y,
				target.x,
				target.y
			);
			g.endFill();

			
			if(displayLabel) {
				vedge.labelView.x = mid.x - (vedge.labelView.width / 2.0);
				vedge.labelView.y = mid.y - (vedge.labelView.height / 2.0);
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