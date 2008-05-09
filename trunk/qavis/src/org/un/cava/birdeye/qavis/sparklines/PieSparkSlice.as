package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import mx.managers.ToolTipManager; 
	import mx.core.IToolTip; 
	
	import flash.events.MouseEvent;
	
	public class PieSparkSlice extends GeometryGroup
	{
		
		/*[Bindable]
		public var field:String;
		[Bindable]
		public var showdtTips:Boolean;
		[Bindable]
		public var toolTip:String;
		[Bindable]
		public var surf:Surface;
		*/
		public var Arc:EllipticalArc;
		
		private var _surf:Surface;
		private var _toolTip:String;
		private var currentToolTipItem:IToolTip; 


		public function PieSparkSlice(wdt:Number,hgt:Number,field:String,showdtTips:Boolean,toolTip:String,surf:Surface)
		{
			_surf=surf;
			_toolTip=toolTip;
			
			Arc=new EllipticalArc();
		 	Arc.id="arc";
		 	Arc.width=wdt/2;
		 	Arc.height=hgt/2;
		 	Arc.closureType="pie"; 
		 	Arc.startAngle=0;
		 	Arc.arc=0;
			
			this.geometryCollection.addItem(Arc);
			if(showdtTips==true){
				this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				this.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverEvent);
			}
			refresh();
		}
		
		
		public function refresh():void 
		{
			this.graphics.clear();
			Arc.preDraw();
			Arc.draw(this.graphics, null);	
		}
		/*private function clicked(event:Event):void 
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
		}*/
		private function onRollOver(event:MouseEvent):void{
			trace('MouseOver'+_toolTip);
			_surf.toolTip=_toolTip;
	    }
	    private function onRollOut(event:MouseEvent):void{
	    	trace('MouseOut');
	    	_surf.toolTip = "";
	    }
		
		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
        	//eventObj.target.mouseChildren=false;
        	//GeometryGroup(eventObj.target).filters=[new GlowFilter(0xFFFFFF,0.5,32,32,255,3,true,true)];
		}
	}
}
