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
 
package birdeye.vis.source
{
	import __AS3__.vec.Vector;
	
	import birdeye.vis.data.DataSet;
	import birdeye.vis.interfaces.sources.ISource;
	
	import com.shortybmc.data.parser.CSV;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	
   	[Event(name="onLoadingCompleted")]
   	[Bindable]
	public class CSVTXT extends CSV implements ISource
	{
		private var _loadDataProvidersOnComplete:Boolean = true;
		[Inspectable(enumeration="true,false")]
		public function set loadDataOnComplete(val:Boolean):void
		{
			_loadDataProvidersOnComplete = val;
		}
		public function get loadDataProvidersOnComplete():Boolean
		{
			return _loadDataProvidersOnComplete;
		}
		
		private var _dataProviders:Array;
        [Inspectable(category="General", arrayType="birdeye.vis.data.DataSet")]
        [ArrayElementType("birdeye.vis.data.DataSet")]
		public function set dataProviders(val:Array):void
		{
			_dataProviders = val;
		}
		public function get dataProviders():Array
		{
			return _dataProviders;
		}
		
		private var _url:String;
		/** Set the url where to load the source.*/
		public function set url(val:String):void
		{
			_url = val;
			addEventListener(Event.COMPLETE, completeHandler);
			load(new URLRequest(url))
		}
		public function get url():String
		{
			return _url;
		}
		
		private var _id:String;
		/** Set the id to be assigned to the source.*/
		public function set id(val:String):void
		{
			_id = val;
		}
		public function get id():String
		{
			return _id;
		}
		
		public function CSVTXT()
		{
			super();
		}
		
		private function completeHandler(e:Event):void
		{
			if (_loadDataProvidersOnComplete)
			{
				var row:Array;
				var tmpVector:Vector.<Object> = new Vector.<Object>();
				
				for each (var dataSet:DataSet in dataProviders)
				{
					var tmpDataSet:Vector.<Object> = new Vector.<Object>();
					var fieldsIndexes:Array = dataSet.fieldsIndexes;
					if (!fieldsIndexes && dataSet.fields)
						fieldsIndexes = loadIndexes(dataSet.fields);
					
					for (var i:uint = 0; i<data.length; i++)
					{
						row = getRecordSet(i);
						
						var item:Object = new Object();
						for (var j:uint = 0; j<fieldsIndexes.length; j++)
						{
							item[dataSet.fields[j]] = row[j];
						}
						if (!dataSet.dataProvider)
							dataSet.dataProvider = new Vector.<Object>();
						tmpDataSet.push(item);
					}
					dataSet.dataProvider = tmpDataSet;
				}
			}
			dispatchEvent(new Event("onLoadingCompleted"));
		}
		
		private function loadIndexes(fields:Array):Array
		{
			var indexes:Array = [];
			for (var i:uint = 0; i<fields.length; i++) 
				indexes[i] = header.indexOf(fields[i]);

			return indexes;
		}
	}
}