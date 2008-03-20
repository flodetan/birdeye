package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
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