package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	/**
	* Control to EastNorthCentral map
	**/
	public class EastNorthCentralMap  extends GeoFrame
	{
		public var region:String;
		public function EastNorthCentralMap()
			{
			super(USARegionTypes.SUBREGION_EASTNORTHCENTRAL);
			region=USARegionTypes.SUBREGION_EASTNORTHCENTRAL;
		}

	}
}