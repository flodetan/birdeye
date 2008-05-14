package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to Mountain map
	**/
	public class MountainMap  extends GeoFrame
	{
		public var region:String;
		public function MountainMap()
			{
			super(USARegionTypes.SUBREGION_MOUNTAIN);
			region=USARegionTypes.SUBREGION_MOUNTAIN;
		}

	}
}