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

package birdeye.vis.trans.modifiers
{
	/** This class applies the Visvalingam-Whyatt simplification algorithm to the polygons of a country. 
	 */
	public class WhyattSimplification extends Simplification
	{

		public override function simplifyPolygon(polygon:Array, epsilon:Number):Array
		{
			var smallestObj:Object;
			var firstObj:Object;
			var lastObj:Object;
			var prevObj:Object;
			var currObj:Object;
			var nextObj:Object;
			var minSize:Number = 0.35*Math.pow(1.1,(100-epsilon)); //Normalize epsilon, so that it ranges from 0(max simplification) to 100 (no simplification) 
			

			//Create linked lists of Objects, which specify the effective area size for each polygon corner.
			//The Objects are linked four ways:
			//  Links (1)next and (2)previous follow the order of the points in the polygon, a.k.a. the polygon list
			//  Links (3)bigger and (4)smaller sort the points by effective area size, a.k.a. the area size list
			prevObj = {index:0,x:(polygon[0][0]),y:(polygon[0][1])};
			currObj = {index:1,x:(polygon[1][0]),y:(polygon[1][1]), prev:prevObj};
			prevObj.next = currObj;
			smallestObj = firstObj = prevObj;
			for (var i:int=1; i<polygon.length-1; i++) { 
 				nextObj = {index:(i+1),x:(polygon[i+1][0]),y:(polygon[i+1][1]),prev:currObj};
				currObj.next = nextObj;
				currObj.size = triangleArea(currObj);
				
				if (insertIntoSizeList(currObj,smallestObj)) { //Make sure currObj gets sorted according to area size
					smallestObj = currObj; //currObj was smaller than the smallest
				} 
				
				prevObj=currObj;
 				currObj=nextObj;
			}
			lastObj=currObj;
			// The polygon list now contains all Objects
			// The area size list now contains all Objects except the first and last points of the polygon

			currObj = smallestObj;
			while (notBiggestInList(currObj)) //Step through the area size list
			{
				prevObj = currObj.prev;
				nextObj = currObj.next;

				//currObj is done. Remove it from the polygon list
				prevObj.next = nextObj;
				nextObj.prev = prevObj;
				
				//Recalculate the sizes of both neighbours and update the area size list accordingly
				recalcSize(prevObj, polygon.length-1,currObj); //prevObj will end up somewhere after currObj in the area size list
				recalcSize(nextObj, polygon.length-1,currObj); //nextObj will end up somewhere after currObj in the area size list
				
				currObj = currObj.bigger;
			}

			return selection(smallestObj,minSize,polygon.length,firstObj,lastObj);
		}

		private function recalcSize(obj:Object, lastIndex:int, refObj:Object):void {
			if (obj.index > 0 && obj.index < lastIndex) //First or last point have no size
			{
				obj.size = triangleArea(obj);
				if (obj.size < refObj.size) {
					obj.size = refObj.size; //Ensure obj is worth at least as much as refObj
				}
				//obj's size has changed. Remove and reinsert it into the area size list
				obj.smaller.bigger = obj.bigger;
				obj.bigger.smaller = obj.smaller;
				insertIntoSizeList(obj,refObj);
			}
		}

		//Enter currObj at its appropriate place in the area size linked list
		private function insertIntoSizeList(currObj:Object, refObj:Object):Boolean {
			var reachedEnd:Boolean = false;
			while (refObj.size <= currObj.size || reachedEnd) //Step upward in the list until reaching the correct place
			{
				if (notBiggestInList(refObj)) {
					refObj = refObj.bigger;
				} else {
					reachedEnd = true;
				}
			}
			
			if (reachedEnd) {
				//Append currObj after refObj, at the end of the list
				currObj.smaller = refObj;
				currObj.bigger = null;
				currObj.smaller.bigger = currObj;
				return false; //currObj wasn't smaller than the smallest
			} else {
				//Insert currObj just before refObj
				if (notSmallestInList(refObj)) {
					currObj.smaller = refObj.smaller;
					currObj.bigger = refObj;
					currObj.smaller.bigger = currObj;
					currObj.bigger.smaller = currObj;
					return false; //currObj wasn't smaller than the smallest
				} else {
					currObj.smaller = null;
					currObj.bigger = refObj;
					currObj.bigger.smaller = currObj;
					return true; //currObj was smaller than the smallest
				}
			}
		}

		//Select the polygon corners with area size bigger than minSize
		private function selection(obj:Object,minSize:Number,origLength:int,firstObj:Object,lastObj:Object):Array {
			var output:Array = new Array(origLength);
			output[0]=[firstObj.x,firstObj.y];			//The first point has no size, so it's not in the area size list
			output[origLength-1]=[lastObj.x,lastObj.y];	//The last point has no size, so it's not in the area size list
			while (notBiggestInList(obj)) {
				if (obj.hasOwnProperty("size") && obj.size>=minSize) {
					output[obj.index] = [obj.x,obj.y];
				} 
				obj=obj.bigger;
			}
			output = output.filter(callback);		
			return output;
		}

        private function callback(item:*, index:int, array:Array):Boolean {
            return (item != null);
        }
		
		//Calculate the area of the triangle formed by three points
		private function triangleArea(currObj:Object):Number {
			var x1:Number = currObj.prev.x;
			var y1:Number = currObj.prev.y;
			var x2:Number = currObj.x;
			var y2:Number = currObj.y;
			var x3:Number = currObj.next.x;
			var y3:Number = currObj.next.y;
			return Math.abs(.5*(x1*y2+x2*y3+x3*y1-x2*y1-x3*y2-x1*y3)); //area of a triangle
		}

		private function notSmallestInList(obj:Object):Boolean {
			return (obj.hasOwnProperty("smaller") && obj.smaller!=null)
		}
		
		private function notBiggestInList(obj:Object):Boolean {
			return (obj.hasOwnProperty("bigger") && obj.bigger!=null)
		}
		
	}
}