package org.un.cava.birdeye.geovis.symbols.GeoSymbols
{
	import mx.events.FlexEvent;
	import mx.core.UIComponent;
	
	import flash.display.DisplayObjectContainer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	
	import org.un.cava.birdeye.qavis.sparklines.BubbleSpark;
	//import org.un.cava.birdeye.geovis.events.GeoCoreEvents;
	import org.un.cava.birdeye.geovis.events.GeoProjEvents;
	
	public class GeoBubbleSpark extends BubbleSpark
	{
		//--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
		
		/**
	     *  @private
	     */
		private var _isProjChanged:Boolean=false;
		
		
		//--------------------------------------------------------------------------
    	//
    	//  Constructor
    	//
    	//--------------------------------------------------------------------------

    	/**
     	*  Constructor.
     	*/
		public function GeoBubbleSpark()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Overridden methods
    	//
    	//--------------------------------------------------------------------------
    	
    	/**
		* @private
		*/
       	override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void{
      		super.updateDisplayList( unscaledWidth, unscaledHeight ); 
      		if(_isProjChanged){
      			trace('GeoBubbleSpark')
      			super.createBubble();
      			_isProjChanged=false;
      		}
      		
      	}
      	
		/**
		 * @private
		 */
		override protected function createBubbleDelayed(e:FlexEvent):void
		{
			super.createBubble();
			trace('Geo createBubbleDelayed : ' + this.parent.parent)
			//this.parent.parent.addEventListener(GeoCoreEvents.DRAW_BASEMAP_COMPLETE, projChanged);
			this.parent.parent.addEventListener(GeoProjEvents.PROJECTION_CHANGED, projChanged);
		}
		
		
		/**
		 * @private
		 */
		override protected function addBubble(bub:UIComponent):void
		{
			trace('Geoaddbubble: ' + this + '/' + bub)
			var dynamicClassName:String=getQualifiedClassName(this.parent);
			var dynamicClassRef:Class = getDefinitionByName(dynamicClassName) as Class;
			var key:String=(this.parent as dynamicClassRef).key;
			var geom:GeometryGroup
			if(_isProjChanged){
				geom=GeometryGroup(Surface(this.parent.parent as DisplayObjectContainer).getChildByName(key));
			}else{
				geom=GeometryGroup(Surface((this.parent.parent as DisplayObjectContainer).getChildByName("Surface")).getChildByName(key));
			}
			trace('geom:'+geom)
			if(geom!=null){
				this.addChild(bub);
				trace('bub added')
			}
		}
		
		//--------------------------------------------------------------------------
    	//
    	//  Methods
    	//
    	//--------------------------------------------------------------------------
		
		/**
     	*  @private
     	*/
        private function projChanged(e:GeoProjEvents):void{
        	_isProjChanged=true;
        	invalidateDisplayList();
        }

	}
}