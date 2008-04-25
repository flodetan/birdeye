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
	
	import mx.controls.Label;
	import mx.core.Application;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;


	/**
	 * This edge renderer draws rectangular edge arrows.
	 * Please note that for undirected graphs, the actual direction
	 * of the arrow might be arbitrary.
	 * */
	public class OrthogonalEdgeRenderer implements IEdgeRenderer {
		
		/* constructor does nothing and is therefore omitted
		 */
		private var arrowLength:Number;
		private var _type:String = 'orthogonal';
		private var _g:Graphics;
		
		/* temporary fix */
		private var color:uint;
		
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a straight line from one node of the edge to the other.
		 * The colour is determined by the "disting" parameter and
		 * a set of edge parameters, which are stored in an edge object.
		 * 
		 * @inheritDoc
		 * */
		public function draw(g:Graphics, edge:IEdge, displayLabel:Boolean = false):void {
			
			/* this is not interface conform !!!! */
			arrowLength = 10;
			
			/* first get the corresponding visual object */
			var vedge:IVisualEdge = edge.vedge;
			var fromNode:IVisualNode = edge.node1.vnode;
			var toNode:IVisualNode = edge.node2.vnode;
			_g = g;
			
			/* now get some current data and calculate their middle */
			var fromX:Number = fromNode.view.x + (fromNode.view.width / 2.0);
			var fromY:Number = fromNode.view.y + (fromNode.view.height / 2.0);
			var toX:Number = toNode.view.x + (toNode.view.width / 2.0);
			var toY:Number = toNode.view.y + (toNode.view.height / 2.0);	
			
			/* calculate the midpoint */
			var midX:Number = fromX + ((toX - fromX) / 2.0);
			var midY:Number = fromY + ((toY - fromY) / 2.0);
			
			/* now we actually draw */
			/* apply the style to the drawing */
			if(vedge.lineStyle != null) {
				_g.lineStyle(
					Number(vedge.lineStyle.thickness),
					uint(vedge.lineStyle.color),
					Number(vedge.lineStyle.alpha),
					Boolean(vedge.lineStyle.pixelHinting),
					String(vedge.lineStyle.scaleMode),
					String(vedge.lineStyle.caps),
					String(vedge.lineStyle.joints),
					Number(vedge.lineStyle.miterLimits)
				);
				color = uint(vedge.lineStyle.color);
			}
			
			if(isFullyLeftOf(fromNode, toNode)){
				if(isFullyAbove(fromNode, toNode)){
					bottomToTop(fromNode, toNode);					
				}
				else if(isFullyBelow(fromNode, toNode)){
					topToBottom(fromNode, toNode);
				}
				else{			
					rightToLeft(fromNode, toNode);
				}
			}
			else if(isFullyRightOf(fromNode, toNode)){
				if(isFullyAbove(fromNode, toNode)){					
					bottomToTop(fromNode, toNode);
				}
				else if(isFullyBelow(fromNode, toNode)){						
					topToBottom(fromNode, toNode);
				}
				else{
					leftToRight(fromNode, toNode);
				}			
			}
			else if(isFullyAbove(fromNode, toNode)){
				bottomToTop(fromNode, toNode);
			}
			else if(isFullyBelow(fromNode, toNode)){
				topToBottom(fromNode, toNode);
			}
			else{
				centerToCenter(fromNode, toNode);
			}				
	
			
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
		private function calculatePoint(fromX:Number, fromY:Number, distance:Number, angle:Number):Object{
			angle = angle * 1.745329E-002;
			var _loc3:Number = fromX + distance * Math.cos(angle);
			var _loc2:Number = fromY - distance * Math.sin(angle);
			return ({x: _loc3, y: _loc2});
		}
     
     	private function drawArrow(fromX:int, fromY:int, toX:int, toY:int):void{
     		var arrowLength:Number = 10;
     		var dXY:Number = (fromY - toY) / (fromX - toX);
     		var arrowOS:Number;
	        if (fromX >= toX)
	        {
	            arrowOS = 155;
	        }
	        else
	        {
	            arrowOS = 25;
	        }	        
	        var arrowLine1:Object = this.calculatePoint(toX, toY, arrowLength, 180 - Math.atan(dXY) * 5.729578E+001 - arrowOS);
	        var arrowLine2:Object = this.calculatePoint(toX, toY, arrowLength, 180 - Math.atan(dXY) * 5.729578E+001 + arrowOS);   		
     		
     		_g.moveTo(toX, toY);
     		_g.beginFill(color,1);
            _g.lineTo(arrowLine1.x, arrowLine1.y);            
            _g.lineTo(arrowLine2.x, arrowLine2.y);
            _g.lineTo(toX, toY);
            _g.endFill();
     	}
     			     	
		//checks if obj1 is fully above obj2 (this includes the space for the arrow)
		private function isFullyAbove(obj1:IVisualNode, obj2:IVisualNode):Boolean {
			return (obj1.view.y + obj1.view.height + arrowLength) < obj2.view.y;
		}     	
		//checks if obj1 is fully below obj2 (this includes the space for the arrow)
		private function isFullyBelow(obj1:IVisualNode, obj2:IVisualNode):Boolean {
			return obj1.view.y > (obj2.view.y + obj2.view.height + arrowLength);
		}   
		//checks if obj1 is fully to the right of obj2 (this includes the space for the arrow)
		private function isFullyRightOf(obj1:IVisualNode, obj2:IVisualNode):Boolean {
			return obj1.view.x > (obj2.view.x + obj2.view.width + arrowLength);
		}			  	
		//checks if obj1 is fully to the left of obj2 (this includes the space for the arrow)
		private function isFullyLeftOf(obj1:IVisualNode, obj2:IVisualNode):Boolean {
			return (obj1.view.x + obj1.view.width + arrowLength) < obj2.view.x;
		}  
		//from the right side of obj1 to the left side of obj2
		private function rightToLeft(obj1:IVisualNode, obj2:IVisualNode):void {
			_g.moveTo(obj1.view.x + obj1.view.width, obj1.view.y + (obj1.view.height/2));
			if(_type == 'orthogonal') {
				_g.lineTo((obj1.view.x + obj1.view.width) + .5*(obj2.view.x - (obj1.view.x + obj1.view.width)) - arrowLength, obj1.view.y + (obj1.view.height/2));
				_g.lineTo((obj1.view.x + obj1.view.width) + .5*(obj2.view.x - (obj1.view.x + obj1.view.width)) - arrowLength, obj2.view.y + (obj2.view.height/2));
				_g.lineTo(obj2.view.x - arrowLength+1, obj2.view.y + (obj2.view.height/2));
				drawArrow((obj1.view.x + obj1.view.width) + .5*(obj2.view.x - (obj1.view.x + obj1.view.width)) - arrowLength, obj2.view.y + (obj2.view.height/2), obj2.view.x, obj2.view.y + (obj2.view.height/2));
			}
			else {
				_g.lineTo(obj2.view.x - arrowLength+1, obj2.view.y + (obj2.view.height/2));	
				drawArrow(obj1.view.x + obj1.view.width, obj1.view.y + (obj1.view.height/2), obj2.view.x, obj2.view.y + (obj2.view.height/2));
			}
		}
		
		//from the left side of obj1 to the right side of obj2
		private function leftToRight(obj1:IVisualNode, obj2:IVisualNode):void {
			_g.moveTo(obj1.view.x, obj1.view.y + (obj1.view.height/2));
			if(_type == 'orthogonal'){
				_g.lineTo((obj2.view.x + obj2.view.width) + .5*(obj1.view.x - (obj2.view.x + obj2.view.width)) + arrowLength, obj1.view.y + (obj1.view.height/2));
				_g.lineTo((obj2.view.x + obj2.view.width) + .5*(obj1.view.x - (obj2.view.x + obj2.view.width)) + arrowLength, obj2.view.y + (obj2.view.height/2));
				_g.lineTo((obj2.view.x + obj2.view.width) + arrowLength-1, obj2.view.y + obj2.view.height/2);
				drawArrow((obj2.view.x + obj2.view.width) + .5*(obj1.view.x - (obj2.view.x + obj2.view.width)) + arrowLength, obj2.view.y + (obj2.view.height/2), (obj2.view.x + obj2.view.width), obj2.view.y + obj2.view.height/2);		
			}
			else{
				_g.lineTo((obj2.view.x + obj2.view.width) + arrowLength-1, obj2.view.y + obj2.view.height/2);
				drawArrow(obj1.view.x, obj1.view.y + (obj1.view.height/2), (obj2.view.x + obj2.view.width), obj2.view.y + obj2.view.height/2);
			}

		}
		
		//from the top of obj1 to the bottom of obj2
		private function topToBottom(obj1:IVisualNode, obj2:IVisualNode):void {
			_g.moveTo(obj1.view.x + (obj1.view.width/2), obj1.view.y);
			if(_type == 'orthogonal'){
				_g.lineTo(obj1.view.x + (obj1.view.width/2), obj1.view.y + .5*((obj2.view.y + obj2.view.height) - obj1.view.y));
				_g.lineTo(obj2.view.x+(obj2.view.width/2), obj1.view.y + .5*((obj2.view.y + obj2.view.height) - obj1.view.y));
				_g.lineTo(obj2.view.x+(obj2.view.width/2), (obj2.view.y + obj2.view.height)+ arrowLength-1);
				drawArrow(obj2.view.x+(obj2.view.width/2), obj1.view.y + .5*((obj2.view.y + obj2.view.height) - obj1.view.y), obj2.view.x+(obj2.view.width/2), (obj2.view.y + obj2.view.height));			
			}
			else{
				_g.lineTo(obj2.view.x+(obj2.view.width/2), (obj2.view.y + obj2.view.height)+ arrowLength-1);
				drawArrow(obj1.view.x + (obj1.view.width/2), obj1.view.y, obj2.view.x+(obj2.view.width/2), (obj2.view.y + obj2.view.height));
			}
			
		}
		
		//from the bottom of obj1 to the top of obj2
		private function bottomToTop(obj1:IVisualNode, obj2:IVisualNode):void {
			_g.moveTo(obj1.view.x + (obj1.view.width/2), obj1.view.y + obj1.view.height);
			if(_type == 'orthogonal') {
				_g.lineTo(obj1.view.x + (obj1.view.width/2), (obj1.view.y + obj1.view.height) + .5*(obj2.view.y - (obj1.view.y + obj1.view.height)));
				_g.lineTo(obj2.view.x + (obj2.view.width/2), (obj1.view.y + obj1.view.height) + .5*(obj2.view.y - (obj1.view.y + obj1.view.height)));
				_g.lineTo(obj2.view.x + (obj2.view.width/2), obj2.view.y - arrowLength+1);
				drawArrow(obj2.view.x + (obj2.view.width/2), (obj1.view.y + obj1.view.height) + .5*(obj2.view.y - (obj1.view.y + obj1.view.height)), obj2.view.x + (obj2.view.width/2), obj2.view.y);
			}
			else {
				_g.lineTo(obj2.view.x + (obj2.view.width/2), obj2.view.y - arrowLength+1);
				drawArrow(obj1.view.x + (obj1.view.width/2), obj1.view.y + obj1.view.height, obj2.view.x + (obj2.view.width/2), obj2.view.y);
			}
		}
		
		//from the center of _obj1 to the center of _obj2
		private function centerToCenter(obj1:IVisualNode, obj2:IVisualNode):void {
			_g.moveTo(obj1.view.x + (obj1.view.width/2), obj1.view.y + (obj1.view.height/2));
			_g.lineTo(obj2.view.x + (obj2.view.width/2), obj2.view.y + (obj2.view.height/2));
			drawArrow(obj1.view.x + (obj1.view.width/2), obj1.view.y + obj1.view.height, obj2.view.x + (obj2.view.width/2), obj2.view.y);
		}			   							
	}
}