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
 
 package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.filters.DropShadowFilter;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
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
	[Inspectable("dataTipFunction")]
	[Inspectable("dataTipPrefix")]		
	public class PieSpark extends UIComponent
	{
			private var values:Array;
			private var interpolate: Object;
			private var GG:GeometryGroup;
			private var _dataProvider:ICollectionView;
			private var _colors:Array;
			private var _gradientColors:Array;
			private var _dataField:String;
			private var _showDataTips:Boolean=false;
			private var _dataTipFunction:Function;
			private var _dataTipPrefix:String;
			//[Bindable("dataTipFunctionChanged")]
    		//[Inspectable(category="Advanced")]
			public var Surf:Surface;
			
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
		
		public function set dataTipPrefix(value:String):void
		{
			_dataTipPrefix = value;
		}
			
		public function get dataTipFunction():Function
	    {
	        return _dataTipFunction;
	    }

	    
    	public function set dataTipFunction(value:Function):void
	    {
	        _dataTipFunction = value;
	        //dispatchEvent(new Event("labelFunctionChanged"));
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
				
				var dynamicClassName:String=getQualifiedClassName(this.parent);
				var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
				var key:String=(this.parent as dynamicClassRef).key;
				
				var geom:GeometryGroup=GeometryGroup(Surface((this.parent.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(key));
				
				if(geom!=null){
					this.addChild(Surf);
					createSlices();
				}
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
					var slice:PieSparkSlice = createSlice(cursor,Surf);
					data[i] = cursor.current[_dataField];
					total += Number(data[i]);
				    i++;
				    cursor.moveNext();      

				}

		
				SLICES = _dataProvider.length;
				redraw(data, total);
			}
			
			private function createSlice(curs:IViewCursor, surf:Surface):PieSparkSlice 
			{
				var c:int;
				var slice:PieSparkSlice = new PieSparkSlice(this.width,this.height,_dataField,_showDataTips,curs,_dataTipFunction,surf,_dataProvider.length,_dataTipPrefix);
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