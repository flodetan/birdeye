package birdeye.vis.interactivity.geometry
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class InteractivePath extends BaseInteractiveGeometry
	{
		public var points:Vector.<Point>;
				
		public function InteractivePath()
		{
			super();
			
			this.points = new Vector.<Point>();
			
		}
		
		public function reset():void
		{
			this.points.splice(0,this.points.length);
		}
		
		public function addPoint(p:Point):void
		{
			if (p==null) return;
			
			this.points.push(p);
			
		}
		
		override public function contains(p:Point):Boolean
		{
			return insidePolygon(p);
		}
		
		
		protected function insidePolygon(p:Point):Boolean
		{
			if (this.points.length < 2) return false;
			
			var oddNodes:Boolean = false;
			var i:int;
			var p1:Point
			var p2:Point;
			var n:int = points.length;
			var j:int = n - 1;
			
			var y:Number = p.y;
			var x:Number = p.x;
			
			for (i = 0; i < n; i++)
			{
				p1 = points[i];
				p2 = points[j];
				
				if (p1.y < y && p2.y >= y || p2.y < y && p1.y >= y)
				{
					if (p1.x + (y - p1.y) / (p2.y - p1.y) * (p2.x - p1.x) < x)
					{
						oddNodes = !oddNodes;
					}
				}
				
				j = i;
			}
			
			return oddNodes;
		}
		
		
		
	}
}