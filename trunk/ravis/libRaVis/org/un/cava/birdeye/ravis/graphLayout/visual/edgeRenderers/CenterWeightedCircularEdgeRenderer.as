package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers
{
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
    
    public class CenterWeightedCircularEdgeRenderer extends CircularEdgeRenderer
    {
        public function CenterWeightedCircularEdgeRenderer(g:Graphics)
        {
            super(g);
        }
        
        protected override function getEdgeAnchor(vedge:IVisualEdge):Point
        {
            var bounds:Rectangle = vedge.vgraph.layouter.bounds;
            var anchor:Point = new Point(bounds.x + bounds.width/2, bounds.y + bounds.height/2);
            return anchor;
        }
        
        protected override function getLabelAnchor(vedge:IVisualEdge):Point
        {
            var bounds:Rectangle = vedge.vgraph.layouter.bounds;
            var anchor:Point = new Point(bounds.x + bounds.width/2, bounds.y + bounds.height/2);
            return anchor;
        }
    }
}