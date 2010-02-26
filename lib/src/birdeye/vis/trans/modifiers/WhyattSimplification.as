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
	import birdeye.vis.data.Pair;

	/** This class applies the Visvalingam-Whyatt simplification algorithm to the polygons of a country. 
	 */
	public class WhyattSimplification extends Simplification
	{
		private var _smallestObj:Object;
		private var _biggestObj:Object;
		private var _firstObj:Object;
		private var _lastObj:Object;
			
		public override function simplifyPolygon(polygon:Vector.<Pair>, epsilon:Number):Vector.<Pair>
		{
			var prevObj:Object;
			var currObj:Object;
			var nextObj:Object;
			var minSize:Number;
									
			//Create linked lists of Objects, which specify the effective area size for each polygon corner.
			//The Objects are linked four ways:
			//  Links (1)next and (2)previous follow the order of the points in the polygon, a.k.a. the polygon list
			//  Links (3)bigger and (4)smaller sort the points by effective area size, a.k.a. the area size list
			prevObj = {index:0,x:(polygon[0].dim1),y:(polygon[0].dim2)};
			currObj = {index:1,x:(polygon[1].dim1),y:(polygon[1].dim2), prev:prevObj};
			prevObj.next = currObj;
			_firstObj = prevObj;
			_smallestObj = _biggestObj = currObj;
			for (var i:int=1; i<polygon.length-1; i++) { 
 				nextObj = {index:(i+1),x:(polygon[i+1].dim1),y:(polygon[i+1].dim2),prev:currObj};
				currObj.next = nextObj;
				currObj.size = triangleArea(currObj);
				
				if (i > 1) {
					insertIntoSizeList(currObj, _smallestObj) //Make sure currObj gets sorted according to area size
				}
				
				prevObj=currObj;
 				currObj=nextObj;
			}
			_lastObj=currObj;
			// The polygon list now contains all Objects
			// The area size list now contains all Objects except the first and last points of the polygon

			//Repeat removing the smallest point and recalculating the area of its neighbours
			currObj = _smallestObj;
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

			minSize = adjustParameter(epsilon,_biggestObj.size);
			
			//Now select the points with size bigger than minSize
			return selection(minSize,polygon.length);
		}

		public static function adjustParameter(epsilon:Number,polygonSize:Number):Number {
			//Adjust epsilon depending on how big weights there are in the polygon, i.e. depending on _biggestObj.size
			return Math.pow((epsilon/100),40) * Math.pow(polygonSize,0.2)*5;			
		}

		private function recalcSize(obj:Object, lastIndex:int, refObj:Object):void {
			if (obj.index > 0 && obj.index < lastIndex) //First or last point have no size
			{
				obj.size = triangleArea(obj);
				if (obj.size < refObj.size) {
					obj.size = refObj.size; //Ensure obj is worth at least as much as refObj
				}
				//obj's size has changed. Remove and reinsert it into the area size list
				if (notSmallestInList(obj)) {
					obj.smaller.bigger = obj.bigger;
				}
				if (notBiggestInList(obj)) {
					obj.bigger.smaller = obj.smaller;
				}
				insertIntoSizeList(obj, refObj);
			}
		}

		//Enter currObj at its appropriate place in the area size linked list
		private function insertIntoSizeList(currObj:Object, refObj:Object):void {
			var reachedEnd:Boolean = false;
			while ((refObj.size <= currObj.size) && !reachedEnd) //Step upward in the list until reaching the correct place
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
				_biggestObj = currObj; //currObj was bigger than the biggest
			} else {
				//Insert currObj just before refObj
				if (notSmallestInList(refObj)) {
					currObj.smaller = refObj.smaller;
					currObj.bigger = refObj;
					currObj.smaller.bigger = currObj;
					currObj.bigger.smaller = currObj;
				} else {
					currObj.smaller = null;
					currObj.bigger = refObj;
					currObj.bigger.smaller = currObj;
					_smallestObj = currObj; //currObj was smaller than the smallest
				}
			}
		}

		//Select the polygon corners with area size bigger than minSize
		private function selection(minSize:Number,origLength:int):Vector.<Pair> {
			var obj:Object = _biggestObj;
			var output:Array = new Array(origLength);
			output[0]=new Pair(_firstObj.x,_firstObj.y);			//The first point has no size, so it's not in the area size list
			output[origLength-1]=new Pair(_lastObj.x,_lastObj.y);	//The last point has no size, so it's not in the area size list
			while (obj.hasOwnProperty("size") && obj.size>=minSize) {
				output[obj.index] = new Pair(obj.x,obj.y);
				//obj--
				if (notSmallestInList(obj)) {
					obj=obj.smaller;
				} else {
					break;
				}
			}
			output = output.filter(callback);
			return Vector.<Pair>(output);
		}

        private function callback(item:*, index:int, array:Array):Boolean {
        	var hasItem:Boolean = (item != null);
            return hasItem;
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