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

package org.un.cava.birdeye.geo.dictionary
{
	public class USAStates
	{
		import flash.utils.Dictionary;
		import org.un.cava.birdeye.geo.dictionary.USARegionTypes;
		
		private var arrRegion:Array=[USARegionTypes.REGION_USA];
		
		//Regions
		private var arrUSA:Array=["HI","AK","FL","SC","GA","AL","NC","TN","RI","CT","MA","ME","NH","VT","NY","NJ","PA","DE","MD","WV","KY","OH","MI","WY","MT","ID","WA","TX","CA","AZ","NV","UT","CO","NM","OR","ND","SD","NE","IA","MS","IN","IL","MN","WI","MO","AR","OK","LA","VA","DC"];//"KN",
		
		//SubRegions
		
		private var dicCountriesNames:Dictionary= new Dictionary();
		
		/**
		* Dictionary class to define US State objects.
		* Definitions provided by standard state two-letter abbreviations. 
		**/
		public function USAStates()
		{
			super();
			setDicCountriesNames();
		}
		
		private function setDicCountriesNames():void
		{
			dicCountriesNames["AL"]="ALABAMA"
			dicCountriesNames["AK"]="ALASKA"
			dicCountriesNames["AS"]="AMERICAN SAMOA"
			dicCountriesNames["AZ"]="ARIZONA "
			dicCountriesNames["AR"]="ARKANSAS"
			dicCountriesNames["CA"]="CALIFORNIA "
			dicCountriesNames["CO"]="COLORADO "
			dicCountriesNames["CT"]="CONNECTICUT"
			dicCountriesNames["DE"]="DELAWARE"
			dicCountriesNames["DC"]="DISTRICT OF COLUMBIA"
			dicCountriesNames["FM"]="FEDERATED STATES OF MICRONESIA"
			dicCountriesNames["FL"]="FLORIDA"
			dicCountriesNames["GA"]="GEORGIA"
			dicCountriesNames["GU"]="GUAM "
			dicCountriesNames["HI"]="HAWAII"
			dicCountriesNames["ID"]="IDAHO"
			dicCountriesNames["IL"]="ILLINOIS"
			dicCountriesNames["IN"]="INDIANA"
			dicCountriesNames["IA"]="IOWA"
			dicCountriesNames["KS"]="KANSAS"
			dicCountriesNames["KY"]="KENTUCKY"
			dicCountriesNames["LA"]="LOUISIANA"
			dicCountriesNames["ME"]="MAINE"
			dicCountriesNames["MH"]="MARSHALL ISLANDS"
			dicCountriesNames["MD"]="MARYLAND"
			dicCountriesNames["MA"]="MASSACHUSETTS"
			dicCountriesNames["MI"]="MICHIGAN"
			dicCountriesNames["MN"]="MINNESOTA"
			dicCountriesNames["MS"]="MISSISSIPPI"
			dicCountriesNames["MO"]="MISSOURI"
			dicCountriesNames["MT"]="MONTANA"
			dicCountriesNames["NE"]="NEBRASKA"
			dicCountriesNames["NV"]="NEVADA"
			dicCountriesNames["NH"]="NEW HAMPSHIRE"
			dicCountriesNames["NJ"]="NEW JERSEY"
			dicCountriesNames["NM"]="NEW MEXICO"
			dicCountriesNames["NY"]="NEW YORK"
			dicCountriesNames["NC"]="NORTH CAROLINA"
			dicCountriesNames["ND"]="NORTH DAKOTA"
			dicCountriesNames["MP"]="NORTHERN MARIANA ISLANDS"
			dicCountriesNames["OH"]="OHIO"
			dicCountriesNames["OK"]="OKLAHOMA"
			dicCountriesNames["OR"]="OREGON"
			dicCountriesNames["PW"]="PALAU"
			dicCountriesNames["PA"]="PENNSYLVANIA"
			dicCountriesNames["PR"]="PUERTO RICO"
			dicCountriesNames["RI"]="RHODE ISLAND"
			dicCountriesNames["SC"]="SOUTH CAROLINA"
			dicCountriesNames["SD"]="SOUTH DAKOTA"
			dicCountriesNames["TN"]="TENNESSEE"
			dicCountriesNames["TX"]="TEXAS"
			dicCountriesNames["UT"]="UTAH"
			dicCountriesNames["VT"]="VERMONT"
			dicCountriesNames["VI"]="VIRGIN ISLANDS"
			dicCountriesNames["VA"]="VIRGINIA "
			dicCountriesNames["WA"]="WASHINGTON"
			dicCountriesNames["WV"]="WEST VIRGINIA"
			dicCountriesNames["WI"]="WISCONSIN"
			dicCountriesNames["WY"]="WYOMING"
		}
		
		public function getCountriesName(countryKey:String):String {
      		return dicCountriesNames[countryKey];
    	}
    	
    	public function getCountriesListByRegion(RegionKey:String):Array {
      		var arrRet:Array=new Array();
      		if(RegionKey=="USA"){
      			arrRet=arrUSA;
      		}
      		return arrRet;
    	}
    	
    	
	}
}