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
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
 	*  Define a gradient for fill a specific country. 
 	*  You should set this to an Array. Elements 0 and 1 specify the start and end values for a color gradient.
 	*  Element 2 specify the type of gradient 0: radial and 1: linear.
 	*  Element 3 specify the rotation angle.
 	*/
	[Style(name="gradientItemFill",type="Array",format="Color",inherit="no")]
	
	/**
 	*  Define a stroke for a specific country. 
 	*  You should set this to an Array. 
 	*  Elements 0 specify the color of the stroke.
 	*  Element 1 specify the alpha.
 	*  Element 2 specify the weight.
 	*  
 	*  @default color:0x000000, alpha:1, weight:1
 	*/
	[Style(name="strokeItem",type="Array",format="Color",inherit="no")]
	
	/**
 	*  Define a default color for fill a specific country. 
 	*/
	[Style(name="fillItem",type="uint",format="Color",inherit="no")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
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
	

	public class Features extends UIComponent
	{
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
		
		/**
	     *  @private
	     */
		private var GeoData:Object;
		/**
	     *  @private
	     */
		private var arrStrokeItem:Array=new Array();
		/**
	     *  @private
	     */
		private var _toolTip:String;
		
		/**
	     *  @private
	     */
		private var surface:Surface;
		
		/**
	     *  @private
	     */
		private var geom:GeometryGroup;
		
		/**
	     *  @private
	     */
		private var myCoo:IGeometry;
	    /**
	     *  @private
	     */
		public var colorItem:SolidFill;
		
		/**
	     *  @private
	     */
		public var stkItem:SolidStroke=new SolidStroke(0x000000,1,1);
		
		/**
	     *  @private
	     */
		public var gradItemFill:Array;
		
		/**
	     *  @private
	     */
		private var _highlighted:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _alpha:Number=1;
		
		/**
	     *  @private
	     */
		private var _isProjChanged:Boolean=false;
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties 
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  foid
	    //----------------------------------

		[Inspectable(defaultValue="")]
		/**
     	 * The value is a 3 letters country ISO code for the world map, and 2 letters states ISO code for the US map.
     	 */
		public var foid:String;
		
		
		
		//----------------------------------
	    //  highlighted
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define a GradientGlowFilter when the mouse move over a country.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default false
	     */
		public function set highlighted(value:Boolean):void{
			_highlighted=value;
		} 
		
		/**
	     *  @private
	     */
		public function get highlighted():Boolean{
			return _highlighted;
		} 
		
		
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function Features()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 */
		override public function set toolTip(value:String):void 
		{
    		_toolTip=value;
    	}
		
		/**
		 * @private
		 */
		override public function set alpha(value:Number):void 
		{
    		_alpha=value;
    	}
    	
		
		
		/**
		 * @private
		 */
        override public function styleChanged( styleProp:String ):void{            
        	super.styleChanged( styleProp );            
        	if ( styleProp == "fillItem" ){               
        		invalidateDisplayList();                
        		return;                            
        	}         
       }
       
       /**
		 * @private
		 */
       override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
      		super.updateDisplayList( unscaledWidth, unscaledHeight );            
      		if(myCoo){
      			myCoo.fill=new SolidFill(getStyle("fillItem"),_alpha);
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
		      
		      if(_isProjChanged){
      			colorizeFeatures();
      			_isProjChanged=false;
      		  }
      		  
      	}
      	
        //--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function creationCompleteHandler (event:FlexEvent):void{    
			colorizeFeatures();
			this.parent.addEventListener(GeoProjEvents.PROJECTION_CHANGED, projChanged);
		}
		
		
		/**
		 * @private
		 */
		private function colorizeFeatures():void{    
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
							colorItem=new SolidFill(getStyle("fillItem"),_alpha);
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
							stkItem= new SolidStroke(arrStrokeItem[0], arrStrokeItem[1],arrStrokeItem[2]);
							
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
        
		/**
		 * @private
		 */
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
			}
	    }
	    
	    /**
		 * @private
		 */
	    private function onRollOut(e:MouseEvent):void{
	    	e.target.useHandCursor=false;
        	e.target.buttonMode=false;
	    	surface.toolTip = null;
	    	GeometryGroup(e.target).filters=null;
	    }
        
      	/**
     	*  @private
     	*/
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	invalidateDisplayList();
        }
        
	}
}