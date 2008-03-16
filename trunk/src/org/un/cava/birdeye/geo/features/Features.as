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
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.paint.*;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
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
			
			GeoData=Projections.getData(proj,region);
			
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
				var surf:Surface=new Surface();
			    //surf.percentWidth=100; 
				//surf.percentHeight=100;
				surf.setStyle("verticalCenter",0);
			    //surf.scaleX=2;
			    //surf.scaleY=2;
				var GPGeom:GeometryGroup=new GeometryGroup();
				
				// The equivalent of the svg transform for flash. This will apply the flip and reposition the item.
				// taken from SVG as translate(0,174.8) scale(1, -1) and multiplied by 2 for magnification
	    		// GPGeom.transform.matrix = new Matrix(GeoData.scaleX,0,0,GeoData.scaleY,GeoData.translateX,1*GeoData.translateY);
				GPGeom.target=surf;
				GPGeom.name=foid;
				GPGeom.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverEvent);
				//GPGeom.addEventListener(MouseEvent.MOUSE_OUT,handleMouseOutEvent);
					
				surf.graphicsCollection.addItem(GPGeom);
				
				var cntry:Path=new Path();
				cntry.data=GeoData.getCoordinates(foid);
				if(getStyle("gradientItemFill")){
					gradItemFill=getStyle("gradientItemFill");
					if(gradItemFill.length!=0){
						if(gradItemFill[2]==0){
							cntry.fill=GeoStyles.setRadialGradient(gradItemFill);
						}else{
							cntry.fill=GeoStyles.setLinearGradient(gradItemFill);
						}
					}
				}else{
					if(colorItem){
						cntry.fill=colorItem;
					}
				}
				
				if(stkItem){
					cntry.stroke=stkItem;
				}
				
				GPGeom.geometryCollection.addItem(cntry);
				GPGeom.draw(null,null);
				this.addChild(surf);
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