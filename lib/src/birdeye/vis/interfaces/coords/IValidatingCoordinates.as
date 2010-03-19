package birdeye.vis.interfaces.coords
{
	import birdeye.vis.interfaces.elements.IElement;
	import birdeye.vis.interfaces.guides.IGuide;

	public interface IValidatingCoordinates extends ICoordinates
	{
		/**
		 * Invalidates the given element, to be drawn in the next cycle.</br>
		 * If no element is given, all elements are invalidated.
		 */
		function invalidateElement(element:IElement=null):void;
		
		/**
		 * Invalidates the given guide, to be drawn in the next cycle.</br>
		 * If no guide is given, all guides are invalidated.
		 */
		function invalidateGuide(guide:IGuide=null):void;

	
	}
}