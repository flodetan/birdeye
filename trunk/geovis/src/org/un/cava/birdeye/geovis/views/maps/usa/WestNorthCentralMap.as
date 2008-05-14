package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to WestNorthCentral map
	**/
	public class WestNorthCentralMap extends GeoFrame
	{
		public var region:String;
		public function WestNorthCentralMap()
			{
			super(USARegionTypes.SUBREGION_WESTNORTHCENTRAL);
			region=USARegionTypes.SUBREGION_WESTNORTHCENTRAL;
		}

	}
}