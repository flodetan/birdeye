// ActionScript file
		import mx.core.IContainer;
		import mx.events.ListEvent;
		
		// Cartesian
		import views.cartesian.AreaChart;
		import views.cartesian.BarChart;
		import views.cartesian.BubbleChart;
		import views.cartesian.ColumnChart;
		import views.classics.NapoleonMarch;
		import views.facets.Barley;
		import views.schemas.Isotype;
		
		// Polar
		import views.polar.CoxcombChart;
		import views.polar.PieChart;
		import views.polar.RadarChart;
		import views.polar.SunburstChart;
		
		// Micro
		import views.micro.MicroCharts;
		
		// Graphs
		import views.graphs.BalloonGraph;
		import views.graphs.ConcentricGraph;
		import views.graphs.EdgeRendererGraph;
		import views.graphs.ForceDirectedGraph;
		import views.graphs.HyperbolicGraph;
		import views.graphs.MDSGraph;
		import views.graphs.NodeRendererGraph;
		import views.graphs.PackingModelGraph;
		import views.graphs.ParentCenteredGraph;
		import views.graphs.SingleCycleGraph;
		import views.graphs.TreeGraph;
		
		// Maps
		import views.maps.ChoroplethMap;
		import views.maps.ContiguousMap;
		import views.maps.DorlingMap;
		import views.maps.KMLMap;
		import views.maps.NoncontiguousMap;
		import views.maps.SHPMap;
		import views.maps.SimplificationMap;
		import views.maps.SymbolizationMap;
		import views.maps.VectorMap;
		
		
		[Bindable]
        public var classRef:Class;
        [Bindable]
        public var currentExampleInstance:IContainer;

		private var unusefulArray:Array = [AreaChart, BarChart, ColumnChart, BubbleChart, 
											NapoleonMarch, Barley, Isotype, MicroCharts,
											BalloonGraph, ConcentricGraph, HyperbolicGraph,
											EdgeRendererGraph, ForceDirectedGraph, MDSGraph, NodeRendererGraph,
											PackingModelGraph, ParentCenteredGraph, SingleCycleGraph, TreeGraph   ]; 
		
        
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