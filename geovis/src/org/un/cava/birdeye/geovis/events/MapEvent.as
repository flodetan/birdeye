package org.un.cava.birdeye.geovis.events
{
	import flash.events.Event;

	public class MapEvent extends Event
	{
		public function MapEvent(type:String)
		{
			super(type);
		}
		
		public static const MAP_CREATION_COMPLETE:String = "MapCreationComplete";
		
		public static const MAP_ZOOM_COMPLETE:String = "MapZoomComplete";
		public static const MAP_ZOOM_WHEEL:String = "MapZoomWheel";
		public static const MAP_ZOOM_DOUBLECLICK:String = "MapZoomDoubleClick";
		public static const MAP_ZOOM_SLIDER:String = "MapZoomSlider";
        public static const MAP_DRAG_START:String = "MapDragStart";
        public static const MAP_DRAG_COMPLETE:String = "MapDragComplete";
        public static const MAP_CENTERED:String = "MapCentered";
        
        public static const MAP_PROPERTY_ON:String = "MapPropertyChanged";
        public static const MAP_PROPERTY_OFF:String = "MapPropertyChanged";
        public static const MAP_ZOOM_CHANGED:String = "MapZoomChanged";

		/**
		 * @private
		 */
        override public function clone():Event {
            return new MapEvent(type);
        }

	}
}