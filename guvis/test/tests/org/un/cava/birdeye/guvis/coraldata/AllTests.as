package tests.org.un.cava.birdeye.guvis.coraldata
{
	import flexunit.framework.TestSuite;
	import flexunit.framework.Test;

	import tests.org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.*;

	public class AllTests extends TestSuite
	{
		public static function suite() : Test
		{
			var testSuite : TestSuite = new TestSuite();
			
			testSuite.addTest( new TestSuite( TestIncidenceListGraph ) );

			return testSuite;

		}
	}
}