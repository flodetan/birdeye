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

package org.un.cava.birdeye.geovis.events
{
	import flash.events.Event;
	
	public class GeoChoroEvents extends Event
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @param scheme
		 * 	@param steps
		 * 	@param colorField
		 */
		public function GeoChoroEvents(type:String,scheme:String, steps:int, colorField:String) {
                super(type);
                this.scheme=scheme;
                this.steps=steps;
                this.colorField=colorField;
        }
		
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	
	    
	     /**
		 *  The <code>GeoChoroEvents.CHOROPLETH_SCHEME_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ChoroplethSchemeChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>scheme</code></td><td>The name of the scheme.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ChoroplethSchemeChanged 
		 */
        public static const CHOROPLETH_SCHEME_CHANGED:String = "ChoroplethSchemeChanged";
        
        /**
		 *  The <code>GeoChoroEvents.CHOROPLETH_STEPS_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ChoroplethStepsChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>steps</code></td><td>The number of steps.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ChoroplethStepsChanged 
		 */
        public static const CHOROPLETH_STEPS_CHANGED:String = "ChoroplethStepsChanged";
        
        /**
		 *  The <code>GeoChoroEvents.CHOROPLETH_COLORFIELD_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ChoroplethColorFieldChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>scheme</code></td><td>The name of the scheme.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ChoroplethColorFieldChanged 
		 */
        public static const CHOROPLETH_COLORFIELD_CHANGED:String = "ChoroplethColorFieldChanged";
        
        
        /**
		 *  The <code>GeoChoroEvents.CHOROPLETH_COLORFIELD_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ChoroplethComplete</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ChoroplethComplete 
		 */
        public static const CHOROPLETH_COMPLETE:String = "ChoroplethComplete";
        
        //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */    
        public var scheme:String;
        
        /**
	     *  @private
	     */    
        public var steps:int;
        
        /**
	     *  @private
	     */    
        public var colorField:String;
        
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 */
        override public function clone():Event {
            return new GeoChoroEvents(type, scheme, steps, colorField);
        }

	}
}