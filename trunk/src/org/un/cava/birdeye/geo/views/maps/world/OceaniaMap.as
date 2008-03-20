package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class OceaniaMap extends GeoFrame
	{
		public var region:String;
		public function OceaniaMap()
		{
			super(WorldRegionTypes.REGION_OCEANIA);
			region=WorldRegionTypes.REGION_OCEANIA;
		}
	}
}