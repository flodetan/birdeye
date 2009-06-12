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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.ToolTipManager;
	
	import org.un.cava.birdeye.geovis.dictionary.*;
	import org.un.cava.birdeye.geovis.events.GeoChoroEvents;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.geovis.utils.ArrayUtils;
	import org.un.cava.birdeye.geovis.utils.ColorBrewer;
	import org.un.cava.birdeye.geovis.utils.HtmlToolTip;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
 	*  Dispatched when the scheme change.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoChoroEvents.CHOROPLETH_SCHEME_CHANGED
 	*/
	[Event(name="ChoroplethSchemeChanged", type="org.un.cava.birdeye.geovis.events.GeoChoroEvents")]
	
	/**
 	*  Dispatched when the number of steps change.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoChoroEvents.CHOROPLETH_STEPS_CHANGED
 	*/
	[Event(name="ChoroplethStepsChanged", type="org.un.cava.birdeye.geovis.events.GeoChoroEvents")]
	
	
	/**
 	*  Dispatched when the colorField change.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoChoroEvents.CHOROPLETH_COLORFIELD_CHANGED
 	*/
	[Event(name="ChoroplethColorFieldChanged", type="org.un.cava.birdeye.geovis.events.GeoChoroEvents")]
	
	/**
 	*  Dispatched when the colorization is complete.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoChoroEvents.CHOROPLETH_COMPLETE
 	*/
	[Event(name="ChoroplethComplete", type="org.un.cava.birdeye.geovis.events.GeoChoroEvents")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
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
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("dataProvider")]
	[Inspectable("foidField")]
	[Inspectable("colorField")]
	[Inspectable("toolTipField")]
	[Inspectable("showDataTips")]
	[Inspectable("dataTipFunction")]
	[Inspectable("thickness")]
	[Inspectable("scheme")]
	[Inspectable("steps")]
	[Inspectable("highlighted")]
	[Exclude(name="toolTip", kind="property")]
	
	public class Choropleth extends UIComponent
	{
		
		/**
	     *  @private
	     */
		private var _dataProvider:ICollectionView;
		
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
		private var _foidField:String;
		
		/**
	     *  @private
	     */
		private var _colorField:String;
		
		/**
	     *  @private
	     */
		private var _toolTipField:String;
		
		/**
	     *  @private
	     */
		private var _thickness:Number=2;
		
		/**
	     *  @private
	     */
		private var _scheme:String;
		
		/**
	     *  @private
	     */
		private var _steps:int=3;
		
		/**
	     *  @private
	     */
		private var GeoData:Object;
		
		/**
	     *  @private
	     */
		private var surface:Surface;
		
		/**
	     *  @private
	     */
		//private var geom:GeometryGroup;
		
		/**
	     *  @private
	     */
		private var myCoo:IGeometry;
		
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
		private var _toolTip:String;
		
		/**
	     *  @private
	     */
		private var _colorItem:uint;
		
		/**
		 * @private
		 */
		 private var _arrDataTips:ArrayCollection;
		
		/**
		 * @private
		 */
		 private var _gg:GeometryGroup;
		 
		 /**
	     *  @private
	     */
		private var arrStrokeItem:Array;
		
		/**
	     *  @private
	     */
		private var stkItem:SolidStroke=new SolidStroke(0x000000,1,1);
		
		/**
	     *  @private
	     */
	     private var _colorChanged:Boolean=false;
	     
	     /**
	     *  @private
	     */
		private var _schemeChanged:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _stepsChanged:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _isBaseMapComplete:Boolean=false;
		
	     /**
	     *  @private
	     */
	     private var arrStep:Array
	     
	     /**
	     *  @private
	     */
	     private var arrCol:Array
	     
	     /**
	     *  @private
	     */
		private var _isReady:Boolean=false;
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
	    //  scheme
	    //----------------------------------

		[Inspectable(enumeration="YlGn,YlGnBu,GnBu,BuGn,PuBuGn,PuBu,BuPu,RdPu,PuRd,OrRd,YlOrRd,YlOrBr,Purples,Blues,Greens,Oranges,Reds,Greys,PuOr,BrBG,PRGn,PiYG,RdBu,RdGy,RdYlBu,Spectral,RdYlGn,Set3,Pastel1,Set1,Pastel2,Set2,Dark2,Paired")]
		
		 /**
     	 *  Define the type of scheme.
     	 *  Valid values are <code>"YlGn"</code> or <code>"YlGnBu"</code> or <code>"GnBu"</code> or <code>"BuGn"</code> or <code>"PuBuGn"</code> or <code>"PuBu"</code> or <code>"BuPu"</code> or <code>"RdPu"</code> or <code>"PuRd"</code> or <code>"OrRd"</code> or <code>"YlOrRd"</code> or <code>"YlOrBr"</code> or <code>"Purples"</code> or <code>"Blues"</code> or <code>"Greens"</code> or <code>"Oranges"</code> or <code>"Reds"</code> or <code>"Greys"</code> or <code>"PuOr"</code> or <code>"BrBG"</code> or <code>"PRGn"</code> or <code>"PiYG"</code> or <code>"RdBu"</code> or <code>"RdGy"</code> or <code>"RdYlBu"</code> or <code>"Spectral"</code> or <code>"RdYlGn"</code> or <code>"Set3"</code> or <code>"Pastel1"</code> or <code>"Set1"</code> or <code>"Pastel2"</code> or <code>"Set2"</code> or <code>"Dark2"</code> or <code>"Paired"</code>.
     	 * You can use the class ColorType to get the list of scheme.
	     */
		public function set scheme(value:String):void
		{
			_scheme = value;
			dispatchEvent(new GeoChoroEvents(GeoChoroEvents.CHOROPLETH_SCHEME_CHANGED,value, null, null));
			_schemeChanged=true;
			invalidateDisplayList();
		}
		
		/**
     	*  @private
     	*/
		public function get scheme():String
		{
			return _scheme;
		}
		
		//----------------------------------
	    //  steps
	    //----------------------------------
	    
	    [Inspectable(enumeration="3,4,5,6,7,8")]
		
		/**
     	 *  Define the number of color's steps.
     	 * 
     	 * @default 3
     	 */
		public function set steps(value:int):void
		{
			_steps = value;
			dispatchEvent(new GeoChoroEvents(GeoChoroEvents.CHOROPLETH_STEPS_CHANGED, null, value, null));
			_stepsChanged=true;
			invalidateDisplayList();
		}
		
		/**
     	*  @private
     	*/	
		public function get steps():int
		{
			return _steps;
		}
		
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
		
		
		//----------------------------------
	    //  colorField
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the value field to use to colorize the countries.
	     */
		public function set colorField(value:String):void{
			_colorField=value;
			dispatchEvent(new GeoChoroEvents(GeoChoroEvents.CHOROPLETH_COLORFIELD_CHANGED, null, null, value));
			_colorChanged=true;
			invalidateDisplayList();
		} 
		
		/**
	     *  @private
	     */
		public function get colorField():String{
			return _colorField;
		} 
		
		
		//----------------------------------
	    //  foidField
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the ISO country Code field.
	     */
		public function set foidField(value:String):void{
			_foidField=value;
		} 
		
		/**
	     *  @private
	     */
		public function get foidField():String{
			return _foidField;
		} 
		
		
		//----------------------------------
	    //  toolTipfield
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the field to use for the toolTips.
	     */
		public function set toolTipField(value:String):void{
			_toolTipField=value;
		} 
		
		/**
	     *  @private
	     */
		public function get toolTipField():String{
			return _toolTipField;
		} 
		
		
	    //--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function Choropleth()
		{
			super();
			ToolTipManager.toolTipClass = HtmlToolTip;
			this.addEventListener(FlexEvent.CREATION_COMPLETE,willColorize);
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
      		if(_isReady){
      			if(_isBaseMapComplete || _colorChanged || _schemeChanged || _stepsChanged){
      				colorize();
      				_isBaseMapComplete=false;
      				_colorChanged=false;
      				_schemeChanged=false;
      				_stepsChanged=false;
      			}
      		}
      		
      	}
      		
    	/**
		 * @private
		 */
		override public function set alpha(value:Number):void 
		{
    		_alpha=value;
    	}
      	
      	
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		/**
		* @private
		**/
		 private function willColorize(event:FlexEvent):void{
		 	colorize();
		 	_isReady=true;
		 	this.parent.addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, baseMapComplete);
		 }
		
		/**
		* @private
		**/
		 private function colorize():void{
		 		arrStrokeItem=new Array();
		 		_arrDataTips=new ArrayCollection();
		 		arrStep=ArrayUtils.FindStepWithoutZero(_dataProvider, _colorField, _steps-1);
		 		if(arrStep[0]!=null){
		 			var colB:ColorBrewer=new ColorBrewer();
		 			arrCol=colB.getColors(_scheme, _steps);
			 		var dynamicClassName:String=getQualifiedClassName(this.parent);
					var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
					var proj:String=(this.parent as dynamicClassRef).projection;
					var region:String=(this.parent as dynamicClassRef).region;		
					var GeoData:Object=Projections.getData(proj,region);
					
					surface=Surface((this.parent as DisplayObjectContainer).getChildByName("Surface"))
					var i:int=0;
					var cursor:IViewCursor = _dataProvider.createCursor();
					
					while(!cursor.afterLast)
					{
						var key:String=cursor.current[_foidField];
						var val:Number=Number(cursor.current[_colorField]);
						if(key!="" && key !=null){
							var geom:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(key)); 
							if(geom!=null){
								geom.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
								geom.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
								if(GeoData.getCoordinates(key)!=null){
									
									for each (var myCoo:Polygon in GeometryGroup(surface.getChildByName(key)).geometryCollection.items) {
										if(_scheme!=null){	
											if(val<=Number(arrStep[0])){
												myCoo.fill=new SolidFill(arrCol[0],_alpha);
												_colorItem=arrCol[0];
											}else if(val>Number(arrStep[_steps-2])){
												myCoo.fill=new SolidFill(arrCol[_steps-1],_alpha);
												_colorItem=arrCol[_steps-1];
											}else{
												for (var k:int=0; k<_steps-2;k++){
													if(val>Number(arrStep[k]) && val<=Number(arrStep[k+1])){
														myCoo.fill=new SolidFill(arrCol[k+1],_alpha);
														_colorItem=arrCol[k+1];
													}
												}
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
										
											if(stkItem){
												myCoo.stroke=stkItem;
											}
										}// end if(_scheme!=null)
								 	} // end for each myCoo
								} // end if GeoData.getCoordinates(key)!=null
							} // end if geom!=null
						} // end ifkey!=""
						
						
						
						if(_dataTipFunction!=null){
							_arrDataTips.addItem({gg:geom, dataTips:_dataTipFunction(cursor)});
						}else{
							_arrDataTips.addItem({gg:geom, dataTips:cursor.current[_toolTipField]});
						}
						
						i++;
						cursor.moveNext();  
					} // end while
				}
				
				dispatchEvent(new GeoChoroEvents(GeoChoroEvents.CHOROPLETH_COMPLETE, _scheme, _steps, _colorField));
    	}
   		
   		
		
   		 
   		/**
		 * @private
		 */
		private function onRollOver(e:MouseEvent):void{
			_gg=GeometryGroup(e.currentTarget);
			e.target.useHandCursor=true;
        	e.target.buttonMode=true;
			surface.toolTip=null;
			_arrDataTips.filterFunction=filterGeom;
			_arrDataTips.refresh();
			if(_arrDataTips.getItemAt(0).dataTips!=null){
				surface.toolTip=_arrDataTips.getItemAt(0).dataTips.toString();
			}
			if(_highlighted==true){
				var glowColor:uint=0xFFFFFF;
				var glowGradFill:Array;
				glowColor=uint(_colorItem);
				
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
		 * @private
		 */
   		private function filterGeom(item:Object):Boolean{
			var isMatch:Boolean;
			if(item.gg==_gg){
				isMatch=true;
			}
			return isMatch;
		}
		
		/**
     	*  @private
     	*/
        private function baseMapComplete(e:GeoCoreEvents):void{
        	_isBaseMapComplete=true;
        	invalidateDisplayList();
        }
       
       
        /**
     	*  return the value for each steps.
     	*/
		public function getStepsValues():Array{
			return arrStep;
		}
		
		/**
     	*  return the colors for each steps.
     	*/
		public function getColors():Array{
			return arrCol;
		}
		
	}
}