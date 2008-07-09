package org.un.cava.birdeye.geovis.controls
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.ToolTipManager;
            
	[Style(name="Color", type="uint", format="Color", inherit="no")]
	[Inspectable("draggable")]
	[Inspectable("allowDragToTheEnd")]
	public class GeoThumb extends UIComponent
	{
		private var bouton:UIComponent;
		private var _height:Number;
		private var _width:Number;
		private var _x:Number;
		private var _y:Number;
		[Bindable]
		private var _min:Number;
		[Bindable]
		private var _max:Number;
		[Bindable]
		private var _value:Number;
		private var _draggable:Boolean=true;
		private var _parentMin:Number;
		private var _parentMax:Number;
		private var dynamicClassName:String;
		private var dynamicClassRef:Class;
		private var _allowDragToTheEnd:Boolean=false;
		private var tt:IToolTip;

		[Bindable]
		public function set minimum(value:Number):void{
			_min = value;
		}
		public function get minimum():Number{
			return _min;
		}
		
		[Bindable]
		public function set maximum(value:Number):void{
			_max = value;
		}
		public function get maximum():Number{
			return _max;
		}
		
		[Bindable(event="valueUpdated")]
		public function set value(value:Number):void{
			_value = value;
			dispatchEvent( new FlexEvent( "valueUpdated" ) );
		}
		public function get value():Number{
			return _value;
		}
		
		[Inspectable(enumeration="true,false")]
		public function set draggable(value:Boolean):void{
			_draggable = value;
		}
		
		public function get draggable():Boolean{
			return _draggable;
		}
		
		
		[Inspectable(enumeration="true,false")]
		public function set allowDragToTheEnd(value:Boolean):void{
			_allowDragToTheEnd = value;
		}
		
		public function get allowDragToTheEnd():Boolean{
			return _allowDragToTheEnd;
		}
		
		public function GeoThumb()
		{
		}
		
		override protected function createChildren() : void 
     	{ 
     		super.createChildren(); 
        	bouton = new UIComponent();
     	}
     	
     	override protected function commitProperties() : void 
     	{ 
	        if (bouton) 
	        { 
	        	dynamicClassName = getQualifiedClassName(this.parent);
				dynamicClassRef = getDefinitionByName(dynamicClassName) as Class;
				_height=(this.parent as dynamicClassRef).height;
				_width=(this.parent as dynamicClassRef).width;
				_x=(this.parent as dynamicClassRef).x;
				_y=(this.parent as dynamicClassRef).y;
				_parentMin=(this.parent as dynamicClassRef).minimumValue;
				_parentMax=(this.parent as dynamicClassRef).maximumValue;
				
				bouton = new UIComponent();
				bouton.graphics.beginFill(getStyle("Color"));
				bouton.graphics.lineStyle(1,0x000000);
				bouton.graphics.moveTo(0,0);
				bouton.graphics.lineTo(-_height/2,-_height);
				bouton.graphics.lineTo(_height/2,-_height);
				bouton.graphics.moveTo(0,0);
				bouton.graphics.endFill();
				bouton.x=_x+(_value*_width)/_parentMax;
				bouton.y=_y-2;
				
			    this.addChild(bouton);
				
				if(_draggable==true){
					bouton.addEventListener(MouseEvent.MOUSE_OVER,MouseOverEvent);
		            bouton.addEventListener(MouseEvent.MOUSE_OVER,MouseOutEvent);
		  			bouton.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
		            bouton.addEventListener(MouseEvent.MOUSE_UP, endDrag);
		            bouton.addEventListener(MouseEvent.MOUSE_OUT, endDrag);
		        }
	        }
     	}
		
		 private function startMove(event:MouseEvent):void
        {
        	toolTipCreate(_value.toString(), event.stageX + 10, event.stageY + 10);
            
            // false : on déplace l'objet par rapport à l'endroit du clic souris
            // true : on déplace l'objet par rapport à son centre
            // Rectangle : zone de déplacement possible du Drag
           if(_allowDragToTheEnd){
           		bouton.startDrag(false, new Rectangle(_x+(_min*_width/_parentMax), _y-2, (_parentMax-_min)*_width/_parentMax, 0));
           }else{
           		bouton.startDrag(false, new Rectangle(_x+(_min*_width/_parentMax), _y-2, (_max-_min)*_width/_parentMax, 0));
           }
           bouton.addEventListener(MouseEvent.MOUSE_MOVE, moveDrag);
        }

        private function endDrag(event:MouseEvent):void
        {
        	toolTipDestroy();
            bouton.stopDrag();
            bouton.removeEventListener(MouseEvent.MOUSE_MOVE, moveDrag);
        }

        private function moveDrag(event:MouseEvent):void
        {
        	if (tt) {
                    tt.move(event.stageX + 10, event.stageY + 10);
                    tt.text=((event.currentTarget.x-_x)*_parentMax/_width).toString();
                    //rounded value with 2 decimal tt.text=(int((event.currentTarget.x-_x)*_parentMax/_width*100)/100).toString();
                    event.updateAfterEvent();
            }
				_value=(event.currentTarget.x-_x)*_parentMax/_width
	        	dispatchEvent( new FlexEvent( "valueUpdated" ) );
	            (this.parent as dynamicClassRef).invalidateDisplayList();
        }
        
        private function MouseOverEvent(event:MouseEvent):void {
        	toolTipCreate(_value.toString(), event.stageX + 10, event.stageY + 10);
        	event.currentTarget.useHandCursor=true;
        	event.currentTarget.buttonMode=true;
        }
		
		private function MouseOutEvent(event:MouseEvent):void {
			toolTipDestroy();
        	event.currentTarget.useHandCursor=false;
        	event.currentTarget.buttonMode=false;
        }
        
        private function toolTipCreate(ttText:String,xPos:Number,yPos:Number):void {
                if (tt) {
                    toolTipDestroy();
                }
                tt = ToolTipManager.createToolTip(ttText, xPos, yPos);
        }

        private function toolTipDestroy():void {
            if (tt) {
                ToolTipManager.destroyToolTip(tt);
                tt = null;
            }
        }

		
	}
}