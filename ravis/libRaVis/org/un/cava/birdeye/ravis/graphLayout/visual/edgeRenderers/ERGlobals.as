package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers {
	
	import flash.display.Graphics;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	
	
	/**
	 * This class contains a set of static methods used for EdgeRendering
	 * */
	public class ERGlobals {
		
		/**
		 * Applies the linestyle stored in the passed visual Edge
		 * object to the passed Graphics object.
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
		
	}
}