package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
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