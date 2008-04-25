package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
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