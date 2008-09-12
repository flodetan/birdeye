package org.un.cava.birdeye.geovis.controls.choropleth
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	import com.degrafa.Surface;
	import com.degrafa.paint.*;
	
	import flash.events.MouseEvent;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.utils.ArrayUtils;
	import org.un.cava.birdeye.geovis.utils.ColorBrewer;
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	
	/**
 	*  Define the default border color. 
 	*/
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default tick color. 
 	*/
	[Style(name="tickColor", type="uint", format="Color", inherit="no")]
	
	/**
 	*  Define the default text color. 
 	*/
	[Style(name="textColor", type="uint", format="Color", inherit="no")]
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[Inspectable("dataProvider")]
	[Inspectable("foidField")]
	[Inspectable("valueField")]
	[Inspectable("geoThumbStart")]
	[Inspectable("geoThumbEnd")]
	[Inspectable("geoScale")]
	[Inspectable("scheme")]
	[Inspectable("steps")]
	[Inspectable("startAtZero")]
	[Inspectable("Title")]
	
	public class GeoAutoGauge extends UIComponent
	{
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
		private var _valueField:String;
		
		/**
	     *  @private
	     */
		private var _stepsValues:Array;
		
		/**
	     *  @private
	     */
		private var _scheme:String;
		
		/**
	     *  @private
	     */
		private var _steps:int=3;
		
		/**
	     *  @private
	     */
		private var _stepsColors:Array;
		
		/**
	     *  @private
	     */
		private var _geoThumbStart:Boolean=true;
		
		/**
	     *  @private
	     */
		private var _geoThumbEnd:Boolean=true;
		
		/**
	     *  @private
	     */
		private var _geoScale:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _min:Number;
		
		/**
	     *  @private
	     */
		private var _max:Number;
		
		/**
	     *  @private
	     */
		private var _schemeChanged:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _stepsChanged:Boolean=false;
		
		/**
	     *  @private
	     */
		private var _startAtZero:Boolean=true;
		
		/**
	     *  @private
	     *  Storage for the targets property.
	     */
	    private var _targets:Array = [];
	    
		/**
	     *  @private
	     */
		private var _x:Number;
		
		/**
	     *  @private
	     */
		private var _y:Number;
		
		/**
	     *  @private
	     */
		private var myCoo:IGeometry;
		
		/**
	     *  @private
	     */
		private var gG:GeoGauge;
		
		/**
	     *  @private
	     */
		private var _title:String="";
		
		//--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
	    
	    //----------------------------------
	    //  dataProvider
	    //----------------------------------
	    
		/**
	     *  An object that contains the data that defined the flows.
	     *  When you assign a value to this property, the Flow class handles
	     *  the source data object as follows:
	     *  <p>
	     *  <ul><li>A String containing valid XML text is converted to an XMLListCollection.</li>
	     *  <li>An XMLNode is converted to an XMLListCollection.</li>
	     *  <li>An XMLList is converted to an XMLListCollection.</li>
	     *  <li>Any object that implements the ICollectionView interface is cast to
	     *  an ICollectionView.</li>
	     *  <li>An Array is converted to an ArrayCollection.</li>
	     *  <li>Any other type object is wrapped in an Array with the object as its sole
	     *  entry.</li></ul>
	     *  </p>
	     */
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
		
    	//----------------------------------
	    //  geoThumbStart
	    //----------------------------------

		[Inspectable(geoThumbStart="true,false")]
		/**
     	 *  setup a thumb that is not draggable at the beginning of the gauge.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default true
	     */
		public function set geoThumbStart(value:Boolean):void
		{
			_geoThumbStart = value;
		}
		
		/**
     	*  @private
     	*/
		public function get geoThumbStart():Boolean
		{
			return _geoThumbStart;
		}
		
		//----------------------------------
	    //  geoThumbEnd
	    //----------------------------------

		[Inspectable(geoThumbEnd="true,false")]
		/**
     	 *  setup a thumb that is not draggable at the end of the gauge.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default true
	     */
		public function set geoThumbEnd(value:Boolean):void
		{
			_geoThumbEnd = value;
		}
		
		/**
     	*  @private
     	*/
		public function get geoThumbEnd():Boolean
		{
			return _geoThumbEnd;
		}
		
		
		//----------------------------------
	    //  geoScale
	    //----------------------------------

		[Inspectable(geoScale="true,false")]
		/**
     	 *  Display the scale.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default false
	     */
		public function set geoTScale(value:Boolean):void
		{
			_geoScale = value;
		}
		
		/**
     	*  @private
     	*/
		public function get geoScale():Boolean
		{
			return _geoScale;
		}
		
		//----------------------------------
	    //  foidField
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the ISO country Code field.
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
		
		
		//----------------------------------
	    //  valueField
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the field that contain the value.
	     */
		public function set valueField(value:String):void{
			_valueField=value;
		} 
		
		/**
	     *  @private
	     */
		public function get valueField():String{
			return _valueField;
		} 
		
		//----------------------------------
	    //  scheme
	    //----------------------------------
	    
		[Bindable(event="schemeChanged")]
		[Inspectable(enumeration="YlGn,YlGnBu,GnBu,BuGn,PuBuGn,PuBu,BuPu,RdPu,PuRd,OrRd,YlOrRd,YlOrBr,Purples,Blues,Greens,Oranges,Reds,Greys,PuOr,BrBG,PRGn,PiYG,RdBu,RdGy,RdYlBu,Spectral,RdYlGn,Set3,Pastel1,Set1,Pastel2,Set2,Dark2,Paired")]
		
		 /**
     	 *  Define the type of scheme.
     	 *  Valid values are <code>"YlGn"</code> or <code>"YlGnBu"</code> or <code>"GnBu"</code> or <code>"BuGn"</code> or <code>"PuBuGn"</code> or <code>"PuBu"</code> or <code>"BuPu"</code> or <code>"RdPu"</code> or <code>"PuRd"</code> or <code>"OrRd"</code> or <code>"YlOrRd"</code> or <code>"YlOrBr"</code> or <code>"Purples"</code> or <code>"Blues"</code> or <code>"Greens"</code> or <code>"Oranges"</code> or <code>"Reds"</code> or <code>"Greys"</code> or <code>"PuOr"</code> or <code>"BrBG"</code> or <code>"PRGn"</code> or <code>"PiYG"</code> or <code>"RdBu"</code> or <code>"RdGy"</code> or <code>"RdYlBu"</code> or <code>"Spectral"</code> or <code>"RdYlGn"</code> or <code>"Set3"</code> or <code>"Pastel1"</code> or <code>"Set1"</code> or <code>"Pastel2"</code> or <code>"Set2"</code> or <code>"Dark2"</code> or <code>"Paired"</code>.
     	 * You can use the class ColorType to get the list of scheme.
	     */
		public function set scheme(value:String):void
		{
			_scheme = value;
			//dispatchEvent(new FlexEvent("schemeChanged"));
			_schemeChanged=true;
			invalidateDisplayList();
		}
		
		/**
     	*  @private
     	*/
		public function get scheme():String
		{
			return _scheme;
		}
		
		//----------------------------------
	    //  steps
	    //----------------------------------
	    [Bindable(event="stepsChanged")]
	    [Inspectable(enumeration="3,4,5,6,7,8")]
		
		/**
     	 *  Define the number of color's steps.
     	 * 
     	 * @default 3
     	 */
		public function set steps(value:int):void
		{
			_steps = value;
			//dispatchEvent(new FlexEvent("stepsChanged"));
			_stepsChanged=true;
			invalidateDisplayList();
		}
		
		/**
     	*  @private
     	*/	
		public function get steps():int
		{
			return _steps;
		}
		
		//----------------------------------
	    //  startAtZero
	    //----------------------------------

		[Inspectable(geoScale="true,false")]
		/**
     	 *  force the scale to start at 0.
     	 *  Valid values are <code>true</code> or <code>false</code>.
     	 *  @default true
	     */
		public function set startAtZero(value:Boolean):void
		{
			_startAtZero = value;
		}
		
		/**
     	*  @private
     	*/
		public function get startAtZero():Boolean
		{
			return _startAtZero;
		}
		
		
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
	
    	
    	//----------------------------------
	    //  title
	    //----------------------------------
		
		[Bindable]
		/**
     	 *  Define the title of the scale.
	     */
		public function set title(value:String):void{
			_title=value;
		} 
		
		/**
	     *  @private
	     */
		public function get title():String{
			return _title;
		} 
		
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoAutoGauge()
		{
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    	
    	/**
	     *  @private
	     */
		override public function set x(value:Number):void{
			_x=value;
		}
		
		/**
	     *  @private
	     */
		override public function set y(value:Number):void{
			_y=value;
		}
     	/**
	     *  @private
	     */
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(_valueField!=null && _dataProvider!=null){
				if(_schemeChanged || _stepsChanged){
					for(var k:int=0; k<this.numChildren; k++){
						this.removeChildAt(k);
					}
					var colB:ColorBrewer=new ColorBrewer();
			 		_stepsColors=colB.getColors(_scheme, _steps);
			 		_stepsValues=ArrayUtils.FindStepWithoutZero(_dataProvider, _valueField, _steps-1);
			 		if(startAtZero){
			 			_min=0;
			 		}else{
			 			_min=ArrayUtils.FindMaxValue(_dataProvider, _valueField)[0];
			 		}
			 		_max=ArrayUtils.FindMaxValue(_dataProvider, _valueField)[1];
					
					gG=new GeoGauge()
					gG.width=this.width;
					gG.height=this.height;
					gG.x=_x;
					gG.y=_y;
					gG.visible=this.visible;
					gG.minimumValue=_min;
					gG.maximumValue=_max;
					gG.setStyle("trackColor",_stepsColors[_stepsColors.length-1]);
					
					
					for(var i:int=0; i<=_stepsValues.length-1; i++){
						var th:GeoThumb=new GeoThumb();
						th.name="t"+i;
						th.setStyle('Color',_stepsColors[i]);
						th.draggable=true;
						th.value=_stepsValues[i];
						th.addEventListener(MouseEvent.MOUSE_DOWN,downEvent);
						th.addEventListener(MouseEvent.MOUSE_UP, stopEvent);
						gG.addChild(th);
					}
					
					AssignValues();
					
					if(_geoThumbStart){
						var thstart:GeoThumb=new GeoThumb();
						thstart.id="t"+(i+1);
						thstart.setStyle('Color','0x000000');
						thstart.draggable=false;
						thstart.value=_min;
						gG.addChild(thstart);
					}
					
					if(_geoThumbEnd){
						var thend:GeoThumb=new GeoThumb();
						thend.id="t"+(i+2);
						thend.setStyle('Color','0x000000');
						thend.draggable=false;
						thend.value=_max;
						gG.addChild(thend);
					}
					
					if(_geoScale){
						var scale:GeoScale=new GeoScale();
						scale.title=_title;
						scale.setStyle('textColor',getStyle('textColor'));
						gG.addChild(scale);
					}
					
					this.addChild(gG);
					
					_schemeChanged=false;
					_stepsChanged=false;
						
				}
			}
		}
	
		
			private function downEvent(e:MouseEvent):void {
				sortAC();
				GeoThumb(e.currentTarget).addEventListener(MouseEvent.MOUSE_MOVE,moveEvent);
            }

			private function moveEvent(e:MouseEvent):void{
				AssignValues();
				recolorizeMap();
			}
			
			private function AssignValues():void{
				for(var j:int=_stepsValues.length-1; j>=0; j--){
									var th1:GeoThumb=GeoThumb(gG.getChildByName('t'+j))
									if(j==0){
										th1.minimum=_min;
										th1.maximum=GeoThumb(gG.getChildByName('t'+(j+1))).value;
									}else if(j==_stepsValues.length-1){
										th1.minimum=(gG.getChildByName('t'+(j-1)) as GeoThumb).value;
										th1.maximum=GeoThumb(th1).value;
										th1.allowDragToTheEnd=true;
									}else{
										th1.minimum=GeoThumb(gG.getChildByName('t'+(j-1))).value;
										th1.maximum=GeoThumb(gG.getChildByName('t'+(j+1))).value;
									}
								}	
			}
			
			private function stopEvent(e:MouseEvent):void{
				GeoThumb(e.currentTarget).removeEventListener(MouseEvent.MOUSE_MOVE, moveEvent);
			}
			
			public function sortAC():void {
				var sortA:Sort = new Sort();
			    sortA.fields=[new SortField(_foidField, false, true)];
		    	_dataProvider.sort=sortA;
		    	_dataProvider.refresh();
			}

			private function recolorizeMap():void{
				var surf:Surface=Surface(_targets[0].getChildByName("Surface"));
				var curs:IViewCursor=_dataProvider.createCursor();
				
				for (var l:int=0; l<=surf.numChildren-1; l++){
					if(surf.getChildAt(l) is GeometryGroup){
						var obj:Object=new Object();
   						obj[_foidField]=GeometryGroup(surf.getChildAt(l)).name;
   						if(curs.findAny(obj)){
							var val:Number=curs.current[_valueField];
							if(val<=GeoThumb(gG.getChildByName('t0')).value){
								GeometryGroup(surf.getChildAt(l)).geometryCollection.getItemAt(0).fill=new SolidFill(_stepsColors[0],1);
							}else if(val>GeoThumb(gG.getChildByName('t' + (_steps-2))).value){
								GeometryGroup(surf.getChildAt(l)).geometryCollection.getItemAt(0).fill=new SolidFill(_stepsColors[_steps-1],1);
							}else{
								for (var k:int=0; k<_steps-2;k++){
									if(val>GeoThumb(gG.getChildByName('t' + k)).value && val<=GeoThumb(gG.getChildByName('t' + (k+1))).value){
										GeometryGroup(surf.getChildAt(l)).geometryCollection.getItemAt(0).fill=new SolidFill(_stepsColors[k+1],1);
									}
								}
							}
										
							
						}
					}
				}
				
				
			}
			
	}
}