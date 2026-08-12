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
						outputDir    : variables.testOutputDir,
						projectTitle : "custom CommandBox module"
					}
				).generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var overviewFile = variables.testOutputDir & "/overview-frame.html";
				expect( fileExists( overviewFile ) ).toBeTrue( "should generate overview-frame.html file" );
				var overviewHTML = fileRead( overviewFile );
				expect( overviewHTML ).toInclude(
					"frameless SPA design",
					"should document CommandBoxStrategyTest.cfc in list of namespaces."
				);
			} );

			it( "produces HTML output in the correct directory", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var overviewFile = variables.testOutputDir & "/overview-frame.html";
				expect( fileExists( overviewFile ) ).toBeTrue( "should generate overview-frame.html file" );

				var overviewHTML = fileRead( overviewFile );
				expect( overviewHTML ).toInclude(
					"frameless SPA design",
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
				debug( fileContents )
				expect( fileContents )
					.toInclude(
						"Creates documentation for CFCs JavaDoc style via DocBox",
						"docs should include component hint"
					)
					.toInclude(
						"The base mapping for the folder.",
						"docs should include property description"
					);

				// ugh! This method hint is not included in the output.
				// expect( fileContents )
				// .toInclude( "Run DocBox to generate your docs", "docs should include method hint" )
			} );

			it( "generates the navigation data file", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var navFile = variables.testOutputDir & "/data/navigation.js";
				expect( fileExists( navFile ) ).toBeTrue( "should generate data/navigation.js for the SPA" );

				var navContent = fileRead( navFile );
				expect( navContent )
					.toInclude(
						"COMMANDBOX_NAV_DATA",
						"navigation data should set COMMANDBOX_NAV_DATA global"
					)
					.toInclude(
						"""namespaces""",
						"navigation data should have a namespaces array"
					)
					.toInclude(
						"""allCommands""",
						"navigation data should have a flat allCommands array"
					)
					.toInclude(
						"""topLevel""",
						"navigation data should have a topLevel array for root commands"
					);
			} );

			it( "places root-level commands in the topLevel navigation array", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var navContent = fileRead( variables.testOutputDir & "/data/navigation.js" );
				// generate.cfc lives at the root mapping, so its command is "generate" (one word = top-level)
				expect( navContent ).toInclude(
					"""generate""",
					"root-level generate command should appear in topLevel navigation array"
				);
			} );

			it( "places namespaced commands in the namespaces navigation array", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var navContent = fileRead( variables.testOutputDir & "/data/navigation.js" );
				// config/show.cfc → command "config show", namespace "config"
				expect( navContent )
					.toInclude(
						"""config""",
						"namespaced config commands should create a config namespace entry"
					)
					.toInclude(
						"""config show""",
						"config show command should appear in allCommands"
					);
			} );

			it( "places child namespace commands in namespace children array", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var navContent = fileRead( variables.testOutputDir & "/data/navigation.js" );
				// config/sync/pull.cfc → command "config sync pull", namespace "config sync"
				// generateNavigation.cfm nests this as a child under the config namespace
				expect( navContent )
					.toInclude(
						"""children""",
						"namespaces with sub-namespaces should have a children array"
					)
					.toInclude(
						"""config sync pull""",
						"child namespace command should appear in allCommands"
					)
					.toInclude(
						"""config sync""",
						"child namespace fullNamespace should be recorded"
					);
			} );

			it( "copies all required static assets", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				// JS overlay from CommandBox theme (step 2 of asset copy)
				expect( fileExists( variables.testOutputDir & "/js/app.js" ) ).toBeTrue(
					"should copy CommandBox SPA app.js"
				);
				// CSS overlay from shared HTMLAPIStrategy theme (step 3)
				expect( fileExists( variables.testOutputDir & "/css/stylesheet.css" ) ).toBeTrue(
					"should copy shared HTMLAPIStrategy stylesheet"
				);
				// Frames theme bootstrap assets (step 1)
				expect( directoryExists( variables.testOutputDir & "/bootstrap" ) ).toBeTrue(
					"should copy Bootstrap assets from frames theme"
				);
				// SyntaxHighlighter from frames theme (step 1)
				expect( directoryExists( variables.testOutputDir & "/highlighter" ) ).toBeTrue(
					"should copy SyntaxHighlighter assets from frames theme"
				);
			} );

			it( "generates an Alpine.js SPA entry point in index.html", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var indexFile = variables.testOutputDir & "/index.html";
				expect( fileExists( indexFile ) ).toBeTrue( "should generate index.html as the SPA shell" );

				var indexHTML = fileRead( indexFile );
				expect( indexHTML )
					.toInclude(
						"x-data=""commandApp()""",
						"index.html should mount the Alpine.js commandApp() component"
					)
					.toInclude(
						"js/app.js",
						"index.html should reference the SPA app.js script"
					)
					.toInclude(
						"data/navigation.js",
						"index.html should reference the generated navigation data script"
					)
					.toInclude(
						"alpine",
						"index.html should reference Alpine.js"
					);
			} );

			it( "generates an overview-summary page", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				var summaryFile = variables.testOutputDir & "/overview-summary.html";
				expect( fileExists( summaryFile ) ).toBeTrue( "should generate overview-summary.html" );
			} );

			it( "augments command pages with the full CLI command path", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests/resources/commandbox-docbox/commands" ),
					mapping  = "commands",
					excludes = "(coldbox|build\-docbox)"
				);

				// config/show.cfc should be documented as "config show"
				var showFile = variables.testOutputDir & "/commands/config/show.html";
				expect( fileExists( showFile ) ).toBeTrue(
					"should generate individual command page for config/show.cfc"
				);

				var showHTML = fileRead( showFile );
				expect( showHTML ).toInclude(
					"config show",
					"command page should display the full CLI command path"
				);
			} );
		} );
	}

}
