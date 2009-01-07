package org.un.cava.birdeye.geovis.controls.viewers.toolbars
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
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
		[{label:"World",ulLat:"90", ulLong:"-180", lrLat:"-90", lrLong:"180"},
		{label:"Africa",ulLat:"32", ulLong:"-23", lrLat:"-25", lrLong:"55"},
		{label:"  -North",ulLat:"34", ulLong:"-16", lrLat:"16", lrLong:"40"}, 
		{label:"  -Sub-Sahara",ulLat:"21", ulLong:"-20", lrLat:"0", lrLong:"50"},
		{label:"Asia",ulLat:"68", ulLong:"24", lrLat:"11", lrLong:"134"},
		{label:"  -Eastern",ulLat:"48", ulLong:"77", lrLat:"18", lrLong:"136"},
		{label:"  -Southern",ulLat:"37", ulLong:"58", lrLat:"4", lrLong:"93"},
		{label:"  -South-eastern",ulLat:"30", ulLong:"84", lrLat:"-10", lrLong:"130"},
		{label:"  -Western",ulLat:"58", ulLong:"28", lrLat:"25", lrLong:"75"},
		{label:"CIS",ulLat:"52", ulLong:"19", lrLat:"36", lrLong:"54"},
		{label:"Europe",ulLat:"66", ulLong:"-28", lrLat:"33", lrLong:"34"},
		{label:"North America",ulLat:"67", ulLong:"-177", lrLat:"14", lrLong:"-75"},
		{label:"South America",ulLat:"14", ulLong:"-90", lrLat:"-50", lrLong:"-9"},
		{label:"Central America",ulLat:"21", ulLong:"-96", lrLat:"7", lrLong:"-76"},
		{label:"Caribbean region",ulLat:"27", ulLong:"-86", lrLat:"9", lrLong:"-58"},
		{label:"Oceania",ulLat:"-5", ulLong:"80", lrLat:"-48", lrLong:"160"}]);

		private var _draggable:Boolean = false;
		
		[Inspectable(enumeration="true,false")]
		public function set draggable(val:Boolean):void
		{
			_draggable = val;
		}

		private var _dataProvider:Object; 
		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
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

		public function RegionZoom()
		{
			super();
		    toolTip = "Select map area for viewing";
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
			addEventListener(MouseEvent.MOUSE_DOWN, moveToolbar);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dataProvider == null || dataProvider == '')
			{
				dataProvider = arrDefaultZoom;
				labelField = "label";
			}
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
			map.zoomMapLatLong(Number(ComboBox(e.target).selectedItem.ulLat), Number(ComboBox(e.target).selectedItem.ulLong),
								Number(ComboBox(e.target).selectedItem.lrLat), Number(ComboBox(e.target).selectedItem.lrLong));
 	    }
	}
}