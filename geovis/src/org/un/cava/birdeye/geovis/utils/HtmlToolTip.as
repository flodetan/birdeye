package org.un.cava.birdeye.geovis.utils
{
	import mx.controls.ToolTip;

	public class HtmlToolTip extends ToolTip
	{
		override protected function commitProperties():void
	    {
	      	super.commitProperties();
	  		textField.htmlText = text
	    }
	}
}