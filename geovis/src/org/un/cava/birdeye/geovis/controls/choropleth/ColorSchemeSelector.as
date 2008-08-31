package org.un.cava.birdeye.geovis.controls.choropleth
{
	import mx.controls.ComboBox;
	import mx.collections.ArrayCollection;

	public class ColorSchemeSelector extends ComboBox
	{
		public function ColorSchemeSelector()
		{
			//TODO: implement function
			super();
		}
		
		[Bindable]
        public var schemes:ArrayCollection = new ArrayCollection(
                [ {scheme:"Sequential", data:"seq"}, 
                  {scheme:"Qualitative", data:"qua"}, 
                  {scheme:"Diverging", data:"div"} ]);

		
	}
}