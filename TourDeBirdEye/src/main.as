// ActionScript file
		import mx.core.IContainer;
        import com.degrafa.geometry.display.IDisplayObjectProxy;
        import mx.events.ListEvent;
		import mx.containers.Canvas;
		
		// Cartesian
		import views.cartesian.AreaChart;
		import views.cartesian.BarChart;
		import views.cartesian.BubbleChart;
		
		// Classics
		import views.classics.NapoleonMarch;
		
		[Bindable]
        public var classRef:Class;
        [Bindable]
        public var currentExampleInstance:IContainer;

		private var unusefulArray:Array = [AreaChart, BarChart, BubbleChart, NapoleonMarch]; 
		
            // Event handler for the Tree control change event.
        public function treeChanged(event:ListEvent):void {
                classRef = Class(getDefinitionByName(myTree.selectedItem.@classRef));
                loadExample(classRef);
                trace(myTree.selectedItem.@data);
                
         }

        public function loadExample(s:Class):void {
            viewPanel.removeAllChildren();
            var c:Class = classRef;
            currentExampleInstance = new c();
            viewPanel.addChild(DisplayObject(currentExampleInstance));
        }