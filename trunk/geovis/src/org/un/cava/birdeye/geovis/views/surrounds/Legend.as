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


package org.un.cava.birdeye.geovis.views.surrounds
{
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	
	import org.un.cava.birdeye.geovis.analysis.Choropleth;
	import org.un.cava.birdeye.geovis.controls.choropleth.GeoAutoGauge;
	import org.un.cava.birdeye.geovis.events.GeoAutoGaugeEvents;
	import org.un.cava.birdeye.geovis.events.GeoChoroEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.utils.LegendKey;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	
	/**
 	*  Define the default background color. 
 	*/
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="backgroudAlpha", type="Number", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="cornerRadius", type="Number", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="borderStyle", type="Number", enumeration="none,solid,dashed,dotted,double,groove,ridge,inset,outset,hidden", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="borderThickness", type="Number", inherit="no")]
	
	/**
 	*  Define the default text color. 
 	*/
	[Style(name="textColor", type="uint", format="Color", inherit="no")]	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("target")]
	
	public class Legend extends UIComponent//HBox //
	{
		
		/**
	     *  @private
	     *  Storage for the targets property.
	     */
	    private var _targets:Array = [];
	    
	    /**
	     *  @private
	     */
		private var _x:Number;
		
		/**
	     *  @private
	     */
		private var _y:Number;
		
		/**
	     *  @private
	     */
		private var _isProjChanged:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _cornerRadius:Number;//=5; 
		
		/**
	     *  @private
	     */
		private var _backgroundAlpha:Number;//=1;
		
		/**
	     *  @private
	     */
	    [Bindable]
		private var _backgroundColor:uint;//=0xFFFFFF
		
		/**
	     *  @private
	     */
		private var _borderStyle:String='none';
		
		/**
	     *  @private
	     */
		private var _borderThickness:Number;//=2;
		
		/**
	     *  @private
	     */
		private var _borderColor:uint;//=0x000000;
		
		/**
	     *  @private
	     */
	    [Bindable]
		private var _textColor:uint=0x000000;
		
		/**
	     *  @private
	     */
		private var HBLegend:HBox;
		
		/**
	     *  @private
	     */
	     private var arrStep:Array;
	     
	     /**
	     *  @private
	     */
	     private var arrCol:Array;
	     
	     /**
	     *  @private
	     */
		private var Numformat:NumberFormatter;
		
		
	    //--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
	    //----------------------------------
	    //  target
	    //----------------------------------
	
	    /** 
	     *  The Map object to which the GeoAutoGauge is applied.
	     */
	    public function get target():Object
	    {
	        if (_targets.length > 0)
	            return _targets[0]; 
	        else
	            return null;
	    }
	    
	    /**
	     *  @private
	     */
	    public function set target(value:Object):void
	    {
	        _targets.splice(0);
	        
	        if (value)
	            _targets[0] = value;
	            _targets[0].addEventListener(GeoProjEvents.PROJECTION_CHANGED,projChangeEvent);
	            if(_targets[0] is Choropleth){
	            	_targets[0].addEventListener(GeoChoroEvents.CHOROPLETH_COMPLETE, choroChangeEvent);
	            }else if(_targets[0] is GeoAutoGauge){
	            	_targets[0].addEventListener(GeoAutoGaugeEvents.VALUES_CHANGED, GeoAutoGaugeChangeEvent);
	            }
	    }
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function Legend()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,willCreateLegend);
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    	
    	/**
	     *  @private
	     */
		override public function set x(value:Number):void{
			_x=value;
		}
		
		/**
	     *  @private
	     */
		override public function set y(value:Number):void{
			_y=value;
		}
		
		/**
		 * @private
		 * Create component child elements. Standard Flex component method.
		 */
		override protected function createChildren() : void 
     	{ 
        	super.createChildren();
        	
        	HBLegend=new HBox();
		  	HBLegend.id="HBLegend";
		  	HBLegend.setStyle("horizontalAlign","center"); 
			HBLegend.setStyle("verticalAlign","middle");
			
			this.addChild(HBLegend);	
     	} 
     	
		
     	/**
	     *  @private
	     */
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(_isProjChanged){
				
			}
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		/**
	     *  @private
	     */
	     private function willCreateLegend(e:FlexEvent):void{
	     	 if(_targets[0] is Choropleth){
	     	 	_targets[0].addEventListener(GeoChoroEvents.CHOROPLETH_COMPLETE, willCL);
	     	 }else{
	     		createLegend();
	     	 }
	     }
	     
	     /**
	     *  @private
	     */
	     private function willCL(e:GeoChoroEvents):void{
	     	createLegend();
	     }
	     
	     /**
	     *  @private
	     */
	     private function createLegend():void{
	     	arrStep=new Array();
			arrCol=new Array();
			if(_targets[0] is GeoAutoGauge){
				setFormatter(_targets[0].decimalNumber);			
			}else{
			  	setFormatter(0);		
			}
			if(HBLegend){
				HBLegend.removeAllChildren();
				HBLegend.x=_x;
			  	HBLegend.y=_y;
			  	HBLegend.height=this.height;
			  	HBLegend.width=this.width;
			  	if(getStyle("cornerRadius")){
					_cornerRadius=getStyle("cornerRadius");
					HBLegend.setStyle("cornerRadius",_cornerRadius);
				}
				if(getStyle("backgroundAlpha")){
					_backgroundAlpha=getStyle("backgroundAlpha");
					HBLegend.setStyle("backgroundAlpha",_backgroundAlpha);
				}
				
				if(getStyle("borderStyle")){
					_borderStyle=getStyle("borderStyle");	
					HBLegend.setStyle("borderStyle",_borderStyle);
				}
				
				if(getStyle("borderThickness")){
					_borderThickness=getStyle("borderThickness");
					HBLegend.setStyle("borderThickness",_borderThickness);
				}
				if(getStyle("borderColor")){
					_borderColor=getStyle("borderColor");
					HBLegend.setStyle("borderColor",_borderColor);
				} 
				if(getStyle("backgroundColor")){
					_backgroundColor=getStyle("backgroundColor");
					HBLegend.setStyle("backgroundColor",_backgroundColor);
				}
				if(getStyle("textColor")){
					_textColor=getStyle("textColor");
				}
				
				arrStep=_targets[0].getStepsValues();
				arrCol=_targets[0].getColors();
				trace(_targets[0])
				for(var j:int=0; j<=arrCol.length-1; j++){
					
					var tt:String=new String();
					
					if(j==0){
						tt='<='+Numformat.format(arrStep[j]).toString();
		  			}else if(j==arrCol.length-1){
						tt='>='+Numformat.format(arrStep[j-1]).toString();
					}else{
						tt='>='+Numformat.format(arrStep[j-1]).toString() + ' and <' + Numformat.format(arrStep[j]).toString();
					}
					
					var lbltext:Label=new Label();
					lbltext.text=tt;
		  			lbltext.height=15;
		  			lbltext.setStyle("color",_textColor);
		  			
		  			var LegendComp:UIComponent=new UIComponent();
		  			//LegendComp.toolTip=tt;
		  			LegendComp.height=15;
		  			LegendComp.width=15;
		  			
					var pr:LegendKey=new LegendKey();
		  			pr.nheight=15;
		  			pr.nwidth=15;
		  			pr.enabled=false;
					pr.includeInLayout=true;
					pr.styleFill=arrCol[j];
					
					LegendComp.addChild(pr);
					
					HBLegend.addChild(LegendComp);
		  			HBLegend.addChild(lbltext);
					
				}
				
			}
	     }
		/**
		 * @private
		 */
		private function projChangeEvent(e:GeoProjEvents):void{
			_isProjChanged=true;
			invalidateDisplayList();
		}
		
		/**
	     *  @private
	     */
		private function choroChangeEvent(e:GeoChoroEvents):void{
			createLegend();
		}
		
		/**
	     *  @private
	     */
		private function GeoAutoGaugeChangeEvent(e:GeoAutoGaugeEvents):void{
			createLegend();
		}
		
		/**
		 * @private
		 */
		private function setFormatter(decNum:Number):void{
			Numformat=new NumberFormatter();
			Numformat.rounding=NumberBaseRoundType.NEAREST;
			Numformat.precision=decNum;
			Numformat.useThousandsSeparator=true;
		}
		
	}
}