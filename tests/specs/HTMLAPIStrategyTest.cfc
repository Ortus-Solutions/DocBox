/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	variables.testOutputDir = expandPath( "/tests/tmp/html" );

	/*********************************** LIFE CYCLE Methods ***********************************/

	/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "HTMLAPIStrategy", function(){
			beforeEach( function(){
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.api.HTMLAPIStrategy",
					properties = {
						projectTitle : "DocBox Tests",
						outputDir    : variables.testOutputDir
					}
				);
				// empty the directory so we know if it has been populated
				if ( directoryExists( variables.testOutputDir ) ) {
					directoryDelete( variables.testOutputDir, true );
				}
				directoryCreate( variables.testOutputDir );
			} );

			it( "can run without failure", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);
			} );

			it( "produces JSON output in the correct directory", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				var allClassesFile = variables.testOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);

				var allClassesHTML = fileRead( allClassesFile );
				expect( allClassesHTML ).toInclude(
					"HTMLAPIStrategyTest",
					"should document HTMLAPIStrategyTest.cfc in list of classes."
				);

				var testFile = variables.testOutputDir & "/tests/specs/HTMLAPIStrategyTest.html";
				expect( fileExists( testFile ) ).toBeTrue(
					"should generate #testFile# to document HTMLAPIStrategyTest.cfc"
				);
			} );
		} );
	}

}

