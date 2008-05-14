package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to South map
	**/
	public class SouthMap extends GeoFrame
	{
		public var region:String;
		public function SouthMap()
			{
			super(USARegionTypes.REGION_SOUTH);
			region=USARegionTypes.REGION_SOUTH;
		}

	}
}