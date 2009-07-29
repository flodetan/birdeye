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
 
 package birdeye.vis.scales
{
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	
	import flash.text.TextFieldAutoSize;
	
	[Exclude(name="scaleType", kind="property")]
	public class Logarithm extends Numeric 
	{
		override public function set scaleType(val:String):void
		{}
		 
		public function Logarithm()
		{
			super();
			_scaleType = BaseScale.LOG;
		}
		
		// other methods
		
		override public function get completeDataValues():Array
		{
			var tmp:Array = new Array();
			
			var tmpInterval:Number = (Math.log(min)<=1)? 0: Math.log(min);
			var snap:Number = Math.pow(10,tmpInterval);
			
			for (; snap<max; tmpInterval++)
			{
				for (snap = Math.pow(10,tmpInterval); 
					snap<max && snap<Math.pow(10,tmpInterval+1); 
					snap += Math.pow(10, tmpInterval) * ((isGivenInterval)? dataInterval:1))
				{
					tmp.push(snap);		
					
				}
			}
			
			return tmp;
		}
		
		/** @Private
		 * Override the XYZAxis getPostion method based on the log scaling.*/
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			var logMin:Number = (min<=1) ? 0 : Math.log(min);
			var logMax:Number = (max<=1) ? 0 : Math.log(max);
			var logDataValue:Number = (Number(dataValue)<=1) ? 0 : Math.log(Number(dataValue));
			
			if (! (isNaN(max) || isNaN(min)))
				switch (dimension)
				{
					case DIMENSION_1:
						pos = size * (logDataValue - logMin)/(logMax - logMin);
						break;
					case DIMENSION_2:
						pos = size * (1 - (logDataValue - logMin)/(logMax - logMin));
						break;
				}
				
			return pos;
		}
	}
}