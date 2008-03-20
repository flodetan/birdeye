package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class EasternMap extends GeoFrame
	{
		public var region:String;
		public function EasternMap()
		{
			super(WorldRegionTypes.SUBREGION_EASTERNASIA);
			region=WorldRegionTypes.SUBREGION_EASTERNASIA;
		}

	}
}