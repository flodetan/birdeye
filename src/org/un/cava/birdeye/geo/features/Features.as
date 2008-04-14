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

package org.un.cava.birdeye.geo.features
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geo.projections.Projections;
	import org.un.cava.birdeye.geo.styles.GeoStyles;
	
	
	[Style(name="gradientItemFill",type="Array",format="Color",inherit="no")]
	[Style(name="strokeItem",type="Array",format="Color",inherit="no")]
	[Style(name="fillItem",type="uint",format="Color",inherit="no")]
	[Inspectable("foid")] 
	[Exclude(name="gradItemFill", kind="property")]
	[Exclude(name="color", kind="property")]
	[Exclude(name="colorItem", kind="property")]
	[Exclude(name="stkItem", kind="property")]
	[Exclude(name="color", kind="style")] 
	[Exclude(name="gradientFill", kind="style")]
	[Exclude(name="stroke", kind="style")]
	[Exclude(name="fill", kind="style")]
	
/** 
* Features Class
* 
* @tag Tag text.
*/
	public class Features extends Canvas
	{
		public var colorItem:SolidFill;
		public var stkItem:SolidStroke;
		
		public var gradItemFill:Array;
		
		[Inspectable(defaultValue="")]
		public var foid:String;
		
		/**
		* Set the color of a particular item for example a country of the map. 
		*/
		/*public function set colorItem(value:uint):void{
			_colorItem=new SolidFill(value,1);
		} 
		public function get colorItem():uint{
			var retColor:uint;
			if(_colorItem){
				retColor=_colorItem.color;
			}else{
				retColor=0;	
			}
			return retColor;
		}   */
		
		/**
		 * Set the stroke of a particular Item for example a country of the map.  
		 */
		/*public function set strokeItem(value:Stroke):void{
			_strokeItem= new SolidStroke(value.color,value.alpha,value.weight);
		} 
		public function get strokeItem():Stroke{
			var retStroke:Stroke;
			if(_strokeItem){
				retStroke=new Stroke(_strokeItem.color,_strokeItem.weight,_strokeItem.alpha);
			}else{
				retStroke=null;
			}
			return retStroke
		}*/
		
		/**
		*Set the gradient of a particular Item for example a country of the map.
		*/ 
		
		private var GeoData:Object;
		private var arrStrokeItem:Array=new Array();
		public function Features()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			
		}
		
		
		private function creationCompleteHandler (event:FlexEvent):void{
			var dynamicClassName:String=getQualifiedClassName(this.parent);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			var proj:String=(this.parent as dynamicClassRef).projection;
			var region:String=(this.parent as dynamicClassRef).region;
			//trace(GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName("CA")).geometryCollection.getItemAt(0).data)
			var myCoo:IGeometry;
			
			GeoData=Projections.getData(proj,region);
			if(GeoData.getCoordinates(foid)!=null){
					if(isNaN(GeoData.getCoordinates(foid).substr(0,1))){
						myCoo = Path(GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(foid)).geometryCollection.getItemAt(0));
					}else{
						myCoo = Polygon(GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(foid)).geometryCollection.getItemAt(0));
					}	
			}
			
			if(foid!=""){
				if(getStyle("fillItem")){
					colorItem=new SolidFill(getStyle("fillItem"),1);
				}
				if(getStyle("strokeItem")){
					if(typeof(getStyle("strokeItem"))=="number"){
						arrStrokeItem.push(getStyle("strokeItem"));
					}else{
						arrStrokeItem=getStyle("strokeItem");
					}
					
					while (arrStrokeItem.length<3) { 
						arrStrokeItem.push(1); 
					}
					stkItem= new SolidStroke(arrStrokeItem[0],arrStrokeItem[1],arrStrokeItem[2]);
				}
				
				
							
				if(getStyle("gradientItemFill")){
					gradItemFill=getStyle("gradientItemFill");
					if(gradItemFill.length!=0){
						if(gradItemFill[2]==0){
							myCoo.fill=GeoStyles.setRadialGradient(gradItemFill);
						}else{
							myCoo.fill=GeoStyles.setLinearGradient(gradItemFill);
						}
					}
				}else{
					if(colorItem){
						myCoo.fill=colorItem;
					}
				}
				
				if(stkItem){
					myCoo.stroke=stkItem;
				}
				
			}
        }
		
		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
        	eventObj.target.mouseChildren=false;
        	//GeometryGroup(eventObj.target).filters=[new GlowFilter(0xFFFFFF,0.5,32,32,255,3,true,true)];
		}
		
		private function handleMouseOutEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
        	eventObj.target.mouseChildren=false;
        	//GeometryGroup(eventObj.target).filters=[new GlowFilter(0xFFFFFF,1,6,6,2,1,false,false)];
        }
	}
}