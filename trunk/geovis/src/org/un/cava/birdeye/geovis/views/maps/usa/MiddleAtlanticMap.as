package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to MiddleAtlantic map
	**/
	public class MiddleAtlanticMap  extends GeoFrame
	{
		public var region:String;
		public function MiddleAtlanticMap()
			{
			super(USARegionTypes.SUBREGION_MIDDLEATLANTIC);
			region=USARegionTypes.SUBREGION_MIDDLEATLANTIC;
		}

	}
}