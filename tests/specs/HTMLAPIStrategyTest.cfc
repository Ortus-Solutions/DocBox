/**
 * Test HTML documentation strategy
 * 
 * @myComponentTag is a custom docblock tag on a component
 */
component extends="testbox.system.BaseSpec" {

    /**
     * test the custom tag support
     * 
     * @myMethodTag is a custom docblock tag on a component method
     */
    public numeric function roundToFive(){}

    /**
     * test the custom tag support
     * 
     * @myPropertyTag is a custom docblock tag on a component property
     */
    property name="maxRows" type="numeric" default="1";

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

			// TODO: Implement
			xit( "throws exception when source does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "docbox.strategy.api.HTMLAPIStrategy",
						properties = {
							projectTitle : "DocBox Tests",
							outputDir    : variables.testOutputDir
						}
					);
					testDocBox.generate(
						source   = "/bla",
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				}).toThrow( "InvalidConfigurationException" );
			});

			it( "throws exception when outputDir does not exist", function() {
				expect( function(){
					var testDocBox = new docbox.DocBox(
						strategy   = "docbox.strategy.api.HTMLAPIStrategy",
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

			it( "produces HTML output in the correct directory", function(){
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

			it( "supports custom tags in the component, property and method output", function() {
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);
				var testFile = variables.testOutputDir & "/tests/specs/HTMLAPIStrategyTest.html";
				expect( fileExists( testFile ) ).toBeTrue(
					"should generate #testFile# to document HTMLAPIStrategyTest.cfc"
				);

				var documentationOutput = fileRead( testFile );
				expect( documentationOutput ).toInclude( "myComponentTag" )
												.toInclude( "is a custom docblock tag on a component" );
				expect( documentationOutput ).toInclude( "myPropertyTag" )
														.toInclude( "is a custom docblock tag on a component property" );
				expect( documentationOutput ).toInclude( "myMethodTag" )
														.toInclude( "is a custom docblock tag on a component method" );
			});
			it( "allows HTML in docblocks", function() {
				variables.docbox.generate(
					source   = expandPath( "/tests" ),
					mapping  = "tests",
					excludes = "(coldbox|build\-docbox)"
				);

				var testFile = variables.testOutputDir & "/tests/specs/HTMLAPIStrategyTest.html";
				expect( fileExists( testFile ) ).toBeTrue();

				var fileContents = fileRead( testFile );

				expect( fileContents ).toInclude( "<code>#chr(10)#testHTML( 'foo' )#chr(10)#</code>" );
			})
		} );
	}

	/**
	 * Test for allowing HTML in docblocks
	 * <p>
	 * This tests that docbox allows and includes docblock HTML in the generated documentation.
	 * <p>
	 * For example:
	 * <p>
	 * <code>
	 * 	testHTML( 'foo' )
	 * </code>
	 */
	function testHTML(){}
}

