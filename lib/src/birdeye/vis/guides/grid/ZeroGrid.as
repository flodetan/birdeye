package birdeye.vis.guides.grid
{
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	import birdeye.vis.scales.BaseScale;
	
	import flash.geom.Rectangle;

	public class ZeroGrid extends Grid
	{
		public function ZeroGrid()
		{
			super();
		}
		
		override protected function createLineData(scale:IScale, bounds:Rectangle):Array
		{
			if (scale is INumerableScale)
			{
				var toReturn:Array = null;
				if (scale 
					&& (scale as INumerableScale).max > 0
					&& (scale as INumerableScale).min < 0
					&& scale.completeDataValues 
					&& scale.completeDataValues.length > 0)
				{
					toReturn = new Array();
					
					var position:Number = scale.getPosition(0);
						
					var itemData:String = "";
					
					if (scale.dimension == BaseScale.DIMENSION_2)
					{
						// horizontal
						itemData = "M" + String(0) + " " + String(position) + " " + 
							"L" + String(bounds.width) + " " + String(position) + " ";
					} else if (scale.dimension == BaseScale.DIMENSION_1)
					{
						// vertical
						itemData = "M" + String(position) + " " + String(0) + " " + 
							"L" + String(position) + " " + String(bounds.height) + " ";
					}
					
					toReturn.push(itemData);
					
					return toReturn;
				}
				
			

			}
			
			return null;
		}
	}
}