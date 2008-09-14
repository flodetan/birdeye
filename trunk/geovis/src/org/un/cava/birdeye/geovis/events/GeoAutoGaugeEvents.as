package org.un.cava.birdeye.geovis.events
{
	import flash.events.Event;
	
	public class GeoAutoGaugeEvents extends Event
	{
		public function GeoAutoGaugeEvents(type:String, value:Array)
		{
			super(type);
            this.value=value;
		}
	
	 /**
		 *  The <code>GeoThumbEvents.VALUES_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>valuesChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>value</code></td><td>The values of the thumbs.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType valuesChanged
		 */
        public static const VALUES_CHANGED:String = "valuesChanged";
        
        //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */    
        public var value:Array;
        
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 */
        override public function clone():Event {
            return new GeoAutoGaugeEvents(type, value);
        }
	}
}