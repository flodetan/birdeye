package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
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