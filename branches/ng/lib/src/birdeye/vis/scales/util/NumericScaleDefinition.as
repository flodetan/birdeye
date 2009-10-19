package birdeye.vis.scales.util
{
	public class NumericScaleDefinition
	{
		public function NumericScaleDefinition(min:Number, max:Number, diff:Number, niceNbrScore:Number, nbrOfTicks:Number, includesZero:Boolean, dataCoverage:Number)
		{
			this.min = min;
			this.max = max;
			this.diff = diff;
			this.niceNbrScore = niceNbrScore;
			this.numberOfIntervals = nbrOfTicks;
			this.includesZero = includesZero;
			this.dataCoverage = dataCoverage;
		}
		
		public var min:Number;
		public var max:Number;
		public var diff:Number;
		public var niceNbrScore:Number;
		public var numberOfIntervals:Number;
		public var includesZero:Boolean;
		public var dataCoverage:Number;
	}
}