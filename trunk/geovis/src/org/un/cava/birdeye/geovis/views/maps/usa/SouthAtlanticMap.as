package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to South Atlantic map
	**/
	public class SouthAtlanticMap extends GeoFrame
	{
		public var region:String;
		public function SouthAtlanticMap()
			{
			super(USARegionTypes.SUBREGION_SOUTHATLANTIC);
			region=USARegionTypes.SUBREGION_SOUTHATLANTIC;
		}

	}
}