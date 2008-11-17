package org.un.cava.birdeye.qavis.microcharts
{
	import com.degrafa.Surface;

	public class MicroChart extends Surface
	{
		private var tot:Number = NaN;

		[Bindable]
		private var _dataProvider:Array = new Array();
		
		public function set dataProvider(val:Array):void
		{
//			setTot(val);
			_dataProvider = val;
		}
		
		/**
		* Set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Array
		{
			return _dataProvider;
		}

		public function MicroChart()
		{
			//TODO: implement function
			super();
		}
	}
}