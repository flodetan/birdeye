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
	import birdeye.vis.interfaces.IEnumerableScale;
	
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterTextPlus;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.RotateTransform;
	
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	[Exclude(name="scaleType", kind="property")]
	[Exclude(name="dataProvider", kind="property")]
	public class Category extends XYZ implements IEnumerableScale
	{
 		/** Define the category strings for category scales.*/
		override public function set dataValues(val:Array):void
		{
			_dataValues = val;
			_dataValues.sort(Array.CASEINSENSITIVE);
			dataProvider = dataValues;
		}

		/** @Private
		 * The scale type cannot be changed, since it's already "category".*/
		override public function set scaleType(val:String):void
		{}
		
		/** Elements for labeling */
		private var _dataProvider:Array = [];
		public function set dataProvider(val:Array):void
		{
			_dataProvider = val;
			invalidateSize();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
		
		private var _categoryField:String;
		/** Category field that will filter the category values from the 
		 * dataprovider.*/
		public function set categoryField(val:String):void
		{
			_categoryField = val;
			invalidateSize();
			invalidateProperties();
			invalidateDisplayList();
		}
		public function get categoryField():String
		{
			return _categoryField;
		}
		
		private var _initialOffset:Number = .5;
		public function set initialOffset(val:Number):void
		{
			_initialOffset = val;
			invalidateDisplayList();
		} 
		
		// UIComponent flow
		
		public function Category()
		{
			super();
			_scaleType = BaseScale.CATEGORY;
			_dataInterval = 1;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// the interval is given by the axis lenght divided the number of 
			// category elements loaded in the CategoryAxis
			if (dataProvider && dataProvider.length >0)
			{
				var recIsGivenInterval:Boolean = isGivenInterval;
				if (_scaleInterval != size/dataProvider.length)
					scaleInterval = size/dataProvider.length;
					
				isGivenInterval = recIsGivenInterval;
			}
			
			// if placement is set, elements are loaded and interval calculated
			// than the axis is ready to be drawn
			if (placement && dataProvider && dataInterval && _categoryField)
				readyForLayout = true;
			else 
				readyForLayout = false;
		}
		
		override protected function measure():void
		{
			super.measure();
 			if (dataProvider && dataProvider.length>0 && placement)
				maxLabelSize();
 		}
 		
		// other methods
		
		/** @Private
		 * Calculate the maximum label size, necessary to define the needed 
		 * width (for y axes) or height (for x axes) of the CategoryAxis.*/
		override protected function maxLabelSize():void
		{
			var tmp:RasterTextPlus = new RasterTextPlus();
 			tmp.fontFamily = "verdana";
 			tmp.fontSize = sizeLabel;
			tmp.autoSize = TextFieldAutoSize.LEFT;
			tmp.autoSizeField = true;

			maxLblSize = 0;
			for (var i:Number = 0; i<_dataProvider.length; i++)
			{
				tmp.text = String(_dataProvider[i]);
				maxLblSize = Math.max(maxLblSize, tmp.displayObject.width); 
			}

			switch (placement)
			{
				case TOP:
				case BOTTOM:
				case HORIZONTAL_CENTER:
					height = Math.max(5, maxLblSize * Math.sin(-_rotateLabels));
					break;
				case LEFT:
				case RIGHT:
				case DIAGONAL:
				case VERTICAL_CENTER:

					width = Math.max(5, maxLblSize * Math.cos(_rotateLabels));
					break;
			}
			
			// calculate the maximum label size according to the 
			// styles defined for the axis 
			super.calculateMaxLabelStyled();
		}
		
		/** @Private
		 * Implement the drawAxes method to draw the axis according to its orientation.*/
		override protected function drawAxes(xMin:Number, xMax:Number, yMin:Number, yMax:Number, sign:Number):void
		{
			if (dataProvider && dataProvider.length>0)
				scaleInterval = size/dataProvider.length;
			else 
				_scaleInterval = NaN;

			var snap:Number, dataProviderIndex:Number=0;

			if (isNaN(maxLblSize) && dataProvider && dataProvider.length>0 && placement)
				maxLabelSize();

			if (_scaleInterval > 0 && invalidated)
			{
trace(getTimer(), "drawing category scale");
				invalidated = false;
				
				var ggIndex:uint = 0;
				
				// vertical orientation
				if (xMin == xMax)
				{
					for (snap = yMax - _scaleInterval/2; snap>yMin; snap -= _scaleInterval*_dataInterval)
					{
		 				if (surf.graphicsCollection.items && surf.graphicsCollection.items.length>ggIndex)
							gg = surf.graphicsCollection.items[ggIndex];
						else
						{
							gg = new GeometryGroup();
							surf.graphicsCollection.addItem(gg);
						}
						gg.target = surf;
						ggIndex++;

						// create thick line
			 			thick = new Line(xMin + thickWidth * sign, snap, xMax, snap);
						thick.stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
						gg.geometryCollection.addItem(thick);
			
						// create label 
	 					label = new RasterTextPlus();
						label.text = String(dataProvider[dataProviderIndex]);
						dataProviderIndex += _dataInterval;
	 					label.fontFamily = "verdana";
	 					label.fontSize = sizeLabel;
	 					label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						if (!isNaN(_rotateLabels) || _rotateLabels != 0)
						{
							var rot:RotateTransform = new RotateTransform();
							rot = new RotateTransform();
							switch (placement)
							{
								case RIGHT:
									_rotateLabelsOn = "centerLeft";
									break;
								case LEFT:
									_rotateLabelsOn = "centerRight";
									break;
							}
							rot.registrationPoint = _rotateLabelsOn;
							rot.angle = _rotateLabels;
							label.transform = rot;
						}
						
						label.y = snap-label.displayObject.height/2;
						label.x = Math.min(thickWidth, (label.displayObject.width + thickWidth) * sign);
						label.fill = new SolidFill(colorLabel);
						gg.geometryCollection.addItem(label);
					}
				} 
				else 
				// horizontal orientation
				{
					for (snap = xMin + _scaleInterval/2; snap<xMax; snap += _scaleInterval*_dataInterval)
					{
		 				if (surf.graphicsCollection.items && surf.graphicsCollection.items.length>ggIndex)
							gg = surf.graphicsCollection.items[ggIndex];
						else
						{
							gg = new GeometryGroup();
							surf.graphicsCollection.addItem(gg);
						}
						gg.target = surf;
						ggIndex++;
						
						// create thick line
			 			thick = new Line(snap, yMin + thickWidth * sign, snap, yMax);
						thick.stroke = new SolidStroke(colorStroke, alphaStroke, weightStroke);
						gg.geometryCollection.addItem(thick);
	
						// create label 
	 					label = new RasterTextPlus();
						label.text = String(dataProvider[dataProviderIndex]);
						dataProviderIndex += _dataInterval;
	 					label.fontFamily = "verdana";
	 					label.fontSize = sizeLabel;
	 					label.visible = true;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.autoSizeField = true;
						if (!isNaN(_rotateLabels) && _rotateLabels != 0)
						{
							rot = new RotateTransform();
							switch (placement)
							{
								case TOP:
									_rotateLabelsOn = "centerLeft";
									label.x = snap; 
									break;
								case BOTTOM:
									_rotateLabelsOn = "centerRight";
									label.x = snap-label.displayObject.width; 
									break;
							}
							rot.registrationPoint = _rotateLabelsOn;
							rot.angle = _rotateLabels;
							label.transform = rot;
						} else
							label.x = snap-label.displayObject.width/2; 
						label.y = thickWidth;
						label.fill = new SolidFill(colorLabel);
						gg.geometryCollection.addItem(label);
					}
				}
trace(getTimer(), "drawing category scale");
			}
		}
		
		/** @Private
		 * Override the XYZAxis getPostion method based on the linear scaling.*/
		override public function getPosition(dataValue:*):*
		{
			var pos:Number = NaN;
			
			switch (placement)
			{
				case BOTTOM:
				case TOP:
					pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					break;
				case LEFT:
				case RIGHT:
					pos = size - ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					break;
				case DIAGONAL:
					pos = ((dataProvider.indexOf(dataValue)+_initialOffset) / dataProvider.length) * size;
					break;
			}
				
			return pos;
		}
		
		override public function resetValues():void
		{
			super.resetValues();
			invalidated = true;
				
			_dataProvider = [];
		}
	}
}