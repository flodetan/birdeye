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
	
	import org.un.cava.birdeye.geovis.features.Features;
	
	public class GeoMapEvents extends Event
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
		 *  @param key The value is a 3 letters country ISO code and 2 letters states ISO code for the US map.
		 *
		 *  @param features Specifies the features of the associated item.
		 *
		 */
		public function GeoMapEvents(type:String,key:String, feature:Features) {
                super(type);
                this.key=key;
                this.feature=feature;
        }
		
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	
	    
	     /**
		 *  The <code>GeoMapEvents.ITEM_CLICKED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>itemClick</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>index</code></td><td>The index of the navigation item that was clicked.</td></tr>
	     *     <tr><td><code>item</code></td><td>The item in the data provider of the navigation
	     * 	   item that was clicked.</td></tr>
	     *     <tr><td><code>label</code></td><td>The label of the navigation item that was clicked.</td></tr>
	     *     <tr><td><code>relatedObject</code></td><td>The child object that generated the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType itemClick 
		 */
        public static const ITEM_CLICKED:String = "ItemClick";
        
        /**
		 *  The <code>GeoMapEvents.ITEM_DOUBLECLICKED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ItemDoubleClick</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>index</code></td><td>The index of the navigation item that was double clicked.</td></tr>
	     *     <tr><td><code>item</code></td><td>The item in the data provider of the navigation
	     * 	   item that was double clicked.</td></tr>
	     *     <tr><td><code>label</code></td><td>The label of the navigation item that was double clicked.</td></tr>
	     *     <tr><td><code>relatedObject</code></td><td>The child object that generated the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ItemDoubleClick
		 */
        public static const ITEM_DOUBLECLICKED:String = "ItemDoubleClick";
        
        /**
		 *  The <code>GeoMapEvents.ITEM_ROLLOVER</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ItemRollOver</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>index</code></td><td>The index of the navigation item that was rolled over.</td></tr>
	     *     <tr><td><code>item</code></td><td>The item in the data provider of the navigation
	     * 	   item that was rolled over.</td></tr>
	     *     <tr><td><code>label</code></td><td>The label of the navigation item that was rolled over.</td></tr>
	     *     <tr><td><code>relatedObject</code></td><td>The child object that generated the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ItemRollOver
		 */
        public static const ITEM_ROLLOVER:String = "ItemRollOver";
        
        /**
		 *  The <code>GeoMapEvents.ITEM_ROLLOUT</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>ItemRollOut</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>index</code></td><td>The index of the navigation item that was rolled out.</td></tr>
	     *     <tr><td><code>item</code></td><td>The item in the data provider of the navigation
	     * 	   item that was rolled out.</td></tr>
	     *     <tr><td><code>label</code></td><td>The label of the navigation item that was rolled out.</td></tr>
	     *     <tr><td><code>relatedObject</code></td><td>The child object that generated the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType ItemRollOut
		 */
        public static const ITEM_ROLLOUT:String = "ItemRollOut";
        
        //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */    
        public var key:String;
        /**
	     *  @private
	     */ 
		public var feature:Features;
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 */
        override public function clone():Event {
            return new GeoMapEvents(type, key, feature);
        }

	}
}