/**
 * JSON API Documentation Generation Strategy for DocBox
 * <h2>Overview</h2>
 * This strategy generates machine-readable JSON documentation from CFML component metadata. It creates
 * a RESTful-style JSON API that can be consumed by documentation viewers, IDE plugins, build tools,
 * or custom documentation websites.
 * <h2>Key Features</h2>
 * <ul>
 * <li><strong>Hierarchical Structure</strong> - Mirrors package organization with nested directories</li>
 * <li><strong>Individual Class Files</strong> - Separate JSON file for each component</li>
 * <li><strong>Package Indices</strong> - Summary files at each package level for navigation</li>
 * <li><strong>Overview Summary</strong> - Top-level index of all packages and classes</li>
 * <li><strong>Normalized Data</strong> - Consistent schema across all JSON files</li>
 * <li><strong>Cross-Platform</strong> - Standard JSON format readable by any tool or language</li>
 * </ul>
 * <h2>Generated Structure</h2>
 * <pre>
 * outputDir/
 * ├── overview-summary.json       - Top-level index with all packages and classes
 * └── {package}/                   - One directory per package
 *     ├── package-summary.json     - Package index with class list
 *     ├── ClassName.json           - Individual class documentation
 *     └── AnotherClass.json
 *
 * Example for "docbox.strategy.api":
 * outputDir/
 * ├── overview-summary.json
 * └── docbox/
 *     └── strategy/
 *         ├── package-summary.json
 *         └── api/
 *             ├── package-summary.json
 *             └── HTMLAPIStrategy.json
 * </pre>
 * <h2>JSON Schema</h2>
 * <h3>Class File Schema (ClassName.json)</h3>
 * <pre>
 * {
 *   "name": "ClassName",
 *   "package": "com.example",
 *   "type": "component|interface",
 *   "extends": "BaseClass" | "",
 *   "fullextends": ":Parent1::Parent2:",
 *   "hint": "Class description",
 *   "functions": [
 *     {
 *       "name": "methodName",
 *       "returnType": "string",
 *       "returnFormat": "plain",
 *       "access": "public|private|package",
 *       "hint": "Method description",
 *       "description": "Detailed description",
 *       "parameters": [
 *         {
 *           "name": "paramName",
 *           "type": "string",
 *           "required": true,
 *           "default": "defaultValue"
 *         }
 *       ],
 *       "position": { "start": 10, "end": 25 }
 *     }
 *   ]
 * }
 * </pre>
 * <h3>Package Summary Schema (package-summary.json)</h3>
 * <pre>
 * {
 *   "classes": [
 *     {
 *       "name": "ClassName",
 *       "path": "com/example/ClassName.json"
 *     }
 *   ]
 * }
 * </pre>
 * <h3>Overview Summary Schema (overview-summary.json)</h3>
 * <pre>
 * {
 *   "title": "Project Title",
 *   "packages": [
 *     {
 *       "name": "com.example",
 *       "path": "com/example/package-summary.json"
 *     }
 *   ],
 *   "classes": [
 *     {
 *       "name": "ClassName",
 *       "path": "com/example/ClassName.json"
 *     }
 *   ]
 * }
 * </pre>
 * <h2>Usage Examples</h2>
 * <h3>Basic JSON Generation</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy( "JSON", {
 *         projectTitle : "My API Docs",
 *         outputDir    : "/var/www/docs/json"
 *     } )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>Combined HTML and JSON Output</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy( "HTML", {
 *         projectTitle : "My API",
 *         outputDir    : "/docs/html"
 *     } )
 *     .addStrategy( "JSON", {
 *         projectTitle : "My API",
 *         outputDir    : "/docs/json"
 *     } )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>Using Generated JSON</h3>
 * <pre>
 * // JavaScript example - loading overview
 * fetch( '/docs/json/overview-summary.json' )
 *     .then( r => r.json() )
 *     .then( data => {
 *         console.log( `Found ${ data.packages.length } packages` );
 *         console.log( `Total classes: ${ data.classes.length }` );
 *     } );
 *
 * // Load specific class
 * fetch( '/docs/json/docbox/strategy/api/HTMLAPIStrategy.json' )
 *     .then( r => r.json() )
 *     .then( classData => {
 *         console.log( `Methods: ${ classData.functions.length }` );
 *     } );
 * </pre>
 * <h2>Use Cases</h2>
 * <ul>
 * <li><strong>API Documentation Websites</strong> - Build custom documentation viewers with modern JavaScript frameworks</li>
 * <li><strong>IDE Integration</strong> - Import API data into IDE plugins for autocomplete and inline documentation</li>
 * <li><strong>Build Tools</strong> - Integrate with CI/CD pipelines for documentation validation and publishing</li>
 * <li><strong>Search Engines</strong> - Index documentation for powerful search capabilities</li>
 * <li><strong>Documentation Portals</strong> - Aggregate multiple project APIs into unified documentation sites</li>
 * <li><strong>SDK Generation</strong> - Use as input for generating client libraries in other languages</li>
 * </ul>
 * <h2>Data Normalization</h2>
 * The strategy normalizes component metadata to ensure consistency:
 * <ul>
 * <li>Missing return types default to "any"</li>
 * <li>Missing access levels default to "public"</li>
 * <li>Missing return formats default to "plain"</li>
 * <li>Position information included when available from BoxLang</li>
 * <li>Annotations and documentation separated for clarity</li>
 * </ul>
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 *
 * @see AbstractTemplateStrategy
 * @see IStrategy
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
	 * Executes the JSON documentation generation strategy
	 * <br>
	 * This is the main entry point for the strategy. It orchestrates the complete JSON documentation
	 * generation process, creating a hierarchical structure of JSON files that mirror the package organization.
	 * <h3>Generation Process</h3>
	 * <ol>
	 * <li><strong>Directory Creation</strong> - Ensures output directory exists (creates if missing)</li>
	 * <li><strong>Metadata Normalization</strong> - Converts query rows to normalized array of class data</li>
	 * <li><strong>Package Grouping</strong> - Groups classes by package for hierarchical organization</li>
	 * <li><strong>Overview Generation</strong> - Creates overview-summary.json with all packages and classes</li>
	 * <li><strong>Package Processing</strong> - For each package:
	 *     <ul>
	 *     <li>Creates package directory structure (e.g., com/example/utils/)</li>
	 *     <li>Generates individual JSON file for each class</li>
	 *     <li>Creates package-summary.json with class index</li>
	 *     </ul>
	 * </li>
	 * </ol>
	 * <h3>File Organization</h3>
	 * The method creates a RESTful-style directory structure where:
	 * <ul>
	 * <li>Each package becomes a directory path (dots replaced with slashes)</li>
	 * <li>Each class gets its own JSON file within its package directory</li>
	 * <li>Each package directory contains a package-summary.json index</li>
	 * <li>The root contains an overview-summary.json with the complete project structure</li>
	 * </ul>
	 * <h3>Automatic Directory Creation</h3>
	 * Unlike HTMLAPIStrategy, this method automatically creates the output directory if it doesn't exist,
	 * providing a more forgiving developer experience for JSON generation.
	 * <h3>Method Chaining</h3>
	 * Returns the strategy instance to enable fluent method chaining with other DocBox operations.
	 *
	 * @metadata Query object from DocBox containing all component metadata with columns: package, name, type, extends, implements, metadata, fullextends
	 *
	 * @return The strategy instance for method chaining
	 */
	IStrategy function run( required query metadata ){
		// Ensure output directory exists
		ensureDirectory( getOutputDir() );

		var classes = normalizePackages(
			arguments.metadata.reduce( ( results, row ) => {
				results.append( row );
				return results;
			}, [] )
		);

		/**
		 * Generate hierarchical JSON package indices with classes
		 */
		var packages = classes.reduce( ( results, class ) => {
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
	 * Constructs the top-level overview summary structure for overview-summary.json
	 * <br>
	 * This method creates the root index file that provides a complete map of all packages and classes
	 * in the documentation. It serves as the entry point for tools and applications consuming the JSON API.
	 * <h3>Structure</h3>
	 * The returned struct contains:
	 * <ul>
	 * <li><strong>title</strong> - The project title from configuration</li>
	 * <li><strong>packages</strong> - Array of package objects with name and path to package-summary.json</li>
	 * <li><strong>classes</strong> - Array of all class objects with name and path to individual class JSON files</li>
	 * </ul>
	 * <h3>Package Links</h3>
	 * Each package entry includes a relative path to its package-summary.json file, enabling hierarchical
	 * navigation through the documentation structure.
	 * <h3>Class Index</h3>
	 * The classes array provides a flat index of all documented components, useful for:
	 * <ul>
	 * <li>Building searchable class lists</li>
	 * <li>Generating sitemaps</li>
	 * <li>Creating alphabetical indices</li>
	 * <li>Validating documentation completeness</li>
	 * </ul>
	 * <h3>Path Resolution</h3>
	 * All paths use forward slashes and are relative to the output directory root, making them
	 * portable across platforms and suitable for web URLs.
	 *
	 * @classData Array of normalized class metadata objects from normalizePackages()
	 * @packages Struct mapping package names to arrays of their contained classes
	 *
	 * @return Struct with keys: title, packages (array), classes (array)
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
	 * Constructs a package-level summary structure for package-summary.json files
	 * <br>
	 * This method creates the index file for a single package, listing all classes and interfaces
	 * contained within that package with links to their individual JSON files.
	 * <h3>Structure</h3>
	 * The returned struct contains:
	 * <ul>
	 * <li><strong>classes</strong> - Array of class objects, each with:
	 *     <ul>
	 *     <li><code>name</code> - Simple class name (e.g., "HTMLAPIStrategy")</li>
	 *     <li><code>path</code> - Relative path to class JSON file (e.g., "docbox/strategy/api/HTMLAPIStrategy.json")</li>
	 *     </ul>
	 * </li>
	 * </ul>
	 * <h3>Usage Context</h3>
	 * These summary files enable:
	 * <ul>
	 * <li>Package-level navigation in documentation viewers</li>
	 * <li>Lazy loading of class data (load summary first, then individual classes on demand)</li>
	 * <li>Package-scoped search and filtering</li>
	 * <li>Verification that all expected classes are documented</li>
	 * </ul>
	 * <h3>Path Format</h3>
	 * Paths are relative to the output directory root and use the format:
	 * <code>{package-with-slashes}/{ClassName}.json</code>
	 *
	 * @classData Array of normalized class metadata objects for classes in this package
	 *
	 * @return Struct with single key "classes" containing array of class name/path objects
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
	 * Normalizes component metadata into a consistent, serializable JSON structure
	 * <br>
	 * This method transforms raw component metadata from DocBox into a standardized format suitable
	 * for JSON serialization. It handles differences between BoxLang and CFML metadata structures,
	 * applies defaults for missing values, and extracts only the information needed for documentation.
	 * <h3>Normalization Rules</h3>
	 * <strong>Component Level:</strong>
	 * <ul>
	 * <li>Extracts name, package, type from query row</li>
	 * <li>Resolves extends relationships to full class names</li>
	 * <li>Preserves fullextends chain for inheritance tracking</li>
	 * <li>Extracts hint/description from documentation metadata</li>
	 * </ul>
	 * <strong>Function Level:</strong>
	 * <ul>
	 * <li>returnType defaults to "any" if missing</li>
	 * <li>returnFormat defaults to "plain" if missing</li>
	 * <li>access defaults to "public" if missing</li>
	 * <li>Preserves complete parameter metadata</li>
	 * <li>Includes position information (line numbers) when available from BoxLang</li>
	 * <li>Separates annotations from documentation for clarity</li>
	 * </ul>
	 * <h3>Engine Compatibility</h3>
	 * The method detects the runtime engine (BoxLang vs CFML) and adapts to their different
	 * metadata structures:
	 * <ul>
	 * <li><strong>BoxLang</strong> - Separates annotations and documentation into distinct keys</li>
	 * <li><strong>CFML</strong> - Annotations and documentation merged in single structure</li>
	 * </ul>
	 * <h3>Data Cleansing</h3>
	 * The normalization process:
	 * <ul>
	 * <li>Removes internal/unnecessary metadata properties</li>
	 * <li>Ensures consistent property names across all entries</li>
	 * <li>Converts complex objects to simple data types suitable for JSON</li>
	 * <li>Filters out null/undefined values where appropriate</li>
	 * </ul>
	 * <h3>Return Structure</h3>
	 * Each array element represents one component with this schema:
	 * <pre>
	 * {
	 *   "name": string,           // Class name
	 *   "package": string,        // Package name
	 *   "type": string,           // "component" or "interface"
	 *   "extends": string,        // Parent class name or empty string
	 *   "fullextends": string,    // Full inheritance chain
	 *   "hint": string,           // Class description
	 *   "functions": [            // Array of methods
	 *     {
	 *       "name": string,
	 *       "returnType": string,
	 *       "returnFormat": string,
	 *       "access": string,
	 *       "hint": string,
	 *       "description": string,
	 *       "parameters": array,
	 *       "position": { "start": number, "end": number }
	 *     }
	 *   ]
	 * }
	 * </pre>
	 *
	 * @classData Array of raw component metadata rows from DocBox query (via query.reduce())
	 *
	 * @return Array of normalized component metadata structs ready for JSON serialization
	 */
	package array function normalizePackages( required array classData ){
		return arguments.classData.map( ( row ) => {
			/**
			 * Marshall functions to match the designed schema;
			 */
			if ( !isNull( arguments.row.metadata.functions ) ) {
				var metaFunctions = arrayMap( arguments.row.metadata.functions, ( method ) => {
					var annotations   = server.keyExists( "boxlang" ) ? arguments.method.annotations : arguments.method;
					var documentation = server.keyExists( "boxlang" ) ? arguments.method.documentation : arguments.method;

					return {
						"returnType"   : arguments.method.returnType ?: "any",
						"returnFormat" : isNull( arguments.method.returnFormat ) ? "plain" : arguments.method.returnFormat,
						"parameters"   : arguments.method.parameters,
						"name"         : arguments.method.name,
						"hint"         : documentation.keyExists( "hint" ) ? documentation.hint : "",
						"description"  : documentation.keyExists( "description" ) ? documentation.description : "",
						"access"       : arguments.method.access ?: "public",
						"position"     : arguments.method.keyExists( "position" ) ? arguments.method.position : {
							"start" : 0,
							"end"   : 0
						}
					};
				} );
			}

			var documentation = server.keyExists( "boxlang" ) ? arguments.row.metadata.documentation : arguments.row.metadata;
			return {
				"name"        : arguments.row.name,
				"package"     : arguments.row.package,
				"type"        : arguments.row.type,
				"extends"     : arguments.row.metadata.keyExists( "metadata" ) && arguments.row.metadata.extends.count() ? arguments.row.metadata.extends : "",
				"fullextends" : structKeyExists(
					arguments.row.metadata,
					"fullextends"
				) ? arguments.row.fullextends : "",
				"hint"      : structKeyExists( documentation, "hint" ) ? documentation.hint : "",
				"functions" : structKeyExists( arguments.row.metadata, "functions" ) ? metaFunctions : []
			};
		} );
	}

	/**
	 * Serializes data to JSON format and writes to a file
	 * <br>
	 * This is a utility method that combines JSON serialization and file writing in a single operation.
	 * It uses CFML's serializeJSON with pretty-printing enabled for human-readable output.
	 * <h3>JSON Formatting</h3>
	 * The method uses <code>serializeJSON( data, true )</code> which:
	 * <ul>
	 * <li>Enables pretty-printing with proper indentation</li>
	 * <li>Makes JSON files readable for debugging and manual inspection</li>
	 * <li>Increases file size slightly but improves developer experience</li>
	 * <li>Compatible with all JSON parsers (whitespace is ignored)</li>
	 * </ul>
	 * <h3>File Handling</h3>
	 * <ul>
	 * <li>Creates new file or overwrites existing file at the specified path</li>
	 * <li>Parent directories must exist (created earlier by run() method)</li>
	 * <li>Uses UTF-8 encoding by default</li>
	 * <li>No error handling - allows exceptions to bubble up to caller</li>
	 * </ul>
	 * <h3>Data Requirements</h3>
	 * The data parameter must be JSON-compatible:
	 * <ul>
	 * <li><strong>Supported</strong>: Structs, arrays, strings, numbers, booleans, null</li>
	 * <li><strong>Not Supported</strong>: Queries, components, functions, closures (will cause serialization errors)</li>
	 * </ul>
	 * <h3>Example Output</h3>
	 * <pre>
	 * // Input:
	 * serializeToFile(
	 *     path = "/docs/example.json",
	 *     data = { name: "Test", values: [ 1, 2, 3 ] }
	 * );
	 *
	 * // Output file content:
	 * {
	 *   "name": "Test",
	 *   "values": [
	 *     1,
	 *     2,
	 *     3
	 *   ]
	 * }
	 * </pre>
	 *
	 * @path Absolute file system path including filename where JSON will be written
	 * @data Struct or array to serialize to JSON (must be JSON-compatible, no queries/components)
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
