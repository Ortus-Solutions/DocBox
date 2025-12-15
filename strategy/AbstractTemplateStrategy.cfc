/**
 * Abstract base class for general templating strategies
 * <h2>Overview</h2>
 * This abstract component provides the foundation for all DocBox documentation generation strategies.
 * It implements the IStrategy interface and provides common functionality for template-based documentation
 * generation, including metadata processing, caching, and template rendering capabilities.
 * <h2>Key Responsibilities</h2>
 * <ul>
 * <li><strong>Metadata Processing</strong> - Builds sorted queries of function and property metadata from component metadata</li>
 * <li><strong>Query Caching</strong> - Maintains function and property query caches for performance optimization</li>
 * <li><strong>Package Tree Building</strong> - Constructs hierarchical package structures from flat package names</li>
 * <li><strong>Template Rendering</strong> - Provides writeTemplate() method for generating output files from CFML templates</li>
 * <li><strong>Type Resolution</strong> - Resolves class names, determines primitive types, and validates type existence</li>
 * <li><strong>Generic Type Handling</strong> - Processes @doc_generic annotations for generic type documentation</li>
 * </ul>
 * <h2>Extending This Class</h2>
 * Concrete strategy implementations must:
 * <ol>
 * <li>Extend this abstract component</li>
 * <li>Implement the <code>run(required query metadata)</code> method</li>
 * <li>Configure template paths and output locations in their constructor</li>
 * <li>Utilize the provided helper methods for metadata processing and template generation</li>
 * </ol>
 * <h2>Common Patterns</h2>
 * <pre>
 * // In your concrete strategy constructor:
 * super.init(); // Initialize parent caches
 *
 * // Use helper methods for metadata processing:
 * var qFunctions = buildFunctionMetaData( componentMetadata );
 * var qProperties = buildPropertyMetaData( componentMetadata );
 *
 * // Build package navigation structures:
 * var packageTree = buildPackageTree( qMetadata );
 *
 * // Render templates to files:
 * writeTemplate(
 *     path = outputDir & "/class.html",
 *     template = "/path/to/template.cfm",
 *     metadata = componentMetadata
 * );
 * </pre>
 * <h2>Performance Considerations</h2>
 * This class implements query caching for function and property metadata to avoid repeated
 * Query of Queries (QoQ) operations during documentation generation. Caches are keyed by
 * component name and persist for the lifetime of the strategy instance.
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 *
 * @see IStrategy
 */
