package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class CountryMap extends GeoFrame
	{
		public function CountryMap()
		{
			super(WorldRegionTypes.REGION_WORLD);
		}
	}
}