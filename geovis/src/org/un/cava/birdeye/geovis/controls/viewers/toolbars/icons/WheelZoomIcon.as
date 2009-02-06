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
 package org.un.cava.birdeye.geovis.controls.viewers.toolbars.icons
{
	public class WheelZoomIcon extends BaseIcon
	{
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			with (graphics)
			{
				// wheel shape
				moveTo(0,0);
				lineStyle(3,c,1);
				lineTo(IconsUtils.size,IconsUtils.size);
		
				moveTo(IconsUtils.size/2,0);
				lineStyle(3,c,1);
				lineTo(IconsUtils.size/2,IconsUtils.size);
		
				moveTo(0,IconsUtils.size/2);
				lineStyle(3,c,1);
				lineTo(IconsUtils.size,IconsUtils.size/2);
		
				moveTo(0,0);
				lineStyle(3,c,1);
				lineTo(IconsUtils.size,IconsUtils.size);

				// zoom shape
				moveTo(IconsUtils.size/2,IconsUtils.size/2);
				lineStyle(1,IconsUtils.BLACK);
				beginFill(c,1);
				drawCircle(IconsUtils.size/2,IconsUtils.size/2,IconsUtils.size/3);
				endFill();
				
 				moveTo(IconsUtils.size/2,IconsUtils.size/4);
				lineStyle(IconsUtils.thick/2,IconsUtils.BLACK,1);
				lineTo(IconsUtils.size/2,IconsUtils.size*3/4);
		
				moveTo(IconsUtils.size/4,IconsUtils.size/2);
				lineStyle(IconsUtils.thick/2,IconsUtils.BLACK,1);
				lineTo(IconsUtils.size*3/4,IconsUtils.size/2);
			}
		}
	}
}