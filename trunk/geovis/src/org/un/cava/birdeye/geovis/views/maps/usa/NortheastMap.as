package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to Northeast map
	**/
	public class NortheastMap  extends GeoFrame
	{
		public var region:String;
		public function NortheastMap()
			{
			super(USARegionTypes.REGION_NORTHEAST);
			region=USARegionTypes.REGION_NORTHEAST;
		}

	}
}