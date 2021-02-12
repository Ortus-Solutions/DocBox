/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	variables.testOutputFile = expandPath( "/tests/tmp/XMITestFile.uml" );

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes after all suites+specs in the run() method
	function afterAll(){
		if ( fileExists( variables.testOutputFile ) ) {
			fileDelete( variables.testOutputFile );
		}

		var testDir = getDirectoryFromPath( variables.testOutputFile );
		if ( directoryExists( variables.testOutputFile ) ) {
			directoryDelete( variables.testOutputFile );
		}
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "XMLStrategy", function(){
			beforeEach( function(){
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.uml2tools.XMIStrategy",
					properties = {
						projectTitle : "DocBox Tests",
						outputFile   : variables.testOutputFile
					}
				);

				// delete the test file so we know if it has been created during test runs
				if ( fileExists( variables.testOutputFile ) ) {
					fileDelete( variables.testOutputFile );
				}
			} );

			it( "can run without failure", function(){
				expect( function(){
					variables.docbox.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				} ).notToThrow();
			} );

			it( "produces UML output in the correct file", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				expect( fileExists( variables.testOutputFile ) ).toBeTrue( "Should generate the UML diagram file " );

				var umlContent = fileRead( variables.testOutputFile );
				expect( UMLContent ).toInclude(
					"name=""XMIStrategyTest"">",
					"should find and document the XMIStrategyTest.cfc class in tests/specs directory"
				);
			} );
		} );
	}

}
