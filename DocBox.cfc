/**
 * <h1>Welcome To DocBox!</h1>
 *
 * <p>DocBox is a powerful API documentation generator for CFML (Adobe ColdFusion, Lucee) and BoxLang applications.
 * It automatically parses your codebase and generates beautiful, searchable documentation in multiple formats
 * including HTML, JSON, and UML/XMI.</p>
 *
 * <h2>Quick Start</h2>
 *
 * <pre>
 * // Initialize DocBox with HTML strategy <br>
 * new docbox.DocBox( strategy: "HTML", properties: { <br>
 *     outputDir: "/docs", <br>
 *     projectTitle: "My Awesome API" <br>
 * } ) <br>
 * .generate( <br>
 *     source: "/path/to/code", <br>
 *     mapping: "myapp" <br>
 * ); <br>
 * </pre>
 *
 * <h2>Features</h2>
 *
 * <ul>
 * <li>📚 <strong>Multiple Output Formats</strong>: Generate HTML, JSON, or UML/XMI documentation</li>
 * <li>🎨 <strong>Theming Support</strong>: Choose between different HTML themes (default, frames)</li>
 * <li>🔍 <strong>Smart Parsing</strong>: Automatically extracts JavaDoc-style comments and metadata</li>
 * <li>🌳 <strong>Inheritance Analysis</strong>: Tracks class hierarchies and interface implementations</li>
 * <li>⚙️ <strong>Flexible Strategy Pattern</strong>: Easily extend with custom output formats</li>
 * <li>🎯 <strong>Exclusion Patterns</strong>: Filter files/folders using regex patterns</li>
 * <li>📦 <strong>Package Organization</strong>: Automatically organizes documentation by package structure</li>
 * <li>🔗 <strong>Cross-Linking</strong>: Intelligent linking between related classes and methods</li>
 * </ul>
 *
 * <h2>Supported Documentation Strategies</h2>
 *
 * <ul>
 * <li><strong>HTML</strong> - Rich, searchable HTML documentation with modern UI</li>
 * <li><strong>JSON</strong> - Machine-readable API documentation for tooling integration</li>
 * <li><strong>XMI</strong> - UML/XMI format for generating visual diagrams</li>
 * <li><strong>CommandBox</strong> - Specialized format for CommandBox CLI commands</li>
 * </ul>
 *
 * <p>Multi-Strategy Generation</p>
 *
 * <p>You can generate multiple documentation formats in a single pass:</p>
 *
 * <pre>
 * new docbox.DocBox() <br>
 *     .addStrategy( "HTML", { outputDir: "/docs/html", projectTitle: "My API" } ) <br>
 *     .addStrategy( "JSON", { outputDir: "/docs/json" } ) <br>
 *     .generate( source: "/app", mapping: "myapp" ); <br>
 * </pre>
 *
 * <h2>Custom Annotations</h2>
 *
 * <p>DocBox recognizes standard JavaDoc tags plus custom annotations:</p>
 *
 * <ul>
 * <li><code>@doc_abstract</code> - Mark components as abstract</li>
 * <li><code>@doc_generic</code> - Specify generic types (e.g., <code>Array&lt;User&gt;</code>, <code>Struct&lt;String,Any&gt;</code>)</li>
 * </ul>
 *
 * <h2>Version Information</h2>
 *
 * <p>Copyright 2015-2025 Ortus Solutions, Corp<br>
 * <a href="https://www.ortussolutions.com">www.ortussolutions.com</a></p>
 *
 * @author Luis Majano &lt;lmajano@ortussolutions.com&gt;
 * @version 3.0.0
 *
 * @see docbox.strategy.IStrategy
 * @see docbox.strategy.api.HTMLAPIStrategy
 * @see docbox.strategy.json.JSONAPIStrategy
 */
