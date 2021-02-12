/**
 * Build process for DocBox
 */
component {

	/**
	 * Constructor
	 */
	function init(){
		// Setup artifact name
		variables.projectName 	= "docbox";
		// Setup Pathing
		variables.cwd          	= getCWD().reReplace( "\.$", "" );
		variables.artifactsDir 	= variables.cwd & "/.artifacts";
		variables.buildDir     	= variables.cwd & "/.tmp";
		variables.apiDocsDir 	= variables.cwd & "/tests/apidocs";
		variables.apiDocsURL   	= "http://localhost:60299/tests/run.cfm";
		variables.testRunner   	= "http://localhost:60299/tests/runner.cfm";

		// Source Excludes Not Added to final binary
		variables.excludes = [
			"build",
			"tests",
			"^\..*",
			"server\-",
			"testbox",
			"coldbox-5-router-documentation.png"
		];

		// Cleanup + Init Build Directories
		[
			variables.buildDir,
			variables.artifactsDir,
			variables.apidocsDir
		].each( function( item ){
			if ( directoryExists( item ) ) {
				directoryDelete( item, true );
			}
			// Create directories
			directoryCreate( item, true, true );
		} );

		// Create Global Mappings
		fileSystemUtil.createMapping(
			"docbox",
			variables.cwd
		);
		fileSystemUtil.createMapping(
			"coldbox",
			variables.cwd & "tests/coldbox"
		);

		return this;
	}

	/**
	 * Run the build process: test, build source, docs, checksums
	 *
	 * @version The version you are building
	 * @buldID The build identifier
	 * @branch The branch you are building
	 */
	function run(
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Run the tests
		runTests();

		// Build the source
		buildSource( argumentCollection = arguments );

		// Build Docs
		docs( argumentCollection = arguments );

		// checksums
		buildChecksums();

		// Build latest changelog
		latestChangelog();

		// Finalize Message
		print.line()
			.boldMagentaLine( "Build Process is done! Enjoy your build!" )
			.toConsole();
	}

	/**
	 * Run the test suites
	 */
	function runTests(){
		// Tests First, if they fail then exit
		print.blueLine( "Testing the package, please wait..." ).toConsole();

		command( "testbox run" )
			.params(
				runner     = variables.testRunner,
				verbose    = true,
				outputFile = "build/results.json"
			)
			.run();

		// Check Exit Code?
		if ( shell.getExitCode() ) {
			return error( "Cannot continue building, tests failed!" );
		}
	}

	/**
	 * Build the source
	 *
	 * @version The version you are building
	 * @buldID The build identifier
	 * @branch The branch you are building
	 */
	function buildSource(
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Build Notice ID
		print.line()
			.boldMagentaLine(
				"Building #variables.projectName# v#arguments.version#+#arguments.buildID# from #variables.cwd# using the #arguments.branch# branch."
			)
			.toConsole();

		// Prepare exports directory
		variables.exportsDir = variables.artifactsDir & "/#variables.projectName#/#arguments.version#";
		directoryCreate( variables.exportsDir, true, true );

		// Project Build Dir
		variables.projectBuildDir = variables.buildDir & "/#variables.projectName#";
		directoryCreate(
			variables.projectBuildDir,
			true,
			true
		);

		// Copy source
		print.blueLine( "Copying source to build folder..." ).toConsole();
		copy(
			variables.cwd,
			variables.projectBuildDir
		);

		// Create build ID
		fileWrite(
			"#variables.projectBuildDir#/#variables.projectName#-#version#+#buildID#",
			"Built with love on #dateTimeFormat( now(), "full" )#"
		);

		// Updating Placeholders
		print.greenLine( "Updating version identifier to #arguments.version#" ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = "@build.version@",
				replacement = arguments.version
			)
			.run();

		print.greenLine( "Updating build identifier to #arguments.buildID#" ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = ( arguments.branch == "master" ? "@build.number@" : "+@build.number@" ),
				replacement = ( arguments.branch == "master" ? arguments.buildID : "-snapshot" )
			)
			.run();

		// zip up source
		var destination = "#variables.exportsDir#/#variables.projectName#-#version#.zip";
		print.greenLine( "Zipping code to #destination#" ).toConsole();
		cfzip(
			action    = "zip",
			file      = "#destination#",
			source    = "#variables.projectBuildDir#",
			overwrite = true,
			recurse   = true
		);

		// Copy box.json for convenience
		fileCopy(
			"#variables.projectBuildDir#/box.json",
			variables.exportsDir
		);
	}

	/**
	 * Produce the API Docs
	 */
	function docs( version = "1.0.0" ){
		// Generate Docs
		print.greenLine( "Generating API Docs, please wait..." ).toConsole();

		var cfhttpResponse = "";
		cfhttp(
			method 		= "GET",
			charset		= "UTF-8",
			url 		= variables.apiDocsURL & "?version=#arguments.version#",
			result		= "cfhttpResponse"
		);

		print.greenLine( "API Docs produced at #variables.apiDocsDir#" ).toConsole();

		var destination = "#variables.exportsDir#/#variables.projectName#-docs-#version#.zip";
		print.greenLine( "Zipping apidocs to #destination#" ).toConsole();
		cfzip(
			action    = "zip",
			file      = "#destination#",
			source    = "#variables.apiDocsDir#",
			overwrite = true,
			recurse   = true
		);
	}

	/**
	 * Build the latest changelog file: changelog-latest.md
	 */
	function latestChangelog(){
		print.blueLine( "Building latest changelog..." ).toConsole();

		if ( !fileExists( variables.cwd & "changelog.md" ) ) {
			return error( "Cannot continue building, changelog.md file doesn't exist!" );
		}

		fileWrite(
			variables.cwd & "changelog-latest.md",
			fileRead( variables.cwd & "changelog.md" ).split( "----" )[ 2 ].trim() & chr( 13 ) & chr( 10 )
		);

		print
			.greenLine( "Latest changelog file created at `changelog-latest.md`" )
			.line()
			.line( fileRead( variables.cwd & "changelog-latest.md" ) );
	}

	/********************************************* PRIVATE HELPERS *********************************************/

	/**
	 * Build Checksums
	 */
	private function buildChecksums(){
		print.greenLine( "Building checksums" ).toConsole();
		command( "checksum" )
			.params(
				path      = "#variables.exportsDir#/*.zip",
				algorithm = "SHA-512",
				extension = "sha512",
				write     = true
			)
			.run();
		command( "checksum" )
			.params(
				path      = "#variables.exportsDir#/*.zip",
				algorithm = "md5",
				extension = "md5",
				write     = true
			)
			.run();
	}

	/**
	 * DirectoryCopy is broken in lucee
	 */
	private function copy( src, target, recurse = true ){
		// process paths with excludes
		directoryList(
			src,
			false,
			"path",
			function( path ){
				var isExcluded = false;
				variables.excludes.each( function( item ){
					if ( path.replaceNoCase( variables.cwd, "", "all" ).reFindNoCase( item ) ) {
						isExcluded = true;
					}
				} );
				return !isExcluded;
			}
		).each( function( item ){
			// Copy to target
			if ( fileExists( item ) ) {
				print.blueLine( "Copying #item#" ).toConsole();
				fileCopy( item, target );
			} else {
				print.greenLine( "Copying directory #item#" ).toConsole();
				directoryCopy(
					item,
					target & "/" & item.replace( src, "" ),
					true
				);
			}
		} );
	}

	/**
	 * Gets the last Exit code to be used
	 **/
	private function getExitCode(){
		return ( createObject( "java", "java.lang.System" ).getProperty( "cfml.cli.exitCode" ) ?: 0 );
	}

}
