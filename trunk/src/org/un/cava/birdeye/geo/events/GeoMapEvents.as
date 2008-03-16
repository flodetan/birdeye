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

package org.un.cava.birdeye.geo.events
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	
	public class GeoMapEvents extends MouseEvent
	{
		public function GeoMapEvents(type:String, isEnabled:Boolean=false) {
                super(type);
                
                this.isEnabled = isEnabled;
        }

        public static const ITEM_CLICKED:String = "ItemClick";
        public static const ITEM_ROLLOVER:String = "ItemRollOver";
        public static const ITEM_ROLLOUT:String = "ItemRollOut";
            
        public var isEnabled:Boolean;

        override public function clone():Event {
            return new GeoMapEvents(type, isEnabled);
        }

		

	}
}