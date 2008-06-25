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

package org.un.cava.birdeye.geovis.features
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	import flash.utils.*;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.geovis.styles.GeoStyles;
	
	[Style(name="gradientItemFill",type="Array",format="Color",inherit="no")]
	[Style(name="strokeItem",type="Array",format="Color",inherit="no")]
	[Style(name="fillItem",type="uint",format="Color",inherit="no")]
	[Inspectable("highlighted")]
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
	public class Features extends UIComponent
	{
		public var colorItem:SolidFill;//=new SolidFill(0xFFFFFF);
		public var stkItem:SolidStroke=new SolidStroke(0x000000,1,1);
		
		public var gradItemFill:Array;
		
		[Inspectable(defaultValue="")]
		public var foid:String;
		
		//[Inspectable(defaultValue=false)]
		public var _highlighted:Boolean=false;
		
		private var _toolTip:String;
		private var surface:Surface;
		private var geom:GeometryGroup;
		private var myCoo:IGeometry;
		
		[Bindable]
		public function set highlighted(value:Boolean):void{
			_highlighted=value;
		} 
		
		public function get highlighted():Boolean{
			return _highlighted;
		} 
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
		override public function set toolTip(value:String):void 
		{
    		_toolTip=value;
    	}
		
		private function creationCompleteHandler (event:FlexEvent):void{
			this.name='feat'+foid;
			var dynamicClassName:String=getQualifiedClassName(this.parent);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			var proj:String=(this.parent as dynamicClassRef).projection;
			var region:String=(this.parent as dynamicClassRef).region;
			surface=Surface((this.parent as DisplayObjectContainer).getChildByName("Surface"))
			geom=GeometryGroup(surface.getChildByName(foid));
			if(geom!=null){
					
					GeoData=Projections.getData(proj,region);
					if(GeoData.getCoordinates(foid)!=null){
						if(isNaN(GeoData.getCoordinates(foid).substr(0,1))){
							myCoo = Path(GeometryGroup(surface.getChildByName(foid)).geometryCollection.getItemAt(0));
						}else{
							myCoo = Polygon(GeometryGroup(surface.getChildByName(foid)).geometryCollection.getItemAt(0));
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
						stkItem.scaleMode="none";
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
					
					geom.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
					geom.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			
        }
		
		
        
		private function onRollOver(e:MouseEvent):void{
			e.target.useHandCursor=true;
        	e.target.buttonMode=true;
			surface.toolTip=null;
			surface.toolTip=_toolTip;
			if(_highlighted==true){
				var glowColor:uint=0xFFFFFF;
				var glowGradFill:Array;
				if(getStyle("gradientItemFill")){
					glowGradFill=getStyle("gradientItemFill");
					if(glowGradFill.length!=0){
						glowColor=uint(glowGradFill[0]);
					}
				}else{
					if(getStyle("fillItem")){
						glowColor=uint(colorItem.color);
					}
				}
				
				var gradientGlow:GradientGlowFilter = new GradientGlowFilter();
				gradientGlow.distance = 0;
				gradientGlow.angle = 45;
				gradientGlow.colors = [0x000000, glowColor];
				gradientGlow.alphas = [0, 1];
				gradientGlow.ratios = [0, 255];
				gradientGlow.blurX = 8;
				gradientGlow.blurY = 8;
				gradientGlow.strength = 2;
				gradientGlow.quality = BitmapFilterQuality.HIGH;
				gradientGlow.type = BitmapFilterType.OUTER;
				GeometryGroup(e.target).filters=[gradientGlow];
				//GeometryGroup(e.target).filters=[new GlowFilter(glowColor,0.5,32,32,255,3,true,true)];
			}
	    }
	    private function onRollOut(e:MouseEvent):void{
	    	e.target.useHandCursor=false;
        	e.target.buttonMode=false;
	    	surface.toolTip = null;
	    	//if(_highlighted==false){
	    		GeometryGroup(e.target).filters=null;
	    	//}
	    }
        
        override public function styleChanged( styleProp:String ):void{            
        	super.styleChanged( styleProp );            
        	if ( styleProp == "fillItem" ){
        		//_sourceChanged = true;                 
        		invalidateDisplayList();                
        		return;                            
        	}         
       }
       
       override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
      		super.updateDisplayList( unscaledWidth, unscaledHeight );            
      		if(myCoo){
      			myCoo.fill=new SolidFill(getStyle("fillItem"),1);
      		}      
      		
      		if(geom!=null){
			        if(_highlighted==true){
						if(!geom.hasEventListener(MouseEvent.ROLL_OVER)){
							geom.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
						}
						if(!geom.hasEventListener(MouseEvent.ROLL_OUT)){
							geom.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
						}
					}else{
						if(geom.hasEventListener(MouseEvent.ROLL_OVER)){
							geom.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
						}
						if(geom.hasEventListener(MouseEvent.ROLL_OUT)){
							geom.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
						}
					}
		        }   
      	}
      	
      	
	}
}