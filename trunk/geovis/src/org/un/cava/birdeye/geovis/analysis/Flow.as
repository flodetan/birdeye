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
	import com.degrafa.Surface;
	import com.degrafa.GeometryGroup;

	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.*;
	import flash.xml.XMLNode;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.projections.Projections;
	/**
	* Flow annotations are used to show the movement or relation of objects 
	* from one location to another.
	**/
	[Inspectable("dataProvider")]
	[Inspectable("dataField")]	
	[Inspectable("showDataTips")]
	[Inspectable("fromField")]
	[Inspectable("toField")]
	[Inspectable("valueField")]
	public class Flow extends UIComponent
	{
		
		
		private var flows:UIComponent;
		private var cntrlpt:UIComponent;
		private var markers:UIComponent;
		private var cntrlpoint:Point;
		private var mid:Point;
		private var ArrMarkers:Array=new Array();
		private var dicMarkers:Dictionary= new Dictionary();
		private var _dataProvider:ICollectionView;
		private var _valueField:String;
		private var _fromField:String;
		private var _toField:String;
		private var _showDataTips:Boolean=false;
		private var dynamicClassName:String;
		private var dynamicClassRef:Class;
		[Bindable]
		private var _scaleY:Number;
		[Bindable]
		private var _scaleX:Number;
	  	private var blnInit:Boolean=true;
	  	private var surf:Surface;
	  	private var proj:String;
		private var region:String;
		
		[Inspectable(showDataTips="true,false")]
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
		}
		
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}
		
		public function get dataProvider():Object
		{
			return this._dataProvider;
		}
		
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
				value = new XMLListCollection(value.children() as XMLList);
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
		
		public function set valueField(value:String):void
		{
			_valueField = value;
		}
		
		public function set fromField(value:String):void
		{
			_fromField = value;
		}
		
		public function get fromField():String
		{
			return _fromField;
		}
		
		public function set toField(value:String):void
		{
			_toField = value;
		}
		
		public function get toField():String
		{
			return _toField;
		}
		
		public function Flow()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createFlows);
		}

		
		 private function createFlows(event:FlexEvent):void{//
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
				var desc:String=cursor.current[_valueField];
				cooFrom=GeoData.getBarryCenter(fromKey);
				var arrPosFrom:Array=cooFrom.split(',');
				cooTo=GeoData.getBarryCenter(toKey);
				var arrPosTo:Array=cooTo.split(',')
						
				var geom1:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(fromKey));
				var geom2:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(toKey));
				
				if(geom1!=null && geom2!=null){
					drawFlow(arrPosFrom,arrPosTo, fromKey, toKey, desc);
				}
				    
				i++;
				cursor.moveNext();  
			}  
    	}
   
  
	   	private function drawFlow(cooFrom:Array, cooTo:Array, fromDest:String, toDest:String, description:String):void{
	   		flows = new UIComponent();
	   	  	flows.name="flow"+fromDest+toDest;
		  	cntrlpt = new UIComponent();
		  	markers = new UIComponent();
		  	cntrlpoint = new Point();
		  	mid = new Point();
		  
		  	_scaleX=(this.parent as dynamicClassRef).scaleX;
	  		_scaleY=(this.parent as dynamicClassRef).scaleY;
		 	flows.scaleX=_scaleX;
	  		flows.scaleY=_scaleY;
	  		cntrlpt.scaleX=_scaleX;
	  		cntrlpt.scaleY=_scaleY;
	  		surf.scaleX=_scaleX;
	  		surf.scaleY=_scaleY;
	  		
			//From
		      var strFrom:String=fromDest;
		      var p1:Point = new Point(cooFrom[0], cooFrom[1]);
		      surf.addChild(flows);
		    
		     // To
		      var strTo:String=toDest;
		      var p2:Point = new Point(cooTo[0], cooTo[1]);
		    
		     // Mid
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
		      flows.graphics.lineStyle(2, 0x333333, .6);  // thickness (flow), color, alpha
		      flows.graphics.beginFill(0x333333, .6);
		      flows.graphics.curveTo(cntrlpoint.x, cntrlpoint.y, p2.x, p2.y);
		      // target back to source + flow value (or static constant as 10)
		      flows.graphics.curveTo(cntrlpoint.x, cntrlpoint.y, p1.x, p1.y+10);
		      flows.graphics.endFill();
		      flows.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverEvent);
		      flows.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOutEvent);
		      if(_showDataTips==true){
		      	flows.toolTip=description;//"From: " + strFrom + "\r" + "To: " + strTo
		      }
		      // control point
		      // need to add drag and drop capability here
		      // drop point of rect becomes new control point for flow     
		      
		      // guide lines
		      cntrlpt.graphics.lineStyle(1, 0xFF0000, .3);
		      cntrlpt.graphics.moveTo(cntrlpoint.x, cntrlpoint.y);
		      cntrlpt.graphics.lineTo(p1.x, p1.y);
		      cntrlpt.graphics.moveTo(cntrlpoint.x, cntrlpoint.y);
		      cntrlpt.graphics.lineTo(p2.x, p2.y);   
	   }
   		
   		private function handleMouseOverEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=true;
        	eventObj.target.buttonMode=true;
		}
		
		private function handleMouseOutEvent(eventObj:MouseEvent):void {
        	eventObj.target.useHandCursor=false;
        	eventObj.target.buttonMode=false;
        }
	/*override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		trace('updateDisplayList');
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		graphics.clear()
		super.addEventListener(FlexEvent.CREATION_COMPLETE,createFlows);
	}*/
}
}