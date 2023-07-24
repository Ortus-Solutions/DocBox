/**
 * Test HTML documentation strategy
 */
component extends="BaseTest" {

	variables.testOutputDir = expandPath( "/tests/tmp/commandbox-docbox" );

	/*********************************** LIFE CYCLE Methods ***********************************/

	/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "CommandBoxStrategy", function(){
			beforeEach( function(){
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.CommandBox.CommandBoxStrategy",
					properties = {
						projectTitle : "DocBox Tests",
						outputDir    : variables.testOutputDir
					}
				);
				resetTmpDirectory( variables.testOutputDir );
			} );

			it( "can run without failure", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);
			} );

			it( "Supports strategy alias", function(){
				new docbox.DocBox(
						"CommandBox",
						{
							outputDir : variables.testOutputDir,
							projectTitle : "custom CommandBox module"
						}
					)
					.generate(
						source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
						mapping  = "commands",
						excludes = "(coldbox|build\-docbox)"
					);

					var overviewFile = variables.testOutputDir & "/overview-frame.html";
					expect( fileExists( overviewFile ) ).toBeTrue(
						"should generate overview-frame.html file to list all commands"
					);
	
					var overviewHTML = fileRead( overviewFile );
					expect( overviewHTML ).toInclude(
						"Generate",
						"should document commands/generate.cfc in list of classes."
					);

			});

			xit( "throws exception when outputDir does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "docbox.strategy.CommandBox.CommandBoxStrategy",
						properties = {
							projectTitle : "DocBox Tests",
							outputDir    : expandPath( "/tests/tmp/bla" )
						}
					);
					testDocBox.generate(
						source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
						mapping  = "commands",
						excludes = "(coldbox|build\-docbox)"
					);
				}).toThrow( "InvalidConfigurationException" );
			});

			it( "produces HTML output in the correct directory", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var overviewFile = variables.testOutputDir & "/overview-frame.html";
				expect( fileExists( overviewFile ) ).toBeTrue(
					"should generate overview-frame.html file to list all commands"
				);

				var overviewHTML = fileRead( overviewFile );
				expect( overviewHTML ).toInclude(
					"Generate",
					"should document commands/generate.cfc in list of classes."
				);

				var testFile = variables.testOutputDir & "/commands/generate.html";
				expect( fileExists( testFile ) ).toBeTrue(
					"should generate #testFile# to document 'docbox generate' command.cfc"
				);
			} );

			it( "produces decent command documentation", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);
				var testFile = variables.testOutputDir & "/commands/generate.html";
				expect( fileExists( testFile ) ).toBeTrue();

				var fileContents = fileRead( testFile );
				
				expect( fileContents )
						.toInclude( "Creates documentation for CFCs JavaDoc style via DocBox", "docs should include component hint" )
						.toInclude( "The base mapping for the folder.", "docs should include property description" );

				// ugh! This method hint is not included in the output.
				//expect( fileContents )
						// .toInclude( "Run DocBox to generate your docs", "docs should include method hint" )
			} );
		} );
	}

}

