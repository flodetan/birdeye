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

package birdeye.vis.trans.graphs.data
{
	import birdeye.vis.interfaces.IEdgeElement;
	import birdeye.vis.interfaces.IGraphLayoutableElement;
	
	public class DataItemsGraphDataProvider implements IGraphDataProvider
	{
		private var nodeElement:IGraphLayoutableElement;
		private var edgeElement:IEdgeElement;

		public function DataItemsGraphDataProvider(nodeElement:IGraphLayoutableElement, edgeElement:IEdgeElement) {
			this.nodeElement = nodeElement;
			this.edgeElement = edgeElement;
		}

		public function get numberOfNodes():int {
			const items:Vector.<Object> = nodeElement.dataItems;
			if (!items) return 0;
			return items.length;
		}

		public function get numberOfEdges():int {
			const items:Vector.<Object> = edgeElement.dataItems;
			if (!items) return 0;
			return items.length;
		}

		public function getNodeId(index:int):String {
			return nodeElement.dataItems[index][nodeElement.dimId];
		}

		public function getNodeTag(index:int):Object {
			return nodeElement.dataItems[index];
		}

		public function getEdgeFromNodeId(index:int):String {
			return edgeElement.dataItems[index][edgeElement.dimStart];
		}

		public function getEdgeToNodeId(index:int):String {
			return edgeElement.dataItems[index][edgeElement.dimEnd];
		}

		public function getEdgeTag(index:int):Object {
			return edgeElement.dataItems[index];
		}

	}
}
