/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	variables.HTMLOutputDir = expandPath( "/tests/tmp/html" );
	variables.JSONOutputDir = expandPath( "/tests/tmp/json" );
	variables.XMIOutputFile = expandPath( "/tests/tmp/XMITestFile.uml" );

	/*********************************** LIFE CYCLE Methods ***********************************/

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "DocBox", function(){
			beforeEach( function(){
				resetTmpDirectory( variables.HTMLOutputDir );
				resetTmpDirectory( variables.JSONOutputDir );
				resetTmpDirectory( getDirectoryFromPath( variables.XMIOutputFile ) );

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
		} );
	}

	function resetTmpDirectory( directory ){
		// empty the directory so we know if it has been populated
		if ( directoryExists( arguments.directory ) ) {
			directoryDelete( arguments.directory, true );
		}
		directoryCreate( arguments.directory );
	}

}

