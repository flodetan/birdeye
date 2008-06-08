package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	
	
	/**
	 * This class contains a set of static methods used for EdgeRendering
	 * */
	public class ERGlobals {
		
		/**
		 * Applies the linestyle stored in the passed visual Edge
		 * object to the passed Graphics object.
		 *
		 * XXX: May be moved into the BaseEdgeRenderer, no more need for this here.
		 * 
		 * @param ve The VisualEdge object that the line style is taken from.
		 * @param g The Graphics object that the line style is applies to.
		 * */
		public static function applyLineStyle(ve:IVisualEdge,g:Graphics):void {
			/* apply the style to the drawing */
			if(ve.lineStyle != null) {
				g.lineStyle(
					Number(ve.lineStyle.thickness),
					uint(ve.lineStyle.color),
					Number(ve.lineStyle.alpha),
					Boolean(ve.lineStyle.pixelHinting),
					String(ve.lineStyle.scaleMode),
					String(ve.lineStyle.caps),
					String(ve.lineStyle.joints),
					Number(ve.lineStyle.miterLimits)
				);
			}
		}
		
		/**
		 * Applies the provided coordinates to the given UI Component.
		 * Is basically a helper to allow to use directly a Point object.
		 * 
		 * XXX May be moved into the BaseEdgeRenderer
		 * 
		 * @param uc The UIComponent to set the coordinates in.
		 * @param p The Point with the target coordinates.
		 * */
		public static function setLabelCoordinates(uc:UIComponent,p:Point):void {
			if(uc != null && p != null) {
				uc.x = p.x;
				uc.y = p.y;
			}
		}
		
	}
}