package styles {
	
	import com.asfusion.mate.actions.AbstractServiceInvoker;
	import com.asfusion.mate.actions.IAction;
	import com.asfusion.mate.core.ISmartObject;
	import com.asfusion.mate.actionLists.IScope;
	
	import mx.events.StyleEvent;
	import mx.styles.StyleManager;

	public class StyleLoader extends AbstractServiceInvoker implements IAction
	{
		/*-.........................................Properties..........................................*/
		
		private var _url:String;
		public var url:Object;
		
		
		/*-.........................................Methods..........................................*/
		override protected function setProperties(scope:IScope):void
		{
			if(url is ISmartObject)
			{
				_url = ISmartObject(url).getValue(scope).toString();
			}
			else {
				_url = url.toString();
			}
		}
		
		
		override protected function run(scope:IScope):void 
		{
			
			innerHandlersDispatcher = StyleManager.loadStyleDeclarations(_url);
			
			if (resultHandlers && resultHandlers.length > 0){
				createInnerHandlers(scope, StyleEvent.COMPLETE, resultHandlers);
			}
			
			if (faultHandlers && faultHandlers.length > 0){
				createInnerHandlers(scope, StyleEvent.ERROR, faultHandlers);
			}
		}
	}
}