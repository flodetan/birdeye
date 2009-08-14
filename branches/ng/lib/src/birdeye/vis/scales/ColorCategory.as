package birdeye.vis.scales
{
	/**
	 * This class returns colors based on which category the data item resides in.</br>
	 * Colors can be set through a colors array.
	 */
	public class ColorCategory extends Category
	{
		public function ColorCategory()
		{
			super();
		}
		
		private var _colors:Array;
		
		public function set colors(val:Array):void
		{
			_colors = val;
		}
		
		public function get colors():Array
		{
			return _colors;
		}
		
		
		override public function getPosition(dataValue:*):*
		{
			var i:Number = dataProvider.indexOf(dataValue);
			
			if (i >= 0 && _colors && _colors.length > 0)
			{			
				return _colors[i % _colors.length];
			}
			
			return 0x000000;
		}
		
	}
}