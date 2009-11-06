package birdeye.vis.trans.modifiers.neighbourhood
{
	import birdeye.vis.data.Pair;
	
	public class PolygonBoundingRectangle
	{
		
		private var _xmin:Number;
		public function get xmin():Number {
			return _xmin;
		}		
		public function set xmin(val:Number):void {
			_xmin = val;
		}
		
		private var _xmax:Number;
		public function get xmax():Number {
			return _xmax;
		}		
		public function set (val:Number):void {
			_xmax = val;
		}

		private var _ymin:Number;
		public function get ymin():Number {
			return _ymin;
		}		
		public function set ymin(val:Number):void {
			_ymin = val;
		}
		
		private var _ymax:Number;
		public function get ymax():Number {
			return _ymax;
		}		
		public function set ymax(val:Number):void {
			_ymax = val;
		}

		public function PolygonBoundingRectangle(coords:Vector.<Pair>, country:String)
		{			
			var x:Number;
			var y:Number;
			//Initiate xmin, xmax, ymin and ymax so that they no longer contain NaN
			_xmin = _xmax = coords[0].dim1;
			_ymin = _ymax = coords[0].dim2;
			
			//Calculate xmin, xmax, ymin and ymax
			for each (var pair:Pair in coords)
			{
				x=pair.dim1;
				y=pair.dim2;
				_xmin = Math.min(_xmin, x);
				_xmax = Math.max(_xmax, x);
				_ymin = Math.min(_ymin, y);
				_ymax = Math.max(_ymax, y);
			}

		}

	}
}