abstract component accessors="true" implements="IStrategy" {

	/**
	 * The function query cache map
	 */
	property name="functionQueryCache" type="struct";

	/**
	 * The property query cache map
	 */
	property name="propertyQueryCache" type="struct";

	/**
	 * Custom annotation for noting generic method return types or argument types.
	 *
	 * @url https://docbox.ortusbooks.com/getting-started/annotating-your-code#custom-docbox-blocks
	 */
	variables.META_GENERIC = "doc_generic";

	/**
	 * Constructor
	 */
	function init(){
		variables.functionQueryCache = {};
		variables.propertyQueryCache = {};
		return this;
	}

	/**
	 * Runs the strategy
	 */
	IStrategy function run( required query metadata ){
		throw(
			type    = "AbstractMethodException",
			message = "Method is abstract and must be overwritten",
			detail  = "The method 'run' in  component '#getMetadata( this ).name#' is abstract and must be overwritten"
		);
	}

	/**
	 * Builds a hierarchical tree structure from flat package names
	 * <br>
	 * This method converts a flat list of package names (e.g., "coldbox.system.web") into a nested
	 * structure suitable for navigation tree rendering. Each package segment becomes a node in the tree,
	 * with child packages nested within their parent nodes.
	 * <h3>Example</h3>
	 * <pre>
	 * Input packages:
	 *   - docbox
	 *   - docbox.strategy
	 *   - docbox.strategy.api
	 *   - coldbox.system
	 *
	 * Output structure:
	 * {
	 *   "docbox": {
	 *     "strategy": {
	 *       "api": {}
	 *     }
	 *   },
	 *   "coldbox": {
	 *     "system": {}
	 *   }
	 * }
	 * </pre>
	 * <h3>Usage in Templates</h3>
	 * The returned structure can be traversed using <code>visitPackageTree()</code> to generate
	 * hierarchical navigation menus, breadcrumbs, or package indices.
	 *
	 * @qMetadata Query containing metadata with a "package" column containing dot-delimited package names
	 *
	 * @return Nested struct representing the package hierarchy, where each key is a package segment and each value is a struct of child packages
	 */
	private struct function buildPackageTree( required query qMetadata ){
		var md        = arguments.qMetadata;
		var qPackages = queryExecute(
			"SELECT DISTINCT
				package
			FROM
				md
			ORDER BY
				package",
			{},
			{ dbtype : "query" }
		)

		var tree = {};
		for ( var thisRow in qPackages ) {
			var node     = tree;
			var aPackage = listToArray( thisRow[ "package" ], "." );

			for ( var thisPath in aPackage ) {
				if ( not structKeyExists( node, thisPath ) ) {
					node[ thisPath ] = {};
				}
				node = node[ thisPath ];
			}
		}

		return tree;
	}

	/**
	 * Recursively visits each node in a package tree structure, invoking callbacks at start and end
	 * <br>
	 * This method implements the Visitor pattern for package tree traversal. It recursively walks through
	 * the hierarchical package structure, invoking a start callback when entering each node and an end
	 * callback when exiting each node. This enables pre-order and post-order processing of the tree.
	 * <h3>Callback Arguments</h3>
	 * Both start and end callbacks receive:
	 * <ul>
	 * <li><strong>name</strong> - The current package segment name (e.g., "api" for "docbox.strategy.api")</li>
	 * <li><strong>fullName</strong> - The complete package path up to this node (e.g., "docbox.strategy.api")</li>
	 * <li><strong>...custom args</strong> - Any additional arguments passed via the args parameter</li>
	 * </ul>
	 * <h3>Example Usage</h3>
	 * <pre>
	 * var tree = buildPackageTree( qMetadata );
	 *
	 * visitPackageTree(
	 *     packageTree = tree,
	 *     startCommand = ( name, fullName ) => {
	 *         writeOutput( '&lt;li data-package="#fullName#"&gt;#name#&lt;ul&gt;' );
	 *     },
	 *     endCommand = ( name, fullName ) => {
	 *         writeOutput( '&lt;/ul&gt;&lt;/li&gt;' );
	 *     },
	 *     args = { depth: 0 }
	 * );
	 * </pre>
	 *
	 * @packageTree The hierarchical package tree structure to traverse (from buildPackageTree)
	 * @startCommand Callback function/closure to invoke when entering a package node (pre-order)
	 * @endCommand Callback function/closure to invoke when exiting a package node (post-order)
	 * @args Additional arguments to pass to both callbacks (merged with name and fullName)
	 *
	 * @return The strategy instance for method chaining
	 */
	private IStrategy function visitPackageTree(
		required struct packageTree,
		required any startCommand,
		required any endCommand,
		struct args = {}
	){
		var startCall = arguments.startCommand;
		var endCall   = arguments.endCommand;

		// default the fullname
		if ( NOT structKeyExists( args, "fullname" ) ) {
			arguments.args.fullname = "";
		}

		// iterate over package tree
		for ( var key in arguments.packageTree ) {
			var thisArgs      = structCopy( arguments.args );
			thisArgs.name     = key;
			thisArgs.fullName = listAppend(
				thisArgs.fullName,
				thisArgs.name,
				"."
			);

			startCall( argumentCollection = thisArgs );

			visitPackageTree(
				arguments.packageTree[ key ],
				startCall,
				endCall,
				thisArgs
			);

			endCall( argumentCollection = thisArgs );
		}

		return this;
	}

	/**
	 * Is the type a primitive value
	 *
	 * @type The type
	 */
	private boolean function isPrimitive( required string type ){
		var primitives = "string,date,struct,array,void,binary,numeric,boolean,query,xml,uuid,any,component,class,function";
		return listFindNoCase( primitives, arguments.type );
	}

	/**
	 * Builds a sorted query of function metadata from component metadata
	 * <br>
	 * This method extracts all functions from component metadata and returns them as a query object
	 * with two columns: "name" and "metadata". The results are sorted alphabetically by function name
	 * and cached to avoid repeated processing of the same component.
	 * <h3>Query Structure</h3>
	 * <ul>
	 * <li><strong>name</strong> (string) - The function name</li>
	 * <li><strong>metadata</strong> (struct) - The complete function metadata including parameters, return type, access level, annotations, etc.</li>
	 * </ul>
	 * <h3>Filtering</h3>
	 * This method automatically filters out internal CFThread functions (those starting with "_cffunccfthread_")
	 * which are generated by the CFML engine and should not appear in documentation.
	 * <h3>Caching</h3>
	 * Results are cached in <code>variables.functionQueryCache</code> using the component name as the key.
	 * Subsequent calls for the same component return the cached query, significantly improving performance
	 * when generating multiple documentation pages for the same component.
	 * <h3>Metadata Safety</h3>
	 * Each function's metadata is processed through <code>safeFunctionMeta()</code> to ensure default
	 * values are set for missing properties like returntype, access, etc.
	 *
	 * @metadata Component metadata structure containing a "functions" array and "name" property
	 *
	 * @return Query with columns [name, metadata] sorted alphabetically by function name, or empty query if no functions exist
	 */
	private query function buildFunctionMetaData( required struct metadata ){
		if ( !metadata.count() ) {
			return queryNew( "name, metadata" );
		}

		var qFunctions = queryNew( "name, metadata" );
		var cache      = this.getFunctionQueryCache();

		if ( structKeyExists( cache, arguments.metadata.name ) ) {
			return cache[ arguments.metadata.name ];
		}

		// if no properties, return empty query
		if ( NOT structKeyExists( arguments.metadata, "functions" ) ) {
			return qFunctions;
		}

		// iterate and create
		for ( var thisFnc in arguments.metadata.functions ) {
			// dodge cfthread functions
			if ( NOT javacast( "string", thisFnc.name ).startsWith( "_cffunccfthread_" ) ) {
				queryAddRow( qFunctions );
				querySetCell( qFunctions, "name", thisFnc.name );
				querySetCell(
					qFunctions,
					"metadata",
					safePropertyMeta( thisFnc, arguments.metadata )
				);
			}
		}

		var results = getMetaSubQuery(
			query   = qFunctions,
			orderby = "name asc"
		);

		cache[ arguments.metadata.name ] = results;

		return results;
	}

	/**
	 * Builds a sorted query of property metadata from component metadata
	 * <br>
	 * This method extracts all properties from component metadata and returns them as a query object
	 * with two columns: "name" and "metadata". The results are sorted alphabetically by property name
	 * and cached to avoid repeated processing of the same component.
	 * <h3>Query Structure</h3>
	 * <ul>
	 * <li><strong>name</strong> (string) - The property name</li>
	 * <li><strong>metadata</strong> (struct) - The complete property metadata including type, default value, required flag, annotations, etc.</li>
	 * </ul>
	 * <h3>Caching</h3>
	 * Results are cached in <code>variables.propertyQueryCache</code> using the component name as the key.
	 * Subsequent calls for the same component return the cached query, improving performance during
	 * documentation generation.
	 * <h3>Metadata Safety</h3>
	 * Each property's metadata is processed through <code>safePropertyMeta()</code> to ensure default
	 * values are set for missing properties like type, access, required, etc.
	 * <h3>Empty Results</h3>
	 * If the component has no properties (no "properties" key in metadata), an empty query is returned
	 * with the correct column structure.
	 *
	 * @metadata Component metadata structure containing a "properties" array and "name" property
	 *
	 * @return Query with columns [name, metadata] sorted alphabetically by property name, or empty query if no properties exist
	 */
	private query function buildPropertyMetaData( required struct metadata ){
		var qProperties = queryNew( "name, metadata" );
		var cache       = this.getPropertyQueryCache();

		if ( structKeyExists( cache, arguments.metadata.name ) ) {
			return cache[ arguments.metadata.name ];
		}

		// if no properties, return empty query
		if ( NOT structKeyExists( arguments.metadata, "properties" ) ) {
			return qProperties;
		}

		// iterate and create
		for ( var thisProp in arguments.metadata.properties ) {
			queryAddRow( qProperties );
			querySetCell( qProperties, "name", thisProp.name );
			querySetCell(
				qProperties,
				"metadata",
				safePropertyMeta( thisProp, arguments.metadata )
			);
		}

		var results = getMetaSubQuery(
			query   = qProperties,
			orderby = "name asc"
		);

		cache[ arguments.metadata.name ] = results;

		return results;
	}

	/**
	 * Returns the simple object name from a full class name
	 *
	 * @class The name of the class
	 */
	private string function getObjectName( required class ){
		return (
			len( arguments.class ) ? listGetAt(
				arguments.class,
				listLen( arguments.class, "." ),
				"."
			) : arguments.class
		);
	}

	/**
	 * Get a package from an incoming class
	 *
	 * @class The name of the class
	 */
	private string function getPackage( required class ){
		var objectname = getObjectName( arguments.class );
		var lenCount   = len( arguments.class ) - ( len( objectname ) + 1 );
		return ( lenCount gt 0 ? left( arguments.class, lenCount ) : arguments.class );
	}

	/**
	 * Whether or not the class exists (does not test for primitives)
	 *
	 * @qMetaData The metadata query
	 * @className The name of the class
	 * @package The package the class comes from
	 */
	private boolean function classExists(
		required query qMetadata,
		required string className,
		required string package
	){
		var resolvedClassName = resolveClassName(
			arguments.className,
			arguments.package
		);
		var objectName  = getObjectName( resolvedClassName );
		var packageName = getPackage( resolvedClassName );
		var qClass      = getMetaSubQuery(
			arguments.qMetaData,
			"LOWER(package)=LOWER('#packageName#') AND LOWER(name)=LOWER('#objectName#')"
		);

		return qClass.recordCount;
	}

	/**
	 * Whether a type exists at all - be it class name, or primitive type
	 * @qMetaData The metadata query
	 * @className The name of the class
	 * @package The package the class comes from
	 */
	private boolean function typeExists(
		required query qMetadata,
		required string className,
		required string package
	){
		return isPrimitive( arguments.className ) OR classExists( argumentCollection = arguments );
	}

	/**
	 * Resolves a class name that may not be full qualified
	 * @className The name of the class
	 * @package The package the class comes from
	 */
	private string function resolveClassName(
		required string className,
		required string package
	){
		if ( listLen( arguments.className, "." ) eq 1 ) {
			arguments.className = arguments.package & "." & arguments.className;
		}
		return arguments.className;
	}

	/**
	 * Query of Queries helper
	 *
	 * @query The metadata query
	 * @where The where string
	 * @orderby The order by string
	 */
	private query function getMetaSubQuery(
		required query query,
		string where,
		string orderBy
	){
		var qry = arguments.query;
		var sql = "SELECT * FROM qry";

		if ( !isNull( arguments.where ) ) {
			sql &= " WHERE #preserveSingleQuotes( arguments.where )#";
		}

		if ( !isNull( arguments.orderBy ) ) {
			sql &= " ORDER BY #arguments.orderBy#";
		}

		return queryExecute( sql, {}, { dbtype : "query" } );
	}

	/**
	 * Sets default values on function metadata
	 *
	 * @func The function metadata
	 * @metadata The original metadata
	 */
	private any function safeFunctionMeta(
		required func,
		required struct metadata
	){
		if ( NOT structKeyExists( arguments.func, "returntype" ) ) {
			arguments.func.returntype = "any";
		}

		if ( NOT structKeyExists( arguments.func, "access" ) ) {
			arguments.func.access = "public";
		}

		// move any argument meta from @foo.bar annotations onto the argument meta
		if ( structKeyExists( arguments.func, "parameters" ) ) {
			// Get function annotations
			var annotations = server.keyExists( "boxlang" ) ? arguments.func.annotations : arguments.func;
			for ( local.metaKey in annotations ) {
				if ( listLen( local.metaKey, "." ) gt 1 ) {
					local.paramKey       = listGetAt( local.metaKey, 1, "." );
					local.paramExtraMeta = listGetAt( local.metaKey, 2, "." );
					local.paramMetaValue = annotations[ local.metaKey ];

					local.len = arrayLen( annotations.parameters );
					for ( local.counter = 1; local.counter lte local.len; local.counter++ ) {
						local.param = annotations.parameters[ local.counter ];

						if ( local.param.name eq local.paramKey ) {
							local.param[ local.paramExtraMeta ] = local.paramMetaValue;
						}
					}
				}
			}
		}
		return arguments.func;
	}

	/**
	 * Sets default values on property metadata
	 *
	 * @property The property metadata
	 * @metadata The original metadata
	 */
	private any function safePropertyMeta(
		required property,
		required struct metadata
	){
		if ( NOT structKeyExists( arguments.property, "type" ) ) {
			arguments.property.type = "any";
		}

		if ( NOT structKeyExists( arguments.property, "required" ) ) {
			arguments.property.required = false;
		}

		if ( NOT structKeyExists( arguments.property, "hint" ) ) {
			arguments.property.hint = "";
		}

		if ( NOT structKeyExists( arguments.property, "default" ) ) {
			arguments.property.default = "";
		}

		if ( NOT structKeyExists( arguments.property, "access" ) ) {
			arguments.property.access = "public";
		}

		if ( NOT structKeyExists( arguments.property, "returntype" ) ) {
			arguments.property.returntype = "any";
		}

		if ( NOT structKeyExists( arguments.property, "serializable" ) ) {
			arguments.property.serializable = true;
		}

		return arguments.property;
	}

	/**
	 * returns the property meta by a given name
	 * @name The name of the property
	 * @properties The property meta
	 */
	private struct function getPropertyMeta(
		required string name,
		required array properties
	){
		for ( var thisProp in arguments.properties ) {
			if ( thisProp.name eq arguments.name ) {
				return thisProp;
			}
		}
		return {};
	}

	/**
	 * Sets a default meta type if not found
	 * @param The struct meta
	 */
	private struct function safeParamMeta( required struct param ){
		if ( NOT structKeyExists( arguments.param, "type" ) ) {
			arguments.param.type = "any";
		}

		return arguments.param;
	}

	/**
	 * Renders a CFML template and writes the output to a file
	 * <br>
	 * This method uses CFML's <code>savecontent</code> to capture template output, then writes the
	 * result to the specified file path. All arguments passed to this method (beyond path and template)
	 * are available in the template's local scope.
	 * <h3>Template Access to Arguments</h3>
	 * Templates can access any arguments passed to this method via the <code>arguments</code> scope:
	 * <pre>
	 * // Calling code:
	 * writeTemplate(
	 *     path = "/output/class.html",
	 *     template = "/templates/class.cfm",
	 *     projectTitle = "My API",
	 *     metadata = componentMeta,
	 *     qFunctions = functionsQuery
	 * );
	 *
	 * // In template (/templates/class.cfm):
	 * &lt;h1&gt;#arguments.projectTitle#&lt;/h1&gt;
	 * &lt;cfloop query="arguments.qFunctions"&gt;
	 *     &lt;div&gt;#name#&lt;/div&gt;
	 * &lt;/cfloop&gt;
	 * </pre>
	 * <h3>File Handling</h3>
	 * The method automatically creates or overwrites the file at the specified path. Parent directories
	 * must exist - use <code>ensureDirectory()</code> if needed.
	 * <h3>Method Chaining</h3>
	 * Returns the strategy instance to enable fluent method chaining:
	 * <pre>
	 * writeTemplate( ... )
	 *     .writeTemplate( ... )
	 *     .writeTemplate( ... );
	 * </pre>
	 *
	 * @path Absolute file system path where the rendered output will be written
	 * @template Absolute path to the CFML template file to render (typically using expandPath or mapped path)
	 *
	 * @return The strategy instance for method chaining
	 */
	private AbstractTemplateStrategy function writeTemplate(
		required string path,
		required string template
	){
		savecontent variable="local.html" {
			include "#arguments.template#";
		}
		fileWrite( arguments.path, local.html );

		return this;
	}

	// Recursive function to output data
	function writeItems(
		struct startingLevel,
		string packageTerm = "package",
		classTerm          = "class"
	){
		for ( var item in startingLevel ) {
			// Skip this key as it isn't a class, just the link for the package.
			if ( item == "$link" ) {
				continue;
			}

			var itemValue = startingLevel[ item ];

			//  If this is a class, output it
			if ( structKeyExists( itemValue, "$#arguments.classTerm#" ) ) {
				var linkData = itemValue[ "$#arguments.classTerm#" ];
				writeOutput( "<li data-jstree='{ ""type"" : ""#arguments.classTerm#"" }' linkhref=""#linkData.link#"" searchlist=""#linkData.searchList#"" thissort=""2"">" );
				writeOutput( item );
				writeOutput( "</li>" );
				// If this is a package, output it and its children
			} else {
				var link = "";
				if ( structKeyExists( itemValue, "$link" ) ) {
					link = itemValue.$link;
				}
				writeOutput(
					"<li data-jstree='{ ""type"" : ""#arguments.packageTerm#"" }' linkhref=""#link#"" searchlist=""#item#"" thissort=""1"">"
				);
				writeOutput( item );
				writeOutput( "<ul>" );
				// Recursive call
				writeItems(
					itemValue,
					arguments.packageTerm,
					arguments.classTerm
				);
				writeOutput( "</ul>" );
				writeOutput( "</li>" );
			}
		}
	}

	/**
	 * Ensure directory
	 * @path The target path
	 */
	private AbstractTemplateStrategy function ensureDirectory( required string path ){
		if ( NOT directoryExists( arguments.path ) ) {
			directoryCreate( arguments.path );
		}
		return this;
	}

	/**
	 * Determines if a component is marked as abstract
	 * <br>
	 * This method checks if a component is abstract by examining its metadata. A component is considered
	 * abstract if it contains an "abstract" key in its metadata structure, which is set when using the
	 * <code>abstract</code> component modifier.
	 * <h3>Abstract Components</h3>
	 * Abstract components are designed to be extended but not instantiated directly. They often contain
	 * method signatures without implementations, requiring concrete subclasses to provide the implementation.
	 * <h3>BoxLang vs CFML</h3>
	 * The method handles differences between BoxLang and CFML metadata structures by detecting the
	 * runtime environment and using the appropriate metadata access method.
	 * <h3>Class Resolution</h3>
	 * If the provided class name is not fully qualified, it is resolved using the current package context
	 * via <code>resolveClassName()</code>.
	 * <h3>Example Usage</h3>
	 * <pre>
	 * // In template:
	 * &lt;cfif isAbstractClass( "BaseHandler", "coldbox.system" )&gt;
	 *     &lt;span class="badge"&gt;Abstract&lt;/span&gt;
	 * &lt;/cfif&gt;
	 * </pre>
	 *
	 * @class The component name (can be simple or fully qualified)
	 * @package The package context for resolving relative class names
	 *
	 * @return True if the component is marked as abstract, false otherwise
	 */
	private boolean function isAbstractClass(
		required string class,
		required string package
	){
		// resolve class name
		arguments.class = resolveClassName( arguments.class, arguments.package );
		// get metadata
		var meta        = server.keyExists( "boxlang" ) ? getClassMetadata( arguments.class ) : getComponentMetadata(
			arguments.class
		);
		var annotations = server.keyExists( "boxlang" ) ? meta.annotations : meta;

		// Part of the class spec
		if ( meta.keyExists( "abstract" ) ) {
			return true;
		}

		return false;
	}

	/**
	 * Extracts generic type information from function or argument metadata
	 * <br>
	 * This method processes the custom <code>@doc_generic</code> annotation to extract generic type
	 * parameters for documentation purposes. It resolves non-primitive types to their fully qualified
	 * class names for proper linking in documentation.
	 * <h3>Generic Types Annotation</h3>
	 * The <code>@doc_generic</code> annotation is a DocBox extension that allows documenting generic
	 * type parameters for methods and arguments:
	 * <pre>
	 * /**
	 *  * Returns a list of users
	 *  * @doc_generic Array&lt;User&gt;
	 *  *&#47;
	 * function getUsers() { }
	 *
	 * /**
	 *  * Processes items
	 *  * @items.doc_generic Array&lt;Product&gt;
	 *  *&#47;
	 * function processItems( required array items ) { }
	 * </pre>
	 * <h3>Type Resolution</h3>
	 * Non-primitive types are resolved to fully qualified names using the current package context:
	 * <ul>
	 * <li>Primitive types (string, numeric, array, etc.) are filtered out</li>
	 * <li>Simple names are resolved using <code>resolveClassName()</code></li>
	 * <li>Fully qualified names are preserved as-is</li>
	 * </ul>
	 * <h3>Multiple Generics</h3>
	 * The annotation supports comma-delimited lists for multiple generic types:
	 * <pre>
	 * @doc_generic Map&lt;String,User&gt;, List&lt;Product&gt;
	 * </pre>
	 *
	 * @meta Function or argument metadata structure that may contain the doc_generic annotation
	 * @package The package context for resolving relative class names
	 *
	 * @return Array of fully qualified class names representing generic types, or empty array if no generics are defined
	 */
	private array function getGenericTypes(
		required struct meta,
		required string package
	){
		var results = [];

		// verify we have the generic annotation
		if (
			structKeyExists(
				arguments.meta,
				variables.META_GENERIC
			)
		) {
			var generics = listToArray( arguments.meta[ variables.META_GENERIC ] );
			// iterate and resolve
			for ( var thisGeneric in generics ) {
				if ( NOT isPrimitive( thisGeneric ) ) {
					arrayAppend(
						results,
						resolveClassName( thisGeneric, arguments.package )
					);
				}
			}
		}

		return results;
	}

}
