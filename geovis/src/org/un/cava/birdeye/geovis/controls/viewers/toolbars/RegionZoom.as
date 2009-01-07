package org.un.cava.birdeye.geovis.controls.viewers.toolbars
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.core.Application;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;
	
	public class RegionZoom extends ComboBox
	{
		// Offset positions used when moving the toolbar on dragging/dropping
	    private var offsetX:Number, offsetY:Number;
	    // Keep the starting point position when dragging, if mouse goes out of the parents' view
	    // than the toolbar will be repositioned to this point
	    private var startDraggingPoint:Point;

		private var arrDefaultZoom:ArrayCollection = new ArrayCollection(
		[{label:"World",center:new Point(432,212), zoomLevel:"0.86"},
		{label:"Africa",center:new Point(473,260), zoomLevel:"2.06"},
		{label:"  -North",center:new Point(448,201), zoomLevel:"6.83"}, 
		{label:"  -Sub-Sahara",center:new Point(450,232), zoomLevel:"5.62"},
		{label:"Asia",center:new Point(633,131), zoomLevel:"2"},
		{label:"  -Eastern",center:new Point(714,145), zoomLevel:"2.76"},
		{label:"  -Southern",center:new Point(613,209), zoomLevel:"4.5"},
		{label:"  -South-eastern",center:new Point(687,248), zoomLevel:"4.44"},
		{label:"  -Western",center:new Point(585,146), zoomLevel:"3.72"},
		{label:"CIS",center:new Point(522,147), zoomLevel:"7.72"},
		{label:"Europe",center:new Point(435,127), zoomLevel:"3.82"},
		{label:"North America",center:new Point(165,143), zoomLevel:"2.22"},
		{label:"South America",center:new Point(273,321), zoomLevel:"2.07"},
		{label:"Central America",center:new Point(220,235), zoomLevel:"13.35"},
		{label:"Caribbean region",center:new Point(252,222), zoomLevel:"9.23"},
		{label:"Oceania",center:new Point(769,328), zoomLevel:"3.38"},]);
		
		private var _draggable:Boolean = false;
		
		[Inspectable(enumeration="true,false")]
		public function set draggable(val:Boolean):void
		{
			_draggable = val;
		}

		public function RegionZoom()
		{
			super();
			dataProvider = arrDefaultZoom;
		    toolTip = "Select map area for viewing";
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
			addEventListener(MouseEvent.MOUSE_DOWN, moveToolbar);
		}
		
		private var map:Map;
		private function init(e:MapEvent):void
		{
			map = Map(e.target); 
		    addEventListener(Event.CHANGE, regionZoomHandler);
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
		}
		
		// Resize panel event handler.
		public  function moveToolbar(event:MouseEvent):void
		{
	  		startMovingToolBar(event); 
	  		stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingToolBar);
		}
		
		// Start moving the toolbar
	    private function startMovingToolBar(e:MouseEvent):void
	    {
	    	this.parent.addEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    	startDraggingPoint = new Point(this.x, this.y);
	    	offsetX = e.stageX - this.x;
	    	offsetY = e.stageY - this.y;
	    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragToolBar);
	    }
	    
	    // Reset the toolbar position to the starting point
	    private function resetToolBarPosition(e:MouseEvent):void
	    {
	    	stopMovingToolBar(e);
	    	this.x = startDraggingPoint.x;
	    	this.y = startDraggingPoint.y;
	    	this.parent.removeEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    }
	    
	    // Stop moving the toolbar 
	    private function stopMovingToolBar(e:MouseEvent):void
	    {
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragToolBar)
	  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingToolBar);
	    	this.parent.removeEventListener(MouseEvent.ROLL_OUT, resetToolBarPosition);
	    }
	    
	    // Moving the toolbar while MOUSE_MOVE event is on
	    private function dragToolBar(e:MouseEvent):void
	    {
	    	this.x = e.stageX - offsetX;
	    	this.y = e.stageY - offsetY;
	    	e.updateAfterEvent();
	    	// dispatch moved toolbar event
	    }
	    
		private function regionZoomHandler(e:Event):void
	    {
/* 	    	if (map.projection == 'Miller cylindrical')
	    	{
 */			    currentZoomValue = map.zoom;
		    	var regionPoint:Point = Point(ComboBox(e.target).selectedItem.center);
		    	var zoomValue:Number = Number(ComboBox(e.target).selectedItem.zoomLevel);
		    	map.centerMap(regionPoint);
		    	map.zoomMap(1/currentZoomValue,regionPoint); 
		    	map.zoomMap(zoomValue,regionPoint); 
/* 	    	}
 */	    }
	    
	    private var currentZoomValue:Number;
	}
}