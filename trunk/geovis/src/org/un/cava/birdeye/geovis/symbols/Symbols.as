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


package org.un.cava.birdeye.geovis.symbols
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.listClasses.BaseListData;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.qavis.sparklines.*;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("dataProvider")]
	[Inspectable("foidField")]
	[Inspectable("itemRenderer")]
	public class Symbols extends UIComponent
	{	
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    
	    
	    /**
	     *  @private
	     */
	    private var _dataProvider:ICollectionView;
	    /**
	     *  @private
	     */
		private var _foidField:String;
		/**
	     *  @private
	     */
		private var _isBaseMapComplete:Boolean=false;
	    
	    /**
	     *  @private
	     */
	    [Bindable]
		private var _visible:Boolean=true;
		
		/**
	     *  @private
	     */
	  	private var surf:Surface;
    //----------------------------------
    //  itemRenderer
    //----------------------------------

    /**
     *  @private
     *  Storage for itemRenderer property.
     */
    private var _itemRenderer:IFactory;
    
    

    [Inspectable(category="Data")]
	/**
     *  IFactory that generates the instances that displays the data for the
     *  drop-down list of the control.  You can use this property to specify 
     *  a custom item renderer for the drop-down list.
     *
     *  <p>The control uses a List control internally to create the drop-down
     *  list.
     *  The default item renderer for the List control is the ListItemRenderer
     *  class, which draws the text associated with each item in the list, 
     *  and an optional icon. </p>
     *
     *  @see mx.controls.List
     *  @see mx.controls.listClasses.ListItemRenderer
     */
    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }

    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        _itemRenderer = value;

    }

	    /**
	     *  @private
	     */
		private var _isRemove:Boolean=false;
		
		/**
	     *  @private
	     */
		private var geom:GeometryGroup;
		
		/**
	     *  @private
	     */
		private var objToDel:DisplayObject;
		
		/**
	     *  @private
	     */
		public var wcData:Object;
		
		/**
	     *  @private
	     */
	     private var _isProjChanged:Boolean=false;
		
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
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
		
	    [Bindable]
    	//----------------------------------
	    //  foidField
	    //----------------------------------

		/**
     	 * The foidField is a 3 letters country ISO code for the world map, and 2 letters states ISO code for the US map.
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
		
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function Symbols()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, createSymbolsDelayed);
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
      		
		      if(_isProjChanged || _isBaseMapComplete){
		      	if(surf){
		      		for(var i:int=surf.numChildren-1; i>=0; i--){
							if(surf.getChildAt(i).name.toString().substr(0,10)=='GeoSymbols'){
								surf.removeChildAt(i);
							}
						}
		      	}
      			createSymbols();
      			_isProjChanged=false;
      			_isBaseMapComplete=false;
      		  }
      		  
      	}
      	
      	/**
		 * @private
		 */
		override public function set visible(value:Boolean):void 
		{
			_visible=value;
    		if(surf){
    			for (var i:int = 0; i < surf.numChildren; i++) {
    				if(surf.getChildAt(i).name.toString().substr(0,10)=='GeoSymbols'){
    					surf.getChildAt(i).visible=_visible;
    				}
    			}
    		}
    	}
    	
    	
	
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		private function createSymbolsDelayed(e:FlexEvent):void{
			createSymbols();
			this.parent.addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, baseMapComplete);
		}
		
		/**
	     *  @private
	     */
		private function createSymbols ():void{
				var dynamicClassName:String=getQualifiedClassName(this.parent);
				var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
				var proj:String=(this.parent as dynamicClassRef).projection;
				var region:String=(this.parent as dynamicClassRef).region;
				
				var cooFoid:String;
				var i:int=0;
				var cursor:IViewCursor = _dataProvider.createCursor();
				
				while(!cursor.afterLast)
				{
					var mySymbol:UIComponent = null;
					var myIR:IDataRenderer;
					if(foidField!=""){
						var GeoData:Object=Projections.getData(proj,region);
						var foidField:String=cursor.current[_foidField];
						cooFoid=GeoData.getBarryCenter(foidField);
						var arrPosFoid:Array=cooFoid.split(',');
						
						var geom:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(foidField));
						surf=Surface((this.parent as DisplayObjectContainer).getChildByName("Surface"));
						
						if(geom!=null){
							var myScaleX:Number=(this.parent as dynamicClassRef).scaleX;
							var myScaleY:Number=(this.parent as dynamicClassRef).scaleY;
							
							if(_itemRenderer != null) {
								myIR=_itemRenderer.newInstance()
								myIR.data = cursor.current ; 
								mySymbol=(myIR as UIComponent);
							} else {
								mySymbol = new UIComponent();
							}
							mySymbol.x=(arrPosFoid[0]-mySymbol.width/2)*myScaleX;
							mySymbol.y=(arrPosFoid[1]-mySymbol.height/2)*myScaleY;
							mySymbol.name="GeoSymbols";
							mySymbol.visible=_visible;
						}
						surf.addChild(mySymbol);
						refresh();
					}
					i++;
					cursor.moveNext();
					
				} 
				
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
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	invalidateDisplayList();
        }
        
        /**
		 * @inheritDoc
		 * */
		public function refresh():void {
			/* this forces the next call of updateDisplayList() */
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