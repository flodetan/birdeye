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
	public class WorldCountries
	{
		import flash.utils.Dictionary;
		
		private var arrRegion:Array=[WorldRegionTypes.REGION_AFRICA, WorldRegionTypes.REGION_NORTH_AMERICA, WorldRegionTypes.REGION_SOUTH_AMERICA, WorldRegionTypes.REGION_ASIA, WorldRegionTypes.REGION_EUROPE, WorldRegionTypes.REGION_OCEANIA, WorldRegionTypes.REGION_WORLD];
		private var arrSubRegion:Array=["Africa", "NorthAmerica", "SouthAmerica","Asia", "Europe", "Oceania", "World"];//"Antartica", 
		
		//Regions
		private var arrWorld:Array=["ZWE","ZMB","ZAF","YEM","WSM","VUT","VNM","VIR","VGB","VEN","VCT","VAT","UZB","USA","URY","UKR","UGA","TZA","TWN","TUV","TUR","TUN","TTO","TON","TLS","TKM","TKL","TJK","THA","TGO","TCD","TCA","SYR","SYC","SWZ","SWE","SVN","SVK","SUR","STP","SRB","SOM","SMR","SLV","SLE","SLB","SJM","SGP","SEN","SDN","SAU","RWA","RUS","ROU","REU","QAT","PYF","PRY","PRT","PRK","PRI","POL","PNG","PLW","PHL","PER","PCN","PAN","PAK","OMN","NZL","NRU","NPL","NOR","NLD","NIU","NIC","NGA","NFK","NER","NCL","NAM","MYT","MYS","MWI","MUS","MTQ","MSR","MRT","MOZ","MNP","MNG","MNE","MMR","MLT","MLI","MKD","MHL","MEX","MDV","MDG","MDA","MCO","MAR","MAC","LVA","LUX","LTU","LSO","LKA","LIE","LCA","LBY","LBR","LBN","LAO","KWT","KOR","KNA","KIR","KHM","KGZ","KEN","KAZ","JPN","JOR","JAM","ITA","ISR","ISL","IRQ","IRN","IRL","IOT","IND","IMY","IDN","HUN","HTI","HRV","HND","HMD","HKG","GUY","GUM","GUF","GTM","GRL","GRD","GRC","GNQ","GNB","GMB","GLP","GIN","GIB","GHA","GEO","GBR","GAB","FSM","FRO","FRA","FLK","FJI","FIN","ETH","EST","ESP","ESH","ERI","EGY","ECU","DZA","DOM","DNK","DMA","DJI","DEU","CZE","CYP","CYM","CXR","CUB","CRI","CPV","COM","COL","COK","COG","COD","CMR","CIV","CHN","CHL","CHE","CCK","CAN","CAF","BWA","BVT","BTN","BRN","BRB","BRA","BOL","BMU","BLZ","BLR","BIH","BHS","BHR","BGR","BGD","BFA","BEN","BEL","BDI","AZE","AUT","AUS","ATG","ATF","ASM","ARM","ARG","ARE","ANT","AND","ALB","AIA","AGO","AFG","ABW"]
		//private var arrWorld:Array=["AFG","ALB","DZA","ASM","AND","AGO","AIA","ATG","ARG","ARM","ABW","AUS","AUT","AZE","BHS","BHR","BGD","BRB","BLR","BEL","BLZ","BEN","BMU","BTN","BOL","BIH","BWA","BVT","BRA","IOT","BRN","BGR","BFA","BDI","KHM","CMR","CAN","CPV","CYM","CAF","TCD","CHL","CHN","CXR","CCK","COL","COM","COG","COK","CRI","CIV","HRV","CUB","CYP","CZE","DNK","DJI","DMA","DOM","TMP","ECU","EGY","SLV","GNQ","ERI","EST","ETH","FLK","FRO","FJI","FIN","FRA","FXX","GUF","PYF","GAB","GMB","GEO","DEU","GHA","GIB","GRC","GRL","GRD","GLP","GUM","GTM","GIN","GNB","GUY","HTI","HMD","HND","HKG","HUN","ISL","IND","IDN","IRN","IRQ","IRL","ISR","ITA","JAM","JPN","JOR","KAZ","KEN","KIR","PRK","KOR","KWT","KGZ","LAO","LVA","LBN","LSO","LBR","LBY","LIE","LTU","LUX","MKD","MAC","MDG","MWI","MYS","MDV","MLI","MLT","MHL","MTQ","MRT","MUS","MYT","MEX","FSM","MDA","MCO","MNG","MSR","MAR","MOZ","MMR","NAM","NRU","NPL","NLD","ANT","NCL","NZL","NIC","NER","NGA","NIU","NFK","MNP","NOR","OMN","PAK","PLW","PAN","PNG","PRY","PER","PHL","PCN","POL","PRT","PRI","QAT","REU","ROM","RUS","RWA","LCA","WSM","SMR","STP","SAU","SEN","SYC","SLE","SGP","SVK","SVN","SLB","SOM","ZAF","SGS","ESP","LKA","SHN","SPM","KNA","VCT","SDN","SUR","SJM","SWZ","SWE","CHE","SYR","TWN","TJK","TZA","THA","TGO","TKL","TON","TTO","TUN","TUR","TKM","TCA","TUV","UGA","UKR","ARE","GBR","USA","UMI","URY","UZB","VUT","VAT","VEN","VNM","VGB","VIR","WLF","ESH","YEM","YUG","ZAR","ZMB","ZWE"];//"ATA","ATF",
		private var arrAfrica:Array=["DZA", "AGO", "BEN", "BWA", "BVT", "BFA", "BDI", "CMR", "CPV", "CAF", "TCD", "COM", "COG", "CIV", "DJI", "EGY", "GNQ", "ERI", "ETH", "GAB", "GMB", "GHA", "GIN", "GNB", "KEN", "LSO", "LBR", "LBY", "MDG", "MWI", "MLI", "MRT", "MUS", "MYT", "MAR", "MOZ", "NAM", "NER", "NGA", "PCN", "REU", "RWA", "STP", "SEN", "SYC", "SLE", "SOM", "ZAF", "SHN", "SDN", "SWZ", "TZA", "TGO", "TUN", "UGA", "ESH", "ZAR", "ZMB", "ZWE"];
		private var arrAntartica:Array=["ATA","ATF"];
		private var arrNorthAmerica:Array=["AIA", "ATG", "ABW", "BHS", "BRB", "BLZ", "BMU", "CAN", "CYM", "CRI", "CUB", "DMA", "DOM", "SLV", "GRD", "GLP", "GTM", "HTI", "HND", "JAM", "MTQ", "MEX", "NIC", "PAN", "PRI", "LCA", "SPM", "KNA", "VCT", "TCA", "USA", "UMI", "VGB", "VIR"];
		private var arrSouthAmerica:Array=["ARG", "BOL", "BRA", "CHL", "COL", "ECU", "FLK", "GUF", "GUY", "MSR", "ANT", "PRY", "PER", "SGS", "SUR", "TTO", "URY", "VEN"];
		private var arrAsia:Array=["AFG", "ASM", "BHR", "BGD", "BTN", "IOT", "BRN", "KHM", "CHN", "CXR", "CCK", "COK", "TMP", "FJI", "PYF", "GEO", "GUM", "HMD", "HKG", "IND", "IDN", "IRN", "IRQ", "ISR", "JPN", "JOR", "KAZ", "KIR", "PRK", "KOR", "KWT", "KGZ", "LAO", "LBN", "MAC", "MYS", "MDV", "MHL", "FSM", "MNG", "MMR", "NRU", "NPL", "NCL", "NIU", "NFK", "MNP", "OMN", "PAK", "PLW", "PNG", "PHL", "QAT", "RUS", "WSM", "SAU", "SGP", "SLB", "LKA", "SYR", "TWN", "TJK", "THA", "TKL", "TON", "TKM", "TUV", "ARE", "UZB", "VUT", "VNM", "WLF", "YEM"];
		private var arrEurope:Array=["ALB", "AND", "ARM", "AUT", "AZE", "BLR", "BEL", "BIH", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FRO", "FIN", "FRA", "FXX", "DEU", "GIB", "GRC", "GRL", "HUN", "ISL", "IRL", "ITA", "LVA", "LIE", "LTU", "LUX", "MKD", "MLT", "MDA", "MCO", "NLD", "NOR", "POL", "PRT", "ROM", "SMR", "SVK", "SVN", "ESP", "SJM", "SWE", "CHE", "TUR", "UKR", "GBR", "VAT", "YUG"];
		private var arrOceania:Array=["AUS","NZL"];
		
		//SubRegions
		
		private var dicCountriesNames:Dictionary= new Dictionary();
		
		/**
		* Dictionary class to define world, regional, subregional, and country objects.
		* Definitions provided by the United Nations geoscheme and ISO 3 letter abbreviations, e.g. FRA=FRANCE. 
		**/
		public function WorldCountries()
		{
			super();
			setDicCountriesNames();
		}
		
		private function setDicCountriesNames():void
		{
			dicCountriesNames["AFG"]="Afghanistan"
			dicCountriesNames["ALB"]="Albania"
			dicCountriesNames["DZA"]="Algeria"
			dicCountriesNames["ASM"]="American Samoa"
			dicCountriesNames["AND"]="Andorra"
			dicCountriesNames["AGO"]="Angola"
			dicCountriesNames["AIA"]="Anguilla"
			dicCountriesNames["ATA"]="Antartica"
			dicCountriesNames["ATG"]="Antigua & Barbuda"
			dicCountriesNames["ARG"]="Argentina"
			dicCountriesNames["ARM"]="Armenia"
			dicCountriesNames["ABW"]="Aruba"
			dicCountriesNames["AUS"]="Australia"
			dicCountriesNames["AUT"]="Austria"
			dicCountriesNames["AZE"]="Azerbaijan"
			dicCountriesNames["BHS"]="Bahamas"
			dicCountriesNames["BHR"]="Bahrain"
			dicCountriesNames["BGD"]="Bangladesh"
			dicCountriesNames["BRB"]="Barbados"
			dicCountriesNames["BLR"]="Belarus"
			dicCountriesNames["BEL"]="Belgium"
			dicCountriesNames["BLZ"]="Belize"
			dicCountriesNames["BEN"]="Benin"
			dicCountriesNames["BMU"]="Bermuda"
			dicCountriesNames["BTN"]="Bhutan"
			dicCountriesNames["BOL"]="Bolivia"
			dicCountriesNames["BIH"]="Bosnia And Herzegovina"
			dicCountriesNames["BWA"]="Botswana"
			dicCountriesNames["BVT"]="Bouvet Island"
			dicCountriesNames["BRA"]="Brazil"
			dicCountriesNames["IOT"]="British Indian Ocean Territory"
			dicCountriesNames["BRN"]="Brunei Darussalam"
			dicCountriesNames["BGR"]="Bulgaria"
			dicCountriesNames["BFA"]="Burkina Faso"
			dicCountriesNames["BDI"]="Burundi"
			dicCountriesNames["KHM"]="Cambodia"
			dicCountriesNames["CMR"]="Cameroon"
			dicCountriesNames["CAN"]="Canada"
			dicCountriesNames["CPV"]="Cape Verde"
			dicCountriesNames["CYM"]="Cayman Islands"
			dicCountriesNames["CAF"]="Central African Republic"
			dicCountriesNames["TCD"]="Chad"
			dicCountriesNames["CHL"]="Chile"
			dicCountriesNames["CHN"]="China"
			dicCountriesNames["CXR"]="Christmas Island"
			dicCountriesNames["CCK"]="Cocos (Keeling) Islands"
			dicCountriesNames["COL"]="Columbia"
			dicCountriesNames["COM"]="Comoros"
			dicCountriesNames["COG"]="Congo"
			dicCountriesNames["COK"]="Cook Islands"
			dicCountriesNames["CRI"]="Costa Rica"
			dicCountriesNames["CIV"]="Cote D'ivoire (Ivory Coast)"
			dicCountriesNames["HRV"]="Croatia"
			dicCountriesNames["CUB"]="Cuba"
			dicCountriesNames["CYP"]="Cyprus"
			dicCountriesNames["CZE"]="Czech Republic"
			dicCountriesNames["DNK"]="Denmark"
			dicCountriesNames["DJI"]="Djibouti"
			dicCountriesNames["DMA"]="Dominica"
			dicCountriesNames["DOM"]="Dominican Republic"
			dicCountriesNames["TMP"]="East Timor"
			dicCountriesNames["ECU"]="Ecuador"
			dicCountriesNames["EGY"]="Egypt"
			dicCountriesNames["SLV"]="El Salvador"
			dicCountriesNames["GNQ"]="Equatorial Guinea"
			dicCountriesNames["ERI"]="Eritrea"
			dicCountriesNames["EST"]="Estonia"
			dicCountriesNames["ETH"]="Ethiopia"
			dicCountriesNames["FLK"]="Falkland Islands (Malvinas)"
			dicCountriesNames["FRO"]="Faroe Islands"
			dicCountriesNames["FJI"]="Fiji"
			dicCountriesNames["FIN"]="Finland"
			dicCountriesNames["FRA"]="France"
			dicCountriesNames["FXX"]="France, Metropolitan"
			dicCountriesNames["GUF"]="French Guiana"
			dicCountriesNames["PYF"]="French Polynesia"
			dicCountriesNames["ATF"]="French Southern Territories"
			dicCountriesNames["GAB"]="Gabon"
			dicCountriesNames["GMB"]="Gambia"
			dicCountriesNames["GEO"]="Georgia"
			dicCountriesNames["DEU"]="Germany"
			dicCountriesNames["GHA"]="Ghana"
			dicCountriesNames["GIB"]="Gibralter"
			dicCountriesNames["GRC"]="Greece"
			dicCountriesNames["GRL"]="Greenland"
			dicCountriesNames["GRD"]="Grenada"
			dicCountriesNames["GLP"]="Guadeloupe"
			dicCountriesNames["GUM"]="Guam"
			dicCountriesNames["GTM"]="Guatemala"
			dicCountriesNames["GIN"]="Guinea"
			dicCountriesNames["GNB"]="Guinea Bissau"
			dicCountriesNames["GUY"]="Guyana"
			dicCountriesNames["HTI"]="Haiti"
			dicCountriesNames["HMD"]="Heard and McDonald Islands"
			dicCountriesNames["HND"]="Honduras"
			dicCountriesNames["HKG"]="Hong Kong"
			dicCountriesNames["HUN"]="Hungary"
			dicCountriesNames["ISL"]="Iceland"
			dicCountriesNames["IND"]="India"
			dicCountriesNames["IDN"]="Indonesia"
			dicCountriesNames["IRN"]="Iran"
			dicCountriesNames["IRQ"]="Iraq"
			dicCountriesNames["IRL"]="Ireland"
			dicCountriesNames["ISR"]="Israel"
			dicCountriesNames["ITA"]="Italy"
			dicCountriesNames["JAM"]="Jamaica"
			dicCountriesNames["JPN"]="Japan"
			dicCountriesNames["JOR"]="Jordan"
			dicCountriesNames["KAZ"]="Kazakhstan"
			dicCountriesNames["KEN"]="Kenya"
			dicCountriesNames["KIR"]="Kirabati"
			dicCountriesNames["PRK"]="Korea, Democratic People's Republic of"
			dicCountriesNames["KOR"]="Korea, Republic of"
			dicCountriesNames["KWT"]="Kuwait"
			dicCountriesNames["KGZ"]="Kyrgyzstan"
			dicCountriesNames["LAO"]="Laos, Peoples Democratic Republic of"
			dicCountriesNames["LVA"]="Latvia"
			dicCountriesNames["LBN"]="Lebanon"
			dicCountriesNames["LSO"]="Lesotho"
			dicCountriesNames["LBR"]="Liberia"
			dicCountriesNames["LBY"]="Liby An Arab Jamahiriya"
			dicCountriesNames["LIE"]="Liechtenstein"
			dicCountriesNames["LTU"]="Lithuania"
			dicCountriesNames["LUX"]="Luxembourg"
			dicCountriesNames["MKD"]="Macedonia, The Former Republic of Yugoslavia"
			dicCountriesNames["MAC"]="Macua"
			dicCountriesNames["MDG"]="Madagascar"
			dicCountriesNames["MWI"]="Malawi"
			dicCountriesNames["MYS"]="Malaysia"
			dicCountriesNames["MDV"]="Maldives"
			dicCountriesNames["MLI"]="Mali"
			dicCountriesNames["MLT"]="Malta"
			dicCountriesNames["MHL"]="Marshall Islands"
			dicCountriesNames["MTQ"]="Martinique"
			dicCountriesNames["MRT"]="Mauritania"
			dicCountriesNames["MUS"]="Mauritius"
			dicCountriesNames["MYT"]="Mayotte"
			dicCountriesNames["MEX"]="Mexico"
			dicCountriesNames["FSM"]="Micronesia, (Federated States of)"
			dicCountriesNames["MDA"]="Moldova, Republic of"
			dicCountriesNames["MCO"]="Monaco"
			dicCountriesNames["MNG"]="Mongolia"
			dicCountriesNames["MSR"]="Montserrat"
			dicCountriesNames["MAR"]="Morocco"
			dicCountriesNames["MOZ"]="Mozambique"
			dicCountriesNames["MMR"]="Myanmar"
			dicCountriesNames["NAM"]="Namibia"
			dicCountriesNames["NRU"]="Nauru"
			dicCountriesNames["NPL"]="Nepal"
			dicCountriesNames["NLD"]="Netherlands"
			dicCountriesNames["ANT"]="Netherlands Antilles"
			dicCountriesNames["NCL"]="New Caledonia"
			dicCountriesNames["NZL"]="New Zealand"
			dicCountriesNames["NIC"]="Nicaragua"
			dicCountriesNames["NER"]="Niger"
			dicCountriesNames["NGA"]="Nigeria"
			dicCountriesNames["NIU"]="Niue"
			dicCountriesNames["NFK"]="Norfolk Island"
			dicCountriesNames["MNP"]="Northern Mariana Islands"
			dicCountriesNames["NOR"]="Norway"
			dicCountriesNames["OMN"]="Oman"
			dicCountriesNames["PAK"]="Pakistan"
			dicCountriesNames["PLW"]="Palau"
			dicCountriesNames["PAN"]="Panama"
			dicCountriesNames["PNG"]="Papua New Guinea"
			dicCountriesNames["PRY"]="Paraguay"
			dicCountriesNames["PER"]="Peru"
			dicCountriesNames["PHL"]="Philippines"
			dicCountriesNames["PCN"]="Pitcairn"
			dicCountriesNames["POL"]="Poland"
			dicCountriesNames["PRT"]="Portugal"
			dicCountriesNames["PRI"]="Puerto Rico"
			dicCountriesNames["QAT"]="Qatar"
			dicCountriesNames["REU"]="Reunion"
			dicCountriesNames["ROM"]="Romania"
			dicCountriesNames["RUS"]="Russian Federation"
			dicCountriesNames["RWA"]="Rwanda"
			dicCountriesNames["LCA"]="Saint Lucia"
			dicCountriesNames["WSM"]="Samoa"
			dicCountriesNames["SMR"]="San Marino"
			dicCountriesNames["STP"]="Sao Tome and Principe"
			dicCountriesNames["SAU"]="Saudi Arabia"
			dicCountriesNames["SEN"]="Senegal"
			dicCountriesNames["SYC"]="Seychelles"
			dicCountriesNames["SLE"]="Sierra Leone"
			dicCountriesNames["SGP"]="Singapore"
			dicCountriesNames["SVK"]="Slovakia"
			dicCountriesNames["SVN"]="Slovenia"
			dicCountriesNames["SLB"]="Solomon Islands"
			dicCountriesNames["SOM"]="Somalia"
			dicCountriesNames["ZAF"]="South Africa"
			dicCountriesNames["SGS"]="South Georgia and the South Sandwich Islands"
			dicCountriesNames["ESP"]="Spain"
			dicCountriesNames["LKA"]="Sri Lanka"
			dicCountriesNames["SHN"]="St. Helena"
			dicCountriesNames["SPM"]="St. Pierre and Miquelon"
			dicCountriesNames["KNA"]="St.Kitts & Nevis"
			dicCountriesNames["VCT"]="St.Vincent"
			dicCountriesNames["SDN"]="Sudan"
			dicCountriesNames["SUR"]="Suriname"
			dicCountriesNames["SJM"]="Svalbard and the Jan Mayen Islands"
			dicCountriesNames["SWZ"]="Swaziland"
			dicCountriesNames["SWE"]="Sweden"
			dicCountriesNames["CHE"]="Switzerland"
			dicCountriesNames["SYR"]="Syrian Arab Republic"
			dicCountriesNames["TWN"]="Taiwan, Province of China"
			dicCountriesNames["TJK"]="Tajikistan"
			dicCountriesNames["TZA"]="Tanzania, United Republic of"
			dicCountriesNames["THA"]="Thailand"
			dicCountriesNames["TGO"]="Togo"
			dicCountriesNames["TKL"]="Tokelau"
			dicCountriesNames["TON"]="Tonga"
			dicCountriesNames["TTO"]="Trinidad & Tobago"
			dicCountriesNames["TUN"]="Tunisia"
			dicCountriesNames["TUR"]="Turkey"
			dicCountriesNames["TKM"]="Turkmenistan"
			dicCountriesNames["TCA"]="Turks and Caicos Islands"
			dicCountriesNames["TUV"]="Tuvula"
			dicCountriesNames["UGA"]="Uganda"
			dicCountriesNames["UKR"]="Ukraine"
			dicCountriesNames["ARE"]="United Arab Emirates"
			dicCountriesNames["GBR"]="United Kingdom"
			dicCountriesNames["USA"]="United States"
			dicCountriesNames["UMI"]="United States Minor Outlying Islands"
			dicCountriesNames["URY"]="Uruguay"
			dicCountriesNames["UZB"]="Uzbekistan"
			dicCountriesNames["VUT"]="Vanuatu"
			dicCountriesNames["VAT"]="Vatican City State (Holy See)"
			dicCountriesNames["VEN"]="Venezuela"
			dicCountriesNames["VNM"]="Viet Nam"
			dicCountriesNames["VGB"]="Virgin Islands (British)"
			dicCountriesNames["VIR"]="Virgin Islands (U.S)"
			dicCountriesNames["WLF"]="Wallis and Futuna Islands"
			dicCountriesNames["ESH"]="Western Sahara"
			dicCountriesNames["YEM"]="Yemen"
			dicCountriesNames["YUG"]="Yugoslavia"
			dicCountriesNames["ZAR"]="Zaire"
			dicCountriesNames["ZMB"]="Zambia"
			dicCountriesNames["ZWE"]="Zimbabwe"
		}
		
		public function getCountriesName(countryKey:String):String {
      		return dicCountriesNames[countryKey];
    	}
    	
    	public function getCountriesListByRegion(RegionKey:String):Array {
      		var arrRet:Array=new Array();
      		if(RegionKey=="World"){
      			arrRet=arrWorld;
      		}else if(RegionKey=="Africa"){
      			arrRet=arrAfrica;
      		}else if(RegionKey=="Antartica"){
      			arrRet=arrAntartica;
      		}else if(RegionKey=="NorthAmerica"){
      			arrRet=arrNorthAmerica;
      		}else if(RegionKey=="SouthAmerica"){
      			arrRet=arrSouthAmerica;
      		}else if(RegionKey=="Asia"){
      			arrRet=arrAsia;
      		}else if(RegionKey=="Europe"){
      			arrRet=arrEurope;
      		}else if(RegionKey=="Oceania"){
      			arrRet=arrOceania;
      		}
      		return arrRet;
    	}
    	
    	
	}
}