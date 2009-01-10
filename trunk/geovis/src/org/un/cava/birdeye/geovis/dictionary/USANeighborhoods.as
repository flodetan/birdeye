package org.un.cava.birdeye.geovis.dictionary
{
	public class USANeighborhoods
	{
		import flash.utils.Dictionary;
		
		private var dicNeighborhoods:Dictionary= new Dictionary();
		
		public function USANeighborhoods()
		{
			setDicNeighborhoods();
		}
		
		public function setDicNeighborhoods():void
		{
			dicNeighborhoods["AL"]="GA,FL,MS,TN";
			dicNeighborhoods["AZ"]="CA,CO,NM,NV,UT";
			dicNeighborhoods["AR"]="LA,MO,MS,OK,TN,TX";
			dicNeighborhoods["CA"]="AZ,NV,OR";
			dicNeighborhoods["CO"]="AZ,KS,NE,NM,OK,UT,WY";
			dicNeighborhoods["CT"]="MA,NY,RI";
			dicNeighborhoods["DE"]="MD,PA,NJ";
			dicNeighborhoods["FL"]="AL,GA";
			dicNeighborhoods["GA"]="AL,FL,NC,TN,SC";
			dicNeighborhoods["ID"]="MT,NV,OR,UT,WA,WY";
			dicNeighborhoods["IL"]="IA,IN,KY,MO,WI";
			dicNeighborhoods["IN"]="IL,KY,MI,OH";
			dicNeighborhoods["IA"]="IL,MN,MO,NE,SD,WI";
			dicNeighborhoods["KS"]="CO,MO,NE,OK";
			dicNeighborhoods["KY"]="IL,IN,MO,OH,TN,VA,WV";
			dicNeighborhoods["LA"]="AR,MS,TX";
			dicNeighborhoods["ME"]="NH";
			dicNeighborhoods["MD"]="DE,PA,VA,WV";
			dicNeighborhoods["MA"]="CT,NH,NY,RI,VT";
			dicNeighborhoods["MI"]="IN,OH,WI";
			dicNeighborhoods["MN"]="IA,ND,SD,WI";
			dicNeighborhoods["MS"]="AL,AR,LA,TN";
			dicNeighborhoods["MO"]="AR,IA,IL,KS,KY,NE,OK,TN";
			dicNeighborhoods["MT"]="ID,ND,SD,WY";
			dicNeighborhoods["NE"]="CO,IA,KS,MO,SD,WY";
			dicNeighborhoods["NV"]="AZ,CA,ID,OR,UT";
			dicNeighborhoods["NH"]="MA,ME,VT";
			dicNeighborhoods["NJ"]="DE,NY,PA";
			dicNeighborhoods["NM"]="AZ,CO,OK,UT,TX";
			dicNeighborhoods["NY"]="CT,MA,NJ,PA,VT";
			dicNeighborhoods["NC"]="GA,SC,TN,VA";
			dicNeighborhoods["ND"]="MN,MT,SD";
			dicNeighborhoods["OH"]="IN,KY,MI,PA,WV";
			dicNeighborhoods["OK"]="AR,CO,KS,MO,NM,TX";
			dicNeighborhoods["OR"]="CA,ID,NV,WA";
			dicNeighborhoods["PA"]="DE,MD,NJ,NY,OH,WV";
			dicNeighborhoods["RI"]="CT,MA";
			dicNeighborhoods["SC"]="GA,NC";
			dicNeighborhoods["SD"]="IA,MN,MT,ND,NE,WY";
			dicNeighborhoods["TN"]="AL,AR,GA,KY,MO,MS,NC,VA";
			dicNeighborhoods["TX"]="AR,LA,NM,OK";
			dicNeighborhoods["UT"]="AZ,CO,ID,NM,NV,WY";
			dicNeighborhoods["VT"]="NH,NY,MA";
			dicNeighborhoods["VA"]="KY,MD,NC,TN,WV";
			dicNeighborhoods["WA"]="ID,OR";
			dicNeighborhoods["WV"]="KY,MD,OH,PA,VA";
			dicNeighborhoods["WI"]="IA,IL,MI,MN";
			dicNeighborhoods["WY"]="CO,ID,MT,NE,SD,UT";
		}
		
		public function getNeighbours(countryKey:String):String {
      		return dicNeighborhoods[countryKey];
    	}
	}
}