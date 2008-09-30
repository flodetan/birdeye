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
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.ComboBox;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Zoom;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("target")]
	[Inspectable("labelField")]
	[Inspectable("ulx")]
	[Inspectable("uly")]
	[Inspectable("lrx")]
	[Inspectable("lry")]
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
		private var ori_ulx:Number;
		
		/**
	     *  @private
	     */
		private var ori_uly:Number;
		
		/**
	     *  @private
	     */
		private var ori_lrx:Number;
		
		/**
	     *  @private
	     */
		private var ori_lry:Number;
		
		/**
	     *  @private
	     */
		private var ori_zoomWidth:Number;
		
		/**
	     *  @private
	     */
		private var ori_zoomHeight:Number;
		
		/**
	     *  @private
	     */
		private var ori_width:Number;
		
		/**
	     *  @private
	     */
		private var ori_height:Number;
		
		/**
	     *  @private
	     */
	    private var _dataProvider:ICollectionView;
	    
	    /**
	     *  @private
	     */
		private var _labelField:String="label";
		
		/**
	     *  @private
	     */
		private var _ulxField:String="ulx";
		
		/**
	     *  @private
	     */
		private var _ulyField:String="uly";
		
		/**
	     *  @private
	     */
		private var _lrxField:String="lrx";
		
		/**
	     *  @private
	     */
		private var _lryField:String="lry";
		
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
		{label:"North America",ulx:"-150", uly:"40", lrx:"10", lry:"40"},
		{label:"South America",ulx:"-120", uly:"35", lrx:"-30", lry:"-60"},
		{label:"Oceania",ulx:"100", uly:"15", lrx:"180", lry:"-50"}]);
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
	    
		[Bindable]
    	//----------------------------------
	    //  ulxField
	    //----------------------------------

		/**
     	 * The ulxField is the field that contain the x data for the upper left corner.
     	 */
		public function set ulxField(value:String):void{
			_ulxField=value;
		}
		
		/**
	     *  @private
	     */
		public function get ulxField():String{
			return _ulxField;
		}
		
		[Bindable]
    	//----------------------------------
	    //  ulyField
	    //----------------------------------

		/**
     	 * The ulyField is the field that contain the y data for the upper left corner.
     	 */
		public function set ulyField(value:String):void{
			_ulyField=value;
		}
		
		/**
	     *  @private
	     */
		public function get ulyField():String{
			return _ulyField;
		}
		
		[Bindable]
    	//----------------------------------
	    //  lrxField
	    //----------------------------------

		/**
     	 * The lrxField is the field that contain the x data for the lower right corner.
     	 */
		public function set lrxField(value:String):void{
			_lrxField=value;
		}
		
		/**
	     *  @private
	     */
		public function get lrxField():String{
			return _lrxField;
		}
		
		[Bindable]
    	//----------------------------------
	    //  lryField
	    //----------------------------------

		/**
     	 * The lryField is the field that contain the y data for the lower right corner.
     	 */
		public function set lryField(value:String):void{
			_lryField=value;
		}
		
		/**
	     *  @private
	     */
		public function get lryField():String{
			return _lryField;
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
			
			xPos=ori_ulx=_targets[0].x;
			yPos=ori_uly=_targets[0].y;
			ori_lrx=_targets[0].x + _targets[0].width;
			ori_lry=_targets[0].y + _targets[0].height;
			ori_width=_targets[0].width;
			ori_height=_targets[0].height;
			
			ori_zoomWidth=(_targets[0] as dynamicClassRef).scaleX;
			ori_zoomHeight=(_targets[0] as dynamicClassRef).scaleY;
			
			if(this.dataProvider==''){
				this.dataProvider=arrDefaultZoom;
			}
			
			setDataProvider(this.dataProvider);
			
			_labelField=this.labelField;
			
			
		 	this.addEventListener(ListEvent.CHANGE, zoom);
		 	_targets[0].addEventListener(GeoProjEvents.PROJECTION_CHANGED, projChanged);
		 }	
		 
		 /**
		 * @private
		 */
		 private function zoom(e:ListEvent):void{
		 	callLater(setZoom, [e])
		 }
		 
		 /**
		 * @private
		 */
		 private function projChanged(e:GeoProjEvents):void{
		 		proj=e.projection;
		 		
		 		this.selectedIndex=0;
		 		_targets[0].scaleX=0.942;
		 		_targets[0].scaleY=0.942;
		 		_targets[0].x=0;
		 		_targets[0].y=20;
		 		parEf=new Parallel();
				EffMove=new Move();
				EffZoom=new Zoom();
				EffMove.duration=1;
				EffZoom.duration=1;
				EffMove.xFrom=xPos;
				EffMove.yFrom=yPos;
				EffMove.xTo=ori_ulx;
				EffMove.yTo=ori_uly;
				EffZoom.zoomWidthFrom=ZoomWidthFrom;
				EffZoom.zoomHeightFrom=ZoomHeightFrom;
				EffZoom.zoomWidthTo=0.942//ori_zoomWidth;
				EffZoom.zoomHeightTo=0.942//ori_zoomHeight;
				ZoomWidthFrom=0.942//ZoomWidthFrom;
				ZoomHeightFrom=0.942//ZoomHeightFrom;
				xPos=ori_ulx;
				yPos=ori_uly;
				parEf.suspendBackgroundProcessing=true;
		  		parEf.addChild(EffMove);
				parEf.addChild(EffZoom);
				parEf.play([_targets[0]]);
				
		 }
		 
		 /**
		 * @private
		 */
		 private function setZoom(e:ListEvent):void{
		 	parEf=new Parallel();
			EffMove=new Move();
			EffZoom=new Zoom();
			EffMove.duration=1500;
			EffZoom.duration=1500;
			
			/*trace('x: ' + _targets[0].x  + 'y: ' + _targets[0].y)
			EffMove.xFrom=_targets[0].x;
			EffMove.yFrom=_targets[0].y; //yPos;
			EffZoom.zoomWidthFrom=ZoomHeightFrom;
			EffZoom.zoomHeightFrom=ZoomWidthFrom;
			
			//var xvalue:Number = lalo.xval;
			//var yvalue:Number = lalo.yval;
					
			var i:int=0;
			var cursor:IViewCursor = _dataProvider.createCursor();
				
			while(!cursor.afterLast){
				if(e.target.selectedLabel==cursor.current[_labelField]){
					var laloul:LatLong=new LatLong();
					laloul.lat=cursor.current[_ulyField];
					laloul.long=cursor.current[_ulxField];
					laloul.target=_targets[0];
					
					var lalolr:LatLong=new LatLong();
					lalolr.lat=cursor.current[_lryField];
					lalolr.long=cursor.current[_lrxField];
					lalolr.target=_targets[0];
					
					trace(cursor.current[_labelField] + ' / ' + cursor.current[_ulxField] + ' / ' + cursor.current[_ulyField] + ' / ' + laloul.xval + ' / ' + laloul.yval)
					EffMove.xTo=Math.abs(xPos)-laloul.xval;
					EffMove.yTo=Math.abs(yPos)-laloul.yval;
					EffZoom.zoomWidthTo=ori_width/(lalolr.xval-laloul.xval);
					EffZoom.zoomHeightTo=ori_height/(lalolr.yval-laloul.yval);
					xPos=Math.abs(xPos)-laloul.xval;
					yPos=Math.abs(yPos)-laloul.yval;
					ZoomHeightFrom=ori_width/(lalolr.xval-laloul.xval);
					ZoomWidthFrom=ori_height/(lalolr.yval-laloul.yval);
				}
				i++;
				cursor.moveNext();
			}*/
			if(proj=='Miller cylindrical'){
				if(e.target.selectedLabel=='World'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=ori_ulx;
					EffMove.yTo=ori_uly;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=0.942//ori_zoomWidth;
					EffZoom.zoomHeightTo=0.942//ori_zoomHeight;
					ZoomWidthFrom=0.942//ZoomWidthFrom;
					ZoomHeightFrom=0.942//ZoomHeightFrom;
					xPos=ori_ulx;
					yPos=ori_uly;
			 	}else if(e.target.selectedLabel=='Africa'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-640;
					EffMove.yTo=-360;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.5;
					EffZoom.zoomHeightTo=1.5;
					ZoomWidthFrom=1.5;
					ZoomHeightFrom=1.5;
					xPos=-640;
					yPos=-360;
			 	}else if(e.target.selectedLabel=='  -North'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1050;
					EffMove.yTo=-500;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1050;
					yPos=-500;
			 	}else if(e.target.selectedLabel=='  -Sub-Sahara'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1020;
					EffMove.yTo=-600;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.7;
					EffZoom.zoomHeightTo=1.7;
					ZoomWidthFrom=1.7;
					ZoomHeightFrom=1.7;
					xPos=-1020;
					yPos=-600;
			 	}else if(e.target.selectedLabel=='Asia'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-700;
					EffMove.yTo=-100;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.3;
					EffZoom.zoomHeightTo=1.3;
					ZoomWidthFrom=1.3;
					ZoomHeightFrom=1.3;
					xPos=-700;
					yPos=-100;
			 	}else if(e.target.selectedLabel=='  -Eastern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-2000;
					EffMove.yTo=-500;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.9;
					EffZoom.zoomHeightTo=1.9;
					ZoomWidthFrom=1.9;
					ZoomHeightFrom=1.9;
					xPos=-2000;
					yPos=-500;
			 	}else if(e.target.selectedLabel=='  -Southern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1500;
					EffMove.yTo=-450;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1500;
					yPos=-450;
			 	}else if(e.target.selectedLabel=='  -South-eastern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1800;
					EffMove.yTo=-500;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1800;
					yPos=-500;
			 	}else if(e.target.selectedLabel=='  -Western'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1800;
					EffMove.yTo=-480;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=2;
					EffZoom.zoomHeightTo=2;
					ZoomWidthFrom=2;
					ZoomHeightFrom=2;
					xPos=-1800;
					yPos=-480;
			 	}else if(e.target.selectedLabel=='CIS'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-900;
					EffMove.yTo=0;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=-900;
					yPos=0;
			 	}else if(e.target.selectedLabel=='Europe'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1300;
					EffMove.yTo=-300;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.9;
					EffZoom.zoomHeightTo=1.9;
					ZoomWidthFrom=1.9;
					ZoomHeightFrom=1.9;
					xPos=-1300;
					yPos=-300;
			 	}else if(e.target.selectedLabel=='North America'){
			 		/*EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=3;
					EffMove.yTo=65;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=3;
					yPos=65;*/
					EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1;
					EffMove.yTo=-50;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.3;
					EffZoom.zoomHeightTo=1.3;
					ZoomWidthFrom=1.3;
					ZoomHeightFrom=1.3;
					xPos=-1;
					yPos=-50;
			 	}else if(e.target.selectedLabel=='Oceania'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1750;
					EffMove.yTo=-750;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.7;
					EffZoom.zoomHeightTo=1.7;
					ZoomWidthFrom=1.7;
					ZoomHeightFrom=1.7;
					xPos=-1750;
					yPos=-750;
			 	}else if(e.target.selectedLabel=='South America'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-150;
					EffMove.yTo=-400;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=-150;
					yPos=-400;
			 	}
			}else{
			 	if(e.target.selectedLabel=='World'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=ori_ulx;
					EffMove.yTo=ori_uly;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=0.942//ori_zoomWidth;
					EffZoom.zoomHeightTo=0.942//ori_zoomHeight;
					ZoomWidthFrom=0.942//ZoomWidthFrom;
					ZoomHeightFrom=0.942//ZoomHeightFrom;
					xPos=ori_ulx;
					yPos=ori_uly;
			 	}else if(e.target.selectedLabel=='Africa'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-640;
					EffMove.yTo=-220;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.5;
					EffZoom.zoomHeightTo=1.5;
					ZoomWidthFrom=1.5;
					ZoomHeightFrom=1.5;
					xPos=-640;
					yPos=-220;
			 	}else if(e.target.selectedLabel=='  -North'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1050;
					EffMove.yTo=-250;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1050;
					yPos=-250;
			 	}else if(e.target.selectedLabel=='  -Sub-Sahara'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1020;
					EffMove.yTo=-350;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.7;
					EffZoom.zoomHeightTo=1.7;
					ZoomWidthFrom=1.7;
					ZoomHeightFrom=1.7;
					xPos=-1020;
					yPos=-350;
			 	}else if(e.target.selectedLabel=='Asia'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-700;
					EffMove.yTo=0;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.3;
					EffZoom.zoomHeightTo=1.3;
					ZoomWidthFrom=1.3;
					ZoomHeightFrom=1.3;
					xPos=-700;
					yPos=0;
			 	}else if(e.target.selectedLabel=='  -Eastern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-2000;
					EffMove.yTo=-300;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.9;
					EffZoom.zoomHeightTo=1.9;
					ZoomWidthFrom=1.9;
					ZoomHeightFrom=1.9;
					xPos=-2000;
					yPos=-300;
			 	}else if(e.target.selectedLabel=='  -Southern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1500;
					EffMove.yTo=-250;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1500;
					yPos=-250;
			 	}else if(e.target.selectedLabel=='  -South-eastern'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1800;
					EffMove.yTo=-300;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.8;
					EffZoom.zoomHeightTo=1.8;
					ZoomWidthFrom=1.8;
					ZoomHeightFrom=1.8;
					xPos=-1800;
					yPos=-300;
			 	}else if(e.target.selectedLabel=='  -Western'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1800;
					EffMove.yTo=-280;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=2;
					EffZoom.zoomHeightTo=2;
					ZoomWidthFrom=2;
					ZoomHeightFrom=2;
					xPos=-1800;
					yPos=-280;
			 	}else if(e.target.selectedLabel=='CIS'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-900;
					EffMove.yTo=0;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=-900;
					yPos=0;
			 	}else if(e.target.selectedLabel=='Europe'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1300;
					EffMove.yTo=-40;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.9;
					EffZoom.zoomHeightTo=1.9;
					ZoomWidthFrom=1.9;
					ZoomHeightFrom=1.9;
					xPos=-1300;
					yPos=-40;
			 	}else if(e.target.selectedLabel=='North America'){
			 		/*EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=3;
					EffMove.yTo=65;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=3;
					yPos=65;*/
					EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1;
					EffMove.yTo=50;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.3;
					EffZoom.zoomHeightTo=1.3;
					ZoomWidthFrom=1.3;
					ZoomHeightFrom=1.3;
					xPos=-1;
					yPos=50;
			 	}else if(e.target.selectedLabel=='Oceania'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-1750;
					EffMove.yTo=-500;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.7;
					EffZoom.zoomHeightTo=1.7;
					ZoomWidthFrom=1.7;
					ZoomHeightFrom=1.7;
					xPos=-1750;
					yPos=-500;
			 	}else if(e.target.selectedLabel=='South America'){
			 		EffMove.xFrom=xPos;
					EffMove.yFrom=yPos;
					EffMove.xTo=-150;
					EffMove.yTo=-280;
					EffZoom.zoomWidthFrom=ZoomWidthFrom;
					EffZoom.zoomHeightFrom=ZoomHeightFrom;
					EffZoom.zoomWidthTo=1.4;
					EffZoom.zoomHeightTo=1.4;
					ZoomWidthFrom=1.4;
					ZoomHeightFrom=1.4;
					xPos=-150;
					yPos=-280;
			 	}
		 }
		 	parEf.suspendBackgroundProcessing=true;
	  		parEf.addChild(EffMove);
			parEf.addChild(EffZoom);
			parEf.play([_targets[0]]);
		 }
		 
		 /**
     	*  @private
     	*/
		private function setDataProvider(value:Object):void
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
		
		 /**
		 * @private
		 */
		 private function setRect(ulx:Number,uly:Number, lrx:Number, lry:Number):Rectangle{
				var rect:Rectangle = new Rectangle(ulx, uly, lrx - ulx, lry - uly);
				return rect	
			}
	}
}