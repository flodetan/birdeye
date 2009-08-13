package birdeye.vis.facets
{
	import birdeye.vis.interfaces.ICoordinates;
	
	import mx.core.IFactory;
	
	/**
	 * This is a container that allows different type of object to be defined in a facet.</br>
	 * This container is created to allow more control over which objects are cloned and which not.</br>
	 * For example scales will not be replicated as they need to evaluate the whole dataset to establish their max and min.
	 */
	public class FacetContainer implements IFactory
	{
		public var coord:ICoordinates;
		public var scales:Array;
		public var elements:Array;
		public var guides:Array;
		
		public function newInstance():*
		{
			return this;
		}
		
			

	}
}