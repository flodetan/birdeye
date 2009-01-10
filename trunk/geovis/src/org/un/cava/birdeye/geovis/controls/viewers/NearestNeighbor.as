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
package org.un.cava.birdeye.geovis.controls.viewers
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	
	import mx.collections.ArrayCollection;
	import mx.controls.HSlider;
	import mx.events.FlexEvent;
	import mx.controls.Alert;
	
	import org.un.cava.birdeye.geovis.dictionary.USANeighborhoods;
	import org.un.cava.birdeye.geovis.dictionary.WorldNeighborhoods;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.geovis.utils.ArrayUtils;
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("foid")]
	[Inspectable("target")]
	[Inspectable("color")]
	[Exclude(name="thumbCount", kind="property")]
	[Exclude(name="snapInterval", kind="property")]
	/**
	* Control to set visibility of neighbors to a selected country or US state 
	* by distance in degrees of separation, e.g. one degree as bordering, 
	* two degrees for countries two borders away, etc.
	**/
	public class NearestNeighbor extends HSlider
	{
		/**
	     *  @private
	     */
		private var _foid:String="";
		
		/**
	     *  @private
	     */
		private var _isProjChanged:Boolean=false;
		
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
	     *  Storage for the targets property.
	     */
	    private var _targets:Array = [];
	    
	    /**
	     *  @private
	     */
	     private var arrCollNN:ArrayCollection;
	     
	     /**
	     *  @private
	     */
	     [Bindable]
	     private var cntryKey:String;
	     
	     /**
	     *  @private
	     */
		private var myCoo:IGeometry;
		
		/**
		 * @private
		 */
		 private var _gg:GeometryGroup;
		
		/**
		 * @private
		 */
		 private var _color:uint;
		 
		 /**
		 * @private
		 */
		 private var _arrDataTips:ArrayCollection;
		 
		 /**
	     *  @private
	     */
		 private var _isBaseMapComplete:Boolean=false;
		
		
		 /**
	     *  @private
	     */
		 private var _isReady:Boolean=false;
		
		/**
	     *  @private
	     */
		private var oldValue:int=0;
		
		/**
		 *  @Private
		 */
		private var myBKUP:Object;
		
		/**
		 *  @Private
		 */
		private var proj:String;
		
		/**
		 *  @Private
		 */
		private var region:String;
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties 
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  foid
	    //----------------------------------

		/**
     	 * The foid is a 3 letters country ISO code for the world map, and 2 letters states ISO code for the US map.
     	 */
		public function set foid(value:String):void{
			_foid=value;
			this.value=0;
			revertColorization();
			
		}
		
		/**
	     *  @private
	     */
		public function get foid():String{
			return _foid;
		}
		
		
		//----------------------------------
	    //  target
	    //----------------------------------
	
	    /** 
	     *  The Map object to which the NearestNeighbor will be applied.
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
	            _targets[0].addEventListener(GeoProjEvents.PROJECTION_CHANGED, projChanged);
	    }
	
    	//----------------------------------
	    //  color
	    //----------------------------------

		/**
     	 * Defines the colour of the nearby countries
     	 */
		public function set color(value:uint):void{
			_color=value;
		}
		
		/**
	     *  @private
	     */
		public function get color():uint{
			return _color;
		}
		
		
    	
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function NearestNeighbor()
		{
			super();
			this.thumbCount=1;
			this.snapInterval=1;
			arrCollNN=new ArrayCollection();
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
       override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
      		super.updateDisplayList( unscaledWidth, unscaledHeight );            
		      if(_isProjChanged){
      			_isProjChanged=false;
      		  }
      		  if(_isReady){
      			showNeighbor();
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
		private function creationCompleteHandler(event:FlexEvent):void{
			showNeighbor();
			_isReady=true;
		 	_targets[0].addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, baseMapComplete);
		}
		
		/**
		 * @private
		 */
		private function showNeighbor():void{ 
			if(_foid!=""){
				proj=_targets[0].projection;
				region=_targets[0].region;
				if(region!=null){
					if(this.value>oldValue){
						var arrCntryKeys:Array=new Array();
						arrCntryKeys=getNeighb(_foid);
						for (var i:int=0; i<this.value; i++){
							var arrTempCntry:Array=new Array();
							for (var j:int=0; j<arrCntryKeys.length; j++){
								cntryKey=arrCntryKeys[j]
								myBKUP=new Object();
								myBKUP["degOfSep"]=i;
		   						myBKUP["key"]=cntryKey;
		   						//myBKUP["stroke"]=myCoo.stroke;
								colorize(cntryKey,new SolidFill(_color,1));
							
								if (checkIsAlreadyInList()){
									arrCollNN.addItem(myBKUP);
								}
								for (var k:int=0; k<getNeighb(arrCntryKeys[j]).length; k++){
									if(getNeighb(arrCntryKeys[j])[k]!=_foid){
										arrTempCntry.push(getNeighb(arrCntryKeys[j])[k]);
									}
								}
							}
							arrTempCntry.sort();
							ArrayUtils.removeDup(arrTempCntry);
							arrCntryKeys=arrTempCntry;
						}			
					}else{
						revertColorization();		
					}
				}
			}
				oldValue=this.value; 
		}
		
		/**
		 * @private
		 */
		private function colorize(CountryKey:String, SF:SolidFill):void{
			
			var GeoData:Object=Projections.getData(proj,region);
			surface=Surface(_targets[0].getChildByName("Surface"))
			geom=GeometryGroup(surface.getChildByName(CountryKey));			
			if(geom!=null){
				if(GeoData.getCoordinates(CountryKey)!=null){
					if(isNaN(GeoData.getCoordinates(CountryKey).substr(0,1))){
						myCoo = Path(GeometryGroup(surface.getChildByName(CountryKey)).geometryCollection.getItemAt(0));
					}else{
						myCoo = Polygon(GeometryGroup(surface.getChildByName(CountryKey)).geometryCollection.getItemAt(0));
					}	
					myBKUP["fill"]=myCoo.fill;
					myCoo.fill=SF;
				}
			}
		}
		
		/**
		 * @private
		 */
		 private function revertColorization():void{
		 	arrCollNN.filterFunction = itemToRemove;
			arrCollNN.refresh();
			for(var l:int=arrCollNN.length-1; l>=0; l--){
				if(arrCollNN[l].fill!=null){
					colorize(arrCollNN[l].key,arrCollNN[l].fill);
				}else{
					colorize(arrCollNN[l].key,new SolidFill(arrCollNN[l].fill,0));
				}
				arrCollNN.removeItemAt(l);
			}
			arrCollNN.filterFunction = null;
            arrCollNN.refresh();
		 }
		 
		/**
		 * @private
		 */
		private function getNeighb(CountryKey:String):Array{
			var Wn:Object;
			if(region=="World" || region=="Africa" || region=="NorthAmerica" || region=="SouthAmerica" || region=="Asia" || region=="Europe" || region=="Oceania" || region=="Antartica" || region=="CIS" || region=="NorthAfrica" || region=="SubSahara" || region=="EasternAsia" || region=="SouthernAsia" || region=="SouthEasternAsia" || region=="WesternAsia"){
				Wn=new WorldNeighborhoods();
			}else if(region=="USA" || region=="CONUS" || region=="OCONUS" || region=="NorthEast" || region=="MidWest" || region=="South" || region=="West" || region=="NewEngland" || region=="MiddleAtlantic" || region=="EastNorthCentral" || region=="WestNorthCentral" || region=="SouthAtlantic" || region=="EastSouthCentral" || region=="WestSouthCentral" || region=="Mountain" || region=="Pacific") {
				Wn=new USANeighborhoods();
			}
			var cntryList:String=Wn.getNeighbours(CountryKey);
			var arrCountryKeys:Array=new Array();
			if(cntryList!=null){
				arrCountryKeys=cntryList.split(',')
			}
			return arrCountryKeys;
		}
		
		/**
		 * @private
		 */
		private function checkIsAlreadyInList():Boolean{
			var retVal:Boolean=false;
			arrCollNN.filterFunction = isAlreadyInclude;
			arrCollNN.refresh();
			if (arrCollNN.length==0){
				retVal = true
			}
			arrCollNN.filterFunction = null;
            arrCollNN.refresh();

			return retVal
		}
		
         /**
		 * @private
		 */
          private function isAlreadyInclude(item:Object):Boolean{
               var isMatch:Boolean = false
               if(item.key.toUpperCase().search(cntryKey.toUpperCase()) != -1){
                   isMatch = true
               }               
               return isMatch;               
           }
		
		/**
		 * @private
		 */
          private function itemToRemove(item:Object):Boolean{
               var isMatch:Boolean = false
               if(item.degOfSep>=this.value){
                   isMatch = true
               }               
               return isMatch;               
           }
		
		/**
     	*  @private
     	*/
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	this.value=0;
        	arrCollNN=new ArrayCollection();
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
