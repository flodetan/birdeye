package org.un.cava.birdeye.geovis.controls.choropleth
{
	import flash.utils.*;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.formatters.NumberFormatter;
	import mx.formatters.NumberBaseRoundType;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
 	*  Define the default text color. 
 	*/
	[Style(name="textColor", type="uint", format="Color", inherit="no")]
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("scaleData")]
	[Inspectable("usePercentScale")]
	[Inspectable("title")]
	public class GeoScale extends UIComponent
	{
		
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
		private var scale:UIComponent;
		
		/**
	     *  @private
	     */
		private var dynamicClassName:String;
		
		/**
	     *  @private
	     */
		private var dynamicClassRef:Class;
		
		/**
	     *  @private
	     */
		private var _height:Number;
		
		/**
	     *  @private
	     */
		private var _width:Number;
		
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
		private var _parentMin:Number;
		
		/**
	     *  @private
	     */
		private var _parentMax:Number;
		
		/**
	     *  @private
	     */
		private var lbl:Label;
		
		/**
	     *  @private
	     */
		private var _title:String;
		
		/**
	     *  @private
	     */
		private var lblTitle:Label;
		
		/**
	     *  @private
	     */
		private var _textColor:uint=0x000000;
		
		/**
	     *  @private
	     */
		private var _usePercentScale:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _scaleData:Array;
		
		/**
	     *  @private
	     */
		private var Numformat:NumberFormatter;
		
		/**
	     *  @private
	     */
		private var _decNum:Number;
		//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  title
	    //----------------------------------
		
		/**
     	 *  Define the title of the GeoScale.
     	*/	
		public function set title(value:String):void{
			_title = value;
		}
		
		/**
	     *  @private
	     */
		public function get title():String{
			return _title;
		}
		
		//----------------------------------
	    //  usePercentScale
	    //----------------------------------
		
		/**
     	 *  Define use the 0-100% scale or not.
     	*/	
		public function set usePercentScale(value:Boolean):void{
			_usePercentScale = value;
		}
		
		/**
	     *  @private
	     */
		public function get usePercentScale():Boolean{
			return _usePercentScale;
		}
		
		//----------------------------------
	    //  scaleData
	    //----------------------------------
		
		/**
     	 *  Define the value for the scale.
     	*/	
		public function set scaleData(value:Array):void{
			_scaleData = value;
		}
		
		/**
	     *  @private
	     */
		public function get scaleData():Array{
			return _scaleData;
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoScale()
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
        	scale=new UIComponent();
     	} 
		
		/**
	     *  @private
	     */
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
				_decNum=(this.parent as dynamicClassRef).decimalNumber;
				setFormatter(_decNum);
				
				scale.x=Number(_x);
				scale.y=Number(_y+_height+2);
				
				if(getStyle("textColor")){
					_textColor=getStyle("textColor");
				}
				
				if(_usePercentScale){
					for (var i:int = 0; i <= 10; i++) {
		  	 			lbl=new Label();
				 		lbl.text=(i*10).toString()+'%';
				 		lbl.setStyle('color',_textColor);
				 		lbl.setStyle('textAlign','center');
				 		lbl.height=15;
				 		lbl.width=40;
				 		lbl.x=Number((_width/10*i) - lbl.width/2);
				 		
				 		scale.addChild(lbl);
		  	 		}
				  }else{
				  	_scaleData.sort(Array.NUMERIC);
				  	//if(_parentMin){
				  		
				  		lbl=new Label();
				 		lbl.text=Numformat.format(_parentMin).toString();
				 		lbl.setStyle('color',_textColor);
				 		lbl.setStyle('textAlign','center');
				 		lbl.height=15;
				 		lbl.width=_width/_scaleData.length;
				 		lbl.x=Number(-lbl.width/2);
				 		scale.addChild(lbl);
				 		
				  	//}
				  	for (var j:int = 0; j <= _scaleData.length-2; j++) {
		  	 			lbl=new Label();
				 		lbl.text=Numformat.format(_scaleData[j]).toString();
				 		lbl.setStyle('color',_textColor);
				 		lbl.setStyle('textAlign','center');
				 		lbl.height=15;
				 		lbl.width=_width/_scaleData.length;
				 		//lbl.x=Number((_width/_scaleData.length*(j+1)) - lbl.width/2);
				 		lbl.x=((_scaleData[j]*_width)/_parentMax) - lbl.width/2;//
				 		scale.addChild(lbl);
		  	 		}
		  	 		//if(_parentMax){
				  		lbl=new Label();
				 		lbl.text=Numformat.format(_parentMax).toString();
				 		lbl.setStyle('color',_textColor);
				 		lbl.setStyle('textAlign','center');
				 		lbl.height=15;
				 		lbl.width=_width/_scaleData.length;
				 		lbl.x=Number((_width/_scaleData.length*(j+1)) - lbl.width/2);
				 		scale.addChild(lbl);
				  	//}
				  }
	  	 		if(_title!=''){
		  	 		lblTitle=new Label();
		  	 		lblTitle.text=_title;
		  	 		lbl.setStyle('color',_textColor);
		  	 		lblTitle.setStyle('textAlign','center');
		  	 		lblTitle.width=_width;
		  	 		lblTitle.height=15;
				 	lblTitle.y=17;
				 	scale.addChild(lblTitle);
	  	 		}
			 		
	  	 		this.addChild(scale)
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
		private function setFormatter(decNum:Number):void{
			
			Numformat=new NumberFormatter();
			Numformat.rounding=NumberBaseRoundType.NEAREST;
			Numformat.precision=decNum;
			Numformat.useThousandsSeparator=true;
		}
		
		
	}
}