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
 
 package birdeye.vis.source.kml.parser
{
	import birdeye.vis.data.Pair;

	public class KMLParser
	{

		private var _longLatPolygons:Array=new Array();
		public function set longLatPolygons(val:Array):void {
			_longLatPolygons = val;
		}
		public function get longLatPolygons():Array {
			return _longLatPolygons;
		}

		private var _longLatBaryCenters:Array=new Array();
		public function set longLatBaryCenters(val:Array):void {
			_longLatBaryCenters = val;
		}
		public function get longLatBaryCenters():Array {
			return _longLatBaryCenters;
		}

		public function KMLParser()
		{
		}

	   /* The function recurTreePath
		* recursively goes down through an XML tree "tree"
		* to the level specified by "path"
		* then applies function "f" on each subtree at that level
		*/
		private function recurTreePath(tree:XML, path:String, f:Function, params:Array):void {	
			if (path.length == 0) { //If already reached the desired level
				f.call(null, tree, params);
			} else if (path.length > 0) {
				//Split one leg at a time from the path (the legs are separated by dots)
				var dotIdx:int = path.indexOf(".");
				var firstLeg:String = path.substring(0,dotIdx);
				var remainingLegs:String = path.substring(dotIdx+1);
				//Recursive call, pursuing one leg after the other, until the whole path has been consumed
				var elementName:QName = new QName(tree.namespace(),firstLeg);
				for each (var subTree:XML in tree.elements(elementName) ) {
					recurTreePath(subTree, remainingLegs, f, params);
				}
			} else { //Should never happen
				trace ("ERROR: Too short path in function KMLParser.recurTreePath");
			}
		}

		private function convertToPair(element:*, index:int, arr:Array):void {
			var sep1:int = element.indexOf(",");
			var sep2:int = element.lastIndexOf(",");
			var long:String = element.substring(0,sep1);
			var lat:String = element.substring(sep1+1,sep2);
            arr[index] = new Pair(new Number(long), new Number(lat));
        }

	   /* The function parsePolygon
	    * is called for each polygon of a country.
	    * It retrieves the coordinates of the polygon
	    * from the KML file 
	    * and appends them to the _longLatPolygons array
	    */
		private function parsePolygon(p:XML, args:Array):void {
			var countryCode:String = args[0];

			var coordString:String = p.toString();
			var tripletArr:Array = coordString.split(" ");
			tripletArr.forEach(convertToPair);	//callout
            _longLatPolygons[countryCode].push(Vector.<Pair>(tripletArr));	//Append the polygon to _longLatPolygons
		}
		
	   /* The function parsePolygonKML
	    * is called for each country.
	    * It retrieves the polygons of the country
	    * from the KML file.
	    */
		private function parseCountryPolygons(countryTree:XML, params:Array):void {
			var countryCodeMarker:String = params[0];
			var subCountryPath:String = params[1];
			
			//Get the country code from the XML
			var elementName:QName = new QName(countryTree.namespace(),countryCodeMarker);
			var countryCode:String = countryTree.elements(elementName);
			_longLatPolygons[countryCode]=new Array(0);
			//Put countryCode into an Array "args"
			//, so that it can be passed to function "parsePolygon"
			var args:Array = new Array(2);
			args[0] = countryCode;
			
			//Do the first recursion step here, and use the function
			//"XML.descendants" instead of "XML.elements"
			var dotIdx:int = subCountryPath.indexOf(".");
			var firstLeg:String = subCountryPath.substring(0,dotIdx);
			var remainingLegs:String = subCountryPath.substring(dotIdx+1);
			elementName = new QName(countryTree.namespace(),firstLeg);
			for each (var polygon:XML in countryTree.descendants(elementName)) {
				recurTreePath(polygon, remainingLegs, parsePolygon, args);
			}
		}
		
	   /* The function parsePolygonKML
		* goes down through the KML tree and
		* picks up the country code from each "countryCodeMarker" element at level "pathToCountry"
		* then continues down to level "subCountryPath" and
		* fetches the coordinates for each country into global variable "_longLatPolygons"
		*/
		public function parsePolygonKML(kml:XML,pathToCountry:String, countryCodeMarker:String, subCountryPath:String):void {
			//Put countryCodeMarker and subCountryPath into an Array "params"
			//, so that they can be passed to function "parseCountryPolygons"
			var params:Array = [countryCodeMarker,subCountryPath];
			
			//For each subtree on the "pathToCountry" level, execute "parseCountryPolygons"
			recurTreePath(kml, pathToCountry, parseCountryPolygons, params);
		}

	   /* The function parsePoint
	    * is called for the Point specifying the bary centre of a country.
	    * It retrieves the coordinates of the bary centre
	    * from the KML file 
	    * and appends it to the _longLatBaryCenters array
	    */
		private function parsePoint(p:XML, args:Array):void {
			var countryCode:String = args[0];
			var coordString:String = p.toString();
			var sep:int = coordString.indexOf(",");
			var long:String = coordString.substring(0,sep);
			var lat:String = coordString.substring(sep+1);
            var point:Pair = new Pair(new Number(long), new Number(lat));
			
            _longLatBaryCenters[countryCode].push(point);	//Add the point to _longLatBaryCenters
		}

	   /* The function parseCountryBaryCenter
	    * is called for each country.
	    * It retrieves the bary centre of the country
	    * from the KML file.
	    */
		private function parseCountryBaryCenter(countryTree:XML, params:Array):void {
			var countryCodeMarker:String = params[0];
			var subCountryPath:String = params[1];
			
			//Get the country code from the XML
			var elementName:QName = new QName(countryTree.namespace(),countryCodeMarker);
			var countryCode:String = countryTree.elements(elementName);
			_longLatBaryCenters[countryCode]=new Array(0);
			
			//Put countryCode into an Array "args"
			//, so that it can be passed to function "parsePolygon"
			var args:Array = new Array(2);
			args[0] = countryCode;

			recurTreePath(countryTree, subCountryPath, parsePoint, args);			
		}
		
	   /* The function parseBaryCenterKML
		* goes down through the KML tree and
		* picks up the country code from each "countryCodeMarker" element at level "pathToCountry"
		* then continues down to level "subCountryPath" and
		* fetches the bary centre coordinates for each country into global variable "_longLatBaryCenters"
		*/
		public function parseBaryCenterKML(baryKml:XML,pathToCountry:String, countryCodeMarker:String, subCountryPath:String):void{
			//Put countryCodeMarker and subCountryPath into an Array "params"
			//, so that they can be passed to function "parseCountryBaryCenter"
			var params:Array = [countryCodeMarker,subCountryPath];
			
			//For each subtree on the "pathToCountry" level, execute "parseCountryBaryCenter"
			recurTreePath(baryKml, pathToCountry, parseCountryBaryCenter, params);
		}

	}
}