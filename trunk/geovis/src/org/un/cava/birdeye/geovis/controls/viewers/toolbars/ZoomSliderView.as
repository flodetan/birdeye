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
 
package org.un.cava.birdeye.geovis.controls.viewers.toolbars
{
	import flash.events.Event;
	
	import mx.controls.VSlider;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	
	public class ZoomSliderView extends VSlider
	{
		public function ZoomSliderView() 
		{
			super();
		    minimum = 0.1;
		    maximum = 20;
		    labels = [0,5,10,15,20];
		    liveDragging = true;
		    enabled = true;
		    toolTip = "Center the map first and then use this slider"
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true)
		}
		
		private var map:Map;
		private function init(e:MapEvent):void
		{
			map = Map(e.target);
		    value = map.zoom;
			map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, updateZoomValue);
//			map.addEventListener(MapEvent.MAP_CHANGED, updateZoomValue);
		    addEventListener(Event.CHANGE, sliderZoomHandler);
			parent.setChildIndex(this, parent.numChildren-1);
		}
		
		private function sliderZoomHandler(e:Event):void
	    {
			map.zoomingWithSlider(e); 
	    }
	    
	    private function updateZoomValue(e:MapEvent):void
	    {
	    	map = Map(e.target);
	    	if (map.zoom < maximum)
	    		value = Math.max(minimum, map.zoom)
	    	else
			    value = Math.min(map.zoom, maximum);
	    }
	}
}