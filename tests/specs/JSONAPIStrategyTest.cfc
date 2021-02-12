/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	variables.testOutputDir = expandPath( "/tests/tmp/json" );

	/*********************************** LIFE CYCLE Methods ***********************************/


	/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "JSONAPIStrategy", function(){
			beforeEach( function(){
				variables.docbox = new docbox.DocBox(
					strategy   = "docbox.strategy.json.JSONAPIStrategy",
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
				expect( function(){
					variables.docbox.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				} ).notToThrow();
			} );

			it( "produces JSON output in the correct directory", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				var results = directoryList(
					variables.testOutputDir,
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
				expect( directoryExists( variables.testOutputDir & "/tests/specs" ) ).toBeTrue(
					"should generate tests/specs directory for output"
				);

				expect( fileExists( variables.testOutputDir & "/tests/specs/JSONAPIStrategyTest.json" ) ).toBeTrue(
					"should generate JSONAPIStrategyTest.json documentation file"
				);

				expect( fileExists( variables.testOutputDir & "/tests/specs/HTMLAPIStrategyTest.json" ) ).toBeTrue(
					"should generate HTMLAPIStrategyTest.json documentation file"
				);
			} );

			it( "produces package-summary.json file for each 'package' level", function(){
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				expect( fileExists( variables.testOutputDir & "/tests/specs/package-summary.json" ) ).toBeTrue(
					"should generate package summary file"
				);

				var packageSummary = deserializeJSON(
					fileRead( variables.testOutputDir & "/tests/specs/package-summary.json" )
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
					expect( fileExists( variables.testOutputDir & "/" & class.path ) ).toBeTrue(
						"should point to existing class documentation file"
					);
				} );
			} );
		} );
	}

}

