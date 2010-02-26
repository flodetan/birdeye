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
 
package birdeye.vis.interfaces.transforms
{
	import __AS3__.vec.Vector;
	
	import birdeye.vis.trans.graphs.model.IGraph;
	import birdeye.vis.trans.graphs.util.geom.IVisualObjectWithDimensions;
	import birdeye.vis.trans.graphs.visual.IVisualEdge;
	import birdeye.vis.trans.graphs.visual.IVisualNode;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public interface IGraphLayout extends ITransform, IVisualObjectWithDimensions
	{
		/**
		 * Provide access to the current origin of the of the Visual Graph
		 * which is required for proper drawing.
		 * */
		function get origin():Point;
		
		/**
		 * Provide access to the center point of the VGraph's
		 * drawing surface, used by layouters to properly center
		 * their layout.
		 * */
		function get center():Point;
		
		/**
		 * Access to the underlying Graph datastructure object.
		 * */
		function get graph():IGraph;
		
		function get nodes():Vector.<IVisualNode>;
		
		function get edges():Vector.<IVisualEdge>;
		
		/** This forces a redraw of all edges */
		function redrawEdges(visualEdges:Array = null):void;
		
		function getVisualNodeById(nodeId:String):IVisualNode;
		
		function isNodeVisible(nodeId:String):Boolean;

		function getNodePosition(nodeId:String):Point;

		function getNodeDisplayObject(nodeId:String):DisplayObject;

		function getEdgeDisplayObject(edgeId:String):DisplayObject;
		
		function get currentRootVNode():IVisualNode;
		
		function get maxVisibleDistance():int;

		/**
		 * Calculate and return the current bounding box of all visible nodes.
		 * This is required by some layouters.
		 * @return The bounding box rectangle of all visible nodes.
		 * */
		function calcNodesBoundingBox():Rectangle;

		/**
		 * Scrolls all objects according to the specified coordinates
		 * (used as an offset).
		 * */
		function scroll(sx:Number, sy:Number):void;

		function get graphId():String;

		function apply(width:Number, height:Number):void;
		
		function set rootNode(vNode:IVisualNode):void;
		
		function isNodeItemVisible(itemId:Object):Boolean;

		function getNodeItemPosition(itemId:Object):Point;
		
		function resetLayout():void;
	}
}
