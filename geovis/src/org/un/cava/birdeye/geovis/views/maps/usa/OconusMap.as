package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	public class OconusMap extends GeoFrame
	{
		public var region:String;
		public function OconusMap()
		{
			super(USARegionTypes.REGION_OCONUS);
			region=USARegionTypes.REGION_OCONUS;
		}

	}
}