package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class NorthAmericaMap extends GeoFrame
	{
		public var region:String;
    	public function NorthAmericaMap()
		{
			super(WorldRegionTypes.REGION_NORTH_AMERICA);
			region=WorldRegionTypes.REGION_NORTH_AMERICA;
		}
	}
}