package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class CountryMap extends GeoFrame
	{
		public function CountryMap()
		{
			super(WorldRegionTypes.REGION_WORLD);
		}
	}
}