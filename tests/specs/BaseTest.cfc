/**
 * Test the main DocBox model
 */
component extends="testbox.system.BaseSpec" {

	variables.HTMLOutputDir = expandPath( "/tests/tmp/html" );
	variables.JSONOutputDir = expandPath( "/tests/tmp/json" );
	variables.XMIOutputFile = expandPath( "/tests/tmp/XMITestFile.uml" );

	function run( testResults, testBox ){
	}

	function resetTmpDirectory( directory ){
		// empty the directory so we know if it has been populated
		if ( directoryExists( arguments.directory ) ) {
			directoryDelete( arguments.directory, true );
		}
		directoryCreate( arguments.directory );
	}

}