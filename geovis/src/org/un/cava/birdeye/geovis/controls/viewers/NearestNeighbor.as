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
	import com.degrafa.Surface;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.controls.HSlider;
	import mx.events.FlexEvent;
	import mx.core.Application;

	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.dictionary.USANeighborhoods;
	import org.un.cava.birdeye.geovis.dictionary.USAStates;
	import org.un.cava.birdeye.geovis.dictionary.WorldCountries;
	import org.un.cava.birdeye.geovis.dictionary.WorldNeighborhoods;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.utils.ArrayUtils;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.projections.Projections;
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
		private var surface:Map;
		
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
				surface=Map(_targets[0].getChildByName("Surface"));
				if(region!=null){
						var arrCntryKeys:Array=new Array();
						var arrTempCntry:Array=new Array();
						arrCntryKeys.push(_foid);
						arrTempCntry.push(_foid);
						for (var i:int=0; i<this.value; i++){
							
							for (var j:int=0; j<arrCntryKeys.length; j++){
								for (var k:int=0; k<getNeighb(arrCntryKeys[j]).length; k++){
									arrTempCntry.push(getNeighb(arrCntryKeys[j])[k]);
								}
							}
							arrTempCntry.sort();
							ArrayUtils.removeDup(arrTempCntry);
							arrCntryKeys=arrTempCntry;
							arrTempCntry=new Array();
						}	
						
						for(var l:int=0; l<getCntryMap(region).length; l++){
							geom=GeometryGroup(surface.getChildByName(getCntryMap(region)[l]));
							if(this.value!=0){	
								if(arrCntryKeys.indexOf(getCntryMap(region)[l])!=-1){
									geom.alpha=1;
								}else{
									geom.alpha=0;
								}
								
							}else{
								geom.alpha=1;
							}
						}
						if(this.value!=0){	
							var GeoData:Object=Projections.getData(proj,region);
							var cooBC:String=GeoData.getBarryCenter(_foid);
							var arrPos:Array=cooBC.split(',');
							var pt:Point=new Point()
							pt.x=arrPos[0];
							pt.y=arrPos[1];
							surface.centerMap(pt);	
						}else{
//							surface.reset();
						}	
				}
			}
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
		private function getCntryMap(Region:String):Array{
			var WCUS:Object;
			if(region=="World" || region=="Africa" || region=="NorthAmerica" || region=="SouthAmerica" || region=="Asia" || region=="Europe" || region=="Oceania" || region=="Antartica" || region=="CIS" || region=="NorthAfrica" || region=="SubSahara" || region=="EasternAsia" || region=="SouthernAsia" || region=="SouthEasternAsia" || region=="WesternAsia"){
				WCUS=new WorldCountries();
			}else if(region=="USA" || region=="CONUS" || region=="OCONUS" || region=="NorthEast" || region=="MidWest" || region=="South" || region=="West" || region=="NewEngland" || region=="MiddleAtlantic" || region=="EastNorthCentral" || region=="WestNorthCentral" || region=="SouthAtlantic" || region=="EastSouthCentral" || region=="WestSouthCentral" || region=="Mountain" || region=="Pacific") {
				WCUS=new USAStates();
			}
			var arrCountryKeys:Array=new Array();
			arrCountryKeys=WCUS.getCountriesListByRegion(Region);
			return arrCountryKeys;
		}
		
		/**
     	*  @private
     	*/
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	this.value=0;
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
