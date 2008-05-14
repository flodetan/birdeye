package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to WestSouthCentral map
	**/
	public class WestSouthCentralMap extends GeoFrame
	{
		public var region:String;
		public function WestSouthCentralMap()
			{
			super(USARegionTypes.SUBREGION_WESTSOUTHCENTRAL);
			region=USARegionTypes.SUBREGION_WESTSOUTHCENTRAL;
		}

	}
}