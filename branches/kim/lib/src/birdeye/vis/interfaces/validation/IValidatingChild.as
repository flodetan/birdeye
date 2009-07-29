package birdeye.vis.interfaces.validation
{
	/**
	 * Interface that defines a method where the parent can call the child to validate itself.</br>
	 * This interface is created for object that are not uicomponents but do need the invalidate/validate cycle.</br>
	 */
	public interface IValidatingChild
	{
		/**
		 * Set the parent for this validating child.
		 */
		function set parent(val:IValidatingParent):void;
		function get parent():IValidatingParent;
		
	
		/**
		 * Commit everything
		 */
		function commit():void;
			
	}
}