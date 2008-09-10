package org.un.cava.birdeye.geovis.events
{
	import flash.events.Event;
	
	public class GeoThumbEvents extends Event
	{
		public function GeoThumbEvents(type:String, value:Number)
		{
			super(type);
            this.value=value;
		}
	
	 /**
		 *  The <code>GeoThumbEvents.VALUE_CHANGED</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for an <code>valueChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>value</code></td><td>The value of the thumb.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
		 *  </table>
		 *
	     *  @eventType valueChanged
		 */
        public static const VALUE_CHANGED:String = "valueChanged";
        
        //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */    
        public var value:Number;
        
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 */
        override public function clone():Event {
            return new GeoThumbEvents(type, value);
        }
	}
}