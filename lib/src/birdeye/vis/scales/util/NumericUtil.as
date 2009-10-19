package birdeye.vis.scales.util
{
	import org.hamcrest.mxml.object.Null;
	
	
	
	/**
	 * This class calculates the best definition of a scale for a given datarange.</br>
	 * This method is based on a method described in Leland Wilkinson's book "The Grammar of Graphics"</br>
	 * In Chapter 6 (page 96) the book descibes how, based on a set of nice numbers, the data coverage and the number of ticks,</br>
	 * an algorithm can be developed that selects the best scale division.</br>
	 */
	public class NumericUtil
	{

		//////////////////
		// CONFIGURATION
		/////////////////
		// TODO -> Make this really configurable!
		
		/**
		 * The number of ticks on scale that is ideal.</br>
		 * This is used in the scoring algorithm. </br>
		*/
		public static const idealNbrOfTicks:uint = 5;
		
		/**
		 * The set of nice number that is used for dividing scales.</br>
		 * <b>Important:</b> the order of these numbers is used for scoring! </br>
		 * For instance the first number gets the maximum score, the last gets the minimum score.
		 */
		public static const baseNiceNumber:Array = [1,5,2,2.5,3];
		
		/**
		 * The minimum number of ticks on a scale.</br>
		 * <b>Important:</b> This is an <i>indication</i> for the scoring algorithm.</br>
		 * Scales with less than these number of ticks get a drastic lower score, but</br>
		 * it is entirely possible that they still get selected.</br>
		 * For instance if the data coverage is superb.</br>
		 */
		public static const minNbrOfTicks:uint = 5;
		
		/**
		 * The maximum number of ticks on a scale.</br>
		 * <b>Important:</b> This is an <i>indication</i> for the scoring algorithm.</br>
		 * Scales with less than these number of ticks get a drastic lower score, but</br>
		 * it is entirely possible that they still get selected.</br>
		 * For instance if the data coverage is superb.</br>
		 */
		public static const maxNbrOfTicks:uint = 5;
		
		
		////////////////////
		// MAIN FUNCTION
		////////////////////
		
		/**
		 * Based on a minimum and a maximum and if the scale needs to include zero</br>
		 * this returns the best scale possible.</br>
		 */
		public static function calculateIdealScale(min:Number, max:Number, includeZero:Boolean=true):NumericScaleDefinition
		{	
			// TODO this should be precalculated
			var niceNbrs:Array = createBaseNiceNumbers(baseNiceNumber);
			
			var exp:Number = calculateClosestMatchingExponent(min, max, includeZero, idealNbrOfTicks);
			
			var scaleIntervals:Array = createRangeOfCandidateScaleIntervals(min, max, exp, niceNbrs, includeZero);
			
			return getBestScaleInterval(scaleIntervals);
		
		}
		
		//////////////////
		// HELPER FUNCTIONS
		//////////////////
		
		/**
		 * Create an array of all the given numbers, sorted in ascending order.</br>
		 * An extra property indicating the score of the nice numbers is added.</br>
		 * @return an array of BaseNiceNumber
		 */
		protected static function createBaseNiceNumbers(baseNiceNumbers:Array):Array
		{
			var toReturn:Array = new Array(baseNiceNumbers.length); 
			
			for (var i:uint = 0;i<baseNiceNumbers.length;i++)
			{
				var t:BaseNiceNumber  = new BaseNiceNumber();
				t.base = baseNiceNumbers[i];
				t.score = i+1;
				
				toReturn[i] = t;
			}
			
			return toReturn.sortOn("base", Array.NUMERIC);
		}
		
		
		/**
		 * Calculates the exponent (10^x) of the given range divided by the</br>
		 * ideal number of ticks.
		 */ 
		protected static function calculateClosestMatchingExponent(min:Number, max:Number, includeZero:Boolean, idealNbrOfTicks:Number):Number
		{
			var dataRange:Number = createDataRange(min, max, includeZero);
			
			var exactRange:Number = dataRange / idealNbrOfTicks;

			return Math.floor(Math.log(exactRange) / Math.LN10); 
		}
		
		/**
		 * Returns the range based on the min and max and if zero should be included.</br>
		 */
		protected static function createDataRange(min:Number, max:Number, includeZero:Boolean):Number
		{
			var dataRange:Number = Math.abs(min - max);
			
			if (includeZero && min > 0 && max > 0)
			{
				dataRange = max;
			}
			
			if (includeZero && min < 0 && max < 0)
			{
				dataRange = Math.abs(min);
			}
			
			return dataRange;
		}
		
		
		/**
		 * Returns a range of possible scale definitions.
		 */
		protected static function createRangeOfCandidateScaleIntervals(dataMin:Number, dataMax:Number, exponent:Number, niceNbrs:Array, includeZero:Boolean):Array
		{				
			var scaleIntervals:Array = new Array(niceNbrs.length*3);
			
			
			for (var i:uint=0; i<niceNbrs.length;i++)
			{
				scaleIntervals[i] = calculateScaleInterval(dataMin, dataMax, niceNbrs[i] as BaseNiceNumber, exponent, includeZero);
				scaleIntervals[i + niceNbrs.length] = calculateScaleInterval(dataMin, dataMax, niceNbrs[i] as BaseNiceNumber, exponent - 1, includeZero);
				scaleIntervals[i + 2*niceNbrs.length] = calculateScaleInterval(dataMin, dataMax, niceNbrs[i] as BaseNiceNumber, exponent + 1, includeZero);
			}
			
			return scaleIntervals;

		}
		
		/**
		 * Create a scale definition based on the given min,max the nice number to be used, </br>
		 * the exponent and if zero should be included. </br>
		 */
		protected static function calculateScaleInterval(dataMin:Number,dataMax:Number, niceNbr:BaseNiceNumber, exponent:Number, includeZero:Boolean):NumericScaleDefinition
		{
			var nbrOfTicks:Number = 1;
			var tickDiff:Number = niceNbr.base * Math.pow(10, exponent);
			var currentValue:Number;
			var min:Number, max:Number;
			
			
			var dataRange:Number = createDataRange(dataMin, dataMax, includeZero);
			
			if (tickDiff > dataRange )
			{
				// difference is to bigg!
				return null;
			}
			
			if (dataMax > 0)
			{
				if (dataMin < 0)
				{
					currentValue = 0;
					while (currentValue > dataMin)
					{
						currentValue -= tickDiff;
						nbrOfTicks++;
					}
					
					min = currentValue;
					currentValue = 0;
				}
				else if (includeZero)
				{
					min = 0;
					currentValue = 0;
				}
				else if (!includeZero)
				{
					// dataMin and dataMax are > 0
					var rest:Number = dataMin % tickDiff;
					currentValue = dataMin - rest;
					min = currentValue;
				}
			
				while(currentValue < dataMax)
				{
					currentValue += tickDiff;
					
					nbrOfTicks++;
					
				}
				
				max = currentValue;
								
				
			}
			else
			{
				if (includeZero)
				{
					max = 0;
					currentValue = 0;
				}
				else
				{
					// dataMin and dataMax are < 0
					rest = dataMax % tickDiff;
					currentValue = dataMax + rest;
					max = currentValue;
				}
				// going down
				while (currentValue > dataMin)
				{
					currentValue -= tickDiff;

					nbrOfTicks++;
				}
				
				min = currentValue;

			}
			
			var dataCoverage:Number = Math.abs(dataRange / (min - max));
			
			return new NumericScaleDefinition(min, max, tickDiff, niceNbr.score, nbrOfTicks, includeZero ,dataCoverage);

			
		}
		
		/**
		 * Based on a given set of scale definitions, return the one with the highest score.
		 */
		protected static function getBestScaleInterval(scaleIntervals:Array):NumericScaleDefinition
		{
			var highestScore:Number = -1;
			var indexHighestScore:Number = -1;
			
			for (var i:uint=0;i<scaleIntervals.length;i++)
			{
				var scaleDef:NumericScaleDefinition = scaleIntervals[i] as NumericScaleDefinition;
				
				if (scaleDef)
				{
					var score:Number = calculateScore(scaleDef);
				
					//trace("Score ", scaleDef.diff, scaleDef.nbrOfTicks, scaleDef.dataCoverage, scaleDef.min, scaleDef.max, score);
					
					if (score > highestScore)
					{
						highestScore = score;
						indexHighestScore = i;
					}
				}
			}
			
			//trace("Highest score", highestScore, indexHighestScore, "\n\n\n\n");
			
			return scaleIntervals[indexHighestScore] as NumericScaleDefinition;
			
		}
		
		/**
		 * Calculate the score of a given scale definition.</br>
		 * The score is determined by three things:</br>
		 * <ul>
		 * <li><b>Simplicity</b> : How nice if the used number </li>
		 * <li><b>Granularity</b> : How ideal are the number of ticks used? </li>
		 * <li><b>Datacoverage</b> : How good does the scale cover the data? </br>
		 * For instance if the range of the scale is 100, but the range of the data is only 50,</br>
		 * the coverage is only 0.5, which is bad.</br>
		 * If the datacoverage is below 75% the score lowers drastically.</br>
		 * </li>
		 * </ul>
		 */
		protected static function calculateScore(scaleInt:NumericScaleDefinition):Number
		{
			var simplicity:Number = 1 - scaleInt.niceNbrScore / baseNiceNumber.length;
			if (scaleInt.includesZero)
			{
				// add because we're using a zero in the scale interval
				simplicity += 1 / baseNiceNumber.length; 
			}
			
			var granularity:Number = 0;
			
			if (scaleInt.nbrOfTicks >= minNbrOfTicks && scaleInt.nbrOfTicks <= maxNbrOfTicks)
			{
				granularity = 1 - Math.abs(scaleInt.nbrOfTicks - idealNbrOfTicks) / idealNbrOfTicks;
			}
			else
			{
				granularity = -1;
			}

			var dcScore:Number = 0;
			if (scaleInt.dataCoverage > 0.75)
			{
				dcScore = scaleInt.dataCoverage;	
			}
			else
			{
				dcScore = scaleInt.dataCoverage / 2;
			}
			
			return (simplicity + granularity + dcScore) / 3;

		}
		
	}
	
}


class BaseNiceNumber
{
	public var base:Number;
	public var score:Number;
}


class NiceNumber
{
	function NiceNumber(realValue:Number, exponent:Number,niceNbr:BaseNiceNumber)
	{
		this.realValue = realValue;
		this.niceNbr = niceNbr;
		this.exponent = exponent;
	}
	
	public var realValue:Number;
	public var exponent:Number;
	public var niceNbr:BaseNiceNumber;
}