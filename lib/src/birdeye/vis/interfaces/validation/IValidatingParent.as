package birdeye.vis.interfaces.validation
{
	/**
 	 * Interface that defines a method where the child can call the parent to invalidate itself.</br>
	 * This interface is created for objects that are not uicomponents but do need the invalidate/validate cycle.</br>
	 */
	public interface IValidatingParent
	{
		/**
		 * Function called by the child to invalidate itself.</br>
		 * This ensures that the commit function is called in the validate cycle.
		 */
		function invalidate(child:IValidatingChild):void;	
	}
}