package birdeye.vis.elements.geometry
{
	import birdeye.vis.elements.BaseElement;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.ISubScale;
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.paint.SolidFill;
	
	import flash.geom.Rectangle;
	
	public class TextElement extends BaseElement
	{
		public function TextElement()
		{
			super();
			
			stdLabel = new RasterText();
			stdLabel.fontFamily = "DIN Medium";
			stdLabel.fontSize = 10;
			stdLabel.textColor = 0x333333;
			stdLabel.align = "center";
			stdLabel.gridFitType = "pixel";
		}
		
		public var dataField:Object = "result0";
		
		
		protected var y0:Number;
		protected var x0:Number;		
		protected var scaleResults:Object;
		protected static const POS1:String = "POS1";
		protected static const POS2:String = "POS2";
		protected static const POS3:String = "POS3";
		protected static const POS3relative:String = "POS3RELATIVE";
		protected static const SIZE:String = "size";
		protected static const COLOR:String = "color";
		protected function determinePositions(dim1:Object, dim2:Object, dim3:Object=null,color:Object=null, size:Object=null, currentItem:Object=null):Object
		{
			var scaleResults:Object = new Object();
			
			//scaleResults[SIZE] = _graphicRendererSize;
			scaleResults[COLOR] = fill;
			
			// if the Element has its own scale1, than get the dim1 coordinate
			// position of the data value filtered by dim1 field. If it's stacked100 than 
			// it considers the last stacked value as a base value for the current one.
			if (scale1)
			{
				scaleResults[POS1] = scale1.getPosition(dim1);
			}
			
			// if there is a multiscale than use the scale2 corresponding to the current
			// dim1 category to get the dim2 position
			if (scale1 is ISubScale && (scale1 as ISubScale).subScalesActive)
			{
				scaleResults[POS2] = (scale1 as ISubScale).subScales[dim1].getPosition(dim2);
			} 
			
			// if the Element has its own scale2, than get the dim2 coordinate
			// position of the data value filtered by dim2 field. If it's stacked100 than 
			// it considers the last stacked value as a base value for the current one.
			if (scale2)
			{
				// if not stacked, than the dim2 coordinate is given by the scale2
				scaleResults[POS2] = scale2.getPosition(dim2);
			}
			
			if (colorScale)
			{
				var col:* = colorScale.getPosition(color);
				if (col is Number)
					scaleResults[COLOR] = new SolidFill(col);
				else if (col is IGraphicsFill)
					scaleResults[COLOR] = col;
			} 
			
			if (sizeScale)
			{
				scaleResults[SIZE] = sizeScale.getPosition(size);
			}
			
			return scaleResults;
		}
		
		
		private var _labelFunction:Function;
		
		public function set labelFunction(lblF:Function):void
		{
			_labelFunction = lblF;
		}
		
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		
		private var _drawingData:Array;
		
		override public function preDraw():Boolean
		{
			if (!(isReadyForLayout() && _invalidatedElementGraphic) )
			{
				return false;
			}
			
			this.graphics.clear();
			var currentItem:Object;
			
			_drawingData= new Array();
			
			for (var cursorIndex:uint = 0; cursorIndex<_dataItems.length; cursorIndex++)
			{
				
				currentItem = _dataItems[cursorIndex];
				
				scaleResults = determinePositions(currentItem[dim1], currentItem[dim2], currentItem[dim3], 
					currentItem[colorField], currentItem[sizeField], currentItem);
				
				trace(dim1, dim2, currentItem[dim1], currentItem[dim2]);
				
				
				var d:Object = new Object();
				
				// save bounds (for graphicRenderer)
				d.bounds = new Rectangle(scaleResults[POS1] - scaleResults[SIZE], scaleResults[POS2] - scaleResults[SIZE], scaleResults[SIZE] * 2, scaleResults[SIZE] * 2);
				
				// save inner data
				d.data = currentItem[dataField];
				
				// save fill and stroke
				d.fill = scaleResults[COLOR];
				d.stroke = stroke;				
				
				d.width = 60;
				d.height = 15;

				if (!isNaN(scaleResults[POS1]))
				{
					d.x = scaleResults[POS1] - d.width/2;
				}
				else
				{
					d.x = 0;
				}
				
				if (!isNaN(scaleResults[POS2]))
				{
					d.y = scaleResults[POS2] - d.height/2;
				}
				else
				{
					d.y = d.height / 2;
				}
				
				_drawingData.push(d);
			}
			
			return true && super.preDraw();
		}
		
		protected var stdLabel:RasterText = new RasterText();
		
		
		override public function drawDataItem() :Boolean
		{
			var d:Object = _drawingData[_currentItemIndex];
			
			stdLabel.x = d.x;
			stdLabel.y = d.y;
			stdLabel.width = d.width;
			stdLabel.height = d.height;
			stdLabel.text = labelFunction ? labelFunction.call(null,d.data) : d.data;
			
			stdLabel.draw(this.graphics, null);
			
			return true && super.drawDataItem();
		}
	}
}