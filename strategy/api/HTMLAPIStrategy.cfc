/**
 * HTML API Documentation Generation Strategy for DocBox
 * <h2>Overview</h2>
 * This strategy generates rich, searchable HTML documentation from CFML component metadata. It supports
 * multiple themes, modern UI components, and both server-based and file:// protocol viewing modes.
 * <h2>Key Features</h2>
 * <ul>
 * <li><strong>Multi-Theme Support</strong> - Choose between "default" (Alpine.js SPA) and "frames" (traditional frameset) themes</li>
 * <li><strong>Modern UI</strong> - Bootstrap 5 with dark mode, responsive design, and interactive components</li>
 * <li><strong>Smart Navigation</strong> - Hierarchical package trees, breadcrumbs, and real-time search</li>
 * <li><strong>Code Highlighting</strong> - Syntax-highlighted code examples and method signatures</li>
 * <li><strong>Cross-Linking</strong> - Automatic links between classes, interfaces, and related components</li>
 * <li><strong>Annotation Support</strong> - Formats @see, @link, and custom annotations with clickable references</li>
 * <li><strong>Offline Capable</strong> - Frames theme works with file:// protocol for offline documentation viewing</li>
 * </ul>
 * <h2>Themes</h2>
 * <h3>Default Theme</h3>
 * A modern Single Page Application (SPA) built with Alpine.js featuring:
 * <ul>
 * <li>Dark/light mode toggle with localStorage persistence</li>
 * <li>Real-time class search with keyboard navigation</li>
 * <li>Dynamic content loading without page refreshes</li>
 * <li>Responsive layout optimized for desktop and mobile</li>
 * <li><strong>Note:</strong> Requires a web server due to CORS restrictions with file:// protocol</li>
 * </ul>
 * <h3>Frames Theme</h3>
 * A traditional frameset-based layout featuring:
 * <ul>
 * <li>Classic three-frame layout (navigation, class list, content)</li>
 * <li>jQuery-based tree navigation with jsTree</li>
 * <li>Works natively with file:// protocol for offline viewing</li>
 * <li>Bootstrap 5 styling with dark mode support</li>
 * <li>Syntax highlighting with SyntaxHighlighter</li>
 * </ul>
 * <h2>Usage Examples</h2>
 * <h3>Basic HTML Generation</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy( "HTML", {
 *         projectTitle : "My API Docs",
 *         outputDir    : "/var/www/docs"
 *     } )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>Custom Theme Selection</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy(
 *         new docbox.strategy.api.HTMLAPIStrategy(
 *             outputDir    = "/var/www/docs",
 *             projectTitle = "My Project",
 *             theme        = "frames"  // or "default"
 *         )
 *     )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>Multiple Output Formats</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy( "HTML", {
 *         projectTitle : "My API",
 *         outputDir    : "/docs/html",
 *         theme        : "default"
 *     } )
 *     .addStrategy( "JSON", {
 *         projectTitle : "My API",
 *         outputDir    : "/docs/json"
 *     } )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h2>Generated Structure</h2>
 * <pre>
 * outputDir/
 * ├── index.html              - Main entry point
 * ├── overview-summary.html   - Package overview
 * ├── overview-frame.html     - Navigation frame
 * ├── allclasses-frame.html   - All classes list
 * ├── css/                    - Stylesheets
 * ├── js/                     - JavaScript files
 * ├── data/                   - Navigation data (default theme)
 * └── {package}/
 *     ├── package-summary.html
 *     └── ClassName.html      - Individual class documentation
 * </pre>
 * <h2>Template Customization</h2>
 * Templates are located in <code>/docbox/strategy/api/themes/{themeName}/resources/templates/</code>.
 * Each theme has its own template set, allowing full customization of output structure and styling.
 * <h2>Performance</h2>
 * <ul>
 * <li>Query caching for metadata processing (inherited from AbstractTemplateStrategy)</li>
 * <li>Static asset copying in a single operation</li>
 * <li>Template rendering with minimal I/O operations</li>
 * <li>Navigation data pre-generated for fast client-side filtering</li>
 * </ul>
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 *
 * @see AbstractTemplateStrategy
 * @see IStrategy
 */
