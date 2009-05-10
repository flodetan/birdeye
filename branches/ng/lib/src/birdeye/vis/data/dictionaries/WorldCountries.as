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

package birdeye.vis.data.dictionaries
{
	import birdeye.vis.elements.geometry.CartesianElement;
	import birdeye.vis.elements.BaseElement;
	
	public class WorldCountries extends BaseElement //SASN extends BaseElement
	{
		import flash.utils.Dictionary;
		import mx.controls.Alert;
		
		private var arrRegion:Array=[WorldRegionTypes.REGION_AFRICA, WorldRegionTypes.REGION_NORTH_AMERICA, WorldRegionTypes.REGION_SOUTH_AMERICA, WorldRegionTypes.REGION_ASIA, WorldRegionTypes.REGION_EUROPE, WorldRegionTypes.REGION_OCEANIA, WorldRegionTypes.REGION_WORLD, WorldRegionTypes.REGION_CIS];
		private var arrSubRegion:Array=[WorldRegionTypes.SUBREGION_NORTHAFRICA, WorldRegionTypes.SUBREGION_SUBSAHARA, WorldRegionTypes.SUBREGION_EASTERNASIA, WorldRegionTypes.SUBREGION_SOUTHERNASIA, WorldRegionTypes.SUBREGION_SOUTHEASTERNASIA, WorldRegionTypes.SUBREGION_WESTERNASIA];//"Antartica", 
		
		//Regions
		private var arrWorld:Array=["ZWE","ZMB","ZAF","YEM","WSM","VUT","VNM","VIR","VGB","VEN","VCT","VAT","UZB","USA","URY","UKR","UGA","TZA","TWN","TUV","TUR","TUN","TTO","TON","TLS","TKM","TKL","TJK","THA","TGO","TCD","TCA","SYR","SYC","SWZ","SWE","SVN","SVK","SUR","STP","SRB","SOM","SLV","SLE","SLB","SJM","SGP","SEN","SDN","SAU","RWA","RUS","ROU","REU","QAT","PYF","PRY","PRT","PRK","PRI","POL","PNG","PLW","PHL","PER","PCN","PAN","PAK","OMN","NZL","NPL","NOR","NLD","NIU","NIC","NGA","NFK","NER","NCL","NAM","MYT","MYS","MWI","MUS","MSR","MRT","MOZ","MNP","MNG","MNE","MMR","MLT","MLI","MKD","MHL","MEX","MDV","MDG","MDA","MCO","MAR","MAC","LVA","LUX","LTU","LSO","LKA","LIE","LCA","LBY","LBR","LBN","LAO","KWT","KOR","KNA","KIR","KHM","KGZ","KEN","KAZ","JPN","JOR","JAM","ITA","ISR","ISL","IRQ","IRN","IRL","IOT","IND","IMY","IDN","HUN","HTI","HRV","HND","HMD","HKG","GUY","GUM","GUF","GTM","GRL","GRD","GRC","GNQ","GNB","GMB","GLP","GIN","GIB","GHA","GEO","GBR","GAB","FSM","FRO","FRA","FLK","FJI","FIN","ETH","EST","ESP","ESH","ERI","EGY","ECU","DZA","DOM","DNK","DMA","DJI","DEU","CZE","CYP","CYM","CXR","CUB","CRI","CPV","COM","COL","COK","COG","COD","CMR","CIV","CHN","CHL","CHE","CCK","CAN","CAF","BWA","BVT","BTN","BRN","BRB","BRA","BOL","BMU","BLZ","BLR","BIH","BHS","BHR","BGR","BGD","BFA","BEN","BEL","BDI","AZE","AUT","AUS","ATG","ATF","ATA","ASM","ARM","ARG","ARE","ANT","AND","ALB","AIA","AGO","AFG","ABW"]//,"MTQ","SMR","NRU",
		private var arrAfrica:Array=["DZA", "AGO", "BEN", "BWA", "BVT", "BFA", "BDI", "CMR", "CPV", "CAF", "TCD", "COM", "COG", "COD", "CIV", "DJI", "EGY", "GNQ", "ERI", "ETH", "GAB", "GMB", "GHA", "GIN", "GNB", "KEN", "LSO", "LBR", "LBY", "MDG", "MWI", "MLI", "MRT", "MUS", "MYT", "MAR", "MOZ", "NAM", "NER", "NGA", "PCN", "REU", "RWA", "STP", "SEN", "SYC", "SLE", "SOM", "ZAF", "SDN", "SWZ", "TZA", "TGO", "TUN", "UGA", "ESH",  "ZMB", "ZWE"];//"SHN", "ZAR",
		private var arrAntartica:Array=["ATF","ATA"];
		private var arrNorthAmerica:Array=["AIA", "ATG", "ABW", "BHS", "BRB", "BLZ", "BMU", "CAN", "CYM", "CRI", "CUB", "DMA", "DOM", "SLV", "GRD", "GLP", "GTM", "HTI", "HND", "JAM",  "MEX", "NIC", "PAN", "PRI", "LCA", "KNA", "VCT", "TCA", "USA", "VGB", "VIR"];//"MTQ","SPM", "UMI", 
		private var arrSouthAmerica:Array=["ARG", "BOL", "BRA", "CHL", "COL", "ECU", "FLK", "GUF", "GUY", "MSR", "ANT", "PRY", "PER", "SUR", "TTO", "URY", "VEN"];//"SGS", 
		private var arrAsia:Array=["AFG", "ASM", "BHR", "BGD", "BTN", "IOT", "BRN", "KHM", "CHN", "CXR", "CCK", "COK", "FJI", "PYF", "GEO", "GUM", "HMD", "HKG", "IND", "IDN", "IRN", "IRQ", "ISR", "JPN", "JOR", "KAZ", "KIR", "PRK", "KOR", "KWT", "KGZ", "LAO", "LBN", "MAC", "MYS", "MDV", "MHL", "FSM", "MNG", "MMR",  "NPL", "NCL", "NIU", "NFK", "MNP", "OMN", "PAK", "PLW", "PNG", "PHL", "QAT", "RUS", "WSM", "SAU", "SGP", "SLB", "LKA", "SYR", "TWN", "TJK", "THA", "TKL", "TON", "TKM", "TUV", "ARE", "UZB", "VUT", "VNM", "YEM"];// "WLF", "TMP", "NRU",
		private var arrEurope:Array=["ALB", "AND", "ARM", "AUT", "AZE", "BLR", "BEL", "BIH", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FRO", "FIN", "FRA",  "DEU", "GIB", "GRC", "GRL", "HUN", "ISL", "IRL", "ITA", "LVA", "LIE", "LTU", "LUX", "MKD", "MLT", "MDA", "MCO", "NLD", "NOR", "POL", "PRT", "SVK", "SVN", "ESP", "SJM", "SWE", "CHE", "TUR", "UKR", "GBR", "VAT"];//, "SMR", "FXX","ROM", "YUG"
		private var arrOceania:Array=["AUS","NZL"];
		private var arrCIS:Array=["ARM","AZE","BLR","GEO","KAZ","KGZ","MDA","RUS","TJK","UKR","UZB","TKM"];
		//SubRegions
		private var arrNorthAfrica:Array=["MAR","ESH","DZA","LBY","TUN","EGY"];
		private var arrSubSahara:Array=["AGO", "BEN", "BWA", "BVT", "BFA", "BDI", "CMR", "CPV", "CAF", "TCD", "COM", "COG", "CIV", "DJI", "GNQ", "ERI", "ETH", "GAB", "GMB", "GHA", "GIN", "GNB", "KEN", "LSO", "LBR", "MDG", "MWI", "MLI", "MRT", "MUS", "MYT", "MOZ", "NAM", "NER", "NGA", "PCN", "REU", "RWA", "STP", "SEN", "SYC", "SLE", "SOM", "ZAF", "SDN", "SWZ", "TZA", "TGO", "UGA", "ZMB", "ZWE"];
		private var arrEasternAsia:Array=["MNG","CHN","KOR","PRK"];
		private var arrSouthernAsia:Array=["IND","NPL","BTN","BGD","PAK","AFG","IRN","LKA","MDV"];
		private var arrSouthEasternAsia:Array=["MMR","THA","LAO","KHM","VNM","MYS","IDN","PHL"];
		private var arrWesternAsia:Array=["TUR","IRQ","SYR","LBN","ISR","JOR","SAU","OMN","YEM","ARE","QAT","KWT","CYP"];
		
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
			dicCountriesNames["ABW"]="Aruba"
			dicCountriesNames["AFG"]="Afghanistan"
			dicCountriesNames["AGO"]="Angola"
			dicCountriesNames["AIA"]="Anguilla"
			dicCountriesNames["ALB"]="Albania"
			dicCountriesNames["AND"]="Andorra"
			dicCountriesNames["ANT"]="Netherlands Antilles"
			dicCountriesNames["ARE"]="United Arab Emirates"
			dicCountriesNames["ARG"]="Argentina"
			dicCountriesNames["ARM"]="Armenia"
			dicCountriesNames["ASM"]="American Samoa"
			dicCountriesNames["ATA"]="Antartica"
			dicCountriesNames["ATF"]="French Southern Territories"
			dicCountriesNames["ATG"]="Antigua & Barbuda"
			dicCountriesNames["AUS"]="Australia"
			dicCountriesNames["AUT"]="Austria"
			dicCountriesNames["AZE"]="Azerbaijan"
			dicCountriesNames["BDI"]="Burundi"
			dicCountriesNames["BEL"]="Belgium"
			dicCountriesNames["BEN"]="Benin"
			dicCountriesNames["BFA"]="Burkina Faso"
			dicCountriesNames["BGD"]="Bangladesh"
			dicCountriesNames["BGR"]="Bulgaria"
			dicCountriesNames["BHR"]="Bahrain"
			dicCountriesNames["BHS"]="Bahamas"
			dicCountriesNames["BIH"]="Bosnia And Herzegovina"
			dicCountriesNames["BLR"]="Belarus"
			dicCountriesNames["BLZ"]="Belize"
			dicCountriesNames["BMU"]="Bermuda"
			dicCountriesNames["BOL"]="Bolivia"
			dicCountriesNames["BRA"]="Brazil"
			dicCountriesNames["BRB"]="Barbados"
			dicCountriesNames["BRN"]="Brunei Darussalam"
			dicCountriesNames["BTN"]="Bhutan"
			dicCountriesNames["BVT"]="Bouvet Island"
			dicCountriesNames["BWA"]="Botswana"
			dicCountriesNames["CAF"]="Central African Republic"
			dicCountriesNames["CAN"]="Canada"
			dicCountriesNames["CCK"]="Cocos (Keeling) Islands"
			dicCountriesNames["CHE"]="Switzerland"
			dicCountriesNames["CHL"]="Chile"
			dicCountriesNames["CHN"]="China"
			dicCountriesNames["CIV"]="Cote D'ivoire (Ivory Coast)"
			dicCountriesNames["CMR"]="Cameroon"
			dicCountriesNames["COD"]="Democratic Republic of the Congo"
			dicCountriesNames["COG"]="Congo"
			dicCountriesNames["COK"]="Cook Islands"
			dicCountriesNames["COL"]="Colombia"
			dicCountriesNames["COM"]="Comoros"
			dicCountriesNames["CPV"]="Cape Verde"
			dicCountriesNames["CRI"]="Costa Rica"
			dicCountriesNames["CUB"]="Cuba"
			dicCountriesNames["CXR"]="Christmas Island"
			dicCountriesNames["CYM"]="Cayman Islands"
			dicCountriesNames["CYP"]="Cyprus"
			dicCountriesNames["CZE"]="Czech Republic"
			dicCountriesNames["DEU"]="Germany"
			dicCountriesNames["DJI"]="Djibouti"
			dicCountriesNames["DMA"]="Dominica"
			dicCountriesNames["DNK"]="Denmark"
			dicCountriesNames["DOM"]="Dominican Republic"
			dicCountriesNames["DZA"]="Algeria"
			dicCountriesNames["ECU"]="Ecuador"
			dicCountriesNames["EGY"]="Egypt"
			dicCountriesNames["ERI"]="Eritrea"
			dicCountriesNames["ESH"]="Western Sahara"
			dicCountriesNames["ESP"]="Spain"
			dicCountriesNames["EST"]="Estonia"
			dicCountriesNames["ETH"]="Ethiopia"
			dicCountriesNames["FIN"]="Finland"
			dicCountriesNames["FJI"]="Fiji"
			dicCountriesNames["FLK"]="Falkland Islands (Malvinas)"
			dicCountriesNames["FRA"]="France"
			dicCountriesNames["FRO"]="Faroe Islands"
			dicCountriesNames["FSM"]="Micronesia, (Federated States of)"
			dicCountriesNames["FXX"]="France, Metropolitan"
			dicCountriesNames["GAB"]="Gabon"
			dicCountriesNames["GBR"]="United Kingdom"
			dicCountriesNames["GEO"]="Georgia"
			dicCountriesNames["GHA"]="Ghana"
			dicCountriesNames["GIB"]="Gibralter"
			dicCountriesNames["GIN"]="Guinea"
			dicCountriesNames["GLP"]="Guadeloupe"
			dicCountriesNames["GMB"]="Gambia"
			dicCountriesNames["GNB"]="Guinea Bissau"
			dicCountriesNames["GNQ"]="Equatorial Guinea"
			dicCountriesNames["GRC"]="Greece"
			dicCountriesNames["GRD"]="Grenada"
			dicCountriesNames["GRL"]="Greenland"
			dicCountriesNames["GTM"]="Guatemala"
			dicCountriesNames["GUF"]="French Guiana"
			dicCountriesNames["GUM"]="Guam"
			dicCountriesNames["GUY"]="Guyana"
			dicCountriesNames["HKG"]="Hong Kong"
			dicCountriesNames["HMD"]="Heard and McDonald Islands"
			dicCountriesNames["HND"]="Honduras"
			dicCountriesNames["HRV"]="Croatia"
			dicCountriesNames["HTI"]="Haiti"
			dicCountriesNames["HUN"]="Hungary"
			dicCountriesNames["IMN"]="Isle of Man"//IMY
			dicCountriesNames["IDN"]="Indonesia"
			dicCountriesNames["IND"]="India"
			dicCountriesNames["IOT"]="British Indian Ocean Territory"
			dicCountriesNames["IRL"]="Ireland"
			dicCountriesNames["IRN"]="Iran"
			dicCountriesNames["IRQ"]="Iraq"
			dicCountriesNames["ISL"]="Iceland"
			dicCountriesNames["ISR"]="Israel"
			dicCountriesNames["ITA"]="Italy"
			dicCountriesNames["JAM"]="Jamaica"
			dicCountriesNames["JOR"]="Jordan"
			dicCountriesNames["JPN"]="Japan"
			dicCountriesNames["KAZ"]="Kazakhstan"
			dicCountriesNames["KEN"]="Kenya"
			dicCountriesNames["KGZ"]="Kyrgyzstan"
			dicCountriesNames["KHM"]="Cambodia"
			dicCountriesNames["KIR"]="Kirabati"
			dicCountriesNames["KNA"]="St.Kitts & Nevis"
			dicCountriesNames["KOR"]="Korea, Republic of"
			dicCountriesNames["KWT"]="Kuwait"
			dicCountriesNames["LAO"]="Laos, Peoples Democratic Republic of"
			dicCountriesNames["LBN"]="Lebanon"
			dicCountriesNames["LBR"]="Liberia"
			dicCountriesNames["LBY"]="Liby An Arab Jamahiriya"
			dicCountriesNames["LCA"]="Saint Lucia"
			dicCountriesNames["LIE"]="Liechtenstein"
			dicCountriesNames["LKA"]="Sri Lanka"
			dicCountriesNames["LSO"]="Lesotho"
			dicCountriesNames["LTU"]="Lithuania"
			dicCountriesNames["LUX"]="Luxembourg"
			dicCountriesNames["LVA"]="Latvia"
			dicCountriesNames["MAC"]="Macao"
			dicCountriesNames["MAR"]="Morocco"
			dicCountriesNames["MCO"]="Monaco"
			dicCountriesNames["MDA"]="Moldova, Republic of"
			dicCountriesNames["MDG"]="Madagascar"
			dicCountriesNames["MDV"]="Maldives"
			dicCountriesNames["MEX"]="Mexico"
			dicCountriesNames["MHL"]="Marshall Islands"
			dicCountriesNames["MKD"]="Macedonia, The Former Republic of Yugoslavia"
			dicCountriesNames["MLI"]="Mali"
			dicCountriesNames["MLT"]="Malta"
			dicCountriesNames["MMR"]="Myanmar"
			dicCountriesNames["MNE"]="MONTENEGRO"
			dicCountriesNames["MNG"]="Mongolia"
			dicCountriesNames["MNP"]="Northern Mariana Islands"
			dicCountriesNames["MOZ"]="Mozambique"
			dicCountriesNames["MRT"]="Mauritania"
			dicCountriesNames["MSR"]="Montserrat"
			dicCountriesNames["MTQ"]="Martinique"
			dicCountriesNames["MUS"]="Mauritius"
			dicCountriesNames["MWI"]="Malawi"
			dicCountriesNames["MYS"]="Malaysia"
			dicCountriesNames["MYT"]="Mayotte"
			dicCountriesNames["NAM"]="Namibia"
			dicCountriesNames["NCL"]="New Caledonia"
			dicCountriesNames["NER"]="Niger"
			dicCountriesNames["NFK"]="Norfolk Island"
			dicCountriesNames["NGA"]="Nigeria"
			dicCountriesNames["NIC"]="Nicaragua"
			dicCountriesNames["NIU"]="Niue"
			dicCountriesNames["NLD"]="Netherlands"
			dicCountriesNames["NOR"]="Norway"
			dicCountriesNames["NPL"]="Nepal"
			dicCountriesNames["NRU"]="Nauru"
			dicCountriesNames["NZL"]="New Zealand"
			dicCountriesNames["OMN"]="Oman"
			dicCountriesNames["PAK"]="Pakistan"
			dicCountriesNames["PAN"]="Panama"
			dicCountriesNames["PCN"]="Pitcairn"
			dicCountriesNames["PER"]="Peru"
			dicCountriesNames["PHL"]="Philippines"
			dicCountriesNames["PLW"]="Palau"
			dicCountriesNames["PNG"]="Papua New Guinea"
			dicCountriesNames["POL"]="Poland"
			dicCountriesNames["PRI"]="Puerto Rico"
			dicCountriesNames["PRK"]="Korea, Democratic People's Republic of"
			dicCountriesNames["PRT"]="Portugal"
			dicCountriesNames["PRY"]="Paraguay"
			dicCountriesNames["PYF"]="French Polynesia"
			dicCountriesNames["QAT"]="Qatar"
			dicCountriesNames["REU"]="Reunion"
			dicCountriesNames["ROU"]="Romania"//ROM
			dicCountriesNames["RUS"]="Russian Federation"
			dicCountriesNames["RWA"]="Rwanda"
			dicCountriesNames["SAU"]="Saudi Arabia"
			dicCountriesNames["SDN"]="Sudan"
			dicCountriesNames["SEN"]="Senegal"
			dicCountriesNames["SGP"]="Singapore"
			dicCountriesNames["SGS"]="South Georgia and the South Sandwich Islands"
			dicCountriesNames["SHN"]="St. Helena"
			dicCountriesNames["SJM"]="Svalbard and the Jan Mayen Islands"
			dicCountriesNames["SLB"]="Solomon Islands"
			dicCountriesNames["SLE"]="Sierra Leone"
			dicCountriesNames["SLV"]="El Salvador"
			dicCountriesNames["SMR"]="San Marino"
			dicCountriesNames["SOM"]="Somalia"
			dicCountriesNames["SPM"]="St. Pierre and Miquelon"
			dicCountriesNames["SRB"]="Serbia"
			dicCountriesNames["STP"]="Sao Tome and Principe"
			dicCountriesNames["SUR"]="Suriname"
			dicCountriesNames["SVK"]="Slovakia"
			dicCountriesNames["SVN"]="Slovenia"
			dicCountriesNames["SWE"]="Sweden"
			dicCountriesNames["SWZ"]="Swaziland"
			dicCountriesNames["SYC"]="Seychelles"
			dicCountriesNames["SYR"]="Syrian Arab Republic"
			dicCountriesNames["TCA"]="Turks and Caicos Islands"
			dicCountriesNames["TCD"]="Chad"
			dicCountriesNames["TGO"]="Togo"
			dicCountriesNames["THA"]="Thailand"
			dicCountriesNames["TJK"]="Tajikistan"
			dicCountriesNames["TKL"]="Tokelau"
			dicCountriesNames["TKM"]="Turkmenistan"
			dicCountriesNames["TLS"]="Timor-Leste"
			dicCountriesNames["TMP"]="East Timor"
			dicCountriesNames["TON"]="Tonga"
			dicCountriesNames["TTO"]="Trinidad & Tobago"
			dicCountriesNames["TUN"]="Tunisia"
			dicCountriesNames["TUR"]="Turkey"
			dicCountriesNames["TUV"]="Tuvula"
			dicCountriesNames["TWN"]="Taiwan, Province of China"
			dicCountriesNames["TZA"]="Tanzania, United Republic of"
			dicCountriesNames["UGA"]="Uganda"
			dicCountriesNames["UKR"]="Ukraine"
			dicCountriesNames["UMI"]="United States Minor Outlying Islands"
			dicCountriesNames["URY"]="Uruguay"
			dicCountriesNames["USA"]="United States"
			dicCountriesNames["UZB"]="Uzbekistan"
			dicCountriesNames["VAT"]="Vatican City State (Holy See)"
			dicCountriesNames["VCT"]="St.Vincent"
			dicCountriesNames["VEN"]="Venezuela"
			dicCountriesNames["VGB"]="Virgin Islands (British)"
			dicCountriesNames["VIR"]="Virgin Islands (U.S)"
			dicCountriesNames["VNM"]="Viet Nam"
			dicCountriesNames["VUT"]="Vanuatu"
			dicCountriesNames["WLF"]="Wallis and Futuna Islands"
			dicCountriesNames["WSM"]="Samoa"
			dicCountriesNames["YEM"]="Yemen"
			dicCountriesNames["YUG"]="Yugoslavia"
			dicCountriesNames["ZAF"]="South Africa"
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
      		}else if(RegionKey=="CIS"){
      			arrRet=arrCIS;
      		}else if(RegionKey=="NorthAfrica"){
      			arrRet=arrNorthAfrica;
      		}else if(RegionKey=="SubSahara"){
      			arrRet=arrSubSahara;
      		}else if(RegionKey=="EasternAsia"){
      			arrRet=arrEasternAsia;
      		}else if(RegionKey=="SouthernAsia"){
      			arrRet=arrSouthernAsia;
      		}else if(RegionKey=="SouthEasternAsia"){
      			arrRet=arrSouthEasternAsia;
      		}else if(RegionKey=="WesternAsia"){
      			arrRet=arrWesternAsia;
      		}
      		return arrRet;
    	}
    	
    	
	}
}