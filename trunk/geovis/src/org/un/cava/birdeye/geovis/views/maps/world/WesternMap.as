package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class WesternMap extends GeoFrame
	{
		public var region:String;
		public function WesternMap()
		{
			super(WorldRegionTypes.SUBREGION_WESTERNASIA);
			region=WorldRegionTypes.SUBREGION_WESTERNASIA;
		}

	}
}