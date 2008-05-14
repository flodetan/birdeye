package org.un.cava.birdeye.geovis.views.maps.usa
{
	import org.un.cava.birdeye.geovis.dictionary.USARegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	/**
	* Control to Pacific map
	**/
	public class PacificMap extends GeoFrame
	{
		public var region:String;
		public function PacificMap()
			{
			super(USARegionTypes.SUBREGION_PACIFIC);
			region=USARegionTypes.SUBREGION_PACIFIC;
		}

	}
}