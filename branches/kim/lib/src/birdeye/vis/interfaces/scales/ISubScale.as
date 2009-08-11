package birdeye.vis.interfaces.scales
{
	import mx.core.IFactory;
	
	/**
	 * This interfaces is used for scales that generate several scales</br>
	 * based on an enumeration.
	 */
	public interface ISubScale extends IEnumerableScale
	{
		/**
		 * A boolean which indicates if the subscale functionality is activated.
		 */
		function get subScalesActive():Boolean;
		
		
		/**
		 * Feed the min and max for each category item
		 * @param minMaxData An array with an object for each category item</br>
		 * Each object has two properties: min and max.</br>
		 */
		function feedMinMax(minMaxData:Array):void;
		
		/**
		 * Set the scale that is used to generate all the scales.
		 */
		function set subScale(val:IFactory):void;
		function get subScale():IFactory;
		
		/**
		 * Set the size for all the subcales
		 */
		 function set subScalesSize(val:Number):void;
		 function get subScalesSize():Number;
		
		
		/**
		 * Get all the generated subscales.
		 * @return an array with as index each category item
		 */
		 function get subScales():Array;
	}

}