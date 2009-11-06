package birdeye.vis.trans.modifiers.neighbourhood
{
	import birdeye.vis.data.Pair;
	import birdeye.vis.data.dictionaries.WorldCountries;
	
	public class NeighbourRegister
	{

		private static var _neighbouringCountries:Array = new Array();
		public static function getNeighbouringCountries():Array {
			return _neighbouringCountries;
		}

		public function NeighbourRegister()
		{
		}
		
		public static function detectNeighbours(countryList:Array, wc:WorldCountries):void {
			var countryA:String; //first loop
			var countryB:String; //second loop
			var boundsA:PolygonBoundingRectangle;
			var boundsB:PolygonBoundingRectangle;
			var commonBorder:Number; //length of border between countryA and countryB
			for (var idxA:int=0; idxA<countryList.length; idxA++)
			{
				countryA = countryList[idxA];
				for (var idxB:int=idxA+1; idxB<countryList.length; idxB++)
				{
					countryB = countryList[idxB];
					//OK, we've got all possible combinations of two countries
					//Now compare the polygons of the two countries to see if they border on each other
					commonBorder=0;
					for each (var polygonA:Vector.<Pair> in wc.getCountryPolygon(countryA))
					{
						boundsA=new PolygonBoundingRectangle(polygonA, countryA);
						for each (var polygonB:Vector.<Pair> in wc.getCountryPolygon(countryB))
						{
							boundsB=new PolygonBoundingRectangle(polygonB, countryB);
							
							//First quickly check if the bounding rectangles of the two polygons overlap at all
							if (areBoundingRectanglesOverlapping(boundsA.xmin, boundsA.xmax, boundsA.ymin, boundsA.ymax, boundsB.xmin, boundsB.xmax, boundsB.ymin, boundsB.ymax))
							{
								//Then proceed to investigate whether the two polygons are actually neighbours
								commonBorder = commonBorder + measureCommonBorder(polygonA, polygonB);
							}
						}
					}
					if (commonBorder > 0) {
						if (_neighbouringCountries[countryA] == null) {
							_neighbouringCountries[countryA]=new Array();
						}
						_neighbouringCountries[countryA].push({country:countryB,borderSize:commonBorder});
						if (_neighbouringCountries[countryB] == null) {
							_neighbouringCountries[countryB]=new Array();
						}
						_neighbouringCountries[countryB].push({country:countryA,borderSize:commonBorder});
					}
				}
			}

		}
		
		private static function areBoundingRectanglesOverlapping(x1min:Number,x1max:Number,y1min:Number,y1max:Number,x2min:Number,x2max:Number,y2min:Number,y2max:Number):Boolean
		{
			var noOverlap:Boolean; //easier to first check if they are non-overlapping
			noOverlap = ((x1max < x2min || x2max < x1min) &&
			             (y1max < y2min || y2max < y1min))

			return (!noOverlap);
		}
		
		private static function measureCommonBorder(polyA:Vector.<Pair>, polyB:Vector.<Pair>):Number
		{
			//Thought for later: only investigate the coordinates inside and next to the overlap of the polygon bounding boxes
			const slopeTolerance:Number = 0.001; //Lines will be considered parallel if their slopes deviate less than this 
			var pairA1:Pair,xA1:Number,yA1:Number; //A point of polygon A
			var pairA2:Pair,xA2:Number,yA2:Number; //Next point of polygon A
			var pairB1:Pair,xB1:Number,yB1:Number; //A point of polygon B
			var pairB2:Pair,xB2:Number,yB2:Number; //Next point of polygon B
			var kA:Number; //Slope of line in polygon A
			var kB:Number; //Slope of line in polygon B
			var k1:Number; //1st mixed slope
			var k2:Number; //2nd mixed slope
			var borderLength:Number = 0;
			
			pairA2=polyA[0];
			//Loop through each line in both polygons
			for (var idxA:int=1; idxA<polyA.length; idxA++) {
				pairA1=pairA2; //The line starts where the previous line ended
				pairA2=polyA[idxA]; //The line ends at the current idxA

				xA1=pairA1.dim1;
				yA1=pairA1.dim2;
				xA2=pairA2.dim1;
				yA2=pairA2.dim2;

				pairB2=polyB[0];
				for (var idxB:int=1; idxB<polyB.length; idxB++) {
					pairB1=pairB2; //The line starts where the previous line ended
					pairB2=polyB[idxB]; //The line ends at the current idxB
	
					xB1=pairB1.dim1;
					yB1=pairB1.dim2;
					xB2=pairB2.dim1;
					yB2=pairB2.dim2;
					
					//OK, we've got all possible combinations of lines from the two polygons
					//Now compare the lines of the two polygons to see if they border on each other
					
					//First quickly check the bounding rectangles of the two lines
					if (areBoundingRectanglesOverlapping(Math.min(xA1,xA2), Math.max(xA1,xA2), Math.min(yA1,yA2), Math.max(yA1,yA2), Math.min(xB1,xB2), Math.max(xB1,xB2), Math.min(yB1,yB2), Math.max(yB1,yB2)))
					{
						//Then check whether they have similar slopes
						kA=(yA2-yA1)/(xA2-xA1);
						kB=(yB2-yB1)/(xB2-xB1);
						if (Math.abs(kB-kA)<slopeTolerance)
						{
							//Finally check whether the slope remains the same even when mixing points from the two lines
							k1=(yA1-yB1)/(xA1-xB1);
							k2=(yA2-yB2)/(xA2-xB2);
							if (Math.abs(k1-k2)<slopeTolerance)
							{
								//OK, there is colinearity. Now calculate how much the lines overlap
								borderLength = borderLength + measureLineOverlap(xA1,yA1,xA2,yA2,xB1,yB1,xB2,yB2);
							}
						}
					}
				}
			}
			return borderLength;
		}

		/* The parameters of function measureLineOverlap define four reasonably colinear points.
		 * Two points belong to one country and two to another country.
		 * The function measures the length of line shared by both countries,
		 * which is the same as the distance between the two inner points.
		 */
		private static function measureLineOverlap(xA1:Number,yA1:Number,xA2:Number,yA2:Number,xB1:Number,yB1:Number,xB2:Number,yB2:Number):Number
		{
			var xInnerStart:Number;
			var yInnerStart:Number;
			var xInnerEnd:Number;
			var yInnerEnd:Number;
			
			var xMin:Number = Math.min(xA1,xA2,xB1,xB2);
			var xMax:Number = Math.max(xA1,xA2,xB1,xB2);
			
			//Determine innerStart, the leftmost point reached by both lines
			if (xA1 == xMin || xA2 == xMin) { //If line A goes farthest left
				//Then choose the leftmost point of line B
				if (xB1 <= xB2) {
					xInnerStart = xB1;
					yInnerStart = yB1;
				} else {
					xInnerStart = xB2;
					yInnerStart = yB2;					
				}
			} else { //If line B goes farthest left
				//Then choose the leftmost point of line A
				if (xA1 <= xA2) {
					xInnerStart = xA1;
					yInnerStart = yA1;
				} else {
					xInnerStart = xA2;
					yInnerStart = yA2;					
				}
			}

			//Determine innerEnd, the rightmost point reached by both lines
			if (xA1 == xMax || xA2 == xMax) { //If line A goes farthest right
				//Then choose the rightmost point of line B
				if (xB1 <= xB2) {
					xInnerEnd = xB2;
					yInnerEnd = yB2;
				} else {
					xInnerEnd = xB1;
					yInnerEnd = yB1;					
				}
			} else { //If line B goes farthest right
				//Then choose the rightmost point of line A
				if (xA1 <= xA2) {
					xInnerEnd = xA2;
					yInnerEnd = yA2;
				} else {
					xInnerEnd = xA1;
					yInnerEnd = yA1;					
				}
			}

			//Sanity check
			if (xInnerStart <= xInnerEnd )
			{
				var commonLength:Number = Math.sqrt(Math.pow(xInnerEnd-xInnerStart,2)+Math.pow(yInnerEnd-yInnerStart,2));	
				return commonLength
			} else {
				trace ("ERROR: NeighbourRegister.measureLineOverlap detected an impossibility: xA1 = " + xA1 + ", xA2 = " + xA2+ ", xB1 = " + xB1 + ", xB2 = " + xB2);
				return 0;
			}
		}

	}
}