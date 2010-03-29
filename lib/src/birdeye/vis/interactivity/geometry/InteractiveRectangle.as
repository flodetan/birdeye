package birdeye.vis.interactivity.geometry
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class InteractiveRectangle extends BaseInteractiveGeometry
	{
		protected var baseGeom:Rectangle;
		
		public function set baseGeometry(rect:Rectangle):void
		{
			this.baseGeom = rect;
			
		}
		
		public function get baseGeometry():Rectangle
		{
			return this.baseGeom;
		}
		
		override public function contains(p:Point) : Boolean
		{
			if (!this.baseGeom)
			{
				return false;
			}
			//trace("Checking", p.x, p.y, " on " , baseGeom.bottom, baseGeom.top, baseGeom.left, baseGeom.right);
			
			return this.baseGeom.containsPoint(p);
		}
	}
}