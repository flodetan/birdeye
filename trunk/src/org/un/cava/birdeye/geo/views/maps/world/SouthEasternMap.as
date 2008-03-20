package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class SouthEasternMap extends GeoFrame
	{
		public var region:String;
		public function SouthEasternMap()
		{
			super(WorldRegionTypes.SUBREGION_SOUTHEASTERNASIA);
			region=WorldRegionTypes.SUBREGION_SOUTHEASTERNASIA;
		}

	}
}