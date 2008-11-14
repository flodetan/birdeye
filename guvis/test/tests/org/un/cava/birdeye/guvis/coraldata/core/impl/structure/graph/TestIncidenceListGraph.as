package tests.org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph
{
	import flexunit.framework.TestCase;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.IncidenceListGraph;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.*;

	
	public class TestIncidenceListGraph extends TestCase
	{
		private var graph:IncidenceListGraph;

		// regular vertices
		private var A:IVertex;
		private var B:IVertex;
		private var C:IVertex;
		private var D:IVertex;
		
		// disconnected vertext
		private var E:IVertex;
		
		// regular edges
		private var AB:IEdge;
		private var BC:IEdge;
		private var BD:IEdge;
		private var DC:IEdge;

		// self loops
		private var AA:IEdge;
		private var CC:IEdge;
		private var DD:IEdge;
		
		// parallel edge
		private var DB:IEdge;
		
		public function TestIncidenceListGraph ( methodName : String = null)
		{
			super ( methodName );
		}
		
		override public function setUp() : void
		{
			graph = new IncidenceListGraph();
			A = graph.addVertex("A");
			B = graph.addVertex("B");
			C = graph.addVertex("C");
			D = graph.addVertex("D");
			
			E = graph.addVertex("E");
			
			AB = graph.addEdge( A,B,"AB", EdgeType.OUT );
			BC = graph.addEdge( B,C,"CB", EdgeType.IN );
			BD = graph.addEdge( B,D,"BD", EdgeType.OUT );
			DC = graph.addEdge( D,C,"DC", EdgeType.UNDIR );
			
			// self-loops
			AA = graph.addEdge( A,A,"AA", EdgeType.UNDIR );
			CC = graph.addEdge( C,C,"CC", EdgeType.OUT );
			DD = graph.addEdge( D,D,"DD", EdgeType.IN );

			// parallel edges
			DB = graph.addEdge( B,D,"DB", EdgeType.IN );
		}
		
		override public function tearDown() : void
		{
		}
	

		public function testAddVertex() : void
		{
			graph.addVertex("F");
			assertEquals( 14 , graph.size() );
		}
		
		public function testDoesContain() : void
		{
			assertTrue( graph.doesContain(A) );
			assertTrue( graph.doesContain(B) );
			assertTrue( graph.doesContain(C) );
			assertTrue( graph.doesContain(D) );

			assertTrue( graph.doesContain(AB) );
			assertTrue( graph.doesContain(BC) );
			assertTrue( graph.doesContain(BD) );
			assertTrue( graph.doesContain(DC) );

			assertTrue( graph.doesContain(AA) );
			assertTrue( graph.doesContain(CC) );
			assertTrue( graph.doesContain(DD) );

			assertTrue( graph.doesContain(DB) );
		}
		
		public function testIsEdgeSelfLoop() : void
		{
			assertFalse( graph.isEdgeSelfLoop(AB) );
			assertFalse( graph.isEdgeSelfLoop(BC) );
			assertFalse( graph.isEdgeSelfLoop(BD) );
			assertFalse( graph.isEdgeSelfLoop(DC) );

			assertTrue( graph.isEdgeSelfLoop(AA) );
			assertTrue( graph.isEdgeSelfLoop(CC) );
			assertTrue( graph.isEdgeSelfLoop(DD) );
		}
		
		public function testToString() : void
		{
			fail( "Testing toString(): "+graph.toString() );
		}
		
		public function testGetVertices() : void
		{
			var it:IIterator = graph.getVertices();
			var v:IVertex;

			var aFound:Boolean = false;
			var bFound:Boolean = false;
			var cFound:Boolean = false;
			var dFound:Boolean = false;
			var eFound:Boolean = false;

			while ( it.hasNext() ) 
			{
				v = IVertex(it.next());
				assertNotNull(v);
				
				if ( v === A ) aFound = true;
				else if ( v === B ) bFound = true;
				else if ( v === C ) cFound = true;
				else if ( v === D ) dFound = true;
				else if ( v === E ) eFound = true;
				else fail( "Vertex "+v+" not in this collection" );
			}
			
			assertTrue( aFound );
			assertTrue( bFound );
			assertTrue( cFound );
			assertTrue( dFound );
			assertTrue( eFound );
		}
		
		public function testAddEdge() : void
		{
			graph.addEdge( D,E,"DE" );
			assertEquals( 14 , graph.size() );
		}
		
		public function testRemove() : void
		{
			assertEquals( "A" , graph.remove(A) );
			assertEquals( 10 , graph.size() );
			assertEquals( "CC" , graph.remove(CC) );
			assertEquals( 9 , graph.size() );
			
		}
		
		public function testGetEdgeOrigin() : void
		{
			assertEquals( A , graph.getEdgeOrigin(AB) );
			assertEquals( C , graph.getEdgeOrigin(BC) );
			assertEquals( B , graph.getEdgeOrigin(BD) );
		}
		
		public function testGetEdgeDestination() : void
		{
			assertEquals( B , graph.getEdgeDestination(AB) );
			assertEquals( B , graph.getEdgeDestination(BC) );
			assertEquals( D , graph.getEdgeDestination(BD) );
		}
		
		public function testNumVertices() : void
		{
			assertEquals( 5 , graph.numVertices() );
		}
		
		public function testGetEdges() : void
		{
			//check all
			var ab_Found:Boolean = false;
			var bc_Found:Boolean = false;
			var bd_Found:Boolean = false;
			var dc_Found:Boolean = false;
			var aa_Found:Boolean = false;
			var cc_Found:Boolean = false;
			var dd_Found:Boolean = false;
			var db_Found:Boolean = false;			
			
			var it:IIterator = graph.getEdges();
			var e:IEdge;

			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertTrue( bc_Found );
			assertTrue( bd_Found );
			assertTrue( dc_Found );
			assertTrue( aa_Found );
			assertTrue( cc_Found );
			assertTrue( dd_Found );
			assertTrue( db_Found );
			
			
			
			// check all - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(null, EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertTrue( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check all - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(null, EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
								
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertTrue( bc_Found );
			assertTrue( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertTrue( db_Found );
			
			
			
			// check all - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(null, EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
								
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check all - self-loops
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(null, EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
								
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertTrue( aa_Found );
			assertTrue( cc_Found );
			assertTrue( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check all - outgoing | self-loop
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(null, (EdgeType.UNDIR | EdgeType.SELF_LOOP) );
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
								
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertTrue( dc_Found );
			assertTrue( aa_Found );
			assertTrue( cc_Found );
			assertTrue( dd_Found );
			assertFalse( db_Found );
			
			
			
			
			
			
			// check A - all
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(A);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertTrue( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check A - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(A , EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check A - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(A , EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check A - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(A , EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check A - self-loops
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(A , EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertTrue( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			
			
			
			
			
			// check B - all
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(B);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertTrue( bc_Found );
			assertTrue( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertTrue( db_Found );
			
			
			// check B - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(B , EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check B - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(B , EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertTrue( ab_Found );
			assertTrue( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertTrue( db_Found );
			
			
			// check B - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(B, EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertTrue( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check B - self-loops
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(B, EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			
			
			
			
			
			
			
			// check C - all
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(C);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertTrue( bc_Found );
			assertFalse( bd_Found );
			assertTrue( dc_Found );
			assertFalse( aa_Found );
			assertTrue( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check C - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(C , EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertTrue( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check C - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(C , EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check C - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(C, EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertTrue( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			// check C - self-loops
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(C, EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertTrue( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			
			
			
			
			
			
			
			
			
			
			// check D - all
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(D);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertTrue( bd_Found );
			assertTrue( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertTrue( dd_Found );
			assertTrue( db_Found );
			
			
			// check D - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(D , EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertTrue( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check D - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(D , EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertTrue( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check D - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(D, EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertTrue( db_Found );
			
			
			
			// check D - self-loops
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(D, EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertTrue( dd_Found );
			assertFalse( db_Found );
			
			
			
			
			
			
			// check E - all
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(E);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check E - undirected
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(E , EdgeType.UNDIR);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check E - incoming
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(E , EdgeType.IN);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check E - outgoing
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(E, EdgeType.OUT);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
			
			// check E - self-loop
			ab_Found = false;
			bc_Found = false;
			bd_Found = false;
			dc_Found = false;
			aa_Found = false;
			cc_Found = false;
			dd_Found = false;
			db_Found = false;	
			
			it = graph.getEdges(E, EdgeType.SELF_LOOP);
			
			while ( it.hasNext() ) 
			{
				e = IEdge(it.next());
				assertNotNull(e);
				
				if ( e === AB ) ab_Found = true;
				else if ( e === BC ) bc_Found = true;
				else if ( e === BD ) bd_Found = true;
				else if ( e === DC ) dc_Found = true;
				else if ( e === AA ) aa_Found = true;
				else if ( e === CC ) cc_Found = true;
				else if ( e === DD ) dd_Found = true;
				else if ( e === DB ) db_Found = true;
				else fail( "Edge "+e+" not in this collection" );
			}
			
			assertFalse( ab_Found );
			assertFalse( bc_Found );
			assertFalse( bd_Found );
			assertFalse( dc_Found );
			assertFalse( aa_Found );
			assertFalse( cc_Found );
			assertFalse( dd_Found );
			assertFalse( db_Found );
			
		}
		
		public function testClear() : void
		{
			graph.clear();
			assertEquals( 0 , graph.size() );
		}
		
		public function testAVertex() : void
		{
			var v:IVertex = graph.aVertex();
			
			var aFound:Boolean = false;
			var bFound:Boolean = false;
			var cFound:Boolean = false;
			var dFound:Boolean = false;
			var eFound:Boolean = false;

			assertNotNull(v);
				
			if ( v === A ) aFound = true;
			else if ( v === B ) bFound = true;
			else if ( v === C ) cFound = true;
			else if ( v === D ) dFound = true;
			else if ( v === E ) eFound = true;
			else fail( "Vertex "+v+" not in this collection" );
			
			
			assertTrue( 
				aFound ||
				bFound || 
				cFound || 
				dFound || 
				eFound );
		}
		
		public function testAnEdge() : void
		{
			var e:IEdge = graph.anEdge();

			var ab_Found:Boolean = false;
			var bc_Found:Boolean = false;
			var bd_Found:Boolean = false;
			var dc_Found:Boolean = false;
			var aa_Found:Boolean = false;
			var cc_Found:Boolean = false;
			var dd_Found:Boolean = false;
			var db_Found:Boolean = false;			
			
			assertNotNull(e);
			
			if ( e === AB ) ab_Found = true;
			else if ( e === BC ) bc_Found = true;
			else if ( e === BD ) bd_Found = true;
			else if ( e === DC ) dc_Found = true;
			else if ( e === AA ) aa_Found = true;
			else if ( e === CC ) cc_Found = true;
			else if ( e === DD ) dd_Found = true;
			else if ( e === DB ) db_Found = true;
			else fail( "Edge "+e+" not in this collection" );
			
			assertTrue( 
			ab_Found ||
			bc_Found ||
			bd_Found ||
			dc_Found ||
			aa_Found ||
			cc_Found ||
			dd_Found ||
			db_Found );
		}
		
		public function testSetEdgeDirection() : void
		{
			graph.setEdgeDirection( AB , EdgeType.IN , A );
			assertEquals( B , graph.getEdgeOrigin(AB) );
			assertEquals( A , graph.getEdgeDestination(AB) );
		}
		
		public function testIsEdgeDirected() : void
		{
			assertTrue( graph.isEdgeDirected( AB ) );
			assertTrue( graph.isEdgeDirected( BC ) );
			assertTrue( graph.isEdgeDirected( BD ) );
			assertFalse( graph.isEdgeDirected( DC ) );

			assertFalse( graph.isEdgeDirected( AA ) );
			assertTrue( graph.isEdgeDirected( CC ) );
			assertTrue( graph.isEdgeDirected( DD ) );

			assertTrue( graph.isEdgeDirected( DB ) );
		}
		
		public function testAreIncident() : void
		{
			assertTrue( graph.areIncident(A , AB) );
			assertFalse( graph.areIncident(A , BC) );
			assertFalse( graph.areIncident(A , BD) );
			assertFalse( graph.areIncident(A , DC) );
			
			assertTrue( graph.areIncident(B , AB) );
			assertTrue( graph.areIncident(B , BC) );
			assertTrue( graph.areIncident(B , BD) );
			assertFalse( graph.areIncident(B , DC) );

			assertFalse( graph.areIncident(C , AB) );
			assertTrue( graph.areIncident(C , BC) );
			assertFalse( graph.areIncident(C , BD) );
			assertTrue( graph.areIncident(C , DC) );

			assertFalse( graph.areIncident(D , AB) );
			assertFalse( graph.areIncident(D , BC) );
			assertTrue( graph.areIncident(D , BD) );
			assertTrue( graph.areIncident(D , DC) );
		}
		
		public function testReverseDirection() : void
		{
			assertEquals( A , graph.getEdgeOrigin(AB) );
			assertEquals( B , graph.getEdgeDestination(AB) );
				graph.reverseDirection(AB)
			assertEquals( B , graph.getEdgeOrigin(AB) );
			assertEquals( A , graph.getEdgeDestination(AB) );
			
			assertEquals( C , graph.getEdgeOrigin(BC) );
			assertEquals( B , graph.getEdgeDestination(BC) );
				graph.reverseDirection(BC)
			assertEquals( B , graph.getEdgeOrigin(BC) );
			assertEquals( C , graph.getEdgeDestination(BC) );

			assertEquals( B , graph.getEdgeOrigin(BD) );
			assertEquals( D , graph.getEdgeDestination(BD) );
				graph.reverseDirection(BD)
			assertEquals( D , graph.getEdgeOrigin(BD) );
			assertEquals( B , graph.getEdgeDestination(BD) );

			assertEquals( D , graph.getEdgeOrigin(DC) );
			assertEquals( C , graph.getEdgeDestination(DC) );
				graph.reverseDirection(DC)
			assertEquals( C , graph.getEdgeOrigin(DC) );
			assertEquals( D , graph.getEdgeDestination(DC) );

			assertEquals( A , graph.getEdgeOrigin(AA) );
			assertEquals( A , graph.getEdgeDestination(AA) );
				graph.reverseDirection(AA)
			assertEquals( A , graph.getEdgeOrigin(AA) );
			assertEquals( A , graph.getEdgeDestination(AA) );

			assertEquals( C , graph.getEdgeOrigin(CC) );
			assertEquals( C , graph.getEdgeDestination(CC) );
				graph.reverseDirection(CC)
			assertEquals( C , graph.getEdgeOrigin(CC) );
			assertEquals( C , graph.getEdgeDestination(CC) );

			assertEquals( D , graph.getEdgeOrigin(DD) );
			assertEquals( D , graph.getEdgeDestination(DD) );
				graph.reverseDirection(DD)
			assertEquals( D , graph.getEdgeOrigin(DD) );
			assertEquals( D , graph.getEdgeDestination(DD) );

			assertEquals( D , graph.getEdgeOrigin(DB) );
			assertEquals( B , graph.getEdgeDestination(DB) );
				graph.reverseDirection(DB)
			assertEquals( B , graph.getEdgeOrigin(DB) );
			assertEquals( D , graph.getEdgeDestination(DB) );

		}
		
		public function testNumEdges() : void
		{
			assertEquals( 8 , graph.numEdges() );
		}
		
		public function testElements() : void
		{
			var aFound:Boolean = false;
			var bFound:Boolean = false;
			var cFound:Boolean = false;
			var dFound:Boolean = false;
			var eFound:Boolean = false;
			
			var ab_Found:Boolean = false;
			var bc_Found:Boolean = false;
			var bd_Found:Boolean = false;
			var dc_Found:Boolean = false;
			var aa_Found:Boolean = false;
			var cc_Found:Boolean = false;
			var dd_Found:Boolean = false;
			var db_Found:Boolean = false;
			
			var it:IIterator = graph.elements();
			var element:Object;
			while( it.hasNext() )
			{
				element = it.next();
				
				if ( element === A.getElement() ) aFound = true;
				else if ( element === B.getElement() ) bFound = true;
				else if ( element === C.getElement() ) cFound = true;
				else if ( element === D.getElement() ) dFound = true;
				else if ( element === E.getElement() ) eFound = true;
				else if ( element === AB.getElement() ) ab_Found = true;
				else if ( element === BC.getElement() ) bc_Found = true;
				else if ( element === BD.getElement() ) bd_Found = true;
				else if ( element === DC.getElement() ) dc_Found = true;
				else if ( element === AA.getElement() ) aa_Found = true;
				else if ( element === CC.getElement() ) cc_Found = true;
				else if ( element === DD.getElement() ) dd_Found = true;
				else if ( element === DB.getElement() ) db_Found = true;		
				else fail( "Element "+element+" not in this collection" );
			}
			
			assertTrue( 
				aFound &&
				bFound && 
				cFound && 
				dFound && 
				eFound &&
				ab_Found &&
				bc_Found &&
				bd_Found &&
				dc_Found &&
				aa_Found &&
				cc_Found &&
				dd_Found &&
				db_Found );
				
		}
		
		public function testGetEdgeType() : void
		{
			assertEquals( EdgeType.OUT , graph.getEdgeType( AB , A ) );
			assertEquals( EdgeType.IN , graph.getEdgeType( BC , B ) );
			assertEquals( EdgeType.OUT , graph.getEdgeType( BD  , B) );
			assertEquals( EdgeType.UNDIR , graph.getEdgeType( DC , D ) );

			assertEquals( EdgeType.UNDIR , graph.getEdgeType( AA , A ) );
			assertEquals( EdgeType.OUT , graph.getEdgeType( CC , C ) );
			assertEquals( EdgeType.OUT , graph.getEdgeType( DD , D ) );		
			
			assertEquals( EdgeType.IN , graph.getEdgeType( DB , B ) );			
		}
				
		public function testPositions() : void
		{
			var aFound:Boolean = false;
			var bFound:Boolean = false;
			var cFound:Boolean = false;
			var dFound:Boolean = false;
			var eFound:Boolean = false;
			
			var ab_Found:Boolean = false;
			var bc_Found:Boolean = false;
			var bd_Found:Boolean = false;
			var dc_Found:Boolean = false;
			var aa_Found:Boolean = false;
			var cc_Found:Boolean = false;
			var dd_Found:Boolean = false;
			var db_Found:Boolean = false;
			
			var it:IIterator = graph.positions();
			var p:IGraphPosition;
			while( it.hasNext() )
			{
				p = IGraphPosition(it.next());
				assertNotNull(p);
				
				if ( p === A ) aFound = true;
				else if ( p === B ) bFound = true;
				else if ( p === C ) cFound = true;
				else if ( p === D ) dFound = true;
				else if ( p === E ) eFound = true;
				else if ( p === AB ) ab_Found = true;
				else if ( p === BC ) bc_Found = true;
				else if ( p === BD ) bd_Found = true;
				else if ( p === DC ) dc_Found = true;
				else if ( p === AA ) aa_Found = true;
				else if ( p === CC ) cc_Found = true;
				else if ( p === DD ) dd_Found = true;
				else if ( p === DB ) db_Found = true;		
				else fail( "GraphPosition "+p+" not in this collection" );
			}
			
			assertTrue( 
				aFound &&
				bFound && 
				cFound && 
				dFound && 
				eFound &&
				ab_Found &&
				bc_Found &&
				bd_Found &&
				dc_Found &&
				aa_Found &&
				cc_Found &&
				dd_Found &&
				db_Found );
		}
		
		public function testSize() : void
		{
			assertEquals( 13 , graph.size() );
		}
		
		public function testSwapElements() : void
		{
			graph.swapElements(A,B);
			assertEquals( "B" , A.getElement() );
		}
		
		public function testIsEmpty() : void
		{
			assertFalse( graph.isEmpty() );
			graph.clear();
			assertTrue( graph.isEmpty() );
		}
		
		public function testFindAccessorByElement() : void
		{
			assertEquals( A , graph.findAccessorByElement("A") );
		}
		
		
	}
}