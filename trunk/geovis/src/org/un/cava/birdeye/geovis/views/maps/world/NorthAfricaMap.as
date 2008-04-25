package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
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