package org.un.cava.birdeye.geovis.controls
{
	import flash.events.Event;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	[Style(name="trackColor", type="uint", format="Color", inherit="no")]
	[Inspectable("ticksMark")]
	public class GeoGauge extends Canvas
	{
		
		private var barre:UIComponent;
        private var _width:Number=300;
        private var _height:Number=15;
        private var _x:Number=0;
        private var _y:Number=0;
        private var _min:Number;
		private var _max:Number;
		private var _ticksMark:Boolean=true;
		private var _ticksWidth:Number=3;
		private var _minorTicksInterval:Number=1;
		private var _majorTicksInterval:Number=10;
		
        override public function set x(x:Number):void{
			_x = x;
		}
		
		override public function get x():Number{
			return _x;
		}
		
		override public function set y(value:Number):void{
			_y = value;
		}
		
		override public function get y():Number{
			return _y;
		}
		
		override public function set width(w:Number):void{
			_width = w;
		}
		
		override public function get width():Number{
			return _width;
		}
		
		override public function set height(h:Number):void{
			_height = h;
		}
		
		override public function get height():Number{
			return _height;
		}
		
		public function set minimumValue(value:Number):void{
			_min = value;
		}
		
		public function get minimumValue():Number{
			return _min;
		}
		
		public function set maximumValue(value:Number):void{
			_max = value;
		}
		
		public function get maximumValue():Number{
			return _max;
		}
		
		[Inspectable(enumeration="true,false")]
		public function set ticksMark(value:Boolean):void{
			_ticksMark = value;
		}
		
		public function set ticksWidth(value:Number):void{
			_ticksWidth = value;
		}
		
		public function set minorTicksInterval(value:Number):void{
			_minorTicksInterval = value;
		}
		
		public function set majorTicksInterval(value:Number):void{
			_majorTicksInterval = value;
		}
		
		public function GeoGauge()
		{
		}
		
		
		override protected function createChildren() : void 
     	{ 
        	super.createChildren(); 
        	barre = new UIComponent();		
     	} 
     	
     	override protected function commitProperties() : void 
     	{ 
     		if (barre) 
	        { 
	        	this.addChild(barre);
	        }
     	}
     	
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(barre){
				barre.graphics.clear();
				barre.graphics.beginFill(getStyle("trackColor"));
				barre.graphics.drawRect(_x,_y,_width,_height);
				barre.graphics.endFill();
				
				for (var i:int = 0; i < this.numChildren-1; i++) {
					var dynamicClassName:String=getQualifiedClassName(this.getChildAt(i));
					var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
					if(dynamicClassName.substr(dynamicClassName.length-8,8)=='GeoThumb')
					{
						if(GeoThumb(this.getChildAt(i)).draggable){
							barre.graphics.beginFill(GeoThumb(this.getChildAt(i)).getStyle("Color"));
							barre.graphics.drawRect(_x+(GeoThumb(this.getChildAt(i)).minimum*_width/_max), _y, (GeoThumb(this.getChildAt(i)).maximum-GeoThumb(this.getChildAt(i)).minimum)*_width/_max, _height);//
							barre.graphics.endFill();
						}
					}
				}
			
				barre.graphics.lineStyle(1,0x000000);
				barre.graphics.drawRect(_x, _y, _width, _height);
				
				for (var j:int = 1; j < 100; j++) {
  	 		 		 if (j%10==0){
  	 		 		 		 barre.graphics.moveTo(_x+_width/100*j,_y+_height-2);
  	 		 		 		 barre.graphics.lineTo(_x+_width/100*j,_y+2);
  	 		 		 }else{
  	 		 		 		 barre.graphics.moveTo(_x+_width/100*j,_y+_height-2);
  	 		 		 		 barre.graphics.lineTo(_x+_width/100*j,_y+(_height*50/100));
  	 		 		 }
  		 		}
			}
		}
		
		
	}
}