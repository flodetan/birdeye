package birdeye.vis.control
{
	import birdeye.vis.elements.geometry.PointElement;
	import birdeye.vis.interfaces.elements.IElement;
	
	import org.greenthreads.GreenThread;
	
	public class ElementDrawerThread extends GreenThread
	{
		public function ElementDrawerThread(debug:Boolean=true)
		{
			super(debug);
		}
		
		
		public var data:Array;
		
		public var element:PointElement;
		
		
		private var dataIndex:int;
		
		
		override protected function initialize() : void
		{
			dataIndex = 0;
		}
		
		
		override protected function run() : Boolean
		{
			if (dataIndex < data.length)
			{
				var d:Object = data[dataIndex];
				
				element.drawDataPoint(d);

				dataIndex++;
				
				return true;
			}
			
			
			return false;
			
		}
	}
}