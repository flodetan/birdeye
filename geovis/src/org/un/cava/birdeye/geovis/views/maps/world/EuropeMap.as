package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
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