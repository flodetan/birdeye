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
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.*;
	
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
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
    	public var surf:Map;
    	
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
			invalidateDisplayList();
			//invalidateProperties();
		}
		
		/**
     	*  @private
     	*/
		public function get projection():String
		{
			return _projection;
		}
		
		
		private var _autosize:String = "fit-height";
		[Inspectable(enumeration="fit-height,fit-width")]
		public function set autosize(val:String):void
		{
			_autosize = val;
		}
		
    	/**
     	*  Constructor.
     	*/
		public function GeoFrame(region:String)
		{
			super();
			_region = region;
			
			_geoGroup = new Array();
			verticalScrollPolicy = "off";
			horizontalScrollPolicy = "off";
			
			this.mouseEnabled=false;
		}

	    override protected function createChildren():void
	    {
	    	super.createChildren();
	    	
	    	surf=new Map();
			surf.name="Surface";
		    this.addChild(surf); 

	  		maskShape = new Shape();
	  		maskCont = new UIComponent();
	  		maskCont.addChild(maskShape);
	  		this.addChild(maskCont);
	  		this.setChildIndex(maskCont, 0);
	  		surf.mask = maskShape;
	    }
	    
		private var maskShape:Shape; 
		private var maskCont:UIComponent;
		private var maskCreated:Boolean = false;
		private var backgroundPoly:RegularRectangle;
		private var background:GeometryGroup;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

		    if (isProjectionChanged) {
				surf.transform.matrix = new Matrix();
		    	surf.scaleX = surf.scaleY = surf.zoom = Map.CREATION_ZOOM;
	 			
				createMap();
				isProjectionChanged=false;
				
				if (!maskCreated)
				{
					maskCont.setActualSize(unscaledWidth, unscaledHeight);
					maskCont.move(0,0);
					maskShape.graphics.beginFill(0xffffff, 0);
					maskShape.graphics.drawRect(0,0,unscaledWidth, unscaledHeight);
					maskShape.graphics.endFill();
		  			this.setChildIndex(maskCont, 0);
		  			maskCreated = true;
				}
trace (maskShape.width, maskShape.height);

				// the projection name is registered inside map
				// this will also updates the unscaled map size with the proper values
				// that will be used for the background size 
				surf.projection = _projection;
				
				// update the background size with the new surface unscaled size. I would have liked to put this into Map
				// and creating the background directly there and appending it to the map as child 0, but the setChildIndex
				// doesn't work and the background is put on top of the Map, thus removing all events over the countries.
				// however, this will change with the new model structure
	
			    backgroundPoly = 
			    	new RegularRectangle(0,0,surf.width, surf.height);
			    backgroundPoly.fill = new SolidFill(0xffffff,0);
			    background.geometryCollection.addItem(backgroundPoly);
			
				switch (_autosize)
				{
					case "fit-height":
						surf.defaultZoom = unscaledHeight/surf.height;
					break;
					case "fit-width":
						surf.defaultZoom = unscaledWidth/surf.width;
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

// on start-up style stroke is still undefined			
trace (getStyle("stroke"));
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
// remove following when the style is properly loaded at start-up
			else 
			{
				_stroke = new SolidStroke(0x000000);
			}
// --------
			_stroke.scaleMode="none";
			getChildValues();
			wcData = Projections.getData(_projection, _region);
			listOfCountry = wcData.getCountriesListByRegion(_region);
			
			// background is necessary to allow events that trigger dragging, zooming, 
			// centering...all over the map and not only where countries are filled out with some fill 
			// check after the for...loop to find the last instructions to define the background size
		    background = new GeometryGroup(); 
		    background.target = surf;
			surf.graphicsCollection.addItemAt(background,0);

			for each (var country:String in listOfCountry)
			{
				if(wcData.getCoordinates(country)!="")
				{
					var countryGeom:GeometryGroup = new GeometryGroup();
					countryGeom.addEventListener(MouseEvent.CLICK, itemClkEv);
					countryGeom.addEventListener(MouseEvent.DOUBLE_CLICK, itemDblClkEv);
					countryGeom.addEventListener(MouseEvent.ROLL_OVER, itemRollOverEv);
					countryGeom.addEventListener(MouseEvent.ROLL_OUT, itemRollOutEv);
					countryGeom.scaleY = countryGeom.scaleX = surf.zoom;
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
					for each (var polygonCoordinates:String in wcData.getCoordinates(country)) //a country may have several polygons
					{
						if(wcData.getCoordinates(country)!=null){

							myCoo = new Polygon();
							myCoo.data = polygonCoordinates;
						
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
						} // end if getCoordinates contained data
					} // end polygon loop for country
					_geoGroup.push(countryGeom);
				}
			}
			dispatchEvent(new GeoCoreEvents(GeoCoreEvents.DRAW_BASEMAP_COMPLETE));
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