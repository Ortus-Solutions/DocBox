/**
 * Build process for DocBox
 */
component {

	/**
	 * Constructor
	 */
	function init(){
		// Setup Pathing
		variables.cwd          = getCWD().reReplace( "\.$", "" );
		variables.artifactsDir = cwd & "/.artifacts";
		variables.buildDir     = cwd & "/.tmp";
		variables.testRunner   = "http://localhost:60299/tests/runner.cfm";

		// Source Excludes Not Added to final binary
		variables.excludes = [
			"build",
			"node-modules",
			"resources",
			"test-harness",
			"(package|package-lock).json",
			"webpack.config.js",
			"server-.*\.json",
			"docker-compose.yml",
			"^\..*",
			"coldbox-5-router-documentation.png"
		];

		// Cleanup + Init Build Directories
		[
			variables.buildDir,
			variables.artifactsDir
		].each( function( item ){
			if ( directoryExists( item ) ) {
				directoryDelete( item, true );
			}
			// Create directories
			directoryCreate( item, true, true );
		} );

		// Create Mappings
		fileSystemUtil.createMapping( "docbox", variables.cwd );

		return this;
	}

	/**
	 * Run the build process: test, build source, checksums
	 *
	 * @projectName The project name used for resources and slugs
	 * @version The version you are building
	 * @buldID The build identifier
	 * @branch The branch you are building
	 */
	function run(
		required projectName,
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Create project mapping
		fileSystemUtil.createMapping( arguments.projectName, variables.cwd );

		// Build the source
		buildSource( argumentCollection = arguments );

		// checksums
		buildChecksums();

		// Finalize Message
		variables.print
			.line()
			.boldMagentaLine( "Build Process is done! Enjoy your build!" )
			.toConsole();
	}

	/**
	 * Run the test suites
	 */
	function runTests(){
		variables.print
			.line()
			.boldGreenLine( "------------------------------------------------" )
			.boldGreenLine( "Starting to execute your tests..." )
			.boldGreenLine( "------------------------------------------------" )
			.toConsole();

		var sTime = getTickCount();

		command( "testbox run" )
			.params(
				runner        = variables.testRunner,
				verbose       = true,
				outputFile    = "#variables.cwd#/tests/results/test-results",
				outputFormats = "json,antjunit"
			)
			.run();

		// Check Exit Code?
		if ( shell.getExitCode() ) {
			return error( "Cannot continue building, tests failed!" );
		} else {
			variables.print
				.line()
				.boldGreenLine( "------------------------------------------------" )
				.boldGreenLine( "All tests passed in #getTickCount() - sTime#ms! Ready to go, great job!" )
				.boldGreenLine( "------------------------------------------------" )
				.toConsole();
		}
	}

	/**
	 * Build the source
	 *
	 * @projectName The project name used for resources and slugs
	 * @version The version you are building
	 * @buldID The build identifier
	 * @branch The branch you are building
	 */
	function buildSource(
		required projectName,
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Build Notice ID
		variables.print
			.line()
			.boldMagentaLine( "Building #arguments.projectName# v#arguments.version#" )
			.toConsole();

		ensureExportDir( argumentCollection = arguments );

		// Project Build Dir
		variables.projectBuildDir = variables.buildDir & "/#projectName#";
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
			"#variables.projectBuildDir#/#projectName#-#version#",
			"Built with love on #dateTimeFormat( now(), "full" )#"
		);

		// Updating Placeholders
		print.greenLine( "Updating version identifier to #arguments.version#" ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = "@build.version@",
				replacement = arguments.version,
				verbose     = true
			)
			.run();

		print.greenLine( "Updating build identifier to [#arguments.buildID#-#arguments.branch#]..." ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = ( arguments.branch == "master" ? "@build.number@" : "+@build.number@" ),
				replacement = ( arguments.branch == "master" ? arguments.buildID : "-snapshot" ),
				verbose     = true
			)
			.run();

		// zip up source
		var destination = "#variables.exportsDir#/#projectName#-#version#.zip";
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

	/**
	 * Ensure the export directory exists at artifacts/NAME/VERSION/
	 */
	private function ensureExportDir(
		required projectName,
		version = "1.0.0"
	){
		if ( structKeyExists( variables, "exportsDir" ) && directoryExists( variables.exportsDir ) ) {
			return;
		}
		// Prepare exports directory
		variables.exportsDir = variables.artifactsDir & "/#projectName#/#arguments.version#";
		directoryCreate( variables.exportsDir, true, true );
	}

}
