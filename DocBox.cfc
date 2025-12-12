/**
 *
 * Core DocBox documentation class that takes care of generating docs for you.
 * You can initialize the object with a strategy and strategy properties or with nothing at all.
 * You can then generate the docs according to 1 or more output strategies via the <code>generate()</code> method.
 * <hr>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	/**
	 * The strategy to use for document generation. Must extend docbox.strategy.AbstractTemplateStrategy
	 */
	property
		name       ="strategies"
		type       ="array"
		doc_generic="docbox.strategy.AbstractTemplateStrategy";

	/**
	 * Constructor
	 *
	 * @strategy The documentation output strategy to utilize.
	 * @properties Struct of data properties required for the specific output strategy
	 *
	 * @return The DocBox instance
	 */
	DocBox function init(
		any strategy      = "",
		struct properties = {}
	){
		variables.strategies = [];
		variables.properties = arguments.properties;

		// If we have a strategy, then add it in
		if ( len( arguments.strategy ) ) {
			addStrategy(
				strategy   = arguments.strategy,
				properties = arguments.properties
			);
		}

		return this;
	}

	/**
	 * Backwards-compatible setter to add a strategy to the docbox configuration.
	 *
	 * @see addStrategy
	 *
	 * @return The DocBox instance
	 */
	DocBox function setStrategy(){
		return addStrategy( argumentCollection = arguments );
	}

	/**
	 * Add a documentation strategy for output format.
	 *
	 * @strategy The optional strategy to generate the documentation with. This can be a class path or an instance of the  strategy. If none is passed then
	 * we create the default strategy of 'docbox.strategy.api.HTMLAPIStrategy'
	 * @properties The struct of properties to instantiate the strategy with.
	 *
	 * @return The DocBox instance
	 */
	DocBox function addStrategy(
		any strategy      = "docbox.strategy.api.HTMLAPIStrategy",
		struct properties = {}
	){
		// Set the incomign strategy to store
		var newStrategy = arguments.strategy;

		// If the strategy is not an object, then look it up
		if ( isSimpleValue( newStrategy ) ) {
			// Discover the strategy
			switch ( uCase( arguments.strategy ) ) {
				case "CommandBox":
					arguments.strategy = "docbox.strategy.CommandBox.CommandBoxStrategy";
					break;
				case "HTML":
				case "HTMLAPISTRATEGY":
					arguments.strategy = "docbox.strategy.api.HTMLAPIStrategy";
					break;
				case "JSON":
				case "JSONAPISTRATEGY":
					arguments.strategy = "docbox.strategy.json.JSONAPIStrategy";
					break;
				case "UML":
				case "XMI":
				case "XMISTRATEGY":
					arguments.strategy = "docbox.strategy.uml2tools.XMIStrategy";
				default:
					break;
			}
			// Build it out
			newStrategy = new "#arguments.strategy#"( argumentCollection = arguments.properties );
		}
		setStrategies( getStrategies().append( newStrategy ) );
		return this;
	}

	/**
	 * Generate the docs
	 *
	 * @source Either, the string directory source, OR an array of structs containing 'dir' and 'mapping' key
	 * @mapping The base mapping for the folder. Only required if the source is a string
	 * @excludes	A regex that will be applied to the input source to exclude from the docs
	 * @throwOnError Throw an error and halt the generation process if DocBox encounters an invalid component.
	 *
	 * @return The DocBox instance
	 */
	DocBox function generate(
		required source,
		string mapping       = "",
		string excludes      = "",
		boolean throwOnError = false
	){
		// verify we have at least one strategy defined, if not, auto add the HTML strategy
		if ( isNull( getStrategies() ) || !getStrategies().len() ) {
			this.addStrategy(
				strategy  : "HTML",
				properties: variables.properties
			);
		}

		// inflate the incoming input and mappings
		var thisSource = "";
		if ( isSimpleValue( arguments.source ) ) {
			thisSource = [
				{
					dir     : arguments.source,
					mapping : arguments.mapping
				}
			];
		} else {
			thisSource = arguments.source;
		}

		// build metadata collection
		var metadata = buildMetaDataCollection(
			thisSource,
			arguments.excludes,
			arguments.throwOnError
		);

		getStrategies().each( function( strategy ){
			strategy.run( metadata );
		} );

		return this;
	}

	/************************************ PRIVATE ******************************************/

	/**
	 * Clean input path
	 *
	 * @path The incoming path to clean
	 * @inputDir The input dir to clean off
	 */
	private function cleanPath( required path, required inputDir ){
		var currentPath = replace(
			getDirectoryFromPath( arguments.path ),
			arguments.inputDir,
			""
		);
		currentPath = reReplace( currentPath, "^[/\\]", "" );
		currentPath = reReplace( currentPath, "[/\\]", ".", "all" );
		return reReplace( currentPath, "\.$", "" );
	}

	/**
	 * Builds the searchable meta data collection
	 *
	 * @inputSource an array of structs containing inputDir and mapping
	 * @excludes	A regex that will be applied to the input source to exclude from the docs
	 * @throwOnError Throw an error and halt the generation process if DocBox encounters an invalid component.
	 */
	query function buildMetaDataCollection(
		required array inputSource,
		string excludes      = "",
		boolean throwOnError = false
	){
		var metadata = queryNew( "package,name,extends,metadata,type,implements,fullextends,currentMapping" );

		// iterate over input sources
		for ( var thisInput in arguments.inputSource ) {
			if ( !directoryExists( thisInput.dir ) ) {
				throw(
					message = "Invalid configuration; source directory not found",
					type    = "InvalidConfigurationException",
					detail  = "Configured source #thisInput.dir# does not exist."
				);
			}
			var aFiles = directoryList( thisInput.dir, true, "path", "*.cfc" );

			// iterate over files found
			for ( var thisFile in aFiles ) {
				// Excludes?
				// Use relative file path so placement on disk doesn't affect the regex check
				var relativeFilePath = replace( thisFile, thisInput.dir, "" );
				if ( len( arguments.excludes ) && reFindNoCase( arguments.excludes, relativeFilePath ) ) {
					continue;
				}
				// get current path
				var currentPath = cleanPath( thisFile, thisInput.dir );

				// calculate package path according to mapping
				var packagePath = thisInput.mapping;
				if ( len( currentPath ) ) {
					packagePath = listAppend( thisInput.mapping, currentPath, "." );
				}
				// setup class name
				var className = listFirst( getFileFromPath( thisFile ), "." );

				// Core Excludes, don't document the Application.(bx|cfc)
				if ( className == "Application" ) {
					continue;
				}

				try {
					// Get metadatata
					var meta = {};
					if ( len( packagePath ) ) {
						meta = server.keyExists( "boxlang" ) ? getClassmetadata( packagePath & "." & className ) : getComponentMetadata( packagePath & "." & className );
					} else {
						meta = server.keyExists( "boxlang" ) ? getClassmetadata( className ) : getComponentMetadata( className );
					}

					if ( len( packagePath ) AND NOT meta.name contains packagePath ) {
						meta.name = packagePath & "." & className;
					}

					// Add row
					queryAddRow( metadata );

					// Add contents
					querySetCell( metadata, "package", packagePath );
					querySetCell( metadata, "name", className );
					querySetCell( metadata, "metadata", meta );
					querySetCell( metadata, "type", meta.type );
					querySetCell( metadata, "currentMapping", thisInput.mapping );
					querySetCell( metadata, "extends", "" );
					querySetCell( metadata, "fullextends", "" );
					querySetCell( metadata, "implements", "" );

					// Get implements
					var implements = getImplements( meta );
					implements     = listQualify( arrayToList( implements ), ":" );
					querySetCell( metadata, "implements", implements );

					// Get inheritance
					var fullextends = getInheritance( meta );
					fullextends     = listQualify( arrayToList( fullextends ), ":" );

					querySetCell( metadata, "fullextends", fullextends );

					// so we cane easily query direct desendents
					if ( structKeyExists( meta, "extends" ) ) {
						if ( meta.type eq "interface" ) {
							querySetCell(
								metadata,
								"extends",
								meta.extends[ structKeyList( meta.extends ) ].name
							);
						} else {
							querySetCell(
								metadata,
								"extends",
								meta.extends.name
							);
						}
					} else {
						querySetCell( metadata, "extends", "" );
					}
				} catch ( Any e ) {
					if ( arguments.throwOnError ) {
						rethrow;
					} else {
						trace(
							type     = "warning",
							category = "docbox",
							inline   = "true",
							text     = "Warning! The following script has errors: " & packagePath & "." & className & ": #e.message & e.detail & e.stacktrace#"
						);
					}

					// Console Debugging
					writeDump(var="Warning! The following script has errors: " & packagePath & "." & className, output="console" )
					writeDump(var= "#e.message & e.detail#", output="console" )
					writeDump(var= e.stackTrace, output="console" )
				}
			}
			// end qFiles iteration
		}
		// end input source iteration

		return metadata;
	}

	/**
	 * Gets an array of the classes that this metadata implements, in order of extension
	 *
	 * @metadata The metadata to look at
	 *
	 * @return array of component interfaces implemented by some component in this package
	 */
	private array function getImplements( required struct metadata ){
		var interfaces = {};

		// check if a cfc
		if ( !listFindNoCase( "component,class", arguments.metadata.type ) ) {
			return [];
		}

		// iterate
		while ( structKeyExists( arguments.metadata, "extends" ) ) {
			if ( structKeyExists( arguments.metadata, "implements" ) ) {
				for ( var key in arguments.metadata.implements ) {
					interfaces[ arguments.metadata.implements[ key ].name ] = 1;
				}
			}
			arguments.metadata = arguments.metadata.extends;
		}
		// get as an array
		interfaces = structKeyArray( interfaces );
		// sort it
		arraySort( interfaces, "textnocase" );

		return interfaces;
	}

	/**
	 * Gets an array of the classes that this metadata extends, in order of extension
	 *
	 * @metadata The metadata to look at
	 *
	 * @return array of classes inherited by some component in this package
	 */
	private array function getInheritance( required struct metadata ){
		// ignore top level
		var inheritence = [];

		while ( structKeyExists( arguments.metadata, "extends" ) ) {
			// manage interfaces
			if ( arguments.metadata.type == "interface" ) {
				arguments.metadata = arguments.metadata.extends[ structKeyList( arguments.metadata.extends ) ];
			} else {
				arguments.metadata = arguments.metadata.extends;
			}

			arrayPrepend( inheritence, arguments.metadata.name );
		}

		return inheritence;
	}

	/**
	 * Undocumented function
	 *
	 * @deprecated This is no longer in use.
	 * @param1 param 1
	 * @param2 param 2
	 *
	 * @throws Throws X,Y and Z
	 *
	 * @return Nothing
	 */
	function testFunction( param1, param2 ){
	}

}
