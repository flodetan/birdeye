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


package org.un.cava.birdeye.geovis.symbols
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.VBox;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.qavis.sparklines.*;
	
	[Inspectable("key")] 
	public class Symbols extends VBox	//Canvas
	{
		private var _key:String="";
		//public var myUIComp:UIComponent;
		public var wcData:Object;
		
		public function set key(value:String):void{
			_key=value;
		}
		
		public function get key():String{
			return _key;
		}
		
		public function Symbols()
		{
			super();
			//this.mouseEnabled=false;
			//this.mouseChildren=false;
			//myUIComp=new UIComponent();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private function creationCompleteHandler (event:FlexEvent):void{
			if(_key!=""){
				var dynamicClassName:String=getQualifiedClassName(this.parent);
				var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
				var proj:String=(this.parent as dynamicClassRef).projection;
				var region:String=(this.parent as dynamicClassRef).region;
				var geom:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(_key));
				
				if(geom!=null){
					var GeoData:Object=Projections.getData(proj,region);
					var cooBC:String=GeoData.getBarryCenter(_key);
					var arrPos:Array=cooBC.split(',')
					
					var myScaleX:Number=(this.parent as dynamicClassRef).scaleX;
					var myScaleY:Number=(this.parent as dynamicClassRef).scaleY;
					if(this.getChildAt(0) is PieSpark)
					{
						this.x=(arrPos[0]-this.width/4)*myScaleX;
						this.y=(arrPos[1]-this.height/4)*myScaleY;
					}else{
						this.x=(arrPos[0]-this.width/2)*myScaleX;
						this.y=(arrPos[1]-this.height/2)*myScaleY;
					}
					
					Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
				}
			}
		}	
		
		
		
		private function handleClickEvent(eventObj:MouseEvent):void {
			eventObj.stopPropagation()
		}
		
	}
}