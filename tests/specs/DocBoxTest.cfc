/**
 * Test the main DocBox model
 */
component extends="BaseTest" {

	variables.HTMLOutputDir = expandPath( "/tests/tmp/html" );
	variables.JSONOutputDir = expandPath( "/tests/tmp/json" );
	variables.XMIOutputFile = expandPath( "/tests/tmp/XMITestFile.uml" );

	/*********************************** LIFE CYCLE Methods ***********************************/

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "DocBox", function(){
			beforeEach( function(){
				resetTmpDirectory( getDirectoryFromPath( variables.XMIOutputFile ) );
				resetTmpDirectory( variables.HTMLOutputDir );
				resetTmpDirectory( variables.JSONOutputDir );

				if ( fileExists( expandPath( "/tests/FunkyComponent.cfc" ) ) ){
					fileDelete( expandPath( "/tests/FunkyComponent.cfc" ) );
				}

				variables.docbox = new docbox.DocBox();
			} );

			it( "Works with single strategy", function(){
				variables.docbox
					.addStrategy(
						"docbox.strategy.api.HTMLAPIStrategy",
						{ outputDir : variables.HTMLOutputDir }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);
			} );

			it( "defaults to HTML if no strategy is set", function(){
				variables.docbox.init(
					properties = {
						projectTitle = "Test", outputDir = variables.HTMLOutputDir
					}
				)
				.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);
				expect( variables.docbox.getStrategies() ).notTobeEmpty();
			} );

			it( "lets me set my own strategy", function(){
				expect( function(){
					var myDemoStrategy = getMockBox().createStub( extends = "docbox.strategy.AbstractTemplateStrategy" );
					myDemoStrategy.$(
						method      = "run",
						returns     = new docbox.strategy.AbstractTemplateStrategy(),
						callLogging = true
					);
					variables.docbox
						.setStrategy( myDemoStrategy )
						.generate(
							source   = expandPath( "/tests" ),
							mapping  = "tests",
							excludes = "(coldbox|build\-docbox)"
						);

					expect( myDemoStrategy.$once( "run" ) ).toBeTrue( "should execute strategy.run()" );
				} ).notToThrow();
			} );

			it( "Works with multiple strategies", function(){
				variables.docbox
					.addStrategy(
						"docbox.strategy.api.HTMLAPIStrategy",
						{ outputDir : variables.HTMLOutputDir }
					)
					.addStrategy(
						"docbox.strategy.json.JSONAPIStrategy",
						{ outputDir : variables.JSONOutputDir }
					)
					.addStrategy(
						"docbox.strategy.uml2tools.XMIStrategy",
						{ outputFile : variables.XMIOutputFile }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);

				var results = directoryList(
					variables.JSONOutputDir,
					true,
					"name"
				);
				expect( results.len() ).toBeGT( 0 );

				expect( arrayContainsNoCase( results, "overview-summary.json" ) ).toBeTrue(
					"should generate overview-summary.json class index file"
				);
			} );

			it( "Supports strategy aliases", function(){
				variables.docbox
					.addStrategy(
						"HTML",
						{ outputDir : variables.HTMLOutputDir }
					)
					.addStrategy(
						"JSON",
						{ outputDir : variables.JSONOutputDir }
					)
					.addStrategy(
						"XMI",
						{ outputFile : variables.XMIOutputFile }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);

				var results = directoryList(
					variables.JSONOutputDir,
					true,
					"name"
				);
				expect( results.len() ).toBeGT( 0 );

				expect( arrayContainsNoCase( results, "overview-summary.json" ) ).toBeTrue(
					"should generate overview-summary.json class index file"
				);
			} );

			/**
			 * Skipped due to issues with trace() messing up the CLI testbox runner.
			 * i.e. a trace() looks like an error to GHA, and totally borks the testbox report format as well.
			 */
			xit( "throws on invalid component if throwOnError=true", function() {
				var componentCode = "componentxyz{}";
				if ( !fileExists( expandPath( "/tests/FunkyComponent.cfc" ) ) ){
					fileWrite( expandPath( "/tests/FunkyComponent.cfc" ), componentCode );
				}
				expect( function(){
					variables.docbox.init(
						properties = {
							projectTitle = "Test",
							outputDir = variables.HTMLOutputDir
						}
					)
					.generate(
						source       = expandPath( "/tests" ),
						mapping      = "tests",
						excludes     = "(coldbox|build\-docbox)",
						throwOnError = true
					);
				}).toThrow( "InvalidComponentException" );
			});

			/**
			 * Skipped due to issues with trace() messing up the CLI testbox runner.
			 * i.e. a trace() looks like an error to GHA, and totally borks the testbox report format as well.
			 */
			xit( "does not throw on invalid component if throwOnError=false", function() {
				var componentCode = "componentxyz{}";
				if ( !fileExists( expandPath( "/tests/FunkyComponent.cfc" ) ) ){
					fileWrite( expandPath( "/tests/FunkyComponent.cfc" ), componentCode );
				}
				expect( function(){
					variables.docbox.init(
						properties = {
							projectTitle = "Test",
							outputDir = variables.HTMLOutputDir
						}
					)
					.generate(
						source       = expandPath( "/tests" ),
						mapping      = "tests",
						excludes     = "(coldbox|build\-docbox)",
						throwOnError = false
					);
				}).notToThrow( "InvalidComponentException" );
			});
		} );
	}

}

