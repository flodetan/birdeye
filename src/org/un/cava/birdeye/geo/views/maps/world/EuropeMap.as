package org.un.cava.birdeye.geo.views.maps.world
{
	import org.un.cava.birdeye.geo.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geo.core.GeoFrame;
	
	public class EuropeMap extends GeoFrame
	{
		public var region:String;
		public function EuropeMap()
		{
			super(WorldRegionTypes.REGION_EUROPE);
			region=WorldRegionTypes.REGION_EUROPE;
		}
		
	}
}