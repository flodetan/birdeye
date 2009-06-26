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

package birdeye.vis.trans
{
	public class SingleCycleGraphLayout extends BaseGraphLayout
	{
		public function SingleCycleGraphLayout() {
			super();
		}
		
		public override function apply(width:int, height:int):void {
			const dataItems:Vector.<Object> = _node.dataItems;
			if (dataItems) {
			    const numItems = dataItems.length;
				const mx:Number = width/2, my:int = height/2, r:int = Math.min(width, height)/2 * .8;
				for (var i:int = 0; i < numItems; i++) {
					setItemPosition(i, 
						mx + Math.cos(2 * Math.PI * i / numItems) * r, 
						my - Math.sin(2 * Math.PI * i / numItems) * r, NaN);
				}
			}
		}
	}
}
