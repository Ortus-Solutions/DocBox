/**
 * JSON API Strategy for DocBox
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 */
component extends="docbox.strategy.AbstractTemplateStrategy" accessors="true" {

	/**
	 * The output directory
	 */
	property name="outputDir" type="string";

	/**
	 * The project title to use
	 */
	property
		name   ="projectTitle"
		default="Untitled"
		type   ="string";

	/**
	 * Constructor
	 *
	 * @outputDir The output directory
	 * @projectTitle The title used in the HTML output
	 */
	component function init(
		required outputDir,
		string projectTitle = "Untitled"
	){
		super.init();

		variables.outputDir    = arguments.outputDir;
		variables.projectTitle = arguments.projectTitle;

		return this;
	}

	/**
	 * Generate JSON documentation
	 *
	 * @metadata All component metadata, sourced from DocBox.
	 */
	component function run( required query metadata ){
		if ( !directoryExists( getOutputDir() ) ){
			throw(
				message = "Invalid configuration; output directory not found",
				type = "InvalidConfigurationException",
				detail = "OutputDir #getOutputDir()# does not exist."
			);
		}
		ensureDirectory( getOutputDir() );

		var classes = normalizePackages(
			arguments.metadata.reduce( function( results, row ){
				results.append( row );
				return results;
			}, [] )
		);

		/**
		 * Generate hierarchical JSON package indices with classes
		 */
		var packages = classes.reduce( function( results, class ){
			if ( !results.keyExists( class.package ) ) {
				results[ class.package ] = [];
			}
			results[ class.package ].append( class );
			return results;
		}, {} );

		/**
		 * Generate top-level JSON package index
		 */
		serializeToFile(
			getOutputDir() & "/overview-summary.json",
			buildOverviewSummary( classes, packages )
		);

		/**
		 * Output a hierarchical folder structure which matches the original package structure -
		 * Including an index.json file for each package level.
		 */
		packages.each( function( package, classes ){
			var path = getOutputDir() & "/" & replace( package, ".", "/", "all" );
			if ( !directoryExists( path ) ) {
				directoryCreate( path );
			}
			classes.each( function( class ){
				serializeToFile( "#path#/#class.name#.json", class );
			} );

			/**
			 * Generate JSON package index for this package level
			 */
			serializeToFile(
				path & "/package-summary.json",
				buildPackageSummary( classes )
			);
		} );

		return this;
	}

	/**
	 * Marshall component names and paths into a package-summary.json file for each package hierarchy level
	 *
	 * @classData Component metadata sourced from DocBox
	 * @packages Array of packages for linking to package summary files
	 */
	package struct function buildOverviewSummary(
		required array classData,
		required struct packages
	){
		return {
			"classes"  : buildPackageSummary( arguments.classData ).classes,
			"packages" : arguments.packages.map( function( package ){
				return {
					"name" : package,
					"path" : "#replace( package, ".", "/", "all" )#/package-summary.json"
				};
			} ),
			"title" : getProjectTitle()
		};
	}

	/**
	 * Marshall component names and paths into a package-summary.json file for each package hierarchy level
	 *
	 * @classData Component metadata sourced from DocBox
	 */
	package struct function buildPackageSummary( required array classData ){
		return {
			"classes" : arguments.classData.map( function( class ){
				return {
					"name" : class.name,
					"path" : "#replace( class.package, ".", "/", "all" )#/#class.name#.json"
				};
			} )
		};
	}

	/**
	 * Normalize component metadata into a serializable package-component data format.
	 *
	 * @classData Component metadata, courtesy of DocBox
	 */
	package array function normalizePackages( required array classData ){
		return arguments.classData.map( function( row ){
			/**
			 * Marshall functions to match the designed schema;
			 */
			if ( !isNull( arguments.row.metadata.functions ) ) {
				var metaFunctions = arrayMap( arguments.row.metadata.functions, function( method ){
					return {
						"returnType"   : arguments.method.returnType ?: "any",
						"returnFormat" : isNull( arguments.method.returnFormat ) ? "plain" : arguments.method.returnFormat,
						"parameters"   : arguments.method.parameters,
						"name"         : arguments.method.name,
						"hint"         : arguments.method.keyExists( "hint" ) ? arguments.method.hint : "",
						"description"  : arguments.method.keyExists( "description" ) ? arguments.method.description : "",
						"access"       : arguments.method.access ?: "public",
						"position"     : arguments.method.keyExists( "position" ) ? arguments.method.position : {
							"start" : 0,
							"end"   : 0
						}
					};
				} );
			}
			return {
				"name"        : arguments.row.name,
				"package"     : arguments.row.package,
				"type"        : arguments.row.type,
				"extends"     : structKeyExists( arguments.row.metadata, "extends" ) ? arguments.row.extends : "",
				"fullextends" : structKeyExists(
					arguments.row.metadata,
					"fullextends"
				) ? arguments.row.fullextends : "",
				"hint"      : structKeyExists( arguments.row.metadata, "hint" ) ? arguments.row.metadata.hint : "",
				"functions" : structKeyExists( arguments.row.metadata, "functions" ) ? metaFunctions : []
			};
		} );
	}

	/**
	 * Serialize the given @data into JSON and write to @path.
	 *
	 * @path Full path and filename of the file to create or overwrite.
	 * @data Must be JSON-compatible... so either an array or a struct.
	 */
	package function serializeToFile(
		required string path,
		required any data
	){
		fileWrite(
			arguments.path,
			serializeJSON( arguments.data, true )
		);
	}

}
