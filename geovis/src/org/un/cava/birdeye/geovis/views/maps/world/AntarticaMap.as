package org.un.cava.birdeye.geovis.views.maps.world
{	
	import org.un.cava.birdeye.geovis.dictionary.WorldRegionTypes;
	import org.un.cava.birdeye.geovis.core.GeoFrame;
	
	public class AntarticaMap extends GeoFrame
	{
		public var region:String;
		public function AntarticaMap()
		{
			super(WorldRegionTypes.REGION_ANTARTICA);
			region=WorldRegionTypes.REGION_ANTARTICA;
		}
	}
}