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
package org.un.cava.birdeye.geovis.analysis
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.*;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.styles.StyleManager;
	
	import org.un.cava.birdeye.geovis.dictionary.*;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.projections.Projections;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
 	*  Define the color of the flow. 
 	* 
 	*  @default 0x333333
 	*/
	[Style(name="fill",type="uint",format="Color",inherit="no")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("dataProvider")]
	[Inspectable("dataField")]	
	[Inspectable("showDataTips")]
	[Inspectable("dataTipFunction")]
	[Inspectable("fromField")]
	[Inspectable("toField")]
	[Inspectable("valueField")]
	[Inspectable("thickness")]
	public class Flow extends UIComponent
	{
		
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
		private var flows:UIComponent;
		/**
	     *  @private
	     */
		private var cntrlpt:UIComponent;
		/**
	     *  @private
	     */
		private var markers:UIComponent;
		/**
	     *  @private
	     */
		private var cntrlpoint:Point;
		/**
	     *  @private
	     */
		private var mid:Point;
		/**
	     *  @private
	     */
		private var ArrMarkers:Array=new Array();
		/**
	     *  @private
	     */
		private var dicMarkers:Dictionary= new Dictionary();
		/**
	     *  @private
	     */
		private var _dataProvider:ICollectionView;
		/**
	     *  @private
	     */
		private var _valueField:String;
		/**
	     *  @private
	     */
		private var _fromField:String;
		/**
	     *  @private
	     */
		private var _toField:String;
		/**
	     *  @private
	     */
		private var _showDataTips:Boolean=false;
		/**
	     *  @private
	     */
		private var _dataTipFunction:Function;
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
		private var _color:uint=0x333333;
		/**
	     *  @private
	     */
		private var _thickness:Number=2;
		
		[Bindable]
		/**
	     *  @private
	     */
		private var _scaleY:Number;
		
		[Bindable]
		/**
	     *  @private
	     */
		private var _scaleX:Number;
	  	
	  	/**
	     *  @private
	     */
	  	private var blnInit:Boolean=true;
	  	
	  	/**
	     *  @private
	     */
	  	private var surf:Surface;
	  	
	  	/**
	     *  @private
	     */
	  	private var proj:String;
		
		/**
	     *  @private
	     */
		private var region:String;
		
		/**
	     *  @private
	     */
	    [Bindable]
		private var _visible:Boolean=true;
		
		/**
	     *  @private
	     */
	     private var _isProjChanged:Boolean=false;
		/**
	     *  @private
	     */
		private var _isBaseMapComplete:Boolean=false;
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  showDataTips
	    //----------------------------------

		[Inspectable(showDataTips="true,false")]
		/**
     	 *  Define if a dataTips is shown or not.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default false
	     */
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
		}
		
		/**
     	*  @private
     	*/
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}
		
		
		//----------------------------------
	    //  dataProvider
	    //----------------------------------
	    
		/**
	     *  An object that contains the data that defined the flows.
	     *  When you assign a value to this property, the Flow class handles
	     *  the source data object as follows:
	     *  <p>
	     *  <ul><li>A String containing valid XML text is converted to an XMLListCollection.</li>
	     *  <li>An XMLNode is converted to an XMLListCollection.</li>
	     *  <li>An XMLList is converted to an XMLListCollection.</li>
	     *  <li>Any object that implements the ICollectionView interface is cast to
	     *  an ICollectionView.</li>
	     *  <li>An Array is converted to an ArrayCollection.</li>
	     *  <li>Any other type object is wrapped in an Array with the object as its sole
	     *  entry.</li></ul>
	     *  </p>
	     */
		public function get dataProvider():Object
		{
			return this._dataProvider;
		}
		
		/**
     	*  @private
     	*/
		public function set dataProvider(value:Object):void
		{
			//_dataProvider = value;
			if(typeof(value) == "string")
	    	{
	    		//string becomes XML
	        	value = new XML(value);
	     	}
	        else if(value is XMLNode)
	        {
	        	//AS2-style XMLNodes become AS3 XML
				value = new XML(XMLNode(value).toString());
	        }
			else if(value is XMLList)
			{
				//XMLLists become XMLListCollections
				if(XMLList(value).children().length()>0){
					value = new XMLListCollection(value.children() as XMLList);
				}else{
					value = new XMLListCollection(value as XMLList);
				}
			}
			else if(value is Array)
			{
				value = new ArrayCollection(value as Array);
			}
			
			if(value is XML)
			{
				var list:XMLList = new XMLList();
				list += value;
				this._dataProvider = new XMLListCollection(list.children());
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            this._dataProvider = ICollectionView(value);
	        }else if(value is Object)
			{
				// convert to an array containing this one item
				this._dataProvider = new ArrayCollection( [value] );
	  		}
	  		else
	  		{
	  			this._dataProvider = new ArrayCollection();
	  		}
		}
		
		//----------------------------------
	    //  valueField
	    //----------------------------------
	    
		/**
     	 * The string that will be displayed on the tooltip.
     	 */
		public function set valueField(value:String):void
		{
			_valueField = value;
		}
		
		//----------------------------------
	    //  fromField
	    //----------------------------------
	    
		/**
     	 *  Define from which country the flow is strating. the value is a 3 letters country ISO code for the world map, and 2 letters states ISO code for the US map.
     	 */
		public function set fromField(value:String):void
		{
			_fromField = value;
		}
		
		/**
     	*  @private
     	*/
		public function get fromField():String
		{
			return _fromField;
		}
		
		//----------------------------------
	    //  toField
	    //----------------------------------
	    
		/**
     	 *  Define to which country the flow is ending. the value is a 3 letters country ISO codeand 2 letters states ISO code for the US map.
     	 */
		public function set toField(value:String):void
		{
			_toField = value;
		}
		
		/**
     	*  @private
     	*/
		public function get toField():String
		{
			return _toField;
		}
		
		//----------------------------------
	    //  thickness
	    //----------------------------------
		/**
     	 *  Define the thickness of the flow.
     	 * 
     	 * @default 2
     	 */
		public function set thickness(value:Number):void
		{
			_thickness = value;
		}
		
		/**
     	*  @private
     	*/	
		public function get thickness():Number
		{
			return _thickness;
		}
		
		//----------------------------------
	    //  dataTipFunction
	    //----------------------------------
	    
		/**
	     *  Specifies a callback function to run on each item of the data provider 
	     *  to determine its dataTip.
	    
	     *  <p>The function must take a single IViewCursor parameter, containing the
	     *  data provider element, and return a String.</p>
	     * 
	     * <pre>
	     * <p>If you have an XML datatprovider with the fields @fromkey and @tokey
	     * private function customDataTipFlows(currDatatip:IViewCursor):String{
		 * 		return 'Originating from: ' + currDatatip.current["@fromkey"].toString() + ' To: ' + currDatatip.current["@tokey"].toString();
		 * }</p>
		 * </pre>
		 * 
	     *  <p>You can use the <code>dataTipFunction</code> property for handling formatting and localization.</p>
	     *
	     */
		public function get dataTipFunction():Function
	    {
	        return _dataTipFunction;
	    }

	    /**
     	*  @private
     	*/
    	public function set dataTipFunction(value:Function):void
	    {
	        _dataTipFunction = value;
	        //dispatchEvent(new Event("labelFunctionChanged"));
	    }
	    
	    //--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function Flow()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createFlowsDelayed);
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    	
    	/**
		* @private
		*/
       	override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
      		super.updateDisplayList( unscaledWidth, unscaledHeight ); 
      		if(_isProjChanged || _isBaseMapComplete){
      			if(surf){
		      		for(var i:int=surf.numChildren-1; i>=0; i--){
							if(surf.getChildAt(i).name.toString().substr(0,7)=='GeoFlow'){
								surf.removeChildAt(i);
							}
						}
		      	}
      			createFlows();
      			_isProjChanged=false;
      			_isBaseMapComplete=false;
      		}
      		
      	}
      	
		/**
		 * @private
		 */
		override public function set visible(value:Boolean):void 
		{
			
    		_visible=value;
    		
    		if(surf){
    			for (var i:int = 0; i < surf.numChildren; i++) {
    				if(surf.getChildAt(i).name.toString().substr(0,7)=='GeoFlow'){
    					surf.getChildAt(i).visible=_visible;
    				}
    			}
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
		private function createFlowsDelayed(e:FlexEvent):void{
			createFlows();
			this.parent.addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, baseMapComplete);
		}
		
		
		/**
		* @private
		* Flow annotations are used to show the movement or relation of objects 
		* from one location to another.
		**/
		 private function createFlows():void{
		 		dynamicClassName =getQualifiedClassName(this.parent);
				dynamicClassRef = getDefinitionByName(dynamicClassName) as Class;
				proj=(this.parent as dynamicClassRef).projection;
				region=(this.parent as dynamicClassRef).region;
				
				var GeoData:Object=Projections.getData(proj,region);
				
				surf=Surface((this.parent as DisplayObjectContainer).getChildByName("Surface"))
				
				var cooFrom:String;
				var cooTo:String;
				var i:int=0;
				var cursor:IViewCursor = _dataProvider.createCursor();
				
				while(!cursor.afterLast)
				{
					var fromKey:String=cursor.current[_fromField];
					var toKey:String=cursor.current[_toField];
					
					var fromKeyDesc:String=GeoData.getCountriesName(cursor.current[_fromField]);
					var toKeyDesc:String=GeoData.getCountriesName(cursor.current[_toField]);
					var desc:String;
					cooFrom=GeoData.getBarryCenter(fromKey);
					var arrPosFrom:Array=cooFrom.split(',');
					cooTo=GeoData.getBarryCenter(toKey);
					var arrPosTo:Array=cooTo.split(',')
					
					if(_dataTipFunction!=null){
						desc=_dataTipFunction(cursor);
					}else{
						desc=cursor.current[_valueField];
					}
					
					var geom1:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(fromKey));
					var geom2:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(toKey));
					
					if(geom1!=null && geom2!=null){
						drawFlow(arrPosFrom,arrPosTo, fromKeyDesc, toKeyDesc, desc);
					}
					    
					i++;
					cursor.moveNext();  
				} 
    	}
   
  		/**
     	*  @private
     	*/
	   	private function drawFlow(cooFrom:Array, cooTo:Array, fromDest:String, toDest:String, description:String):void{
	   		flows = new UIComponent();
	   	  	flows.name="GeoFlow"+fromDest+toDest;
	   	  	flows.visible=_visible;
		  	cntrlpt = new UIComponent();
		  	markers = new UIComponent();
		  	cntrlpoint = new Point();
		  	mid = new Point();
		  
/* 		  	_scaleX = (this.parent as dynamicClassRef).scaleX;
	  		_scaleY = (this.parent as dynamicClassRef).scaleY;
		 	flows.scaleX=_scaleX;
	  		flows.scaleY=_scaleY;
	  		cntrlpt.scaleX=_scaleX;
	  		cntrlpt.scaleY=_scaleY;
  	  		surf.scaleX=_scaleX;
	  		surf.scaleY=_scaleY;
 */ 
 			var matr:Matrix = surf.transform.matrix;
		  	_scaleX = matr.a;
	  		_scaleY = matr.d;
		 	flows.scaleX=_scaleX;
	  		flows.scaleY=_scaleY;
	  		cntrlpt.scaleX=_scaleX;
	  		cntrlpt.scaleY=_scaleY;
 	  		
	  		if(getStyle("fill")){
				_color=uint(getStyle("fill"));
			}else{
				if(styleName){
					if(StyleManager.getStyleDeclaration("."+ styleName).getStyle("fill")){
			   			_color=uint("0x"+StyleManager.getStyleDeclaration("."+ styleName).getStyle("fill").toString(16));
			   		}
			 	}
			}
					
					
			  var strFrom:String=fromDest;
		      var p1:Point = new Point(cooFrom[0], cooFrom[1]);
		      surf.addChild(flows);
		    
		      var strTo:String=toDest;
		      var p2:Point = new Point(cooTo[0], cooTo[1]);
		    
		      mid = new Point(p1.x + ((p2.x - p1.x) / 2.0), p1.y + ((p2.y - p1.y) / 2.0));
		      
			  // initial parameters for control point
			  // changed by drag and drop of cntrlptHandle
		      cntrlpoint.x=mid.x;
		      cntrlpoint.y=mid.y*1.5;
		      
		      // draw flow
		      // note: direction matters
		      flows.graphics.clear();
		      // source to target
		      flows.graphics.moveTo(p1.x, p1.y);
		      // need to parameterize color
		      flows.graphics.lineStyle(_thickness, _color, .6);  // thickness (flow), color, alpha
		      flows.graphics.beginFill(_color, .6);
		      flows.graphics.curveTo(cntrlpoint.x, cntrlpoint.y, p2.x, p2.y);
		      // target back to source + flow value (or static constant as 10)
		      flows.graphics.curveTo(cntrlpoint.x, cntrlpoint.y, p1.x, p1.y+10);
		      flows.graphics.endFill();
		      flows.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverEvent);
		      flows.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOutEvent);
		      if(_showDataTips==true){
		      	if(description!=''){
		      		flows.toolTip=description;
		      	}else{
		      		flows.toolTip="From: " + strFrom + "\r" + "To: " + strTo
		      	}
		      }
		      
		      // guide lines
		      cntrlpt.graphics.lineStyle(1, 0xFF0000, .3);
		      cntrlpt.graphics.moveTo(cntrlpoint.x, cntrlpoint.y);
		      cntrlpt.graphics.lineTo(p1.x, p1.y);
		      cntrlpt.graphics.moveTo(cntrlpoint.x, cntrlpoint.y);
		      cntrlpt.graphics.lineTo(p2.x, p2.y);   
	   }
   		
   		/**
     	*  @private
     	*/
   		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
		}
		
		/**
     	*  @private
     	*/
		private function handleMouseOutEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=false;
        	eventObj.target.buttonMode=false;
        }
        
        /**
     	*  @private
     	*/
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	invalidateDisplayList();
        }
        
        /**
     	*  @private
     	*/
        private function baseMapComplete(e:GeoCoreEvents):void{
        	_isBaseMapComplete=true;
        	invalidateDisplayList();
        }
	
}
}