package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to New England map
	**/
	public class NewEnglandMap  extends GeoFrame
	{
		public var region:String;
		public function NewEnglandMap()
			{
			super(USARegionTypes.SUBREGION_NEWENGLAND);
			region=USARegionTypes.SUBREGION_NEWENGLAND;
		}

	}
}