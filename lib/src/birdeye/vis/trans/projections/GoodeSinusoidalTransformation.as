/* 
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package birdeye.vis.trans.projections
{
	import flash.geom.Point;

	public class GoodeSinusoidalTransformation extends SinusoidalTransformation
	{
		public function GoodeSinusoidalTransformation()
		{
			super();
		}
		
/*		protected override function calcUnscaledSizeX(minLat:Number, maxLat:Number, minLong:Number, maxLong:Number):Number
		{
			const limit:Number = convertDegToRad(40.73333403); //Limit between Sinusoidal and Mollweide part of the Goode projection 
			if (minLat >= limit) //The Sinusoidal part is outside the frame
			{
				return Number.NaN;
			}
			if (maxLat > limit) //Only consider points in the Sinusoidal part of the globe
			{
				maxLat = limit;
			}
			return super.calcUnscaledSizeX(minLat, maxLat, minLong, maxLong);
		}

		protected override function calcUnscaledSizeY(minLat:Number, maxLat:Number, minLong:Number, maxLong:Number):Number
		{
			const limit:Number = convertDegToRad(40.73333403); //Limit between Sinusoidal and Mollweide part of the Goode projection 
			if (minLat >= limit) //The Sinusoidal part is outside the frame
			{
				return Number.NaN;
			}
			if (maxLat > limit) //Only consider points in the Sinusoidal part of the globe
			{
				maxLat = limit;
			}
			return super.calcUnscaledSizeY(minLat, maxLat, minLong, maxLong);
		}
*/	}
}
