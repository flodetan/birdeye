package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	public class ConusMap extends GeoFrame
	{
		public var region:String;
		public function ConusMap()
		{
			super(USARegionTypes.REGION_CONUS);
			region=USARegionTypes.REGION_CONUS;
		}

	}
}