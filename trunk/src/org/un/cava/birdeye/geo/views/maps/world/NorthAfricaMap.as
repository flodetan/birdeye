package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class NorthAfricaMap extends GeoFrame
	{
		public var region:String;
		public function NorthAfricaMap()
		{
			super(WorldRegionTypes.SUBREGION_NORTHAFRICA);
			region=WorldRegionTypes.SUBREGION_NORTHAFRICA;
		}

	}
}