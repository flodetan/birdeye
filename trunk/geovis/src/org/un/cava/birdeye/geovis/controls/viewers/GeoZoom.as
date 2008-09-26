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
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.ComboBox;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Zoom;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import org.un.cava.birdeye.geovis.locators.LatLong;
	
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
			//proj = (_targets[0] as dynamicClassRef).projection;			
			ZoomHeightFrom = (_targets[0] as dynamicClassRef).scaleX;
			ZoomWidthFrom = (target as dynamicClassRef).scaleY;
			xPos=_targets[0].x;
			yPos=_targets[0].y;
			
			ori_ulx=_targets[0].x;
			ori_uly=_targets[0].y;
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
		 private function setZoom(e:ListEvent):void{
		 	parEf=new Parallel();
			EffMove=new Move();
			EffZoom=new Zoom();
			EffMove.duration=2000;
			EffZoom.duration=2000;
			
			EffMove.xFrom=xPos;
			EffMove.yFrom=yPos;
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
					
					trace(cursor.current[_ulxField] + ' / ' + cursor.current[_ulyField] + ' / ' + laloul.xval + ' / ' + laloul.yval)
					EffMove.xTo=laloul.xval;
					EffMove.yTo=laloul.yval;
					EffZoom.zoomWidthTo=ori_width/(lalolr.xval-laloul.xval);
					EffZoom.zoomHeightTo=ori_height/(lalolr.yval-laloul.yval);
					xPos=laloul.xval;
					yPos=laloul.yval;
					ZoomHeightFrom=ori_width/(lalolr.xval-laloul.xval);
					ZoomWidthFrom=ori_height/(lalolr.yval-laloul.yval);
				}
				i++;
				cursor.moveNext();
			}
			
		 	/*if(e.target.selectedLabel=='World'){
		 		EffMove.xFrom=xPos;
				EffMove.yFrom=yPos;
				EffMove.xTo=ori_ulx;
				EffMove.yTo=ori_uly;
				EffZoom.zoomWidthFrom=ZoomHeightFrom;
				EffZoom.zoomHeightFrom=ZoomWidthFrom;
				EffZoom.zoomWidthTo=ori_zoomWidth;
				EffZoom.zoomHeightTo=ori_zoomHeight;
				ZoomWidthFrom=ZoomHeightFrom;
				ZoomHeightFrom=ZoomWidthFrom;
				xPos=ori_ulx;
				yPos=ori_uly;
		 	}else if(e.target.selectedLabel=='Africa'){
		 		EffMove.xFrom=xPos;
				EffMove.yFrom=yPos;
				EffMove.xTo=3;
				EffMove.yTo=75;
				EffZoom.zoomWidthFrom=ZoomHeightFrom;
				EffZoom.zoomHeightFrom=ZoomWidthFrom;
				EffZoom.zoomWidthTo=1.2;
				EffZoom.zoomHeightTo=1.2;
				ZoomWidthFrom=1.2;
				ZoomHeightFrom=1.2;
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
		 		
		 	}*/
		 	
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