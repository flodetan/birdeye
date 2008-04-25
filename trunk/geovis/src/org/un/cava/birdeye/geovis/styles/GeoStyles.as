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


package org.un.cava.birdeye.geovis.styles{
	import com.degrafa.paint.LinearGradientFill;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.GradientStop;
	
	import mx.effects.Glow; 
    import mx.effects.Effect; 
    
	[ExcludeClass]
	public class GeoStyles{
		 
		public static function setRadialGradient(values:Array):RadialGradientFill{
			var arrGradColor:Array=new Array();
		   	var gradStop1:GradientStop=new GradientStop();
		   	gradStop1.color=values[0];
		   	gradStop1.alpha=1;
		   	gradStop1.ratio=0;
		   	arrGradColor.push(gradStop1);
		   	var gradStop2:GradientStop=new GradientStop();
		   	gradStop2.color=values[1];
		   	gradStop2.alpha=1;
		   	gradStop2.ratio=1;
		   	arrGradColor.push(gradStop2);
		   	var Gradient:RadialGradientFill = new RadialGradientFill();
		    Gradient.gradientStops=arrGradColor;
		   	if(values[3]!=""){
		   		Gradient.angle=90;
		   	}else{
		   		Gradient.angle=values[3];
		   	}
		    return Gradient;
		}
		
		public static function setLinearGradient(values:Array):LinearGradientFill{
			var arrGradColor:Array=new Array();
		   	var gradStop1:GradientStop=new GradientStop();
		   	gradStop1.color=values[0];
		   	gradStop1.alpha=1;
		   	gradStop1.ratio=0;
		   	arrGradColor.push(gradStop1);
		   	var gradStop2:GradientStop=new GradientStop();
		   	gradStop2.color=values[1];
		   	gradStop2.alpha=1;
		   	gradStop2.ratio=1;
		   	arrGradColor.push(gradStop2);
		   	var Gradient:LinearGradientFill = new LinearGradientFill();
		    Gradient.gradientStops=arrGradColor;
		   	if(values[3]!=""){
		   		Gradient.angle=90;
		   	}else{
		   		Gradient.angle=values[3];
		   	}
		    return Gradient;
		}
		
		public static function rollOverEffect():Effect { 
        	var glowColor:int = 0xFF9434;
        	var effect:Glow = new Glow(); 
            effect.strength += 1; 
            effect.blurXTo = effect.blurYTo = 10; 
            effect.alphaFrom = 0; 
            effect.alphaTo = 0.6; 
            effect.color = glowColor; 
            return effect; 
      } 
 
       public static function rollOutEffect():Effect { 
		 var glowColor:int = 0xFF9434;
		 var effect: Glow = new Glow(); 
         effect.strength += 1; 
         effect.blurXTo = effect.blurYTo = 0; 
         effect.alphaFrom = 0.6; 
         effect.alphaTo = 0; 
         effect.color = glowColor; 
         return effect; 
      } 
	}
}