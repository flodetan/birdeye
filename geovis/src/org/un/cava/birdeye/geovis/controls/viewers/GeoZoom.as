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
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Zoom;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("target")]
	
	/**
	* Control to Zoom map based on map object id or lat/long
	**/
	public class GeoZoom extends ComboBox
	{
		/**
	     *  @private
	     *  Storage for the targets property.
	     */
	    private var _targets:Array = [];
	    
	    /**
	     *  @private
	     */
	    private var EffMove:Move;
		
		/**
	     *  @private
	     */
		private var EffZoom:Zoom;
		
		/**
	     *  @private
	     */
		private var parEf:Parallel;
		
		/**
	     *  @private
	     */
		private var ZoomWidthFrom:Number;
		
		/**
	     *  @private
	     */
		private var ZoomHeightFrom:Number;
		
		/**
	     *  @private
	     */
		private var xPos:Number;
		
		/**
	     *  @private
	     */
		private var yPos:Number;
		
		/**
	     *  @private
	     */
		private var proj:String;
		
		/**
	     *  @private
	     */
		private var arrDefaultZoom:ArrayCollection = new ArrayCollection(
		[{label:"World",ulx:"", uly:"", lrx:"", lry:""},
		{label:"Africa",ulx:"-20", uly:"40", lrx:"60", lry:"-20"},
		{label:"  -North",ulx:"-20", uly:"30", lrx:"60", lry:"20"},
		{label:"  -Sub-Sahara",ulx:"-20", uly:"30", lrx:"60", lry:"-35"},
		{label:"Asia",ulx:"35", uly:"45", lrx:"145", lry:"0"},
		{label:"  -Eastern",ulx:"70", uly:"45", lrx:"130", lry:"20"},
		{label:"  -Southern",ulx:"40", uly:"40", lrx:"100", lry:"10"},
		{label:"  -South-eastern",ulx:"90", uly:"30", lrx:"140", lry:"-10"},
		{label:"  -Western",ulx:"15", uly:"40", lrx:"60", lry:"15"},
		{label:"CIS",ulx:"25", uly:"75", lrx:"180", lry:"35"},
		{label:"Europe",ulx:"-25", uly:"75", lrx:"40", lry:"35"},
		{label:"NorthAmerica",ulx:"-150", uly:"40", lrx:"10", lry:"40"},
		{label:"Oceania",ulx:"100", uly:"15", lrx:"180", lry:"-50"},
		{label:"SouthAmerica",ulx:"-120", uly:"35", lrx:"-30", lry:"-60"}]);
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
	    }
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoZoom()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, setGeoZoom);
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		 private function setGeoZoom(e:FlexEvent):void{
		 	var dynamicClassName:String = getQualifiedClassName(target);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			proj = (_targets[0] as dynamicClassRef).projection;			
			ZoomHeightFrom = (_targets[0] as dynamicClassRef).scaleX;
			ZoomWidthFrom = (target as dynamicClassRef).scaleY;
			xPos=_targets[0].x;
			yPos=_targets[0].y;
			if(this.dataProvider==''){
				this.dataProvider=arrDefaultZoom;
			}
			
		 	this.addEventListener(ListEvent.CHANGE, zoom);
		 }	
		 
		 /**
		 * @private
		 */
		 private function zoom(e:ListEvent):void{
		 	parEf=new Parallel();
			EffMove=new Move();
			EffZoom=new Zoom();
		 	if(e.target.selectedLabel=='World'){
		 		
		 	}else if(e.target.selectedLabel=='Africa'){
		 		EffMove.xFrom=xPos;
				EffMove.yFrom=yPos;
				EffMove.xTo=3;
				EffMove.yTo=75;
				EffMove.duration=2000;
				EffZoom.zoomWidthFrom=ZoomHeightFrom;
				EffZoom.zoomHeightFrom=ZoomWidthFrom;
				EffZoom.zoomWidthTo=0.8;
				EffZoom.zoomHeightTo=0.8;
				EffZoom.duration=2000;
				ZoomWidthFrom=0.8;
				ZoomHeightFrom=0.8;
				xPos=3;
				yPos=75;
		 	}else if(e.target.selectedLabel=='  -North'){
		 		
		 	}else if(e.target.selectedLabel=='  -Sub-Sahara'){
		 		
		 	}else if(e.target.selectedLabel=='  -Eastern'){
		 		
		 	}else if(e.target.selectedLabel=='  -Southern'){
		 		
		 	}else if(e.target.selectedLabel=='  -South-eastern'){
		 		
		 	}else if(e.target.selectedLabel=='  -Western'){
		 		
		 	}else if(e.target.selectedLabel=='CIS'){
		 		
		 	}else if(e.target.selectedLabel=='Europe'){
		 		
		 	}else if(e.target.selectedLabel=='NorthAmerica'){
		 		
		 	}else if(e.target.selectedLabel=='Oceania'){
		 		
		 	}else if(e.target.selectedLabel=='SouthAmerica'){
		 		
		 	}
		 	
		 	parEf.suspendBackgroundProcessing=true;
	  		parEf.addChild(EffMove);
			parEf.addChild(EffZoom);
			parEf.play([_targets[0]]);
		 }
		 
		 /**
		 * @private
		 */
		 private function setRect(ulx:Number,uly:Number, lrx:Number, lry:Number):Rectangle{
				var rect:Rectangle = new Rectangle(ulx, uly, lrx - ulx, lry - uly);
				return rect	
			}
	}
}