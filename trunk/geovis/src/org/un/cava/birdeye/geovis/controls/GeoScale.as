package org.un.cava.birdeye.geovis.controls
{
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.controls.Label;
	import mx.containers.Canvas;
	
	import flash.utils.*;
	import flash.events.Event;
	
	public class GeoScale extends UIComponent
	{
		private var scale:UIComponent;
		private var dynamicClassName:String;
		private var dynamicClassRef:Class;
		private var _height:Number;
		private var _width:Number;
		private var _x:Number;
		private var _y:Number;
		private var _parentMin:Number;
		private var _parentMax:Number;
		
		public function GeoScale()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createScale);
		}
		
		private function createScale(e:Event):void{
			dynamicClassName = getQualifiedClassName(this.parent);
			dynamicClassRef = getDefinitionByName(dynamicClassName) as Class;
			_height=(this.parent as dynamicClassRef).height;
			_width=(this.parent as dynamicClassRef).width;
			_x=(this.parent as dynamicClassRef).x;
			_y=(this.parent as dynamicClassRef).y;
			_parentMin=(this.parent as dynamicClassRef).minimumValue;
			_parentMax=(this.parent as dynamicClassRef).maximumValue;
			trace(_x+'//'+Number(_y)+Number(_height)+2)
			scale=new UIComponent();
			scale.x=_x;
			scale.y=_y+_height+2;
  	 		this.addChild(scale);
  	 		for (var i:int = 0; i <= 10; i++) {
  	 			var lbl:Label=new Label();
		 		 lbl.text=(i*10).toString();
		 		 lbl.setStyle('color',0x000000);
		 		 lbl.y=_y+_height+2;
		 		 lbl.x=_x+(_width/10*i) - lbl.width/2;
		 		 trace('added:'+(i*10).toString()+'/'+(_x+_width/10*i- lbl.width/2).toString() +'/'+(_y+_height+2).toString());
		 		 scale.addChild(lbl);
  	 		}
  	 		
  	 		/*var lbl:Label=new Label();
  	 		lbl.text="hello Wjm";
  	 		scale.addChild(lbl);*/
		}

	}
}