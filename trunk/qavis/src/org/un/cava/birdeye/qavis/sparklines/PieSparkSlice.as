/*  
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
 package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	import com.degrafa.GeometryGroup;
	import flash.events.MouseEvent;
	
	import mx.collections.IViewCursor;
	import mx.core.IToolTip;
	
	public class PieSparkSlice extends GeometryGroup
	{
		
		public var Arc:EllipticalArc;
		
		private var _surf:Surface;
		private var _toolTip:String;
		private var _cursor:IViewCursor;
		private var currentToolTipItem:IToolTip; 
		private var _dtFunction:Function;
		
		public function PieSparkSlice(wdt:Number,hgt:Number,field:String,showdtTips:Boolean,cursor:IViewCursor,dataTipFunction:Function,surf:Surface, numOfSlice:int)
		{
			_surf=surf;
			_dtFunction=dataTipFunction;
			_cursor=cursor;
			
			if(_dtFunction!=null){
				_toolTip=_dtFunction(_cursor);
			}else{
				_toolTip=cursor.current[field];
			}
			
			Arc=new EllipticalArc();
		 	Arc.id="arc";
		 	Arc.width=wdt/2;
		 	Arc.height=hgt/2;
		 	if(numOfSlice==1){
		 		Arc.closureType="chord"; 
		 	}else{
		 		Arc.closureType="pie"; 
		 	}
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
			_surf.toolTip=_toolTip;
	    }
	    
	    private function onRollOut(event:MouseEvent):void{
	    	_surf.toolTip = "";
	    }
		
		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
       }
	}
}
