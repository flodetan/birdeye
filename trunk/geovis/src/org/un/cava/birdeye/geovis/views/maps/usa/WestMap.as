package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to West map
	**/
	public class WestMap extends GeoFrame
	{
		public var region:String;
		public function WestMap()
			{
			super(USARegionTypes.REGION_WEST);
			region=USARegionTypes.REGION_WEST;
		}

	}
}