package birdeye.vis.data
{
	public class PairPlus extends Pair
	{

		protected var _weight:Number;

		public function PairPlus(d1:Number, d2:Number, wght:Number)
		{
			super(d1,d2);
			_weight = wght;
		}

		override public function toString():String {
			return ("["+_dim1+","+_dim2+","+_weight+"]");
		}
		
		public function set weight(wght:Number):void {
			_weight = wght;
		}

		public function get weight():Number {
			return _weight;
		}

	}
}