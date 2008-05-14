package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to Midwest map
	**/
	public class MidwestMap  extends GeoFrame
	{
		public var region:String;
		public function MidwestMap()
			{
			super(USARegionTypes.REGION_MIDWEST);
			region=USARegionTypes.REGION_MIDWEST;
		}

	}
}