package org.un.cava.birdeye.geovis.controls.choropleth
{
	import flash.events.Event;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.controls.choropleth.GeoAutoGauge;
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
 	*  Define the default track color. 
 	*/
	[Style(name="trackColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default tick color. 
 	*/
	[Style(name="tickColor", type="uint", format="Color", inherit="no")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("ticksMark")]
	public class GeoGauge extends Canvas
	{
		
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
		private var barre:UIComponent;
		/**
	     *  @private
	     */
        private var _width:Number=300;
        /**
	     *  @private
	     */
        private var _height:Number=15;
        /**
	     *  @private
	     */
        private var _x:Number=0;
        /**
	     *  @private
	     */
        private var _y:Number=0;
        /**
	     *  @private
	     */
        private var _min:Number;
		/**
	     *  @private
	     */
		private var _max:Number;
		/**
	     *  @private
	     */
		private var _ticksMark:Boolean=true;
		/**
	     *  @private
	     */
		private var _ticksWidth:Number=3;
		/**
	     *  @private
	     */
		private var _minorTicksInterval:Number=1;
		/**
	     *  @private
	     */
		private var _majorTicksInterval:Number=10;
		/**
	     *  @private
	     */
		private var _borderColor:uint=0x000000;
		/**
	     *  @private
	     */
		private var _tickColor:uint=0x000000;
		
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  x
	    //----------------------------------
		
		/**
     	 *  Define the x position of the GeoGauge.
     	*/		
        override public function set x(x:Number):void{
			_x = x;
		}
		
		/**
	     *  @private
	     */
		override public function get x():Number{
			return _x;
		}
		
		//----------------------------------
	    //  y
	    //----------------------------------
		
		/**
     	 *  Define the y position of the GeoGauge.
     	*/	
		override public function set y(value:Number):void{
			_y = value;
		}
		
		/**
	     *  @private
	     */
		override public function get y():Number{
			return _y;
		}
		
		//----------------------------------
	    //  width
	    //----------------------------------
		
		/**
     	 *  Define the width of the GeoGauge.
     	*/	
		override public function set width(w:Number):void{
			_width = w;
		}
		
		/**
	     *  @private
	     */
		override public function get width():Number{
			return _width;
		}
		
		//----------------------------------
	    //  height
	    //----------------------------------
		
		/**
     	 *  Define the height of the GeoGauge .
     	*/	
		override public function set height(h:Number):void{
			_height = h;
		}
		
		/**
	     *  @private
	     */
		override public function get height():Number{
			return _height;
		}
		
		//----------------------------------
	    //  minimumValue
	    //----------------------------------
		
		/**
     	 *  Define the minimal value of the GeoGauge .
     	*/	
		public function set minimumValue(value:Number):void{
			_min = value;
		}
		
		/**
	     *  @private
	     */
		public function get minimumValue():Number{
			return _min;
		}
		
		//----------------------------------
	    //  maximumValue
	    //----------------------------------
		
		/**
     	 *  Define the maximal value of the GeoGauge .
     	*/	
		public function set maximumValue(value:Number):void{
			_max = value;
		}
		
		/**
	     *  @private
	     */
		public function get maximumValue():Number{
			return _max;
		}
		
		[Inspectable(enumeration="true,false")]
		//----------------------------------
	    //  ticksMark
	    //----------------------------------
		
		/**
		*  Define if the ticks mark are shown or not.
     	*  Valid values are <code>true</code> or <code>false</code>.
     	*  @default true
		*/
		public function set ticksMark(value:Boolean):void{
			_ticksMark = value;
		}
		
		//----------------------------------
	    //  thicksWidth
	    //----------------------------------
		
		/**
     	 *  Define the width of the ticks mark.
     	 * 
     	 * @default 3
     	*/	
		public function set ticksWidth(value:Number):void{
			_ticksWidth = value;
		}
		
		//----------------------------------
	    //  minorThicksInterval
	    //----------------------------------
		
		/**
     	 *  Define the interval of the minor ticks mark.
     	 * 
     	 * @default 1
     	*/	
		public function set minorTicksInterval(value:Number):void{
			_minorTicksInterval = value;
		}
		
		//----------------------------------
	    //  majorThicksInterval
	    //----------------------------------
		
		/**
     	 *  Define the interval of the major ticks mark.
     	 * 
     	 * @default 10
     	*/	
		public function set majorTicksInterval(value:Number):void{
			_majorTicksInterval = value;
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoGauge()
		{
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    
		/**
		 * @private
		 * Create component child elements. Standard Flex component method.
		 */
		override protected function createChildren() : void 
     	{ 
        	super.createChildren(); 
        	barre = new UIComponent();
        	barre.name="geoBarre";		
     	} 
     	
     	/**
	     *  @private
	     */
     	override protected function commitProperties() : void 
     	{ 
     		if (barre) 
	        { 
	        	if(!this.getChildByName("geoBarre")){
	        		this.addChild(barre);
	        	}
	        }
     	}
     	
     	/**
	     *  @private
	     */
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(barre){
				if(getStyle("borderColor")){
					_borderColor=getStyle("borderColor");
				}
				
				if(getStyle("tickColor")){
					_tickColor=getStyle("tickColor");
				}
				
				barre.graphics.clear();
				barre.graphics.beginFill(getStyle("trackColor"));
				barre.graphics.lineStyle(1,_borderColor);
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
			
				barre.graphics.lineStyle(1,_borderColor);
				barre.graphics.drawRect(_x, _y, _width, _height);
				barre.graphics.lineStyle(1,_tickColor);
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