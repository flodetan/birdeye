package birdeye.vis.elements
{
	import birdeye.vis.VisScene;
	import birdeye.vis.elements.collision.StackElement;
	import birdeye.vis.elements.events.ElementDataItemsChangeEvent;
	import birdeye.vis.interfaces.coords.ICoordinates;
	import birdeye.vis.interfaces.coords.IValidatingCoordinates;
	import birdeye.vis.interfaces.elements.IDataElement;
	import birdeye.vis.interfaces.scales.IEnumerableScale;
	import birdeye.vis.interfaces.scales.INumerableScale;
	import birdeye.vis.interfaces.scales.IScale;
	
	import com.degrafa.Surface;
	
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	
	import org.greenthreads.ThreadProcessor;
	
	/**
	 * This class defines the basic data elements for an element.</br>
	 * This consists of:</br>
	 * scales</br>
	 * dataProvider</br>
	 * data centric functions and setters/getters</br>
	 * </br>
	 * <b>This is an abstract class</b>
	 */
	public class BaseDataElement extends Surface implements IDataElement
	{
		public static const DIM1:String = "dim1";
		public static const DIM2:String = "dim2";
		public static const DIM3:String = "dim3";
		public static const COLOR_FIELD:String = "colorField";
		public static const SIZE_FIELD:String = "sizeField";
		public static const SIZE_START_FIELD:String = "sizeStartField";
		public static const SIZE_END_FIELD:String = "sizeEndField";
		public static const SPLIT_FIELD:String = "splitField";
		public static const LABEL_FIELD:String = "labelField";
		public static const DIM_START:String = "dimStart";
		public static const DIM_END:String = "dimEnd";
		public static const DIM_NAME:String = "dimName";
		public static var fieldsNames:Array = [DIM1, DIM2, DIM3, COLOR_FIELD, SIZE_FIELD, SIZE_START_FIELD, SIZE_END_FIELD, SPLIT_FIELD, LABEL_FIELD, DIM_START, DIM_END, DIM_NAME];

		
		public static const SCALE1:String = "scale1";
		public static const SCALE2:String = "scale2";
		
		public var dataFields:Array;

	
		public function BaseDataElement()
		{
			super();
			
			collisionScale = SCALE2;
			
			dataFields = [];
			// prepare data for a standard tooltip message in case the user
			// has not set a dataTipFunction
			dataFields[DIM1] = dim1;
			dataFields[DIM2] = dim2;
			dataFields[DIM3] = dim3;
			dataFields[COLOR_FIELD] = colorField;
			dataFields[SIZE_FIELD] = sizeField;
			dataFields[SIZE_START_FIELD] = sizeStartField;
			dataFields[SIZE_END_FIELD] = sizeEndField;
			dataFields[SPLIT_FIELD] = splitField;
			dataFields[LABEL_FIELD] = labelField;
			dataFields[DIM_NAME] = dimName;
		}
		
		/*
		* BASE Getters and setters
		*/
		private var _chart:ICoordinates;
		public function set visScene(val:ICoordinates):void
		{
			_chart = val;
			invalidateProperties();
		}
		public function get visScene():ICoordinates
		{
			return _chart;
		}

		// collisionType is here because it has influence on data specific stuff		
		protected var _collisionType:String = StackElement.OVERLAID;
		/** Define the type of collisions in case the dimN involves more than one data.*/
		[Inspectable(enumeration="overlaid,cluster,stack")]
		public function set collisionType(val:String):void
		{
			_collisionType = val;
			invalidateDisplayList();
		}
		public function get collisionType():String
		{
			return _collisionType;
		}

		
		/*
		* DATA CENTRIC Getters and setters
		*/
		
		private var _filter1:*;
		/** Implement filtering for data values on dim1. The filter can be a String an Array or a 
		 * function.*/
		public function set filter1(val:*):void
		{
			_filter1 = val;
			invalidatingDisplay();
		}
		
		private var _filter2:*;
		/** Implement filtering for data values on dim2. The filter can be a String an Array or a 
		 * function.*/
		public function set filter2(val:*):void
		{
			_filter2 = val;
			invalidatingDisplay();
		}
		
		private var _dimName:String;
		public function set dimName(val:String):void {
			_dimName = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		public function get dimName():String {
			return _dimName;
		}
		
		private var _dim1:Object;
		public function set dim1(val:Object):void
		{
			_dim1= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim1():Object
		{
			return _dim1;
		}
		
		private var _dim2:Object;
		public function set dim2(val:Object):void
		{
			_dim2= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim2():Object
		{
			return _dim2;
		}
		
		private var _dim3:String;
		public function set dim3(val:String):void
		{
			_dim3= val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get dim3():String
		{
			return _dim3;
		}
		
		private var _colorField:String;
		public function set colorField(val:String):void
		{
			_colorField = val;
			invalidatingDisplay();
		}
		public function get colorField():String
		{
			return _colorField;
		}
		
		private var _sizeField:Object;
		public function set sizeField(val:Object):void
		{
			_sizeField = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get sizeField():Object
		{
			return _sizeField;
		}
		
		protected var _sizeStartField:String;
		public function set sizeStartField(val:String):void {
			_sizeStartField = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get sizeStartField():String {
			return _sizeStartField;
		}
		
		protected var _sizeEndField:String;
		public function set sizeEndField(val:String):void	{
			_sizeEndField = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get sizeEndField():String {
			return _sizeEndField;
		}

		protected var _splitField:String;
		/** This field allows to define the data needed to separate paths sequences according
		 * the specified field. If no field is specified, than the whole data will be considered
		 * as a unique sequential group.*/
		public function set splitField(val:String):void
		{
			_splitField = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get splitField():String
		{
			return _splitField;
		}

		protected var labelCreationNotOverridden:Boolean = true;
		private var _labelField:String;
		public function set labelField(val:String):void
		{
			_labelField = val;
			invalidatingDisplay();
		}
		public function get labelField():String
		{
			return _labelField;
		}
		
		protected var invalidatedData:Boolean = false;
		private var _cursor:IViewCursor;
		protected var _dataProvider:Object=null;
		/** Set the data provider for the series, if the series doesn't have its own dataProvider
		 * than it will automatically take the chart data provider. It's not necessary
		 * to specify the chart data provider, and it's recommended not to do it. */
		public function set dataProvider(value:Object):void
		{
			if (value is Vector.<Object>)
			{
				dataItems = value as Vector.<Object>;
				
			} else {
				//_dataProvider = value;
				if(typeof(value) == "string")
				{
					//string becomes XML
					value = new XML(value);
				}
				else if(value is XMLNode)
				{
					//AS2-style XMLNodes become AS3 XML
					value = new XML(XMLNode(value).toString());
				}
				else if(value is XMLList)
				{
					if(XMLList(value).children().length()>0){
						value = new XMLListCollection(value.children() as XMLList);
					}else{
						value = new XMLListCollection(value as XMLList);
					}
				}
				else if(value is Array)
				{
					value = new ArrayCollection(value as Array);
				}
				
				if(value is XML)
				{
					var list:XMLList = new XMLList();
					list += value;
					this._dataProvider = new XMLListCollection(list.children());
				}
					//if already a collection dont make new one
				else if(value is ICollectionView)
				{
					this._dataProvider = ICollectionView(value);
				}else if(value is Object)
				{
					// convert to an array containing this one item
					this._dataProvider = new ArrayCollection( [value] );
				}
				else
				{
					this._dataProvider = new ArrayCollection();
				}
				
				if (ICollectionView(_dataProvider).length > 0)
				{
					_cursor = ICollectionView(_dataProvider).createCursor();
				}
			}
			// in case the chart is cartesian, we must invalidate 
			// also the chart properties and display list
			// to let the chart update with the element data provider change. in fact
			// the element dataprovider modifies the chart data and axes properties
			// therefore it modifies the chart properties and displaying
			if (visScene is VisScene)
			{
				VisScene(visScene).axesFeeded = false;
				VisScene(visScene).layoutsFeeded = false;
				VisScene(visScene).invalidateProperties();
				VisScene(visScene).invalidateDisplayList();
				
			}
			invalidatedData = true;
			invalidateProperties();
			invalidatingDisplay();
		}		
		/**
		 * Set the dataProvider to feed the chart. 
		 */
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		/*
		* SCALE CENTRIC Getters and setters
		*/
		
		private var _collisionScale:String;
		/** Set the scale that defines the 'direction' of the stack. For ex. BarElements are stacked horizontally with 
		 * stack100 and vertically with normal stack. Columns (for both polar and cartesians)
		 * are stacked vertically with stack100, and horizontally for normal stack.*/
		[Inspectable(enumeration="scale1,scale2")]
		public function set collisionScale(val:String):void
		{
			_collisionScale = val;
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get collisionScale():String
		{
			return _collisionScale;
		}
		
		private var _colorScale:IScale;
		/** Define an axis to set the colorField for data items.*/
		public function set colorScale(val:IScale):void
		{
			_colorScale = val;
			if (_colorScale is INumerableScale)
			{
				(_colorScale as INumerableScale).format = false;
			}
			
			invalidatingDisplay();
		}
		public function get colorScale():IScale
		{
			return _colorScale;
		}
		
		private var _sizeScale:INumerableScale;
		/** Define a scale to set the sizeField for data items.*/
		public function set sizeScale(val:INumerableScale):void
		{
			_sizeScale = val;
			_sizeScale.format = false;
			
			invalidatingDisplay();
		}
		public function get sizeScale():INumerableScale
		{
			return _sizeScale;
		}
		
		private var _scale1:IScale;
		public function set scale1(val:IScale):void
		{
			_scale1 = val;				
			
			if (_scale1)
			{
				BindingUtils.bindSetter(redraw, _scale1, "completeDataValues");
				BindingUtils.bindSetter(redraw, _scale1, "size");
			}
			
			invalidateProperties();
			invalidatingDisplay();
		}
		public function get scale1():IScale
		{
			return _scale1;
		}
		
		private var _scale2:IScale;
		public function set scale2(val:IScale):void
		{
			_scale2 = val;
			
			if (_scale2)
			{
				BindingUtils.bindSetter(redraw, _scale2, "completeDataValues");
				BindingUtils.bindSetter(redraw, _scale2, "size");
			}

			invalidateProperties();
			invalidatingDisplay();
		}
		public function get scale2():IScale
		{
			return _scale2;
		}
		
		
		protected function redraw(o:Object):void
		{

		}
		
		/*
		* INNER DATA Centric getters and setters
		* TODO These should have a namespace that is shared with the ICoordinates
		*/
		
		protected var _dataItems:Vector.<Object>;
		public function set dataItems(items:Vector.<Object>):void
		{
			const oldVal:Vector.<Object> = _dataItems;
			if (items !== oldVal) {
				_dataItems = items;
				initDataItemsById();
				_maxDim1Value = _maxDim2Value = _totalDim1PositiveValue = NaN;
				_minDim1Value = _minDim2Value = NaN;
				_minColorValue = _maxColorValue = _minSizeValue = _maxSizeValue = NaN;
				dispatchEvent(new ElementDataItemsChangeEvent(this, oldVal, items));
				invalidateProperties();
				invalidatingDisplay();
			}
		}
		public function get dataItems():Vector.<Object>
		{
			return _dataItems;
		}
		
		protected var _maxDim1Value:Number = NaN;
		public function get maxDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_maxDim1Value))
				_maxDim1Value = getMaxValue(dim1);
			return _maxDim1Value;
		}
		
		protected var _maxDim2Value:Number = NaN;
		public function get maxDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale) && isNaN(_maxDim2Value))
				_maxDim2Value = getMaxValue(dim2);
			return _maxDim2Value;
		}
		
		protected var _minDim1Value:Number = NaN;
		public function get minDim1Value():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_minDim1Value))
				_minDim1Value = getMinValue(dim1);
			return _minDim1Value;
		}
		
		protected var _minDim2Value:Number = NaN;
		public function get minDim2Value():Number
		{
			if (! (scale2 is IEnumerableScale) && isNaN(_minDim2Value))
				_minDim2Value = getMinValue(dim2);
			return _minDim2Value;
		}

		private var _totalDim1PositiveValue:Number = NaN;
		public function get totalDim1PositiveValue():Number
		{
			if (! (scale1 is IEnumerableScale) && isNaN(_totalDim1PositiveValue))
				_totalDim1PositiveValue = getTotalPositiveValue(dim1);
			return _totalDim1PositiveValue;
		}
		
		protected var _maxColorValue:Number = NaN;
		public function get maxColorValue():Number
		{
			_maxColorValue = getMaxValue(colorField);
			return _maxColorValue;
		}
		
		private var _minColorValue:Number = NaN;
		public function get minColorValue():Number
		{
			_minColorValue = getMinValue(colorField);
			return _minColorValue;
		}
		
		protected var _maxSizeValue:Number = NaN;
		public function get maxSizeValue():Number
		{
			if (_sizeField)
				_maxSizeValue = getMaxValue(_sizeField);
			else if (_sizeStartField && _sizeEndField)
				_maxSizeValue = getMaxValueOnAllFields([_sizeStartField, _sizeEndField]);
			return _maxSizeValue;
		}
		
		private var _minSizeValue:Number = NaN;
		public function get minSizeValue():Number
		{
			if (_sizeField)
				_minSizeValue = getMinValue(_sizeField);
			else if (_sizeStartField && _sizeEndField)
				_minSizeValue = getMinValueOnAllFields([_sizeStartField, _sizeEndField]);
			return _minSizeValue;
		}
		
		private var _nodeIdField:String;
		
		public function set nodeIdField(val:String):void {
			_nodeIdField = val;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		 * Name of the field of the input data containing the itemId.
		 **/
		public function get nodeIdField():String {
			return _nodeIdField;
		}
		
		
		
		/*
		* FUNCTIONS 
		*/
		
		/*
		* UI FLOW FUNCTIONS
		*/
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (invalidatedData && _cursor)
			{
				loadElementsValues();
				
				invalidatedData = false;
			}
		}
		
		protected var _invalidatedElementGraphic:Boolean = false;
		
		protected function invalidatingDisplay():void
		{
			_invalidatedElementGraphic = true;
			invalidateDisplayList();
		}
		
		protected function isReadyForLayout():Boolean
		{
			// verify than all element axes (or chart's if none owned by the element)
			// are ready. If they aren't the element can't be drawn, since data values
			// cannot be positioned yet in the axis.
			var axesCheck:Boolean = true;
			
			if (scale2)
			{
				if (scale2 is IEnumerableScale)
					axesCheck = Boolean(IEnumerableScale(scale2).dataProvider);
				
				axesCheck = axesCheck && (scale2.size>0);
			} 
			
			if (scale1)
			{
				if (scale1 is IEnumerableScale)
					axesCheck = axesCheck && Boolean(IEnumerableScale(scale1).dataProvider);
				
				axesCheck = axesCheck && (scale1.size>0);
			} 
			
			
			var globalCheck:Boolean = visScene && dataItems;
			
			return globalCheck && axesCheck;
		}
		
		
		
		/* 
		* DATA CENTRIC FUNCTIONS
		*/
		
		protected var _dataItemsByIds:Dictionary;
		
		public function getDataItemById(itemId:Object):Object {
			if (_dataItemsByIds) {
				return _dataItemsByIds[itemId];
			} else {
				return null;
			}
		}
		
		private function initDataItemsById():void {
			if (nodeIdField) {
				_dataItemsByIds = new Dictionary();
				for each (var item:Object in _dataItems) {
					_dataItemsByIds[item[nodeIdField]] = item;
				}
			} else {
				_dataItemsByIds = null;
			}
		}
		
		
		private function loadElementsValues():void
		{
			_cursor.seek(CursorBookmark.FIRST);
			const items:Vector.<Object> = new Vector.<Object>;
			var j:uint = 0;
			while (!_cursor.afterLast)
			{
				items[j++] = _cursor.current;
				_cursor.moveNext();
			}
			dataItems = items;
		}
		
		private var currentValue:Number;
		protected function getTotalPositiveValue(field:Object):Number
		{
			var tot:Number = NaN;
			if (dataItems && field)
			{
				var currentItem:Object;
				
				for (var cursIndex:uint = 0; cursIndex<dataItems.length; cursIndex++)
				{
					currentItem = dataItems[cursIndex];
					var tmpArray:Array = (dim1 is Array) ? dim1 as Array : [String(dim1)];
					
					for (var i:Number = 0; i<tmpArray.length; i++)
					{
						currentValue = currentItem[tmpArray[i]];
						if (!isNaN(currentValue) && currentValue > 0)
						{
							if (isNaN(tot))
								tot = currentValue;
							else
								tot += currentValue;
						}
					}
				}
			}
			return tot;
		}
		
		protected function getMinValue(field:Object):Number
		{
			var min:Number = NaN;
			
			if (field is Array)
			{
				var dims:Array = field as Array
				for (var i:Number = 0; i< dims.length; i++)
				{
					var tmpMin:Number = getMinV(dims[i]);
					if (isNaN(min))
						min = tmpMin;
					else 
						min = Math.min(min, tmpMin);
				}
			} else 
				min = getMinV(String(field));
			
			return min;
		}
		
		protected function getMaxValue(field:Object):Number
		{
			var max:Number = NaN;
			if (field is Array)
			{
				var dims:Array = field as Array
				for (var i:Number = 0; i< dims.length; i++)
				{
					var tmpMax:Number = getMaxV(dims[i]);
					if (isNaN(max))
						max = tmpMax;
					else {
						if (collisionType == StackElement.STACKED)
							max += Math.max(0,tmpMax);
						else 
							max = Math.max(max, tmpMax);
					}
				}
			} else 
				max = getMaxV(String(field));
			
			return max;
		}
		
		private function getMaxV(field:String):Number
		{
			var max:Number = NaN;
			if (dataItems && field)
			{
				var currentItem:Object;
				
				for (var cursIndex:uint = 0; cursIndex<dataItems.length; cursIndex++)
				{
					currentItem = dataItems[cursIndex];
					
					currentValue = currentItem[field];
					if ((isNaN(max) || max < currentValue) && !isNaN(currentValue))
						max = currentValue;
				}
			}
			return max
		}
		
		private function getMaxValueOnAllFields(fields:Array):Number
		{
			var max:Number = NaN;
			if (dataItems && fields)
			{
				var currentItem:Object;
				for (var cursIndex:uint = 0; cursIndex<dataItems.length; cursIndex++)
				{
					currentItem = dataItems[cursIndex];
					
					var tmpMax:Number = Number.MIN_VALUE;
					for each (var field:String in fields)
					if (isNaN(currentItem[field]))
					{
						tmpMax = NaN;
						break;
					} else 
						tmpMax = Math.max(currentItem[field], tmpMax);
					
					if ((isNaN(max) || max < tmpMax) && !isNaN(tmpMax))
						max = tmpMax;
				}
			}
			return max
		}
		
		private function getMinV(field:String):Number
		{
			var min:Number = NaN;
			
			if (dataItems && field)
			{
				var currentItem:Object;
				
				for (var cursIndex:uint = 0; cursIndex<dataItems.length; cursIndex++)
				{
					currentItem = dataItems[cursIndex];
					
					currentValue = currentItem[field];
					if ( (isNaN(min) || min > currentValue) && !isNaN(currentValue))
						min = currentValue;
				}
			}
			return min;
		}
		
		private function getMinValueOnAllFields(fields:Array):Number
		{
			var min:Number = NaN;
			if (dataItems && fields)
			{
				var currentItem:Object;
				for (var cursIndex:uint = 0; cursIndex<dataItems.length; cursIndex++)
				{
					currentItem = dataItems[cursIndex];
					
					var tmpMin:Number = Number.MAX_VALUE;
					for each (var field:String in fields)
					if (isNaN(currentItem[field]))
					{
						tmpMin = NaN;
						break;
					} else 
						tmpMin = Math.min(currentItem[field], tmpMin);
					
					if ((isNaN(min) || min > tmpMin) && !isNaN(tmpMin))
						min = tmpMin;
				}
			}
			return min;
		}
		
		protected static function getItemFieldValue(item:Object, fieldName:String):Object {
			var value:Object = item[fieldName];
			if (value is XMLList) {
				value = value.toString();
			}
			return value;
		}

	}
}