component extends="docbox.strategy.AbstractTemplateStrategy" accessors="true" {

	/**
	 * The absolute file system path where HTML documentation will be generated
	 * <br>
	 * This directory will contain all generated HTML files, static assets, and navigation data.
	 * The directory structure mirrors the package structure of the documented code.
	 * <h3>Requirements</h3>
	 * <ul>
	 * <li>Must exist before running the strategy (throws InvalidConfigurationException if not found)</li>
	 * <li>Must have write permissions for the current process</li>
	 * <li>Should be empty or ready to be overwritten (existing files will be replaced)</li>
	 * </ul>
	 */
	property name="outputDir" type="string";

	/**
	 * The project title displayed in HTML headers, page titles, and navigation
	 * <br>
	 * This title appears in:
	 * <ul>
	 * <li>Browser tab titles and bookmarks</li>
	 * <li>Main heading on the overview page</li>
	 * <li>Navigation headers and breadcrumbs</li>
	 * <li>HTML meta tags for search engine optimization</li>
	 * </ul>
	 *
	 * @default "Untitled"
	 */
	property
		name   ="projectTitle"
		default="Untitled"
		type   ="string";

	/**
	 * The visual theme to use for documentation generation
	 * <br>
	 * Determines the template set, UI components, and JavaScript frameworks used in the generated documentation.
	 * <h3>Available Themes</h3>
	 * <ul>
	 * <li><strong>default</strong> - Modern Alpine.js SPA with dynamic content loading (requires web server)</li>
	 * <li><strong>frames</strong> - Traditional frameset layout compatible with file:// protocol (offline capable)</li>
	 * </ul>
	 * <h3>Theme Selection Guidelines</h3>
	 * <ul>
	 * <li>Use <strong>default</strong> for: Internal documentation served via web server, modern UI requirements, advanced search features</li>
	 * <li>Use <strong>frames</strong> for: Offline documentation, CD/USB distribution, legacy browser support, file:// protocol access</li>
	 * </ul>
	 *
	 * @default "frames"
	 */
	property
		name   ="theme"
		default="frames"
		type   ="string";

	/**
	 * Where HTML templates are stored
	 */
	variables.TEMPLATE_PATH = "/docbox/strategy/api/themes";

	/**
	 * Static assets used in HTML templates
	 */
	variables.ASSETS_PATH = "/docbox/strategy/api/themes";

	/**
	 * Constructor
	 * @outputDir The output directory
	 * @projectTitle The title used in the HTML output
	 * @theme The theme to use for documentation (default: frames)
	 */
	HTMLAPIStrategy function init(
		required outputDir,
		string projectTitle = "Untitled",
		string theme        = "default"
	){
		super.init();

		variables.outputDir    = arguments.outputDir;
		variables.projectTitle = arguments.projectTitle;
		variables.theme        = arguments.theme;

		// Update paths based on theme
		variables.TEMPLATE_PATH = "/docbox/strategy/api/themes/#variables.theme#/resources/templates";
		variables.ASSETS_PATH   = "/docbox/strategy/api/themes/#variables.theme#/resources/static";

		return this;
	}

	/**
	 * Executes the HTML documentation generation strategy
	 * <br>
	 * This is the main entry point for the strategy. It orchestrates the entire documentation generation process,
	 * from validating configuration to copying assets and rendering all HTML templates.
	 * <h3>Generation Process</h3>
	 * <ol>
	 * <li><strong>Validation</strong> - Ensures output directory exists</li>
	 * <li><strong>Asset Copying</strong> - Copies CSS, JavaScript, images, and other static files from theme resources</li>
	 * <li><strong>Index Generation</strong> - Creates the main index.html entry point</li>
	 * <li><strong>Overview Pages</strong> - Generates overview-summary.html and overview-frame.html with package listings</li>
	 * <li><strong>Class List</strong> - Creates allclasses-frame.html with alphabetical class index</li>
	 * <li><strong>Package Pages</strong> - Generates package-summary.html and individual class documentation for each package</li>
	 * </ol>
	 * <h3>Output Structure</h3>
	 * The method creates a complete documentation website with:
	 * <ul>
	 * <li>Hierarchical navigation matching package structure</li>
	 * <li>Individual HTML pages for each class and interface</li>
	 * <li>Cross-linked references between related components</li>
	 * <li>Static assets (CSS, JS) copied from theme resources</li>
	 * <li>Navigation data files for client-side filtering (default theme)</li>
	 * </ul>
	 * <h3>Error Handling</h3>
	 * Throws <code>InvalidConfigurationException</code> if the output directory does not exist or is not writable.
	 * Callers should catch this exception and create the directory before retrying.
	 * <h3>Method Chaining</h3>
	 * Returns the strategy instance to enable fluent method chaining with other DocBox operations.
	 *
	 * @metadata Query object from DocBox containing all component metadata with columns: package, name, type, extends, implements, metadata, fullextends, currentMapping
	 *
	 * @return The strategy instance for method chaining
	 *
	 * @throws InvalidConfigurationException if output directory does not exist or other configuration is invalid
	 */
	IStrategy function run( required query metadata ){
		if ( !directoryExists( getOutputDir() ) ) {
			throw(
				message = "Invalid configuration; output directory not found",
				type    = "InvalidConfigurationException",
				detail  = "OutputDir #getOutputDir()# does not exist."
			);
		}
		// copy over the static assets
		directoryCopy(
			expandPath( variables.ASSETS_PATH ),
			getOutputDir(),
			true
		);

		// write the index template
		var args = {
			path         : getOutputDir() & "/index.html",
			template     : "#variables.TEMPLATE_PATH#/index.cfm",
			projectTitle : getProjectTitle()
		};
		writeTemplate( argumentCollection = args )
			// Write overview summary and frame
			.writeOverviewSummaryAndFrame( arguments.metadata )
			// Write classes frame
			.writeAllClassesFrame( arguments.metadata )
			// Write packages
			.writePackagePages( arguments.metadata );

		return this;
	}

	/**
	 * Generates package summary pages and individual class documentation files
	 * <br>
	 * This method processes each package in the metadata and creates:
	 * <ul>
	 * <li>A package-summary.html page listing all classes and interfaces in the package</li>
	 * <li>Individual HTML files for each class and interface with complete API documentation</li>
	 * </ul>
	 * <h3>Package Organization</h3>
	 * Each package is written to a directory structure matching its dot notation:
	 * <pre>
	 * com.example.utils -&gt; outputDir/com/example/utils/
	 *   ├── package-summary.html
	 *   ├── StringHelper.html
	 *   └── DateUtils.html
	 * </pre>
	 * <h3>Template Processing</h3>
	 * This method includes the theme's packagePages.cfm template which handles the iteration logic.
	 * The template has access to:
	 * <ul>
	 * <li><code>qMetaData</code> - Complete metadata query</li>
	 * <li><code>buildClassPages()</code> - Method for generating individual class files</li>
	 * <li><code>getMetaSubQuery()</code> - Helper for filtering metadata</li>
	 * </ul>
	 * <h3>Adobe ColdFusion Compatibility</h3>
	 * The implementation uses a template include rather than query grouping in writeOutput
	 * to maintain compatibility with Adobe ColdFusion's query iteration limitations.
	 *
	 * @qMetaData Complete query of component metadata from DocBox
	 *
	 * @return The strategy instance for method chaining
	 */
	HTMLAPIStrategy function writePackagePages( required query qMetadata ){
		var currentDir  = 0;
		var qPackage    = 0;
		var qClasses    = 0;
		var qInterfaces = 0;

		// done this way as ACF compat. Does not support writeoutput with query grouping.
		include "#variables.TEMPLATE_PATH#/packagePages.cfm";

		return this;
	}

	/**
	 * Generates individual HTML documentation files for each class in a package
	 * <br>
	 * This method creates detailed API documentation pages for each component in the provided package query.
	 * Each generated page includes complete information about the class structure, inheritance, properties,
	 * methods, and relationships with other components.
	 * <h3>Page Content</h3>
	 * Each class page includes:
	 * <ul>
	 * <li><strong>Class Header</strong> - Package breadcrumbs, class name, type (class/interface), abstract indicator</li>
	 * <li><strong>Inheritance Tree</strong> - Visual hierarchy showing parent classes and implemented interfaces</li>
	 * <li><strong>Class Description</strong> - JavaDoc-style documentation with formatted annotations</li>
	 * <li><strong>Subclass Lists</strong> - Direct subclasses and implementing classes</li>
	 * <li><strong>Property Summary</strong> - Table of all properties with types, access levels, and descriptions</li>
	 * <li><strong>Constructor Summary</strong> - Initialization methods with parameters</li>
	 * <li><strong>Method Summary</strong> - Tabbed interface (All/Public/Private/Static/Abstract) with method signatures</li>
	 * <li><strong>Detailed Sections</strong> - Full documentation for each property, constructor, and method</li>
	 * <li><strong>Method Search</strong> - Real-time filtering with keyboard navigation (default theme)</li>
	 * </ul>
	 * <h3>Relationship Queries</h3>
	 * For components (classes), the method queries for:
	 * <ul>
	 * <li><strong>Direct subclasses</strong> - Components that extend this class</li>
	 * </ul>
	 * For interfaces, the method queries for:
	 * <ul>
	 * <li><strong>Extending interfaces</strong> - Interfaces that extend this interface</li>
	 * <li><strong>Implementing classes</strong> - Components that implement this interface</li>
	 * </ul>
	 * <h3>File Location</h3>
	 * Each class file is written to: <code>outputDir/{package}/{ClassName}.html</code>
	 * <h3>Template Context</h3>
	 * The class.cfm template receives these arguments:
	 * <ul>
	 * <li><code>projectTitle</code> - Project name for headers</li>
	 * <li><code>package</code> - Package name</li>
	 * <li><code>name</code> - Class name</li>
	 * <li><code>metadata</code> - Complete component metadata</li>
	 * <li><code>qMetadata</code> - Full metadata query for cross-linking</li>
	 * <li><code>qSubClass</code> - Query of direct subclasses/extending interfaces</li>
	 * <li><code>qImplementing</code> - Query of implementing classes (interfaces only)</li>
	 * </ul>
	 *
	 * @qPackage Query containing metadata for all components in a single package
	 * @qMetaData Complete query of all component metadata (used for cross-references and relationship queries)
	 *
	 * @return The strategy instance for method chaining
	 */
	HTMLAPIStrategy function buildClassPages(
		required query qPackage,
		required query qMetadata
	){
		for ( var thisRow in arguments.qPackage ) {
			var currentDir = variables.outputDir & "/" & replace( thisRow.package, ".", "/", "all" );
			var safeMeta   = structCopy( thisRow.metadata );

			// Is this a class
			if ( listFindNoCase( "component,class", safeMeta.type ) ) {
				var qSubClass = getMetaSubquery(
					arguments.qMetaData,
					"UPPER( extends ) = UPPER( '#thisRow.package#.#thisRow.name#' )",
					"package asc, name asc"
				);
				var qImplementing = queryNew( "" );
			} else {
				// all implementing subclasses
				var qSubClass = getMetaSubquery(
					arguments.qMetaData,
					"UPPER(fullextends) LIKE UPPER('%:#thisRow.package#.#thisRow.name#:%')",
					"package asc, name asc"
				);
				var qImplementing = getMetaSubquery(
					arguments.qMetaData,
					"UPPER(implements) LIKE UPPER('%:#thisRow.package#.#thisRow.name#:%')",
					"package asc, name asc"
				);
			}

			// write it out
			writeTemplate(
				path          = currentDir & "/#thisRow.name#.html",
				template      = "#variables.TEMPLATE_PATH#/class.cfm",
				projectTitle  = variables.projectTitle,
				package       = thisRow.package,
				name          = thisRow.name,
				qSubClass     = qSubClass,
				qImplementing = qImplementing,
				qMetadata     = qMetaData,
				metadata      = safeMeta
			);
		}

		return this;
	}


	/**
	 * writes the overview-summary.html
	 * @qMetaData The metadata
	 */
	HTMLAPIStrategy function writeOverviewSummaryAndFrame( required query qMetadata ){
		var md        = arguments.qMetadata;
		var qPackages = queryExecute(
			"SELECT DISTINCT package
			FROM md
			ORDER BY package",
			{},
			{ dbtype : "query" }
		);

		// overview summary
		writeTemplate(
			path         = getOutputDir() & "/overview-summary.html",
			template     = "#variables.TEMPLATE_PATH#/overview-summary.cfm",
			projectTitle = getProjectTitle(),
			qPackages    = qPackages
		);

		// overview frame
		writeTemplate(
			path         = getOutputDir() & "/overview-frame.html",
			template     = "#variables.TEMPLATE_PATH#/overview-frame.cfm",
			projectTitle = getProjectTitle(),
			qMetadata    = arguments.qMetadata
		);

		return this;
	}

	/**
	 * writes the allclasses-frame.html
	 * @qMetaData The metadata
	 */
	HTMLAPIStrategy function writeAllClassesFrame( required query qMetadata ){
		arguments.qMetadata = getMetaSubquery(
			query   = arguments.qMetaData,
			orderby = "name asc"
		);

		writeTemplate(
			path      = getOutputDir() & "/allclasses-frame.html",
			template  = "#variables.TEMPLATE_PATH#/allclasses-frame.cfm",
			qMetaData = arguments.qMetaData
		);

		return this;
	}

	/************************** SHARED TEMPLATE HELPERS **************************/

	/**
	 * Format a @see annotation value as a clickable link (if applicable)
	 *
	 * This method handles three cases:
	 * 1. HTTP URLs - Creates external links
	 * 2. Package paths - Resolves to class documentation links
	 * 3. Plain text - Returns as-is if not resolvable
	 *
	 * @seeValue The value of the @see annotation
	 * @qMetaData The metadata query to search for class references
	 * @currentPackage The current package context for relative path calculation
	 *
	 * @return string HTML string with link or plain text
	 */
	string function formatSeeAnnotation(
		required string seeValue,
		required query qMetaData,
		required string currentPackage
	){
		var trimmedValue = trim( arguments.seeValue );

		// Case 1: HTTP URL - create external link
		if ( left( trimmedValue, 4 ) == "http" ) {
			return "<a href=""#trimmedValue#"" target=""_blank"" class=""text-decoration-none"">#trimmedValue#</a>";
		}

		// Case 2: Try to resolve as package path
		var seePackage = listLen( trimmedValue, "." ) > 1 ? left(
			trimmedValue,
			len( trimmedValue ) - len( listLast( trimmedValue, "." ) ) - 1
		) : "";
		var seeName   = listLast( trimmedValue, "." );
		var qSeeClass = getMetaSubQuery(
			arguments.qMetaData,
			"LOWER(package)=LOWER('#seePackage#') AND LOWER(name)=LOWER('#seeName#')"
		);

		if ( qSeeClass.recordCount ) {
			// Calculate relative path from current package to target class
			var relativePath = repeatString(
				"../",
				listLen( arguments.currentPackage, "." )
			);
			var classPath = replace( qSeeClass.package, ".", "/", "all" );
			return "<a href=""#relativePath##classPath#/#qSeeClass.name#.html"" class=""text-decoration-none"">#trimmedValue#</a>";
		}

		// Case 3: Not found - return plain text
		return trimmedValue;
	}

	/**
	 * Extract package name from a fully qualified class name
	 *
	 * @className The full class name (e.g., "com.example.MyClass")
	 *
	 * @return string The package portion (e.g., "com.example")
	 */
	string function getPackage( required string className ){
		if ( listLen( arguments.className, "." ) > 1 ) {
			return left(
				arguments.className,
				len( arguments.className ) - len( listLast( arguments.className, "." ) ) - 1
			);
		}
		return "";
	}

	/**
	 * Extract object/class name from a fully qualified class name
	 *
	 * @className The full class name (e.g., "com.example.MyClass")
	 *
	 * @return string The class name portion (e.g., "MyClass")
	 */
	string function getObjectName( required string className ){
		return listLast( arguments.className, "." );
	}

}
