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

package birdeye.vis.trans.graphs.visual
{
	import birdeye.vis.trans.graphs.util.geom.IVisualObjectWithDimensions;
	import birdeye.vis.trans.graphs.model.INode;
	
	import flash.display.DisplayObject;
	
	public interface IVisualNode extends IVisualItem, IVisualObjectWithDimensions
	{

		/**
		 * Access to the target X coordinate of this
		 * VisualNode. The commit() method will actually
		 * apply these coordinates in the node's UIComponent.
		 * @see commit()
		 * */
		function get x():Number;

		function set x(n:Number):void;

		function get moveable():Boolean;
		
		/**
		 * Access to the target Y coordinate of this
		 * VisualNode. The commit() method will actually
		 * apply these coordinates in the node's UIComponent.
		 * @see commit()
		 * */
		function get y():Number;	

		function set y(n:Number):void;
		
		/**
		 * Property for access to the associated graph node
		 * of this visual node.
		 * */			
		function get node():INode;

		/**
		 * A layouter can optionally set an orientation angle 
		 * parameter in the node. Right now we hardcode this as
		 * one single parameter. If we need more in the future,
		 * we can replace this by a hash with multiple keys.
		 * This parameter may be accessed by the nodeRenderer for instance.
		 * The value is in degrees.
		 * */
		function get orientAngle():Number;

		/**
		 * @private
		 * */
		function set orientAngle(oa:Number):void;

		/**
		 * This method set the coordinates of the visual node's
		 * view to the internal coordinates of the visual node,
		 * thus effectively placing the view at the point where the
		 * visual coordinates point to.
		 * */
		function commit():void;

		/**
		 * This method updates the internal coordinates of the
		 * visual node with the current coordinates of the visual node's
		 * view (i.e. it's current real coordinates).
		 * */
		function refresh():void;
		
		function get viewScaleX():Number;

		function set viewScaleX(scaleX:Number):void;
		
		function get viewScaleY():Number;

		function set viewScaleY(scaleY:Number):void;
	}
}
