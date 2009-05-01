package views.charts
{
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.core.IToolTip;
	import org.un.cava.birdeye.qavis.microcharts.Micro100BarChart;

	public class MyTip2 extends Panel implements IToolTip
	{
		public function MyTip2()
		{
			super();
			setStyle("borderColor", "0x000000");
			setStyle("borderThickness", "2");
			alpha = 1;
		}
		
		private var lbl:Label = new Label();
		public var barChart:Micro100BarChart;
		override protected function createChildren():void
		{
			super.createChildren();
			addChild(lbl);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		public function set dataProvider(value:Object):void
		{
			barChart = new Micro100BarChart(value);
			if (!contains(barChart))
				addChild(barChart);
		}
		
		public function get text():String
		{
			return lbl.text;
		}
		public function set text(value:String):void
		{
			lbl.text = value;
		}
		
	}
}