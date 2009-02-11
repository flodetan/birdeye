///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2009 Michael VanDaniker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////

package org.un.cava.birdeye.qavis.matrix
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextLineMetrics;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.CollectionEvent;
	import mx.formatters.NumberFormatter;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	/**
	 *  The color of the background of a renderer when the user rolls over it.
	 *
	 *  @default 0xB2E1E1
	 */
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	
	/**
	 *  The color of the background of a renderer when the user selects it.
	 *
	 *  @default 0x7FCEFF
	 */
	[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

	/**
	 * A ComparisonMatrix shows the relationships between the attributes of objects
	 * in a collection. Each attribute is assigned a row and a column. The cell at
	 * the intersection of row A and column B represents the relationship between
	 * attributes A and B. The default behavior of the ComparisonMatrix is to use
	 * the correlation coefficent as a measure of relationship, but a custom
	 * function can be provided instead.
	 * 
	 * The ComparisonMatrix takes an ArrayCollection of objects and generates a
	 * ComparisonItem for each pair of attributes in the fields property. An itemRenderer
	 * is created for each of these ComparisonItems. The ComparisonItems can be accessed
	 * through the read-only comparisonItems property.
	 * 
	 * See http://michaelvandaniker.com/blog/2009/01/21/visualizing-the-2008-nfl-season/
	 * for an example application using this component.
	 */
	public class ComparisonMatrix extends UIComponent
	{
		public function ComparisonMatrix()
		{
			super();
		}
		
		// Initialize the rollOverColor and selectionColor styles. Through the
		// magic of CSS, they will find their way down to the comparisonRenderer.
		private static function initializeStyles():void
		{
			if (!StyleManager.getStyleDeclaration("ComparisonMatrix"))
            {
                var defaultStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
                defaultStyles.defaultFactory = function():void
                {
                    this.rollOverColor = 0xB2E1E1;
                    this.selectionColor = 0x7FCEFF;
                }
                StyleManager.setStyleDeclaration("ComparisonMatrix", defaultStyles, true);
            }
		}
		initializeStyles();
		
		/**
		 * The itemRenderers that will be arranged into the matrix.
		 */
		protected var cells:Array = [];
		
		/**
		 * The textFields that will be displayed along the matrix, indicating the fields being rendered.
		 */
		protected var textFields:Array = [];
		
		[Bindable(event="comparisonRendererChange")]
		/**
		 * The class used to generate the cells in the ComparisonMatrix. The term "comparisonRenderer"
		 * is used to emphasize that the ComparisonMatrix does not render the items in its dataProvider
		 * like the List, DataGrid, and so many others. Rather, the ComparisonMatrix evaluates the
		 * relationships between the attributes in the dataProvider and renders those comparisons.
		 * 
		 * Objects created by the comparisonRenderer factory must be DisplayObjects and implement
		 * IComparisonRenderer.
		 * 
		 * The default is a ClassFactory for ComparisonMatrixCells.
		 */
		public function set comparisonRenderer(value:IFactory):void
		{
			if(value != _comparisonRenderer)
			{
				var instance:Object = comparisonRenderer.newInstance();
				if(instance is IComparisonRenderer && instance is DisplayObject)
				{
					_comparisonRenderer = value;
					comparisonRendererDirty = true;
					invalidateProperties();
					invalidateDisplayList();
					dispatchEvent(new Event("comparisonRendererChange"));
				}
				else
				{
					throw new Error("Objects created by the comparisonRenderer factory must be "+
						"DisplayObjects and implement IComparisonRenderer.");
				}
			}
		}
		public function get comparisonRenderer():IFactory
		{
			return _comparisonRenderer;
		}
		private var _comparisonRenderer:IFactory = new ClassFactory(ComparisonMatrixCell);
		
		private var comparisonRendererDirty:Boolean = true;
		
		[Bindable(event="comparisonItemsChange")]
		/**
		 * The ComparisonItems generated from the dataProvider.
		 */
		public function get comparisonItems():Array
		{
			return _comparisonItems;
		}
		protected function set _comparisonItems(value:Array):void
		{
			if(value != __comparisonItems)
			{
				__comparisonItems = value;
				dispatchEvent(new Event("comparisonItemsChange"));
			}
		}
		protected function get _comparisonItems():Array
		{
			return __comparisonItems;
		}
		private var __comparisonItems:Array;
		
		[Bindable(event="showLabelsChange")]
		/**
		 * Whether or not labels should be shown along the diagonal of the ComparisonMatrix
		 */
		public function set showLabels(value:Boolean):void
		{
			if(value != _showLabels)
			{
				_showLabels = value;
				invalidateSize();
				invalidateDisplayList();
				dispatchEvent(new Event("showLabelsChange"));
			}
		}
		public function get showLabels():Boolean
		{
			return _showLabels;
		}
		private var _showLabels:Boolean = true;
		
		[Bindable(event="cellSizeChange")]
		/**
		 * The desired size of each cell. This is respected as long as the ComparisonMatrix
		 * has enough room to render all the cells at the specified size.
		 */
		public function set cellSize(value:Number):void
		{
			if(value != explicitCellSize)
			{
				explicitCellSize = value;
				invalidateSize();
				invalidateDisplayList();
				dispatchEvent(new Event("cellSizeChange"));
			}
		}
		public function get cellSize():Number
		{
			return actualCellSize;
		}
		private var explicitCellSize:Number;
		
		/**
		 * The actual size of each cell as found by computeCellSize. 
		 */
		private var actualCellSize:Number;
		
		[Bindable(event="fieldLabelFunctionChange")]
		/**
		 * The function used to determine what text should be shown in the labels
		 * along the edges of the ComparisonMatrix. The function should take
		 * a String -- the current attribute that the ComparisonMatrix is operating on --
		 * and return a String -- the label that should be used for that attribute.
		 */
		public function set fieldLabelFunction(value:Function):void
		{
			if(value != _fieldLabelFunction)
			{
				_fieldLabelFunction = value;
				invalidateDisplayList();
				dispatchEvent(new Event("fieldLabelFunctionChange"));
			}
		}
		public function get fieldLabelFunction():Function
		{
			return _fieldLabelFunction;
		}
		private var _fieldLabelFunction:Function;
		
		[Bindable(event="cellLabelFunctionChange")]
		/**
		 * The function used to determine what text should be shown in each cell.
		 * It is passed down to each comparisonRenderer. For details see the
		 * documentation on IComparisonRenderer.labelFunction.
		 */
		public function set cellLabelFunction(value:Function):void
		{
			if(value != _cellLabelFunction)
			{
				_cellLabelFunction = value;
				invalidateDisplayList();
				dispatchEvent(new Event("cellLabelFunctionChange"));
			}
		}
		public function get cellLabelFunction():Function
		{
			return _cellLabelFunction;
		}
		private var _cellLabelFunction:Function;
		
		[Bindable(event="toolTipFunctionChange")]
		/**
		 * The function used to determine what text should be shown in the
		 * toolTip for each cell. The default behavior is to use a String
		 * of the format
		 * 
		 * xField + "\n"+ yField + "\n" + comparisonValue
		 * 
		 * where comparisonValue is rounded to four decimal places.
		 */
		public function set toolTipFunction(value:Function):void
		{
			if(value != _toolTipFunction)
			{
				_toolTipFunction = value;
				invalidateDisplayList();
				dispatchEvent(new Event("toolTipFunctionChange"));
			}
		}
		public function get toolTipFunction():Function
		{
			return _toolTipFunction;
		}
		private var _toolTipFunction:Function;
		
		[Bindable(event="alphaFunctionChange")]
		/**
		 * A function used to determine the alpha value of then interior of each comparisonRenderer.
		 * For details see IComparisonRenderer.alphaFunction.
		 */
		public function set alphaFunction(value:Function):void
		{
			if(value != _alphaFunction)
			{
				_alphaFunction = value;
				invalidateDisplayList();
				dispatchEvent(new Event("alphaFunctionChange"));
			}
		}
		public function get alphaFunction():Function
		{
			return _alphaFunction;
		}
		private var _alphaFunction:Function;
		
		[Bindable(event="colorFunctionChange")]
		/**
		 * A function used to determine the color of the interior of each IComparisonRenderer.
		 * For details see IComparisonRenderer.colorFunction.
		 */
		public function set colorFunction(value:Function):void
		{
			if(value != _colorFunction)
			{
				_colorFunction = value;
				invalidateDisplayList();
				dispatchEvent(new Event("colorFunctionChange"));
			}
		}
		public function get colorFunction():Function
		{
			return _colorFunction;
		}
		private var _colorFunction:Function;
		
		[Bindable(event="comparisonFunctionChange")]
		/**
		 * The function used to evaluate the relationship between attributes in the dataProvider.
		 * It should take an ArrayCollection and two Strings as arguments and return a Number
		 * representing the relationship between those attributes within the collection.
		 * 
		 * The returned Number need not be within any particular range. The default behavior
		 * of the functions in ComparisonMatrix and ComparisonMatrixCell expect a range between
		 * -1 and 1, but this can be manipulated through the colorFunction and alphaFunction
		 * propertyies. 
		 * 
		 * The default function is ComparisonMatrix.correlationCoefficent.
		 */
		public function set comparisonFunction(value:Function):void
		{
			if(value != _comparisonFunction)
			{
				_comparisonFunction = value;
				invalidateProperties();
				dispatchEvent(new Event("comparisonFunctionChange"));
			}
		}
		public function get comparisonFunction():Function
		{
			return _comparisonFunction;
		}
		private var _comparisonFunction:Function = correlationCoefficent;
		
		[Bindable(event="selectedItemChange")]
		/**
		 * The selected ComparisonItem
		 */
		public function set selectedItem(value:ComparisonItem):void
		{
			if(value != _selectedItem)
			{
				_selectedItem = value;
				invalidateDisplayList();
				dispatchEvent(new Event("selectedItemChange"));
			}
		}
		public function get selectedItem():ComparisonItem
		{
			return _selectedItem;
		}
		private var _selectedItem:ComparisonItem;
		
		[Bindable(event="fieldsChange")]
		/**
		 * An array of attributes the ComparisonMatrix should consider when evaluating
		 * the relationships in the dataProvider.
		 */
		public function set fields(value:Array):void
		{
			if(value == null)
				value = [];
			if(value != _fields)
			{
				_fields = value;
				invalidateProperties();
				invalidateDisplayList();
				comparisonsDirty = true;
				dispatchEvent(new Event("fieldsChange"));
			}
		}
		public function get fields():Array
		{
			return _fields;
		}
		private var _fields:Array = [];
		
		/**
		 * Whether or not the relationships between the attributes need to be re-evaluated.
		 */
		private var comparisonsDirty:Boolean = true;
		
		[Bindable(event="dataProviderChange")]
		/**
		 * An ArrayCollection of Objects the ComparisonMatrix should operate on.
		 */
		public function set dataProvider(value:Object):void
		{
			var collection:ArrayCollection;
			if(value is ArrayCollection)
			{
				collection = value as ArrayCollection;
			}
			else if(value is Array)
			{
				if(_dataProvider)
				{
					if(_dataProvider.source == value)
						return;
				}
				collection = new ArrayCollection(value as Array);
			}
			
			if(collection != _dataProvider)
			{
				if(_dataProvider)
					_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,handleCollectionChange);
				_dataProvider = collection;
				if(_dataProvider)
					_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,handleCollectionChange);
				comparisonsDirty = true;
				invalidateProperties();
				invalidateDisplayList();
				dispatchEvent(new Event("dataProviderChange"));
			}
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		private var _dataProvider:ArrayCollection;
		
		/**
		 * Handler for when the dataProvider's COLLECTION_CHANGE event.
		 * 
		 * Any change in the dataProvider could require re-running the comparisons.
		 */
		protected function handleCollectionChange(event:CollectionEvent):void
		{
			comparisonsDirty = true;
			invalidateProperties();
		}
		
		/**
		 * Evaluates the correlation coefficent between the xField and yField properties
		 * on the Objects in the collection.
		 */
		public static function correlationCoefficent(collection:ArrayCollection, xField:String, yField:String):Number
		{
			var len:Number = collection.length;
			var xTotal:Number = 0;
			var yTotal:Number = 0;
			var xSquaredTotal:Number = 0;
			var ySquaredTotal:Number = 0;
			var xYTotal:Number = 0;
			for each(var o:Object in collection)
			{
				var xValue:Number = o[xField];
				var yValue:Number = o[yField];
				xTotal += xValue;
				yTotal += yValue;
				xSquaredTotal += Math.pow(xValue,2);
				ySquaredTotal += Math.pow(yValue,2);
				xYTotal += xValue * yValue;
			}
			var top:Number = (len * xYTotal) - (xTotal * yTotal);
			var bottomLeft:Number = Math.sqrt( (len * xSquaredTotal) - Math.pow(xTotal,2) );
			var bottomRight:Number = Math.sqrt( (len * ySquaredTotal) - Math.pow(yTotal,2) );
			return top/(bottomLeft * bottomRight);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(comparisonsDirty)
			{
				comparisonRendererDirty = true;
				generateComparisonStatistics();
				comparisonsDirty = false;
			}
			if(comparisonRendererDirty)
			{
				createOrRemoveCells();
				updateTextFields();
				comparisonRendererDirty = false;				
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			// If the user has specified a cellSize we can measure the width and height of the entire matrix 
			if(!isNaN(explicitCellSize))
			{
				var totalCellSize:Number = explicitCellSize * (fields.length - 1);
				measuredHeight = totalCellSize;
				measuredWidth = totalCellSize;
				if(showLabels && textFields.length > 0)
				{
					measuredHeight += textFields[0].height;
					measuredWidth += textFields[textFields.length - 1].width; 
				}
			}
			
			// If cellSize hasn't been specified we'll just default to a 400x400 matrix, give or take
			else
			{
				measuredWidth = 400;
				measuredHeight = 400;
				if(!isNaN(explicitCellSize) || (showLabels && textFields.length > 0))
				{
					var measuredCellSize:Number = computeCellSize(measuredWidth,measuredHeight);
					measuredHeight = measuredCellSize * (fields.length - 1);
					if(showLabels && textFields.length > 0)
						measuredHeight += textFields[0].height;
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			actualCellSize = computeCellSize(width,height);
				
			if(showLabels && _dataProvider)
				layoutTextFields();
			else
				hideTextFields();
			
			if(_dataProvider)
				layoutCells();
		}
		
		/**
		 * Evaluate the relationship between each pair of attributes in the fields Array
		 * using the comparisonFunction. 
		 */
		protected function generateComparisonStatistics():void
		{
			_comparisonItems = new Array();
			if(fields.length == 0 || dataProvider == null || dataProvider.length == 0)
				return;
			
			var len:int = fields.length;
			var index:int = 0;
			for(var a:int = 0; a < len; a++)
			{
				for(var b:int = 0; b < a + 1;  b++)
				{
					if(a != b)
					{
						var item:ComparisonItem = new ComparisonItem();
						item.xField = fields[a];
						item.yField = fields[b];
						item.comparisonValue = comparisonFunction.apply(this,[dataProvider,item.xField,item.yField]);
						item.dataProvider = _dataProvider;
						_comparisonItems.push(item);
						index++;
					}
				}
			}
		}
		
		/**
		 * Determine the size of each cell based on available width and height and
		 * the user specified cell size.
		 */
		protected function computeCellSize(width:Number,height:Number):int
		{
			var availableWidthForCells:Number = width;
			var availableHeightForCells:Number = height;
			if(showLabels && textFields.length > 0)
			{
				availableWidthForCells = width - textFields[textFields.length - 1].width;
				availableHeightForCells = height - textFields[0].height;
			}
			else
			{
				availableWidthForCells = width;
				availableHeightForCells = height;
			}
			var measuredCellSize:Number = Math.min(availableWidthForCells,availableHeightForCells) / (fields.length - 1);

			if(!isNaN(explicitCellSize))
				return int(Math.min(measuredCellSize,explicitCellSize));
			else
				return int(measuredCellSize);
		}
		
		/**
		 * Add or remove comparisonRenderers so there is one for each comparisonItem.
		 */
		protected function createOrRemoveCells():void
		{
			if(comparisonRendererDirty)
				removeAllCells();
			
			var len:int = _comparisonItems.length;
			while(cells.length < len)
			{
				var cellToAdd:IComparisonRenderer = comparisonRenderer.newInstance() as IComparisonRenderer;
				cellToAdd.addEventListener(MouseEvent.CLICK, handleCellClick, false, 0, true);
				cells.push(cellToAdd);
				addChild(cellToAdd as DisplayObject);
			}
			while(len < cells.length)
			{
				var cellToRemove:IComparisonRenderer = IComparisonRenderer(cells.pop());
				removeChild(cellToRemove as DisplayObject);
			}
		}
		
		protected function removeAllCells():void
		{
			while(cells.length > 0)
			{
				var cellToRemove:IComparisonRenderer = IComparisonRenderer(cells.pop());
				removeChild(cellToRemove as DisplayObject);
			}
		}
		
		/**
		 * Add or remove textFields as needed to match the number of fields.
		 */
		protected function updateTextFields():void
		{
			var len:int = fields.length;
			for(var a:int = 0; a < len; a++)
			{
				var textField:UITextField;
				if(textFields.length < a + 1)
				{
					var textFieldToAdd:UITextField = new UITextField();
					textFields.push(textFieldToAdd);
					addChild(textFieldToAdd);
				}
				textField = UITextField(textFields[a]);
				if(fieldLabelFunction != null)
					textField.text = fieldLabelFunction.apply(this,[fields[a]]);
				else
					textField.text = fields[a];
				
				var metrics:TextLineMetrics = textField.getLineMetrics(0);
				textField.width = metrics.width + 4;
				textField.height = metrics.height + 2;
			}
			while(len < textFields.length)
			{
				var textFieldToRemove:UITextField = UITextField(textFields.pop());
				removeChild(textFieldToRemove);
			}
		}
		
		/**
		 * Position the textFields along the edges of the matrix.
		 */
		protected function layoutTextFields():void
		{
			var len:int = textFields.length;
			if(len > 0)
			{
				var firstTextField:UITextField = textFields[0] as UITextField;
				var startY:Number = firstTextField.height;
				
				for(var a:int = 0; a < len; a++)
				{
					var textField:UITextField = UITextField(textFields[a]);
					textField.x = a * cellSize + 1;
					if(a == 0)
						textField.y = 0;
					else
						textField.y = (a - 1) * cellSize + startY; 
					textField.visible = true;
				}
			}
		}
		
		/**
		 * Just set each textField's visible property to false.
		 */
		protected function hideTextFields():void
		{
			for each(var textField:UITextField in textFields)
			{
				textField.visible = false;
			}
		}
		
		/**
		 * Arrange the cells in a stair-step fashion.
		 */
		protected function layoutCells():void
		{
			var nf:NumberFormatter = new NumberFormatter();
			nf.precision = 4;
			
			var startY:Number = 0;
			if(showLabels && textFields.length > 0)
			{
				var firstTextField:UITextField = textFields[0] as UITextField;
				startY = firstTextField.y + firstTextField.height;
			}
			
			var len:int = fields.length;
			var index:int = 0;
			for(var a:int = 0; a < len; a++)
			{
				for(var b:int = 0; b < a + 1;  b++)
				{
					if(a != b)
					{
						var item:ComparisonItem = _comparisonItems[index] as ComparisonItem;
						
						var cell:IComparisonRenderer = IComparisonRenderer(cells[index]);
						cell.comparisonItem = item;
						cell.labelFunction = cellLabelFunction;
						cell.colorFunction = colorFunction;
						cell.alphaFunction = alphaFunction;
						cell.selected = item == selectedItem;
						
						// toolTip isn't a part of IUIComponent, interesting, eh?
						if(cell is UIComponent)
						{
							var tt:String = "";
							if(toolTipFunction != null)
								tt = toolTipFunction.apply(this,[item]);
							else				
								tt = item.xField + "\n" + item.yField + "\n" + nf.format(item.comparisonValue);
							(cell as UIComponent).toolTip = tt;
						}
						
						var cellX:Number = b * cellSize;
						var cellY:Number = (a - 1) * cellSize + startY;
						cell.move(cellX,cellY);
						cell.setActualSize(actualCellSize,actualCellSize);
						
						index++;
					}
				}
			}
		}
		
		/**
		 * Update the selectedItem when the user clicks on a cell.
		 */
		protected function handleCellClick(event:MouseEvent):void
		{
			var clickedCell:IComparisonRenderer = event.currentTarget as IComparisonRenderer;
			selectedItem = clickedCell.comparisonItem;
		}
		
		public function invalidateCells():void
		{
			for each(var cell:IComparisonRenderer in cells)
			{
				if(cell is UIComponent)
					UIComponent(cell).invalidateDisplayList();
			}
		}
	}
}