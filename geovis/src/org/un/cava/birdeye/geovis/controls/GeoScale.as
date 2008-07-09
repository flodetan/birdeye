package org.un.cava.birdeye.geovis.controls
{
	import flash.utils.*;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	[Inspectable("title")]
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
		private var lbl:Label;
		private var _title:String;
		private var lblTitle:Label;
		
		public function set title(value:String):void{
			_title = value;
		}
		
		public function get title():String{
			return _title;
		}
		
		public function GeoScale()
		{
		}
		
		
		override protected function createChildren() : void 
     	{ 
        	super.createChildren(); 
        	scale=new UIComponent();
     	} 
		
		override protected function commitProperties() : void 
     	{ 
	        if (scale) 
	        {
	           dynamicClassName = getQualifiedClassName(this.parent);
				dynamicClassRef = getDefinitionByName(dynamicClassName) as Class;
				_height=(this.parent as dynamicClassRef).height;
				_width=(this.parent as dynamicClassRef).width;
				_x=(this.parent as dynamicClassRef).x;
				_y=(this.parent as dynamicClassRef).y;
				_parentMin=(this.parent as dynamicClassRef).minimumValue;
				_parentMax=(this.parent as dynamicClassRef).maximumValue;
				
				scale.x=Number(_x);
				scale.y=Number(_y+_height+2);
			
				for (var i:int = 0; i <= 10; i++) {
	  	 			lbl=new Label();
			 		lbl.text=(i*10).toString()+'%';
			 		lbl.setStyle('color',0x000000);
			 		lbl.setStyle('textAlign','center');
			 		lbl.height=15;
			 		lbl.width=40;
			 		lbl.x=Number((_width/10*i) - lbl.width/2);
			 		
			 		scale.addChild(lbl);
	  	 		}
	  	 		if(_title!=''){
		  	 		lblTitle=new Label();
		  	 		lblTitle.text=_title;
		  	 		lblTitle.setStyle('textAlign','center');
		  	 		lblTitle.width=_width;
		  	 		lblTitle.height=15;
				 	lblTitle.y=17;
				 	scale.addChild(lblTitle);
	  	 		}
			 		
	  	 		this.addChild(scale)
	        }     
	     } 
	}
}