component accessors="true" {

	/**
	 * Collection of documentation generation strategies
	 *
	 * DocBox supports multiple strategies running in parallel, allowing you to generate
	 * different output formats (HTML, JSON, XMI) in a single execution. Each strategy
	 * must implement the `IStrategy` interface and extend `AbstractTemplateStrategy`.
	 *
	 * Strategies are executed in the order they were added when `generate()` is called.
	 *
	 * @see docbox.strategy.IStrategy
	 * @see docbox.strategy.AbstractTemplateStrategy
	 */
	property
		name       ="strategies"
		type       ="array"
		doc_generic="Array<docbox.strategy.AbstractTemplateStrategy>";

	/**
	 * Initialize a new DocBox documentation generator
	 *
	 * <p>Creates a new DocBox instance with an optional initial strategy. You can add
	 * additional strategies later using <code>addStrategy()</code> or <code>setStrategy()</code>.</p>
	 *
	 * <h2>Examples</h2>
	 *
	 * <p>Basic initialization with no strategy (defaults to HTML when generate() is called):</p>
	 * <pre>
	 * docbox = new docbox.DocBox(); <br>
	 * </pre>
	 *
	 * <p>Initialize with HTML strategy using shorthand:</p>
	 * <pre>
	 * docbox = new docbox.DocBox( <br>
	 *     strategy: "HTML", <br>
	 *     properties: { <br>
	 *         outputDir: "/docs", <br>
	 *         projectTitle: "My API Docs", <br>
	 *         theme: "frames" <br>
	 *     } <br>
	 * ); <br>
	 * </pre>
	 *
	 * <p>Initialize with full class path:</p>
	 * <pre>
	 * docbox = new docbox.DocBox( <br>
	 *     strategy: "docbox.strategy.json.JSONAPIStrategy", <br>
	 *     properties: { outputDir: "/api/json" } <br>
	 * ); <br>
	 * </pre>
	 *
	 * @strategy The documentation output strategy to use. Can be:
	 *           <ul>
	 *           <li>A shorthand string: "HTML", "JSON", "XMI", "CommandBox"</li>
	 *           <li>A full class path: "docbox.strategy.api.HTMLAPIStrategy"</li>
	 *           <li>An instantiated strategy object</li>
	 *           <li>Empty string "" to defer strategy configuration</li>
	 *           </ul>
	 * @properties Configuration struct for the strategy. Common properties include:
	 *             <ul>
	 *             <li><code>outputDir</code> (required): Directory where docs will be generated</li>
	 *             <li><code>projectTitle</code>: Title for the documentation</li>
	 *             <li><code>theme</code>: Theme name for HTML output ("default" or "frames")</li>
	 *             </ul>
	 *
	 * @return The DocBox instance for method chaining
	 *
	 * @see addStrategy
	 * @see generate
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
	 * Legacy method to add a documentation strategy
	 *
	 * <p>This method provides backwards compatibility with DocBox 2.x. It's functionally
	 * identical to <code>addStrategy()</code> and simply delegates to it.</p>
	 *
	 * <p><strong>Recommendation</strong>: Use <code>addStrategy()</code> for new code as it better communicates
	 * the ability to add multiple strategies.</p>
	 *
	 * @deprecated Use addStrategy() instead
	 * @see addStrategy
	 *
	 * @return The DocBox instance for method chaining
	 */
	DocBox function setStrategy(){
		return addStrategy( argumentCollection = arguments );
	}

	/**
	 * Add a documentation generation strategy to the output pipeline
	 *
	 * <p>This method allows you to configure one or more strategies for generating documentation
	 * in different formats. Each strategy runs independently during <code>generate()</code>, allowing
	 * you to produce HTML, JSON, and XMI documentation simultaneously.</p>
	 *
	 * <h2>Strategy Shorthands</h2>
	 *
	 * <p>DocBox provides convenient shortcuts for built-in strategies:</p>
	 * <ul>
	 * <li><code>"HTML"</code> → <code>docbox.strategy.api.HTMLAPIStrategy</code></li>
	 * <li><code>"JSON"</code> → <code>docbox.strategy.json.JSONAPIStrategy</code></li>
	 * <li><code>"XMI"</code> or <code>"UML"</code> → <code>docbox.strategy.uml2tools.XMIStrategy</code></li>
	 * <li><code>"CommandBox"</code> → <code>docbox.strategy.CommandBox.CommandBoxStrategy</code></li>
	 * </ul>
	 *
	 * <h2>Examples</h2>
	 *
	 * <p>Chain multiple strategies:</p>
	 * <pre>
	 * new docbox.DocBox() <br>
	 *     .addStrategy( "HTML", { outputDir: "/docs/html" } ) <br>
	 *     .addStrategy( "JSON", { outputDir: "/docs/json" } ) <br>
	 *     .generate( source: "/app", mapping: "myapp" ); <br>
	 * </pre>
	 *
	 * @strategy The strategy to use for documentation generation. Accepts:
	 *           <ul>
	 *           <li>Shorthand string ("HTML", "JSON", "XMI", "CommandBox")</li>
	 *           <li>Full class path to a custom strategy</li>
	 *           <li>Pre-instantiated strategy object implementing IStrategy</li>
	 *           </ul>
	 * @properties Configuration struct passed to the strategy constructor. Required properties
	 *             vary by strategy but typically include <code>outputDir</code> and <code>projectTitle</code>.
	 *
	 * @return The DocBox instance for method chaining
	 *
	 * @see docbox.strategy.IStrategy
	 * @see generate
	 */
	DocBox function addStrategy(
		any strategy      = "HTML",
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

		variables.strategies.append( newStrategy )

		return this;
	}

	/**
	 * Generate API documentation from your codebase
	 *
	 * <p>This is the primary method that orchestrates the entire documentation generation process.
	 * It scans your source directories, parses component metadata, analyzes inheritance chains,
	 * and executes all configured strategies to produce documentation output.</p>
	 *
	 * <h2>Examples</h2>
	 *
	 * <p>Single source directory:</p>
	 * <pre>
	 * docbox.generate( <br>
	 *     source: "/path/to/myapp", <br>
	 *     mapping: "myapp" <br>
	 * ); <br>
	 * </pre>
	 *
	 * <p>Multiple source directories:</p>
	 * <pre>
	 * docbox.generate( <br>
	 *     source: [ <br>
	 *         { dir: "/path/to/models", mapping: "models" }, <br>
	 *         { dir: "/path/to/services", mapping: "services" } <br>
	 *     ] <br>
	 * ); <br>
	 * </pre>
	 *
	 * <p>With exclusions:</p>
	 * <pre>
	 * docbox.generate( <br>
	 *     source: "/coldbox", <br>
	 *     mapping: "coldbox", <br>
	 *     excludes: "(tests|build|temp)" <br>
	 * ); <br>
	 * </pre>
	 *
	 * @source The source code to document. Accepts:
	 *         <ul>
	 *         <li><strong>String</strong>: A single directory path (requires <code>mapping</code> parameter)</li>
	 *         <li><strong>Array</strong>: Array of structs with <code>dir</code> and <code>mapping</code> keys</li>
	 *         </ul>
	 * @mapping The base mapping/package name for the source directory.
	 *          Required when <code>source</code> is a string.
	 * @excludes Regular expression pattern to exclude files/folders from documentation.
	 *           Applied to relative file paths. Examples: "tests", "(tests|build)"
	 * @throwOnError If <code>true</code>, throws an exception when encountering invalid components.
	 *               If <code>false</code> (default), logs warnings and continues.
	 *
	 * @return The DocBox instance for method chaining
	 *
	 * @throws InvalidConfigurationException If a source directory doesn't exist
	 *
	 * @see addStrategy
	 * @see buildMetaDataCollection
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

		// run each strategy
		variables.strategies.each( ( strategy ) => strategy.run( metadata ) )

		return this;
	}

	/************************************ PRIVATE ******************************************/

	/**
	 * Convert a file system path to a package-style dot notation
	 *
	 * <p>Transforms file system paths into package names by removing the base directory
	 * prefix and converting path separators to dots.</p>
	 *
	 * @path The full file system path to the component file
	 * @inputDir The base input directory to remove from the path
	 *
	 * @return The package name in dot notation (e.g., "models.user.admin")
	 *
	 * @see buildMetaDataCollection
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
	 * Build a comprehensive metadata collection from source directories
	 *
	 * <p>This private method performs the core work of scanning directories, parsing component
	 * metadata, and building the data structure that strategies use to generate documentation.</p>
	 *
	 * <p>The returned query contains columns: package, name, extends, metadata, type,
	 * implements, fullextends, currentMapping</p>
	 *
	 * @inputSource Array of source directory configurations with <code>dir</code> and <code>mapping</code> keys
	 * @excludes Regular expression pattern for excluding files
	 * @throwOnError If <code>true</code>, throws exceptions on component parsing errors
	 *
	 * @return Query object containing all component metadata
	 *
	 * @throws InvalidConfigurationException If a source directory doesn't exist
	 *
	 * @see getInheritance
	 * @see getImplements
	 * @see cleanPath
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
						meta = server.keyExists( "boxlang" ) ? getClassmetadata( packagePath & "." & className ) : getComponentMetadata(
							packagePath & "." & className
						);
					} else {
						meta = server.keyExists( "boxlang" ) ? getClassmetadata( className ) : getComponentMetadata(
							className
						);
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
					querySetCell(
						metadata,
						"currentMapping",
						thisInput.mapping
					);
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
					if ( structKeyExists( meta, "extends" ) && meta.extends.count() ) {
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
					writeDump(
						var    = "Warning! The following script has errors: " & packagePath & "." & className,
						output = "console"
					)
					writeDump(
						var    = "#e.message & e.detail#",
						output = "console"
					)
					writeDump(
						var    = e.stackTrace,
						output = "console"
					)
				}
			}
			// end qFiles iteration
		}
		// end input source iteration

		return metadata;
	}

	/**
	 * Extract all interfaces implemented by a component and its ancestors
	 *
	 * <p>This method walks up the entire inheritance chain collecting all interfaces
	 * implemented at each level. Essential for generating complete API documentation.</p>
	 *
	 * @metadata The component metadata structure from <code>getComponentMetadata()</code>
	 *
	 * @return Array of interface names sorted alphabetically
	 *
	 * @see getInheritance
	 * @see buildMetaDataCollection
	 */
	private array function getImplements( required struct metadata ){
		var interfaces = {};

		// check if a cfc
		if (
			!listFindNoCase(
				"component,class",
				arguments.metadata.type
			)
		) {
			return [];
		}

		// Check current class first
		if ( structKeyExists( arguments.metadata, "implements" ) ) {
			// Handle both array and struct formats for implements
			if ( isArray( arguments.metadata.implements ) ) {
				// Array format: each item is full metadata
				for ( var imeta in arguments.metadata.implements ) {
					interfaces[ imeta.name ] = 1;
				}
			} else {
				// Struct format: key is interface name, value is metadata
				for ( var key in arguments.metadata.implements ) {
					var imeta                = arguments.metadata.implements[ key ];
					interfaces[ imeta.name ] = 1;
				}
			}
		}

		// iterate ancestors
		while ( structKeyExists( arguments.metadata, "extends" ) ) {
			arguments.metadata = arguments.metadata.extends;

			if ( structKeyExists( arguments.metadata, "implements" ) ) {
				// Handle both array and struct formats for implements
				if ( isArray( arguments.metadata.implements ) ) {
					// Array format: each item is full metadata
					for ( var imeta in arguments.metadata.implements ) {
						interfaces[ imeta.name ] = 1;
					}
				} else {
					// Struct format: key is interface name, value is metadata
					for ( var key in arguments.metadata.implements ) {
						var imeta                = arguments.metadata.implements[ key ];
						interfaces[ imeta.name ] = 1;
					}
				}
			}
		}
		// get as an array
		interfaces = structKeyArray( interfaces );
		// sort it
		arraySort( interfaces, "textnocase" );

		return interfaces;
	}

	/**
	 * Build the complete inheritance chain for a component
	 *
	 * <p>Traverses the inheritance hierarchy to build a complete list of all ancestor
	 * classes, from the immediate parent up to the root base class.</p>
	 *
	 * @metadata The component or interface metadata structure
	 *
	 * @return Array of ancestor class names in hierarchical order (root to immediate parent)
	 *
	 * @see getImplements
	 * @see buildMetaDataCollection
	 */
	private array function getInheritance( required struct metadata ){
		// ignore top level
		var inheritence = [];

		while ( structKeyExists( arguments.metadata, "extends" ) && arguments.metadata.extends.count() ) {
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
	 * Example of a deprecated method with comprehensive documentation
	 *
	 * <p>Demonstrates DocBox's ability to parse and display deprecation warnings,
	 * multiple parameters, exception documentation, and return type information.</p>
	 *
	 * @deprecated This method is no longer in use and will be removed in version 4.0
	 * @param1 The first parameter demonstrating basic parameter documentation
	 * @param2 The second parameter showing multiple param docs
	 *
	 * @throws TypeMismatchException When param1 is not the expected type
	 * @throws ValidationException When param2 fails validation rules
	 *
	 * @return void This method doesn't return a value
	 */
	function testFunction( param1, param2 ){
		// Empty implementation - demonstration only
	}

	/**
	 * Example remote method demonstrating custom annotations
	 *
	 * <p>Showcases remote access modifier, required parameters, and custom annotations.</p>
	 *
	 * @input The input string to process (required parameter)
	 *
	 * @return string The processed result
	 */
	remote function remoteTest( required string input ) annotation1 annotation2="value"{
		return arguments.input;
	}

	/**
	 * Example static void method
	 *
	 * <p>Demonstrates static methods (callable without instance) and void return type.</p>
	 *
	 * @return void No return value
	 */
	static void function staticVoidFunction(){
		// Empty implementation - demonstration only
	}

	/**
	 * Example static method with typed parameters and return
	 *
	 * <h2>Usage</h2>
	 *
	 * <pre>
	 * result = DocBox::calculate( 10, 5 );  // returns true <br>
	 * result = DocBox::calculate( 5, 10 );  // returns false <br>
	 * </pre>
	 *
	 * @num1 The first number to compare (required)
	 * @num2 The second number to compare (optional, defaults to 0)
	 *
	 * @return boolean Returns <code>true</code> if num1 is greater than num2
	 */
	static boolean function calculate( required numeric num1, num2 = 0 ){
		return arguments.num1 GT arguments.num2;
	}

	/**
	 * Example method demonstrating generic type documentation
	 *
	 * <p>The <code>@doc_generic</code> annotation specifies more precise type information
	 * than CFML's basic type system.</p>
	 *
	 * @return array An array of numeric values
	 *
	 * @doc_generic Array&lt;Numeric&gt;
	 */
	static array function getArrayExample(){
		return [ 1, 2, 3 ];
	}

}
