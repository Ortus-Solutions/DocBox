/**
 * My BDD Test
 */
component extends="BaseTest" {

	// executes after all suites+specs in the run() method
	function afterAll(){
		if ( fileExists( variables.XMIOutputFile ) ) {
			fileDelete( variables.XMIOutputFile );
		}

		var testDir = getDirectoryFromPath( variables.XMIOutputFile );
		if ( directoryExists( variables.XMIOutputFile ) ) {
			directoryDelete( variables.XMIOutputFile );
		}
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "XMLStrategy", function(){
			beforeEach( function(){
				resetTmpDirectory( getDirectoryFromPath( variables.XMIOutputFile ) );
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.uml2tools.XMIStrategy",
					properties = {
						projectTitle : "DocBox Tests",
						outputFile   : variables.XMIOutputFile
					}
				);

				// delete the test file so we know if it has been created during test runs
				if ( fileExists( variables.XMIOutputFile ) ) {
					fileDelete( variables.XMIOutputFile );
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

				expect( fileExists( variables.XMIOutputFile ) ).toBeTrue( "Should generate the UML diagram file " );

				var umlContent = fileRead( variables.XMIOutputFile );
				expect( UMLContent ).toInclude(
					"name=""XMIStrategyTest"">",
					"should find and document the XMIStrategyTest.cfc class in tests/specs directory"
				);
			} );
			it( "throws exception when outputFile path does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "XMI",
						properties = {
							projectTitle : "DocBox Tests",
							outputFile   : "my/output/file.uml"
						}
					);
					testDocBox.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				}).toThrow( "InvalidConfigurationException" );
			});
		} );
	}

}
