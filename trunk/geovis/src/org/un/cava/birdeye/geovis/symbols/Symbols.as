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
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import flash.xml.XMLNode;
	import mx.core.IFactory;
		
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.containers.Box;
	
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	import org.un.cava.birdeye.geovis.projections.Projections;
	import org.un.cava.birdeye.qavis.sparklines.*;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("dataProvider")]
	[Inspectable("foidField")]
	[Inspectable("itemRenderer")]
	public class Symbols extends Box//UIComponent
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
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		private function createSymbolsDelayed(e:FlexEvent):void{
			createSymbols();
			this.parent.addEventListener(GeoProjEvents.PROJECTION_CHANGED, projChanged);
		}
		
		/**
	     *  @private
	     */
		private function createSymbols ():void{
				
						
				var dynamicClassName:String=getQualifiedClassName(this.parent);
				var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
				var proj:String=(this.parent as dynamicClassRef).projection;
				var region:String=(this.parent as dynamicClassRef).region;
				var GeoData:Object=Projections.getData(proj,region);
				
				Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).addChild(this);
								
				var cooFoid:String;
				var i:int=0;
				var cursor:IViewCursor = _dataProvider.createCursor();
				
				while(!cursor.afterLast)
				{
					
					var foidField:String=cursor.current[_foidField];
					cooFoid=GeoData.getBarryCenter(foidField);
					var arrPosFoid:Array=cooFoid.split(',');
					
					if(foidField!=""){
							var geom:GeometryGroup=GeometryGroup(Surface((this.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(foidField));
					
					if(geom!=null){
						var myScaleX:Number=(this.parent as dynamicClassRef).scaleX;
						var myScaleY:Number=(this.parent as dynamicClassRef).scaleY;
			
						this.x=(arrPosFoid[0]-this.getChildAt(0).width/2)*myScaleX;
						this.y=(arrPosFoid[1]-this.getChildAt(0).height/2)*myScaleY;
						
						drawSymbols();
					}
					}
					i++;
					cursor.moveNext();
					
				} 
				
		}	
		
		private function drawSymbols():void{
			
			var mySymbol:UIComponent = null;
							
			if(_itemRenderer != null) {
						mySymbol = _itemRenderer.newInstance();
						} else {
						mySymbol = new UIComponent();
						}
			this.addChild(mySymbol);
			refresh();
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
			this.invalidateDisplayList();
		}

		
		
	}
}