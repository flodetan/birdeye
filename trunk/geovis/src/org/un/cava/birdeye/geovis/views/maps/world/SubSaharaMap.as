package org.un.cava.birdeye.geovis.views.maps.world
{
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class SubSaharaMap extends GeoFrame
	{
		public var region:String;
		public function SubSaharaMap()
		{
			super(WorldRegionTypes.SUBREGION_SUBSAHARA);
			region=WorldRegionTypes.SUBREGION_SUBSAHARA;
		}

	}
}