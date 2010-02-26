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
		
	   /* The function nextLevel
		* retrieves a set of descendants in the given XML tree "tree".
		* The descendants are selected based on their names,
		* specified by the first part of the parameter "path".
		*/
		private function nextLevel(tree:XML, path:String, jump:Boolean):XMLList {
			//Take the first leg from the path (legs are separated by dots)
			var firstLeg:String = path.substring(0,path.indexOf("."));
			//Select XML children named like the first leg
			var elementName:QName = new QName(tree.namespace(),firstLeg);
			if (jump) { //Find not only direct children, but also grandchildren, great-grandchildren, etc
				return tree.descendants(elementName);
			} else { //Limit search to direct element children, i.e. not grandchildren, great-grandchildren, attributes etc
				return tree.elements(elementName);
			}
		}

	   /* The function recurTreePath
		* recursively goes down through an XML tree "tree"
		* to the level specified by "jumpPath" and "nonJumpPath"
		* then applies function "f" on each subtree at that level
		*/
		private function recurTreePath(tree:XML, jumpPath:String, nonJumpPath:String, f:Function, params:Array):void {	
			var remainingLegs:String;
			//Jump to the descendants specified in jumpPath
			if (jumpPath.length > 0) {
				remainingLegs = jumpPath.substring(jumpPath.indexOf(".")+1); //Cut away the first leg of jumpPath, i.e. the part before the first dot
				for each ( var jumpedSubTree:XML in nextLevel(tree,jumpPath,true) ) {
					recurTreePath(jumpedSubTree, remainingLegs, nonJumpPath, f, params); //Recursive call, will continue until jumpPath is consumed
				}									
			//If no jump to do, proceed with the nonJumpPath
			} else if (nonJumpPath.length > 0) {
				remainingLegs = nonJumpPath.substring(nonJumpPath.indexOf(".")+1); //Cut away the first leg of nonJumpPath, i.e. the part before the first dot
				for each ( var subTree:XML in nextLevel(tree,nonJumpPath,false) ) {
					recurTreePath(subTree, jumpPath, remainingLegs, f, params); //Recursive call, will continue until nonJumpPath is consumed
				}
			//If already reached the desired level
			} else if (nonJumpPath.length == 0) {
				f.call(null, tree, params); //Make the call
			
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
			var jumpPath:String = params[1];
			var nonJumpPath:String = params[2]; 
			
			//Get the country code from the XML
			var elementName:QName = new QName(countryTree.namespace(),countryCodeMarker);
			var countryCode:String = countryTree.elements(elementName);
			_longLatPolygons[countryCode]=new Array(0);
			//Put countryCode into an Array "args"
			//, so that it can be passed to function "parsePolygon"
			var args:Array = [countryCode];
			
			recurTreePath(countryTree, jumpPath, nonJumpPath, parsePolygon, args);
		}
		
	   /* The function parsePolygonKML
		* goes down through the KML tree and
		* picks up the country code from each "countryCodeMarker" element at level "pathToCountry"
		* then continues down to level "subCountryPath" and
		* fetches the coordinates for each country into global variable "_longLatPolygons"
		*/
		public function parsePolygonKML(kml:XML, countryCodeMarker:String, pathToCountry:String, jumpPath:String, nonJumpPath:String):void {
			//Put countryCodeMarker and subCountryPath into an Array "params"
			//, so that they can be passed to function "parseCountryPolygons"
			var params:Array = [countryCodeMarker,jumpPath,nonJumpPath];
			
			//For each subtree on the "pathToCountry" level, execute "parseCountryPolygons"
			recurTreePath(kml, "", pathToCountry, parseCountryPolygons, params);
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
			var jumpPath:String = params[1];
			var nonJumpPath:String = params[2]; 
			
			//Get the country code from the XML
			var elementName:QName = new QName(countryTree.namespace(),countryCodeMarker);
			var countryCode:String = countryTree.elements(elementName);
			_longLatBaryCenters[countryCode]=new Array(0);
			
			//Put countryCode into an Array "args"
			//, so that it can be passed to function "parsePolygon"
			var args:Array = [countryCode];

			recurTreePath(countryTree, jumpPath, nonJumpPath, parsePoint, args);			
		}
		
	   /* The function parseBaryCenterKML
		* goes down through the KML tree and
		* picks up the country code from each "countryCodeMarker" element at level "pathToCountry"
		* then continues down to level "jumpPath", then level "nonJumpPath" and then
		* fetches the bary centre coordinates for each country into global variable "_longLatBaryCenters"
		*/
		public function parseBaryCenterKML(baryKml:XML, countryCodeMarker:String, pathToCountry:String, jumpPath:String, nonJumpPath:String):void{
			//Put countryCodeMarker, jumpPath and nonJumpPath into an Array "params"
			//, so that they can be passed to function "parseCountryBaryCenter"
			var params:Array = [countryCodeMarker,jumpPath,nonJumpPath];
			
			//For each subtree on the "pathToCountry" level, execute "parseCountryBaryCenter"
			recurTreePath(baryKml, "", pathToCountry, parseCountryBaryCenter, params);
		}

	}
}