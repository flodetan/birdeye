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
package org.un.cava.birdeye.geo.core
{	
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.*;
	
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	
	import org.un.cava.birdeye.geo.features.Features;
	import org.un.cava.birdeye.geo.projections.Projections;
	import org.un.cava.birdeye.geo.styles.GeoStyles;
		
	[Event(name="ItemClick", type="org.un.cava.birdeye.geo.events.GeoMapEvents")]
	[Style(name="gradientFill",type="Array",format="Color",inherit="no")]
	[Style(name="stroke",type="Array",format="Color",inherit="no")]
	[Style(name="fill",type="uint",format="Color",inherit="no")]
	[Inspectable("projection")]
	[Exclude(name="gpGeom", kind="property")]
	[Exclude(name="surf", kind="property")]
	[Exclude(name="colorItem", kind="property")]
	[Exclude(name="strokeItem", kind="property")]
	[Exclude(name="color", kind="style")]
	[Exclude(name="colorItem", kind="style")]
	
	[ExcludeClass]
	
	/**
	* This class is the main class that draw the maps.
	* All the other maps are subclass of this one.
	*/ 
	public class GeoFrame extends Canvas
	{
		private var _region:String;
		private var _projection:String;
		private var _color:SolidFill;
		private var _geoGroup:Array;
		private var _stroke:SolidStroke=new SolidStroke(0x000000,1,1);
		private var _gradientFill:Array=new Array();
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var listOfCountry:Array=new Array();
    	private var arrChildColors:Dictionary=new Dictionary();
    	private var arrChildStrokes:Dictionary=new Dictionary();
    	private var arrChildGradients:Dictionary=new Dictionary();
    	private var arrStroke:Array=new Array();
    	
    	public var wcData:Object;
    	public var surf:Surface;
    	
		[Inspectable(enumeration="Geographic,Lambert equal area,Mercator,Mollweide,WinkelTripel,Miller cylindrical,EckertIV,EckertVI,Goode,Sinsoidal,Robinson")]
		public function set projection(value:String):void
		{
			_projection = value;
			
			invalidateProperties();
		}
		
		public function get projection():String
		{
			return _projection;
		}
		
    	override public function set scaleX(value:Number):void
    	{
    		_scaleX=value;
			// Draw composite GeometryGroup collection 
			for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.scaleX = value;			
			}
			
			if(surf!=null){
				for (var n:int = 0; n<surf.numChildren; n++) 
				{
					surf.getChildAt(n).x=surf.getChildAt(n).x*value/surf.scaleX;
					surf.getChildAt(n).scaleX=value;
				}
				surf.scaleX=value;
			}
			invalidateDisplayList();
    	}
    	
    	//override public function get scaleX():Number
    	override public function get scaleX():Number
    	{
				return _scaleX;
    	}
    	
    	override public function set scaleY(value:Number):void
    	{
    		_scaleY=value;
			// Draw composite GeometryGroup collection 
			for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.scaleY = value;
			}
			if(surf!=null){
				for (var n:int = 0; n<surf.numChildren; n++) 
				{
					surf.getChildAt(n).y=surf.getChildAt(n).y*value/surf.scaleY;
					surf.getChildAt(n).scaleY=value;
				}
				surf.scaleY=value;
			}
			invalidateDisplayList();
    	}
    	
    	override public function get scaleY():Number
    	{
				return _scaleY;
    	}
    	/**
		* The type of projection used to draw the map.  
		* If not specified a default projection of "No projection" is used. 
		*/
		public function GeoFrame(region:String)
		{
			super();
			
			_region = region;
			
			_geoGroup = new Array();
			
			this.mouseEnabled=false;
			//this.creationPolicy="queued";
			/*this.verticalScrollPolicy="off";
			this.horizontalScrollPolicy="off";
			this.percentHeight=100;
			this.percentWidth=100;*/
		}

		/**
		 * Create component child elements. Standard Flex component method.
		 * 
		 */
	    override protected function createChildren():void
	    {
	        super.createChildren();
	        
			createMap();
	    }
		
		/**
		 * Create map elements.
		 * 
		 */
		private function createMap():void
		{
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
			
			getChildValues();

			wcData = Projections.getData(_projection, _region);
			listOfCountry = wcData.getCountriesListByRegion(_region);
			
			surf=new Surface();
			surf.name="Surface";
		    //surf.percentWidth=100; 
			//surf.percentHeight=100;
			//surf.setStyle("verticalCenter",0);
		    //surf.scaleX=0.5;
		    //surf.scaleY=0.5;

			for each (var country:String in listOfCountry)
			{
				if(wcData.getCoordinates(country)!="")
				{
					var countryGeom:GeometryGroup = new GeometryGroup();
					
					countryGeom.name = country;
					
					// The equivalent of the svg transform for flash. This will apply the flip and reposition the item.
					// taken from SVG as translate(0,174.8) scale(1, -1) and multiplied by 2 for magnification
		    		//countryGeom.transform.matrix = new Matrix(wcData.scaleX,0,0,wcData.scaleY,wcData.translateX,1*wcData.translateY);
					countryGeom.target=surf;
						
					//countryGeom.addEventListener(MouseEvent.CLICK,handleClickEvent);
					//countryGeom.addEventListener(MouseEvent.CLICK,handleClickEvent);
					countryGeom.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverEvent);
					//countryGeom.addEventListener(MouseEvent.MOUSE_OUT,handleMouseOutEvent);
					//countryGeom.addEventListener(MouseEvent.CLICK, handleClickEvent);
					//countryGeom.addEventListener(MouseEvent.ROLL_OVER, handleRollOverEvent);
					//countryGeom.addEventListener(MouseEvent.ROLL_OUT, handleRollOutEvent);
					
					surf.graphicsCollection.addItem(countryGeom);
					
					//check if it is a path or a polygone
					var myCoo:IGeometry;
					if(wcData.getCoordinates(country)!=null){
						if(isNaN(wcData.getCoordinates(country).substr(0,1))){
							myCoo = new Path();
						}else{
							myCoo = new Polygon();
						}
						
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
				
			}
			
			this.addChild(surf);
		}
		
	    
	    
	    
		/**
		 * Draw child elements.
		 * 
	     *  @param unscaledWidth Specifies the width of the component, in pixels,
	     *  in the component's coordinates, regardless of the value of the
	     *  <code>scaleX</code> property of the component.
	     *
	     *  @param unscaledHeight Specifies the height of the component, in pixels,
	     *  in the component's coordinates, regardless of the value of the
	     *  <code>scaleY</code> property of the component.
		 * 
		 */		
		 
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Draw composite GeometryGroup collection 
			for each (var gpGeom:GeometryGroup in _geoGroup)
			{
				gpGeom.draw(null,null);			
			}
			
		}
	    
		private function handleClickEvent(eventObj:MouseEvent):void {
			//
			//if(eventObj.target!="[object GeometryGroup]"){
				//dispatchEvent(new GeoMapEvents("ItemClick"));
				//Alert.show('/'+eventObj.type+eventObj.target+'/'+eventObj.currentTarget);
				eventObj.stopPropagation()
			//}
			
		}

      
		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
        	eventObj.target.mouseChildren=false;
        	//GeometryGroup(eventObj.target).filters=[new GlowFilter(0xFFFFFF,0.5,32,32,255,3,true,true)];
		}
		
		private function handleMouseOutEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
        	eventObj.target.mouseChildren=false;
        	//GeometryGroup(eventObj.target).filters=[new GlowFilter(0xFFFFFF,1,6,6,2,1,false,false)];
        }
		
		/*private function handleClickEvent(eventObj:MouseEvent):void {
        	dispatchEvent(new MouseEvent("click"));
		}
		private function handleRollOverEvent(eventObj:MouseEvent):void {
			dispatchEvent(new MouseEvent("rollover"));
		}
		private function handleRollOutEvent(eventObj:MouseEvent):void {
        	dispatchEvent(new MouseEvent("rollout"));
		}*/

		private function getChildValues():void{
			for(var numOfChildren:int=0; numOfChildren<this.numChildren; numOfChildren++){
				var ClassName:String=getQualifiedClassName(this.getChildAt(numOfChildren));
				//Alert.show(ClassName);
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

		/*private function setZPosition():void{
			var arrChildren:Array=new Array();
			arrChildren=this.getChildren();
			var childNumber:int=0;
			while (childNumber<arrChildren.length) { 
				var ClassName:String=getQualifiedClassName(this.getChildAt(childNumber));
				if(ClassName=="Features"){
					this.setChildIndex(this.getChildAt(childNumber),1);
				}else if(ClassName=="Symbols"){
					this.setChildIndex(this.getChildAt(childNumber),2);
				}
				childNumber++;
			}
		}*/
	}
}