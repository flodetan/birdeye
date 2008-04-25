package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	public class PieSparkSlice extends GeometryGroup
	{
		
		public var Arc:EllipticalArc;
		
		public function PieSparkSlice(wdt:Number,hgt:Number)
		{
			Arc=new EllipticalArc();
		 	Arc.id="arc";
		 	Arc.width=wdt/2;
		 	Arc.height=hgt/2;
		 	Arc.closureType="pie"; 
		 	Arc.startAngle=0;
		 	Arc.arc=0;

			this.geometryCollection.addItem(Arc);
			
			refresh();
		}
		
		[Bindable]
		public var field:String;
		
		
		
		public function refresh():void 
		{
			this.graphics.clear();
			Arc.preDraw();
			Arc.draw(this.graphics, null);	
		}
		private function clicked(event:Event):void 
		{
			trace ('clicked: ' + this);
		}
		
		private function onMouseOver(event:Event):void 
		{
			trace ('mouse over: ' + this);
		}
		
		private function onMouseOut(event:Event):void 
		{
			trace ('moue out: '+ this);
		}

	}
}