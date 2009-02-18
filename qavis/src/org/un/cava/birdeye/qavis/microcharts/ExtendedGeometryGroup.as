package org.un.cava.birdeye.qavis.microcharts
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import mx.collections.IViewCursor;
	
	public class ExtendedGeometryGroup extends GeometryGroup
	{
		public var toolTip:String;
		public var toolTipFill:IGraphicsFill;
		public var posX:Number;
		public var posY:Number;
		private var toolTipStroke:IGraphicsStroke;
		private var toolTipGeometry:Circle;
		private var whiteCircle:Circle;
		 
		private var _showDataTips:Boolean = false;
		private var _dataTipFunction:Function;
		private var _dataTipPrefix:String;
		
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
	    }
	    
		public function ExtendedGeometryGroup()
		{

		}
		
		public function createToolTip(item:Object, dataField:String, posX:Number, posY:Number, radius:Number):void
		{
			this.posX = posX;
			this.posY = posY;
			whiteCircle = new Circle(posX,posY,4);
			whiteCircle.fill = new SolidFill(0xffffff);
			toolTipGeometry = new Circle(posX,posY,2);
			toolTipGeometry.fill = (toolTipFill) ? toolTipFill : new SolidFill(0xffffff,1);
			whiteCircle.stroke = (toolTipStroke) ? toolTipStroke : new SolidStroke(0x999999,1);
			
			if (_dataTipFunction != null)
				toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
							+ _dataTipFunction(item);
			else
				toolTip = ((_dataTipPrefix) ? _dataTipPrefix : "") 
							+ ((dataField) ? item[dataField] : Number(item)); 
				
			geometryCollection.addItem(whiteCircle);
			geometryCollection.addItem(toolTipGeometry);
			hideToolTipGeometry();
		} 
		
		public function showToolTipGeometry():void
		{
			whiteCircle.visible = true;
			toolTipGeometry.visible = true;
		}
		
		public function hideToolTipGeometry():void
		{
			whiteCircle.visible = false;
			toolTipGeometry.visible = false;
		}
	}
}