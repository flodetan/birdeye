package birdeye.vis.interfaces.elements
{
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	
	import flash.events.IEventDispatcher;

	public interface IDataElement extends IEventDispatcher
	{
		/** Set the visualization target. This allows to share axes, layouts and other properties
		 * of the visualization among several elements, even among different visualization .*/
		function set visScene(val:ICoordinates):void;
		function get visScene():ICoordinates;
		
		/** Set the colorField to filter horizontal data values.*/
		function set colorField(val:String):void;
		function get colorField():String;
		
		/** Set the color axis.*/
		function set colorScale(val:IScale):void;
		function get colorScale():IScale;
		//function get maxColorValue():Number;
		//function get minColorValue():Number;
		
		/** Set the sizeField to filter horizontal data values.*/
		function set sizeField(val:Object):void;
		function get sizeField():Object;
		
		/** Set/get the collision type if the element includes several dimN.*/
		function set collisionType(val:String):void;
		function get collisionType():String;
		
		/** Set the size axis.*/
		function set sizeScale(val:INumerableScale):void;
		function get sizeScale():INumerableScale;
		function get maxSizeValue():Number;
		function get minSizeValue():Number;
		
		/** Set the data provider of a cartesian Element, which must be a CartesianChart.*/
		function set dataProvider(val:Object):void;
		function get dataProvider():Object;
		
		/** Set the dim1 to filter horizontal data values.*/
		function set dim1(val:Object):void;
		function get dim1():Object;
		
		/** Set the dim2 to filter vertical data values.*/
		function set dim2(val:Object):void;
		function get dim2():Object;
		
		/** Set the dim3 to filter vertical data values.*/
		function set dim3(val:String):void;
		function get dim3():String;
		
		/** Set the scale for dim1.*/
		function set scale1(val:IScale):void;
		function get scale1():IScale;
		
		/** Set the scale for dim2.*/
		function set scale2(val:IScale):void;
		function get scale2():IScale;
		
		/** Set the scale for dim3.*/
		function set scale3(val:IScale):void;
		function get scale3():IScale;
		
		function get maxDim1Value():Number;
		function get minDim1Value():Number;
		
		function get maxDim2Value():Number;
		function get minDim2Value():Number;
		
		function get maxDim3Value():Number;
		function get minDim3Value():Number;
		
		function get totalDim1PositiveValue():Number;
		
		/** Set the cursor vector used by the Element. It can either derive from the Element own 
		 * dataProvider or from the chart dataProvider.*/
		function set dataItems(val:Vector.<Object>):void;
		function get dataItems():Vector.<Object>;
	}
}