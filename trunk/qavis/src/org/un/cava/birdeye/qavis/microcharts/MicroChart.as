package org.un.cava.birdeye.qavis.microcharts
{
	import com.degrafa.Surface;

	public class MicroChart extends Surface
	{
		private var tot:Number = NaN;
		
		[Bindable]
		private var tempColor:int = 0xbbbbbb;
		
		[Bindable]
		private var _sizeY:Number = NaN;
		
		[Bindable]
		private var _sizeX:Number = NaN;

		[Bindable]
		private var _dataProvider:Array = new Array();
		
		[Bindable]
		private var _colors:Array = null;

		[Bindable]
		public function set sizeX(val:Number):void
		{
			_sizeX = val;
		}
		
		/**
		* Set the width parameter of the chart. 
		* At this stage, it's recommended to use sizeX together with width to avoid rendering and binding problems. 
		*/
		public function get sizeX():Number
		{
			return _sizeX;
		}
					
		[Bindable]
		public function set sizeY(val:Number):void
		{
			_sizeY = val;
		}
		
		/**
		* Set the height parameter of the chart. 
		* At this stage, it's recommended to use sizeY together with height to avoid rendering and binding problems. 
		*/
		public function get sizeY():Number
		{
			return _sizeY;
		}
					
		[Bindable]
		public function set dataProvider(val:Array):void
		{
			setTot(val);
			_dataProvider = val;
		}
		
		/**
		* Set the dataProvider to feed the chart. 
		*/
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
				
		[Bindable]
		public function set colors(val:Array):void
		{
			_colors = val;
		}
		
		public function MicroChart()
		{
			//TODO: implement function
			super();
		}
		
		/**
		* @private  
		*/
		override protected function commitProperties():void
		{
			super.commitProperties();
		}

		/**
		* @private  
		* Set automatic colors to the bars, in case these are not provided. 
		*/
		private function useColor(indexIteration:Number, target:Object):int
		{
			if (colors != null && colors.length > 0)
				tempColor = colors[indexIteration];
			else
				tempColor += 0x123456; 

			return tempColor;
		}
	}
}