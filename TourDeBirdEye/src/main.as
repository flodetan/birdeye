// ActionScript file
		import mx.core.IContainer;
		import mx.events.ListEvent;
		
		import views.cartesian.AreaChart;
		import views.cartesian.BarChart;
		import views.cartesian.BubbleChart;
		import views.classics.NapoleonMarch;
		import views.facets.Barley;
		
		[Bindable]
        public var classRef:Class;
        [Bindable]
        public var currentExampleInstance:IContainer;

		private var unusefulArray:Array = [AreaChart, BarChart, BubbleChart, NapoleonMarch, Barley ]; 
		
            // Event handler for the Tree control change event.
        public function treeChanged(event:ListEvent):void {
        	try {
                classRef = Class(getDefinitionByName(myTree.selectedItem.@classRef));
                loadExample(classRef);
                trace(myTree.selectedItem.@data);
        	} catch (e:Error) {}
         }

        public function loadExample(s:Class):void {
            viewPanel.removeAllChildren();
            var c:Class = classRef;
            currentExampleInstance = new c();
            viewPanel.addChild(DisplayObject(currentExampleInstance));
        }