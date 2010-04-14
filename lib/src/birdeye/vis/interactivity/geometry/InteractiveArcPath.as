package birdeye.vis.interactivity.geometry
{
	import flash.geom.Point;

	public class InteractiveArcPath extends BaseInteractiveGeometry
	{
		public function InteractiveArcPath()
		{
			super();
		}
		
		protected var r:Number, R:Number, startAngle:Number, endAngle:Number, center:Point; 
		
		public function setArcData(r:Number, R:Number, startAngle:Number, arcAngle:Number, center:Point):void
		{
			if (isNaN(r) || isNaN(startAngle) || isNaN(arcAngle) || !center) return;
			
			this.r = r;
			this.R = R;
			this.startAngle = startAngle * Math.PI / 180;
			this.endAngle = this.startAngle + arcAngle * Math.PI / 180;
			this.center = center;
		}
		
		public function reset():void
		{
			this.r = NaN;
			this.R = NaN;
			this.startAngle = NaN;
			this.endAngle = NaN;
			this.center = null;
		}
		
		
		public static const DOUBLE_PI:Number = Math.PI * 2;
		
		override public function contains(p:Point):Boolean
		{
			var dist:Number = Point.distance(center, p);
			
			if (dist < r || dist > R)
			{
				return false;
			}
			
			// ok is in the same range, is the angle ok?
			var radAngle:Number = Math.atan2(center.x - p.x, center.y - p.y );
			
			radAngle += Math.PI / 2;
			
			if (radAngle < 0)
			{
				radAngle = radAngle + DOUBLE_PI;
			}
			
			if (radAngle > DOUBLE_PI)
			{
				radAngle = radAngle - DOUBLE_PI;
			}
				
			return radAngle >= startAngle && radAngle <= endAngle;
			
		}
	}
}