package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class AsiaMap extends GeoFrame
	{
		public var region:String;
		public function AsiaMap()
		{
			super(WorldRegionTypes.REGION_ASIA);
			region=WorldRegionTypes.REGION_ASIA;
		}
		
	}
}