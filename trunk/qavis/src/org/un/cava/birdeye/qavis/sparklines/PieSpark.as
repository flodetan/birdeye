package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import flash.filters.DropShadowFilter;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	[Inspectable("dataProvider")]
	[Inspectable("gradientColors")]
	[Inspectable("colors")]
	[Inspectable("dataField")]		
	public class PieSpark extends UIComponent
	{
			private var values:Array;
			private var interpolate: Object;
			private var GG:GeometryGroup;
			private var _dataProvider:ArrayCollection;
			private var _colors:Array;
			private var _gradientColors:Array;
			private var _dataField:String;
			
			/*[Bindable]
			public var dataProvider:ArrayCollection;
			*/
			[Bindable]
			private var tweenDataProvider:ArrayCollection;
			
			private static var SLICES:int = 0;
			
		public function set dataProvider(value:ArrayCollection):void
		{
			_dataProvider = value;
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
				var Surf:Surface=new Surface()
			
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
				
				for (var i:int=0;i<_dataProvider.length;i++)
				{
					
					var slice:PieSparkSlice = createSlice();
					data[i] = _dataProvider.getItemAt(i)[_dataField];
					total += data[i];
				
				}
				SLICES = _dataProvider.length;
				
				redraw(data, total);
			}
			
			
			private function createSlice():PieSparkSlice 
			{
				var c:int;
				var slice:PieSparkSlice = new PieSparkSlice(this.width,this.height);
				slice.x = 0;
				slice.y = 0;
				slice.field = _dataField;
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