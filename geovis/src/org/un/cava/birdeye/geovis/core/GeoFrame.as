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
 
package org.un.cava.birdeye.geovis.core
{	
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.*;
	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.analysis.*;
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoMapEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.features.Features;
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.geovis.styles.GeoStyles;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
 	*  Dispatched when a country has been clicked on the map.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoMapEvents.ITEM_CLICKED
 	*/
	[Event(name="ItemClick", type="org.un.cava.birdeye.geovis.events.GeoMapEvents")]
	
	
	/**
 	*  Dispatched when a country has been double clicked on the map.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoMapEvents.ITEM_DOUBLECLICKED
 	*/
	[Event(name="ItemDoubleClick", type="org.un.cava.birdeye.geovis.events.GeoMapEvents")]
	
	/**
 	*  Dispatched when a country has been rolled over.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoMapEvents.ITEM_ROLLOVER
 	*/
	[Event(name="ItemRollOver", type="org.un.cava.birdeye.geovis.events.GeoMapEvents")]
	
	
	/**
 	*  Dispatched when a country has been rolled out.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoMapEvents.ITEM_ROLLOUT
 	*/
	[Event(name="ItemRollOut", type="org.un.cava.birdeye.geovis.events.GeoMapEvents")]
	
	/**
 	*  Dispatched when the base map is complete.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoCoreEvents.DRAW_BASEMAP_COMPLETE
 	*/
	[Event(name="DrawBaseMapComplete", type="org.un.cava.birdeye.geovis.events.GeoCoreEvents")]
	
	/**
 	*  Dispatched when the projection change.
 	*
 	*  @eventType org.un.cava.birdeye.geovis.events.GeoProjEvents.PROJECTION_CHANGED
 	*/
	[Event(name="ProjectionChanged", type="org.un.cava.birdeye.geovis.events.GeoProjEvents")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
 	*  Define a default gradient for fill all the countries. 
 	*  You should set this to an Array. Elements 0 and 1 specify the start and end values for a color gradient.
 	*  Element 2 specify the type of gradient 0: radial and 1: linear.
 	*  Element 3 specify the rotation angle.
 	*/
	[Style(name="gradientFill",type="Array",format="Color",inherit="no")]
	
	/**
 	*  Define a default stroke for all the countries. 
 	*  You should set this to an Array. 
 	*  Elements 0 specify the color of the stroke.
 	*  Element 1 specify the alpha.
 	*  Element 2 specify the weight.
 	*  
 	*  @default color:0x000000, alpha:1, weight:1
 	*/
	[Style(name="stroke",type="Array",format="Color",inherit="no")]
	
	/**
 	*  Define a default color for fill all the countries. 
 	*/
	[Style(name="fill",type="uint",format="Color",inherit="no")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("projection")]
	[Exclude(name="gpGeom", kind="property")]
	[Exclude(name="surf", kind="property")]
	[Exclude(name="colorItem", kind="property")]
	[Exclude(name="strokeItem", kind="property")]
	[Exclude(name="color", kind="style")]
	[Exclude(name="colorItem", kind="style")]
	
	[ExcludeClass]
	
	
	/**
	 *  The GeoFrame class is the main class that draw the maps.
	 *  All the other maps are subclass of this one.
	 */
	public class GeoFrame extends Canvas
	{
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
		private var _region:String;
		
		/**
	     *  @private
	     */
		private var _projection:String="Geographic";
		
		/**
	     *  @private
	     */
		private var _color:SolidFill;
		
		/**
	     *  @private
	     */
		private var _geoGroup:Array;
		
		/**
	     *  @private
	     */
		private var _stroke:SolidStroke=new SolidStroke(0x000000,1,1);
		
		/**
	     *  @private
	     */
		private var _gradientFill:Array=new Array();
		
		/**
	     *  @private
	     */
		private var _scaleX:Number=1;
		
		/**
	     *  @private
	     */
		private var _scaleY:Number=1;
		
		/**
	     *  @private
	     */
		private var listOfCountry:Array=new Array();
		
		/**
	     *  @private
	     */
    	private var arrChildColors:Dictionary=new Dictionary();
    	
    	/**
	     *  @private
	     */
    	private var arrChildStrokes:Dictionary=new Dictionary();
    	
    	/**
	     *  @private
	     */
    	private var arrChildGradients:Dictionary=new Dictionary();
    	
    	/**
	     *  @private
	     */
    	private var arrStroke:Array;
    	
    	/**
     	*  @private
     	*/
    	public var wcData:Object;
    	
    	/**
     	*  @private
     	*/
    	public var surf:Surface;
    	
    	/**
     	*  @private
     	*/
    	private var isAlreadyCreated:Boolean=false;
    	
    	/**
     	*  @private
     	*/
    	private var isProjectionChanged:Boolean=false;
    	
    	/**
     	*  @private
     	*/
    	private var isScaleXChanged:Boolean=false;
    	
    	/**
     	*  @private
     	*/
    	private var isScaleYChanged:Boolean=false;
    	//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
    	//----------------------------------
	    //  projection
	    //----------------------------------

		[Inspectable(enumeration="Geographic,Lambert equal area,Mercator,Mollweide,WinkelTripel,Miller cylindrical,EckertIV,EckertVI,Goode,Sinsoidal,Robinson")]
		
		 /**
     	 *  Define the type of projection of the map.
     	 *  Valid values are <code>"Geographic"</code> or <code>"Lambert equal area"</code> or <code>"Mercator"</code> or <code>"Mollweide"</code> or <code>"WinkelTripel"</code> or <code>"Miller cylindrical"</code> or <code>"EckertIV"</code> or <code>"EckertVI"</code> or <code>"Goode"</code> or <code>"Sinsoidal"</code> or <code>"Robinson"</code>.
     	 * @default Geographic
	     */
		public function set projection(value:String):void
		{
			_projection = value;
			isProjectionChanged=true;
			///invalidateDisplayList();
			invalidateProperties();
			dispatchEvent(new GeoProjEvents(GeoProjEvents.PROJECTION_CHANGED,value));
		}
		
		/**
     	*  @private
     	*/
		public function get projection():String
		{
			return _projection;
		}
		
		
		//----------------------------------
	    //  scaleX
	    //----------------------------------
	    
		/**
	     *  The X scale of the map.
	     *  Any number, 2 is the double of the original size.
	     */
    	override public function set scaleX(value:Number):void
    	{
    		_scaleX=value;
			/*for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.scaleX = value;
			}*/
			
			if(surf!=null){
				for (var n:int = 0; n<surf.numChildren; n++) 
				{
					surf.getChildAt(n).x=surf.getChildAt(n).x*value/surf.scaleX;
					surf.getChildAt(n).scaleX=value;
				}
				surf.scaleX=value;
			}
			isScaleXChanged=true;
			//invalidateDisplayList();
			
    	}
    	
    	/**
     	*  @private
     	*/
    	override public function get scaleX():Number
    	{
				return _scaleX;
    	}
    	
    	
    	//----------------------------------
	    //  scaleY
	    //----------------------------------
	    
	    
    	/**
	     *  The Y scale of the map.
	     *  Any number, 2 is the double of the original size.
	     */
    	override public function set scaleY(value:Number):void
    	{
    		_scaleY=value;
			/*for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.scaleY = value;
			}*/
			if(surf!=null){
				for (var n:int = 0; n<surf.numChildren; n++) 
				{
					surf.getChildAt(n).y=surf.getChildAt(n).y*value/surf.scaleY;
					surf.getChildAt(n).scaleY=value;
				}
				surf.scaleY=value;
			}
			isScaleYChanged=true;
			//invalidateDisplayList();
			
    	}
    	
    	/**
     	*  @private
     	*/
    	override public function get scaleY():Number
    	{
				return _scaleY;
    	}
    	
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoFrame(region:String)
		{
			super();
			//super.measure();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, setMap)
			_region = region;
			
			_geoGroup = new Array();
			
			this.mouseEnabled=false;
			//this.setStyle("verticalCenter",0);
			//this.setStyle("horizontalCenter",0);
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
	    override protected function createChildren():void
	    {
	    	super.createChildren();
	    	surf=new Surface();
			surf.name="Surface";
			surf.scaleX=_scaleX;
		    surf.scaleY=_scaleY;
		    this.addChild(surf);
		    
		    createMap();
		
	    }
		
		
		/**
		 * @private
		 * Draw child elements.
		 * 
	     *  @param unscaledWidth Specifies the width of the component, in pixels,
	     *  in the component's coordinates, regardless of the value of the
	     *  <code>scaleX</code> property of the component.
	     *
	     *  @param unscaledHeight Specifies the height of the component, in pixels,
	     *  in the component's coordinates, regardless of the value of the
	     *  <code>scaleY</code> property of the component.
		 */		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			/*for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.draw(null,null);			
			}*/
			//trace(isScaleXChanged  + ' || ' +  isScaleYChanged + ' || ' + isProjectionChanged)
			///if(isScaleXChanged || isScaleYChanged || isProjectionChanged){// 
				
			///if(surf){
				///trace('goodBye')
				//if(isProjectionChanged){
				///for(var i:int=surf.numChildren-1; i>=0; i--){
				///	if(surf.getChildAt(i) is GeometryGroup){
				///		surf.removeChildAt(i);
				///	}
				///}
				//createMap();
				
				//}
				/*if(isProjectionChanged==true && isAlreadyCreated==true){
					for(var i:int=surf.numChildren-1; i>=0; i--){
						surf.removeChildAt(i);
					}
					isProjectionChanged=false;
					//isAlreadyCreated=false;
				}*/
				///createMap();
			///}
			//isProjectionChanged=false;
			//isScaleXChanged=false;
			//isScaleYChanged=false;
			//isAlreadyCreated=true;

			///}
		}
		
		override protected function commitProperties():void {
		    super.commitProperties();
		    
		    if (isProjectionChanged) {
		       createMap();
				isProjectionChanged=false;
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
		private function setMap(e:FlexEvent):void{
			
			createMap();
		}
		
		/**
		 * @private
		 * Create map elements.
		 */
		private function createMap():void
		{
			if(surf){
				for(var i:int=surf.numChildren-1; i>=0; i--){
						if(surf.getChildAt(i) is GeometryGroup){
							surf.removeChildAt(i);
						}
					}
			}	
			arrStroke=new Array();
			if(getStyle("fill"))
			{
				_color=new SolidFill(getStyle("fill"),1);
			}
			
			if(getStyle("stroke"))
			{
				if(typeof(getStyle("stroke"))=="number")
				{
					arrStroke.push(getStyle("stroke"));
				}
				else
				{
					arrStroke=getStyle("stroke");
				}
				
				while (arrStroke.length<3) 
				{ 
					arrStroke.push(1); 
				}
				_stroke = new SolidStroke(arrStroke[0],arrStroke[1],arrStroke[2]);
				
			}
			_stroke.scaleMode="none";
			getChildValues();
			wcData = Projections.getData(_projection, _region);
			listOfCountry = wcData.getCountriesListByRegion(_region);
			
			
		    
			for each (var country:String in listOfCountry)
			{
				if(wcData.getCoordinates(country)!="")
				{
					var countryGeom:GeometryGroup = new GeometryGroup();
					countryGeom.addEventListener(MouseEvent.CLICK, itemClkEv);
					countryGeom.addEventListener(MouseEvent.DOUBLE_CLICK, itemDblClkEv);
					countryGeom.addEventListener(MouseEvent.ROLL_OVER, itemRollOverEv);
					countryGeom.addEventListener(MouseEvent.ROLL_OUT, itemRollOutEv);
					countryGeom.scaleX=_scaleX;
					countryGeom.scaleY=_scaleY;
					countryGeom.name = country;
					
					/*
					var myBarryCoo:Array=wcData.getBarryCenter(country).split(",");
					var transMat:Matrix = countryGeom.transform.matrix; 
					transMat.translate(-myBarryCoo[0],-myBarryCoo[1]); 
					transMat.scale(_scaleX,_scaleY); 
					transMat.translate(myBarryCoo[0],myBarryCoo[1]); 
					countryGeom.transform.matrix=transMat; 
					*/

					countryGeom.target=surf;
						
					surf.graphicsCollection.addItem(countryGeom);
					
					var myCoo:IGeometry;
					if(wcData.getCoordinates(country)!=null){
						if(isNaN(wcData.getCoordinates(country).substr(0,1))){
							myCoo = new Path();
						}else{
							myCoo = new Polygon();
						}
						
						/*var trsf:Transform=new Transform();
						trsf.registrationPoint="center";
						trsf.scaleX=_scaleX;
						trsf.scaleY=_scaleY;
						
						if(isNaN(wcData.getCoordinates(country).substr(0,1))){
							Path(myCoo).transform = trsf;
						}else{
							Polygon(myCoo).transform = trsf;
						}*/
						
						//var geoComp:GeometryComposition=new GeometryComposition();
						//geoComp.transform=trsf;
						
						myCoo.data = wcData.getCoordinates(country);
						
						if(arrChildStrokes[country]===undefined)
						{
							myCoo.stroke=_stroke;
						}
						
						
						if(arrChildGradients[country]===undefined)
						{
							if(arrChildColors[country]===undefined)
							{
							
								if(getStyle("gradientFill")){
									_gradientFill=getStyle("gradientFill");
									if(_gradientFill.length!=0)
									{
										if(_gradientFill[2]==0)
										{
											myCoo.fill=GeoStyles.setRadialGradient(_gradientFill);
										}
										else
										{
											myCoo.fill=GeoStyles.setLinearGradient(_gradientFill);
										}
									}
								}
								else
								{
									if(_color)
									{
										myCoo.fill=_color;
									}
								}
							}
						}
						
						
						
						countryGeom.geometryCollection.addItem(myCoo);
					
					}
					_geoGroup.push(countryGeom);
				
			}
			
			
			dispatchEvent(new GeoCoreEvents(GeoCoreEvents.DRAW_BASEMAP_COMPLETE));
			}
		}
		
		/**
     	*  @private
     	*/
	    private function itemClkEv(e:MouseEvent):void{
	    	dispatchEvent(new GeoMapEvents(GeoMapEvents.ITEM_CLICKED,e.currentTarget.name,Features(this.getChildByName('feat'+e.currentTarget.name))))
	    }
	    
	    /**
     	*  @private
     	*/
	    private function itemDblClkEv(e:MouseEvent):void{
	    	dispatchEvent(new GeoMapEvents(GeoMapEvents.ITEM_DOUBLECLICKED,e.currentTarget.name,Features(this.getChildByName('feat'+e.currentTarget.name))))
	    }
	    
	    /**
     	*  @private
     	*/
	    private function itemRollOverEv(e:MouseEvent):void{
	    	dispatchEvent(new GeoMapEvents(GeoMapEvents.ITEM_ROLLOVER,e.currentTarget.name,Features(this.getChildByName('feat'+e.currentTarget.name))))
	    }
	    
	    /**
     	*  @private
     	*/
	    private function itemRollOutEv(e:MouseEvent):void{
	    	dispatchEvent(new GeoMapEvents(GeoMapEvents.ITEM_ROLLOUT,e.currentTarget.name,Features(this.getChildByName('feat'+e.currentTarget.name))))
	    }
	    
		
	    
	    /**
     	*  @private
     	*/
		private function handleClickEvent(eventObj:MouseEvent):void {
			eventObj.stopPropagation()
			
		}
		
		/**
     	*  @private
     	*/
		private function handleRollOverEvent(eventObj:MouseEvent):void {
			highlightSeries(eventObj.target);
		}
		
		/**
     	*  @private
     	*/
		private function handleRollOutEvent(eventObj:MouseEvent):void {
        	eventObj.target.filters=[];
		}
		
		/**
     	*  @private
     	*/
		private function getChildValues():void{
			for(var numOfChildren:int=0; numOfChildren<this.numChildren; numOfChildren++){
				var ClassName:String=getQualifiedClassName(this.getChildAt(numOfChildren));
				if(ClassName=="org.un.cava.birdeye.geo.features::Features"){
					if(Features(this.getChildAt(numOfChildren)).colorItem){
						arrChildColors[Features(this.getChildAt(numOfChildren)).foid.toString()]=Features(this.getChildAt(numOfChildren)).colorItem;
					}
					if(Features(this.getChildAt(numOfChildren)).stkItem){
						arrChildStrokes[Features(this.getChildAt(numOfChildren)).foid.toString()]=Features(this.getChildAt(numOfChildren)).stkItem;
					}
					if(Features(this.getChildAt(numOfChildren)).gradItemFill){
						arrChildGradients[Features(this.getChildAt(numOfChildren)).foid.toString()]=Features(this.getChildAt(numOfChildren)).gradItemFill;
					}
				}
			}
		}
		
		/**
     	*  @private
     	*/
		private function highlightSeries(Ser:Object):void{
	            var filter:GlowFilter = getBitmapFilter();
	            var myFilters:Array = new Array();
	            myFilters.push(filter);
	            Ser.filters = myFilters;
	           
    			var target:Array = new Array();
    			target.push(Ser);
	        }
			
			/**
     		*  @private
     		*/
	        private function getBitmapFilter():GlowFilter {
	            var color:Number = 0xCCCCCC;
	            var alpha:Number = 1;
	            var blurX:Number = 4;
	            var blurY:Number = 4;
	            var strength:Number = 5;
	            var inner:Boolean = false;
	            var knockout:Boolean = false;
	            var quality:Number = 5;
	
	            return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
	        }
	}
}