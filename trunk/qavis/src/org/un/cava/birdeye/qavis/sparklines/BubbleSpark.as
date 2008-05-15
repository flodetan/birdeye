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
 
 package org.un.cava.birdeye.qavis.sparklines
{
	import com.degrafa.*;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import mx.collections.ICollectionView;
	import mx.containers.VBox;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.styles.StyleManager;
	
	
	[Inspectable("radius")]
	[Inspectable("showDataTips")]	
	[Inspectable("dataTips")]
	[Inspectable("ratio")]
	[Style(name="fill",type="uint",format="Color",inherit="no")]
	/*StyleName define the css style*/
	public class BubbleSpark extends UIComponent
	{
			private var values:Array;
			private var interpolate: Object;
			private var GG:GeometryGroup;
			private var _dataProvider:ICollectionView;
			private var _dataField:String;
			private var _showDataTips:Boolean=false;
			private var _radius:Number;
			private var _color:uint=0xFFFFFF;
			private var _ratio:Number=1;
			private var _alpha:Number=0.8;
			private var _dataTips:String;
			public var Surf:Surface;
			
			
		[Inspectable(showDataTips="true,false")]
		public function set showDataTips(value:Boolean):void
		{
			_showDataTips = value;
		}
		
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}
		
		public function set dataTips(value:String):void
		{
			_dataTips = value;
		}
		
		public function get dataTips():String
		{
			return _dataTips;
		}
		
		public function set radius(value:Number):void
		{
			_radius = value;
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set ratio(value:Number):void
		{
			_ratio = value;
		}
			
		public function get ratio():Number
		{
			return _ratio;
		}
		
		public function BubbleSpark()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createBubble);
		}
			
			/**
			* This class is the main class that draw the Bubbles.
			*/ 
			private function createBubble(e:FlexEvent):void
			{
					var vertBox:VBox=new VBox();
		    		vertBox.setStyle("horizontalAlign","center"); 
		    		vertBox.setStyle("verticalAlign","middle"); 
		    		vertBox.setStyle("verticalGap",-2);
		    		
					var ref:UIComponent = new UIComponent();
					if(_showDataTips){
						ref.toolTip=_dataTips;
					}
		    		
		   		
			   		var arrGradColor:Array=new Array();
			   		
			   		var gradStop1:GradientStop=new GradientStop();
			   		gradStop1.color=uint("0xFFFFFF");
			   		gradStop1.alpha=.8;
			   		gradStop1.ratio=0;
			   		arrGradColor.push(gradStop1);
			   		
			   		if(getStyle("fill")){
						_color=uint(getStyle("fill"));
					}else{
						if(styleName){
							if(StyleManager.getStyleDeclaration("."+ styleName).getStyle("fill")){
					   			_color=uint("0x"+StyleManager.getStyleDeclaration("."+ styleName).getStyle("fill").toString(16));
					   		}
					 	}
					}
					
					if(styleName){
						if(StyleManager.getStyleDeclaration("."+ styleName).getStyle("alpha")){
				   			_alpha=Number(StyleManager.getStyleDeclaration("."+ styleName).getStyle("alpha"));
				   		}
					}else{
					 	if(alpha){
							_alpha=alpha;
						}
					}
					
					
					if(styleName){
						if(StyleManager.getStyleDeclaration("."+ styleName).getStyle("ratio")){
					   			_ratio=Number(StyleManager.getStyleDeclaration("."+ styleName).getStyle("ratio"));
					   	}
					}else{
						if(ratio){
							_ratio=ratio;
						}
					}
					
					var gradStop2:GradientStop=new GradientStop();
			   		gradStop2.color=_color;
			   		gradStop2.alpha=_alpha;
			   		gradStop2.ratio=_ratio;
			   		arrGradColor.push(gradStop2);
			   		
			   		var Gradient:RadialGradientFill = new RadialGradientFill();
			        Gradient.gradientStops=arrGradColor;
			        Gradient.angle=90;
		        
				    var surf:Surface=new Surface();
				    //surf.scaleX=0.02;
				    //surf.scaleY=0.02;
					var GPGeom:GeometryGroup=new GeometryGroup();
					GPGeom.target=surf;
					surf.graphicsCollection.addItem(GPGeom);
					
					ref.addChild(surf);
					
					var bubble:Circle=new Circle(0,0,0);
					bubble.fill=Gradient;
					bubble.radius=_radius;
					
					GPGeom.geometryCollection.addItem(bubble);
					GPGeom.draw(null,null);
					//vertBox.addChild(ref);
					this.addChild(ref);
		    	} 
			
			
			
			
			private function randColor():uint
			{	
				var red:Number = Math.random() * 255;	
				var green:Number = Math.random() * 255;	
				var blue:Number = Math.random() * 255;	
				return(rgb2col(red,green,blue));
			}
			
			private function rgb2col(red:Number,green:Number,blue:Number):uint
			{	
				return((red * 65536) + (green * 256) + (blue));
			}
	}
}
