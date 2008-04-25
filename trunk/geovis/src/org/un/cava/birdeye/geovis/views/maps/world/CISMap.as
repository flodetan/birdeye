package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class CISMap extends GeoFrame
	{
		public var region:String;
		public function CISMap()
		{
			super(WorldRegionTypes.REGION_CIS);
			region=WorldRegionTypes.REGION_CIS;
		}

	}
}