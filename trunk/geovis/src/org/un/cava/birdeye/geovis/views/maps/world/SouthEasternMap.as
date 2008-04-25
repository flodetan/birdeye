package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
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