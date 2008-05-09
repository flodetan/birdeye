package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import flash.filters.DropShadowFilter;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	[Inspectable("dataProvider")]
	[Inspectable("gradientColors")]
	[Inspectable("colors")]
	[Inspectable("dataField")]	
	[Inspectable("showDataTips")]	
	public class PieSpark extends UIComponent
	{
			private var values:Array;
			private var interpolate: Object;
			private var GG:GeometryGroup;
			//private var _dataProvider:ArrayCollection;
			private var _dataProvider:ICollectionView//ListCollectionView;// = new ArrayCollection();
			private var _colors:Array;
			private var _gradientColors:Array;
			private var _dataField:String;
			private var _showDataTips:Boolean=false;
			public var Surf:Surface;
			
			/*[Bindable]
			public var dataProvider:ArrayCollection;
			*/
			[Bindable]
			private var tweenDataProvider:ArrayCollection;
			
			private static var SLICES:int = 0;
			
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
			trace('type:'+typeof(value));
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
				value = new XMLListCollection(value as XMLList);
			}
			else if(value is Array)
			{
				value = new ArrayCollection(value as Array);
			}
			
			if(value is XML)
			{
				var list:XMLList = new XMLList();
				list += value;
				this._dataProvider = new XMLListCollection(list.children());//.attribute('unit2')
				trace(_dataProvider);
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
		
		
		public function set colors(value:Array):void
		{
			_colors = value;
		}
		
		public function set gradientColors(value:Array):void
		{
			_gradientColors = value;
		}
		
		public function set dataField(value:String):void
		{
			_dataField = value;
		}
			
		public function PieSpark()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createPie);
		}
	
			private function createPie(e:FlexEvent):void
			{
				Surf=new Surface();
			
				var DSF:DropShadowFilter=new DropShadowFilter()
				DSF.color=0x000000;
				DSF.alpha=0.5;
				
				GG=new GeometryGroup();
				GG.filters=[DSF];
				
				Surf.addChild(GG);
				this.addChild(Surf);
				
				createSlices();
			
			}
			private function createSlices():void 
			{
				interpolate = new Object();
				var data:Array = new Array();
				var total:Number = 0;
				var i:int=0;
				
				var cursor:IViewCursor = _dataProvider.createCursor();
				while(!cursor.afterLast)
				{
					var slice:PieSparkSlice = createSlice(cursor.current[_dataField],Surf);
					data[i] = cursor.current[_dataField];
					total += Number(data[i]);
				    trace('wjm2: '+ cursor.current[_dataField]);
				    i++;
				    cursor.moveNext();      

				}

				/*for (var i:int=0;i<_dataProvider.length;i++)
				{
					
					trace('wjm'+_dataProvider.getItemAt(i))
					trace('wjm'+_dataProvider.getItemAt(i)[_dataField])
					var slice:PieSparkSlice = createSlice(i,Surf);
					data[i] = _dataProvider.getItemAt(i)[_dataField];
					total += data[i];
				
				}*/
				SLICES = _dataProvider.length;
				
				redraw(data, total);
			}
			
			private function createSlice(ttips:String, surf:Surface):PieSparkSlice 
			{
				var c:int;
				var slice:PieSparkSlice = new PieSparkSlice(this.width,this.height,_dataField,_showDataTips,ttips,surf);
				slice.x = 0;
				slice.y = 0;
				var fill:LinearGradientFill = new LinearGradientFill();
				var g:Array = new Array();
				var i:int = GG.numChildren;
				if(_gradientColors==null){
					var colorItem:SolidFill;
					if(_colors==null)
					{
						colorItem=new SolidFill(randColor());
					}else{
						c = Math.floor(((i/_colors.length) - int(i/_colors.length)) * _colors.length);
						colorItem=new SolidFill(uint(_colors[c]));
					}
					slice.Arc.fill = colorItem;
				}else{
					c = Math.floor(((i/_gradientColors.length) - int(i/_gradientColors.length)) * _gradientColors.length);
					g.push(new GradientStop(_gradientColors[c][0], 1));
					g.push(new GradientStop(_gradientColors[c][1], 1));
					fill.gradientStops = g;
					slice.Arc.fill = fill;
				}
				GG.addChild(slice);
				return slice;
				
			}
			
			/*
			redraw the pie slies
			*/
			private function redraw(data:Array, total:Number):void 
			{
				var angle:Number = 0;
trace(data)
trace(total)
trace(SLICES)
				for (var i:int=0;i<SLICES;i++)
				{
					var value:Number = data[i];
					var arc:Number = ((((value/total)*100)*360)/100);
					var slice:PieSparkSlice = GG.getChildAt(i) as PieSparkSlice;
					slice.Arc.startAngle = angle;
					slice.Arc.arc = arc;
					slice.refresh();
					angle += arc;
				}
				GG.draw(null,null);	
			}
			
			private function randColor():uint
			{	
				var red:Number = Math.random() * 255;	
				var green:Number = Math.random() * 255;	
				var blue:Number = Math.random() * 255;	
				return(rgb2col(red,green,blue));
			}
			
			private function rgb2col(red:Number,green:Number,blue:Number):uint
			{	
				return((red * 65536) + (green * 256) + (blue));
			}
	}
}