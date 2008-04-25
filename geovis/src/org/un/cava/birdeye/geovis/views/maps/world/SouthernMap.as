package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class SouthernMap extends GeoFrame
	{
		public var region:String;
		public function SouthernMap()
		{
			super(WorldRegionTypes.SUBREGION_SOUTHERNASIA);
			region=WorldRegionTypes.SUBREGION_SOUTHERNASIA;
		}

	}
}