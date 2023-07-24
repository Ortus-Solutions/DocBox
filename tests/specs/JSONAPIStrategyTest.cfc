/**
 * My BDD Test
 */
component extends="BaseTest" {

	function run(){
		// all your suites go here.
		describe( "JSONAPIStrategy", function(){
			beforeEach( function(){
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.json.JSONAPIStrategy",
					properties = {
						projectTitle : "DocBox Tests",
						outputDir    : variables.JSONOutputDir
					}
				);
				resetTmpDirectory(variables.JSONOutputDir);
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

			it( "throws exception when source does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "docbox.strategy.json.JSONAPIStrategy",
						properties = {
							projectTitle : "DocBox Tests",
							outputDir    : variables.JSONOutputDir
						}
					);
					testDocBox.generate(
						source   = "bla",
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				}).toThrow( "InvalidConfigurationException" );
			});

			it( "throws exception when outputDir does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "docbox.strategy.json.JSONAPIStrategy",
						properties = {
							projectTitle : "DocBox Tests",
							outputDir    : expandPath( "nowhere/USA" )
						}
					);
					testDocBox.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				}).toThrow( "InvalidConfigurationException" );
			});

			it( "produces JSON output in the correct directory", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				var results = directoryList(
					variables.JSONOutputDir,
					true,
					"name"
				);
				expect( results.len() ).toBeGT( 0 );

				expect( arrayContainsNoCase( results, "overview-summary.json" ) ).toBeTrue(
					"should generate index.json class index file"
				);
				expect( arrayContainsNoCase( results, "JSONAPIStrategyTest.json" ) ).toBeTrue(
					"should generate JSONAPIStrategyTest.json to document JSONAPIStrategyTest.cfc"
				);
			} );

			it( "Produces the correct hierarchy of class documentation files", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);
				expect( directoryExists( variables.JSONOutputDir & "/tests/specs" ) ).toBeTrue(
					"should generate tests/specs directory for output"
				);

				expect( fileExists( variables.JSONOutputDir & "/tests/specs/JSONAPIStrategyTest.json" ) ).toBeTrue(
					"should generate JSONAPIStrategyTest.json documentation file"
				);

				expect( fileExists( variables.JSONOutputDir & "/tests/specs/HTMLAPIStrategyTest.json" ) ).toBeTrue(
					"should generate HTMLAPIStrategyTest.json documentation file"
				);
			} );

			it( "produces package-summary.json file for each 'package' level", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				expect( fileExists( variables.JSONOutputDir & "/tests/specs/package-summary.json" ) ).toBeTrue(
					"should generate package summary file"
				);

				var packageSummary = deserializeJSON(
					fileRead( variables.JSONOutputDir & "/tests/specs/package-summary.json" )
				);

				expect( packageSummary ).toBeTypeOf( "struct" ).toHaveKey( "classes" );

				expect( packageSummary.classes ).toBeTypeOf( "array" );
				expect( packageSummary.classes.len() ).toBeGT(
					0,
					"should have a few documented packages"
				);
				packageSummary.classes.each( function( class ){
					expect( class )
						.toBeTypeOf( "struct" )
						.toHaveKey( "path" )
						.toHaveKey( "name" );
					expect( listLast( class.path, "." ) ).toBe( "json" );
					expect( fileExists( variables.JSONOutputDir & "/" & class.path ) ).toBeTrue(
						"should point to existing class documentation file"
					);
				} );
			} );
		} );
	}

}

