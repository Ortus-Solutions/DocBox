/**
 * Dog eat Dog: Build your own docs
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
		variables.apidocsDir   = variables.buildDir & "/apidocs";
		variables.projectName  = "docbox";

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
	 * Build the docs!
	 */
	function run( version = "1.0.0" ){
		ensureExportDir( argumentCollection = arguments );
		directoryCreate( variables.apidocsDir, true, true );
		print.greenLine( "Generating API Docs, please wait..." ).toConsole();

		new docbox.DocBox()
			.addStrategy(
				"HTML",
				{
					projectTitle : "DocBox API Docs",
					outputDir    : variables.apidocsDir
				}
			)
			.addStrategy(
				"JSON",
				{
					projectTitle : "DocBox API Docs",
					outputDir    : variables.apidocsDir
				}
			)
			.generate(
				source   = expandPath( "/docbox" ),
				mapping  = "docbox",
				excludes = "(.github|build|tests)"
			);

		print.greenLine( "API Docs produced at #variables.apidocsDir#" ).toConsole();

		var destination = "#variables.exportsDir#/#projectName#-docs-#version#.zip";
		print.greenLine( "Zipping apidocs to #destination#" ).toConsole();
		cfzip(
			action    = "zip",
			file      = "#destination#",
			source    = "#variables.apidocsDir#",
			overwrite = true,
			recurse   = true
		);
	}

	/**
	 * Ensure the export directory exists at artifacts/NAME/VERSION/
	 */
	private function ensureExportDir( version = "1.0.0" ){
		if ( structKeyExists( variables, "exportsDir" ) && directoryExists( variables.exportsDir ) ) {
			return;
		}
		// Prepare exports directory
		variables.exportsDir = variables.artifactsDir & "/#projectName#/#arguments.version#";
		directoryCreate( variables.exportsDir, true, true );
	}

}
