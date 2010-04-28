package birdeye.vis.interactivity.tooltips
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.interactivity.IInteractiveGeometry;
	
	public class MinMaxToolTipManager extends FilterableToolTipManager
	{
		public function MinMaxToolTipManager(coords:ICoordinates)
		{
			super(coords);
		}
		
		private var min:Number = Number.MAX_VALUE;
		private var max:Number = Number.MIN_VALUE;
		
		public var showMax:Boolean = true;
		public var showMin:Boolean = true;
		
		override protected function filter(geom:IInteractiveGeometry):void
		{
			if (geoms.length < 2)
			{
				geoms.push(null,null);
			}
			
			var nbr:Number = Number(geom.data[geom.element[labelDimension]]);
			
			
			if (showMin && nbr < min)
			{
				min = nbr;
				
				geoms[0] = geom;
			}
			
			if (showMax && nbr > max)
			{
				max = nbr;
				
				geoms[1] = geom;
			}
			
		}
	}
}