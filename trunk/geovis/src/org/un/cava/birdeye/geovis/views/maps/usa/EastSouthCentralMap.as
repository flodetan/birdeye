package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to EastSouthCentral map
	**/
	public class EastSouthCentralMap  extends GeoFrame
	{
		public var region:String;
		public function EastSouthCentralMap()
			{
			super(USARegionTypes.SUBREGION_EASTSOUTHCENTRAL);
			region=USARegionTypes.SUBREGION_EASTSOUTHCENTRAL;
		}

	}
}