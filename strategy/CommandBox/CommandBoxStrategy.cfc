/**
 * CommandBox CLI Documentation Generation Strategy
 * <h2>Overview</h2>
 * This specialized strategy extends HTMLAPIStrategy to generate documentation specifically tailored for
 * CommandBox CLI commands and namespaces. It transforms CommandBox command components into searchable,
 * navigable HTML documentation with command-specific features and terminology.
 * <h2>Key Features</h2>
 * <ul>
 * <li><strong>Command-Centric Navigation</strong> - Organizes documentation by command namespaces rather than packages</li>
 * <li><strong>CLI Terminology</strong> - Uses "commands" and "namespaces" instead of "classes" and "packages"</li>
 * <li><strong>Qualified Names</strong> - Displays full command paths (e.g., "server start", "package show")</li>
 * <li><strong>Namespace Hierarchy</strong> - Visualizes command organization and nesting</li>
 * <li><strong>Custom Templates</strong> - CommandBox-specific templates with CLI-focused layouts</li>
 * <li><strong>Frames Theme</strong> - Uses proven frames theme assets for compatibility and stability</li>
 * </ul>
 *
 * <h2>Usage Examples</h2>
 * <h3>Documenting CommandBox Core</h3>
 * <pre>
 * new docbox.DocBox() <br>
 *     .addStrategy( <br>
 *         new docbox.strategy.CommandBox.CommandBoxStrategy( <br>
 *             outputDir    = "/docs/commandbox", <br>
 *             projectTitle = "CommandBox CLI Reference" <br>
 *         ) <br>
 *     ) <br>
 *     .generate( <br>
 *         source  = "/commandbox/cfml/system/modules_app/", <br>
 *         mapping = "commandbox.commands" <br>
 *     ); <br>
 * </pre>
 * <h3>Custom CommandBox Module</h3>
 * <pre>
 * new docbox.DocBox() <br>
 *     .addStrategy( "CommandBox", { <br>
 *         projectTitle : "My CommandBox Commands", <br>
 *         outputDir    : "/docs/commands" <br>
 *     } ) <br>
 *     .generate( <br>
 *         source  = "/modules/my-commands/commands/", <br>
 *         mapping = "my-commands" <br>
 *     ); <br>
 * </pre>
 *
 * <h2>Generated Structure</h2>
 * <pre>
 * outputDir/ <br>
 * ├── index.html                  - Main entry point (frameset) <br>
 * ├── overview-summary.html       - Namespace overview <br>
 * ├── overview-frame.html         - Navigation sidebar <br>
 * ├── css/, js/, bootstrap/       - Static assets (from frames theme) <br>
 * └── {namespace}/ <br>
 *     ├── package-summary.html    - Namespace detail <br>
 *     └── {command}.html          - Individual command docs <br>
 * </pre>
 *
 * <small><em>Copyright since 2012 Ortus Solutions, Corp <a href="www.ortussolutions.com/products/commandbox">www.ortussolutions.com/products/commandbox</a></em></small>
 */
component extends="docbox.strategy.api.HTMLAPIStrategy" {

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
	 * @outputDir The output directory
	 * @projectTitle The title used in the HTML output
	 */
	function init(
		required outputDir,
		string projectTitle = "Untitled"
	){
		super.init( argumentCollection = arguments );

		// Override the parent's theme-based paths with CommandBox-specific paths
		variables.TEMPLATE_PATH = "/docbox/strategy/CommandBox/resources/templates";
		variables.ASSETS_PATH   = "/docbox/strategy/api/themes/frames/resources/static";

		return this;
	}

	/**
	 * Executes the CommandBox documentation generation strategy
	 * <br>
	 * This method extends the parent HTMLAPIStrategy.run() by first augmenting the metadata query with
	 * CommandBox-specific columns (command and namespace), then proceeding with standard HTML generation
	 * using CommandBox-specific templates.
	 * <h3>Metadata Augmentation Process</h3>
	 * <ol>
	 * <li><strong>Column Preparation</strong> - Creates empty array for ACF compatibility with queryAddColumn</li>
	 * <li><strong>Add Columns</strong> - Adds "command" and "namespace" columns to metadata query</li>
	 * <li><strong>Populate Values</strong> - Iterates through query, calculating command/namespace for each row</li>
	 * <li><strong>HTML Generation</strong> - Calls standard generation methods with augmented metadata</li>
	 * </ol>
	 * <h3>Command Transformation</h3>
	 * For each component in the metadata:
	 * <pre>
	 * Input: <br>
	 *   package:        "commandbox.commands.server.start" <br>
	 *   name:           "start" <br>
	 *   currentMapping: "commandbox.commands" <br>
	 * <br>
	 * Transformation: <br>
	 *   fullPath = package + "." + name <br>
	 *            = "commandbox.commands.server.start" <br>
	 * <br>
	 *   Remove mapping: <br>
	 *            = "server.start" <br>
	 * <br>
	 *   Convert dots to spaces: <br>
	 *   command  = "server start" <br>
	 * <br>
	 *   Remove last segment: <br>
	 *   namespace = "server" <br>
	 * </pre>
	 * <h3>Namespace Extraction</h3>
	 * The namespace is the command path without the final command name:
	 * <ul>
	 * <li>"server start" → namespace "server"</li>
	 * <li>"package show" → namespace "package"</li>
	 * <li>"help" → namespace "" (root command)</li>
	 * </ul>
	 * <h3>ACF Compatibility Note</h3>
	 * The method pre-populates column value arrays to work around Adobe ColdFusion's Query of Queries
	 * limitations. Without this, ACF would fail when trying to add columns to the query.
	 * <h3>Asset and Template Processing</h3>
	 * After metadata augmentation, the method:
	 * <ul>
	 * <li>Copies static assets from frames theme (CSS, JavaScript, Bootstrap)</li>
	 * <li>Generates index.html using CommandBox template</li>
	 * <li>Creates overview pages with namespace-specific queries</li>
	 * <li>Builds package pages for each namespace with command listings</li>
	 * </ul>
	 * <h3>Template Context</h3>
	 * All CommandBox templates receive the augmented metadata with:
	 * <ul>
	 * <li>All standard columns (package, name, type, extends, metadata, etc.)</li>
	 * <li><strong>command</strong> - Space-delimited CLI command path</li>
	 * <li><strong>namespace</strong> - Command namespace for grouping</li>
	 * </ul>
	 *
	 * @metadata Query object from DocBox containing component metadata (will be augmented with command/namespace columns)
	 *
	 * @return The strategy instance for method chaining
	 */
	IStrategy function run( required query metadata ){
		// ACF requires an array of values, and hiccups in QoQ's if we don't populate that array.
		var values = [];
		queryEach( arguments.metadata, ( row ) => values.append( "" ) );
		queryAddColumn(
			arguments.metadata,
			"command",
			values
		);
		queryAddColumn(
			arguments.metadata,
			"namespace",
			values
		);

		var index = 1;
		for ( var thisRow in arguments.metadata ) {
			var thisCommand = listAppend( thisRow.package, thisRow.name, "." );
			thisCommand     = replaceNoCase(
				thisCommand,
				thisRow.currentMapping,
				"",
				"one"
			);
			thisCommand       = listChangeDelims( thisCommand, " ", "." );
			var thisNamespace = listDeleteAt(
				thisCommand,
				listLen( thisCommand, " " ),
				" "
			);

			querySetCell(
				arguments.metadata,
				"command",
				thisCommand,
				index
			);
			querySetCell(
				arguments.metadata,
				"namespace",
				thisNamespace,
				index
			);
			index++;
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
			// Write packages
			.writePackagePages( arguments.metadata );

		return this;
	}

	/**
	 * Generates overview summary and frame pages with namespace-aware queries
	 * <br>
	 * This method overrides the parent implementation to use CommandBox-specific terminology and include
	 * namespace information in the package query. It creates the main overview pages that serve as the
	 * entry point for navigating CommandBox command documentation.
	 * <h3>Overview Summary Page</h3>
	 * The overview-summary.html page displays:
	 * <ul>
	 * <li>Project title (e.g., "CommandBox CLI Reference")</li>
	 * <li>List of all command namespaces with descriptions</li>
	 * <li>Command count per namespace</li>
	 * <li>Links to namespace detail pages</li>
	 * </ul>
	 * <h3>Overview Frame Page</h3>
	 * The overview-frame.html page provides:
	 * <ul>
	 * <li>Left sidebar navigation tree</li>
	 * <li>Hierarchical namespace structure</li>
	 * <li>Expandable command groups</li>
	 * <li>Direct links to individual command pages</li>
	 * </ul>
	 * <h3>Namespace Query</h3>
	 * Unlike the parent method which queries for distinct packages, this method queries for distinct
	 * package/namespace pairs:
	 * <pre>
	 * SELECT DISTINCT [package], [namespace] <br>
	 * FROM metadata <br>
	 * ORDER BY [package] <br>
	 * </pre>
	 * This enables templates to display both the full package path and the user-facing namespace.
	 * <h3>Query Column Escaping</h3>
	 * Note the use of <code>[package]</code> and <code>[namespace]</code> with brackets in the SQL.
	 * This is required because "package" and "namespace" may be reserved words in some CFML engines'
	 * Query of Queries implementations.
	 * <h3>Template Arguments</h3>
	 * Both templates receive:
	 * <ul>
	 * <li><code>projectTitle</code> - Project name for page headers</li>
	 * <li><code>qPackages</code> - Query of distinct package/namespace pairs</li>
	 * <li><code>qMetadata</code> - Complete augmented metadata (overview-frame only)</li>
	 * </ul>
	 *
	 * @qMetaData Complete augmented metadata query including command and namespace columns
	 *
	 * @return The strategy instance for method chaining
	 */
	function writeOverviewSummaryAndFrame( required query qMetadata ){
		var md        = arguments.qMetadata;
		var qPackages = queryExecute(
			"SELECT DISTINCT [package], [namespace]
			FROM md
			ORDER BY [package]",
			{},
			{ dbtype : "query" }
		)

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
	 * writes the package summaries
	 * @qMetaData The metadata
	 */
	function writePackagePages( required query qMetadata ){
		var currentDir  = 0;
		var qPackage    = 0;
		var qClasses    = 0;
		var qInterfaces = 0;

		// done this way as ACF compat. Does not support writeoutput with query grouping.
		include "#variables.TEMPLATE_PATH#/packagePages.cfm";

		return this;
	}

	/**
	 * Generates individual command documentation pages
	 * <br>
	 * This method extends the parent implementation by passing the command column to the class template,
	 * enabling CommandBox-specific command documentation with CLI syntax and examples.
	 * <h3>Command Page Content</h3>
	 * Each command page includes:
	 * <ul>
	 * <li><strong>Command Header</strong> - Full command path (e.g., "server start") with namespace breadcrumbs</li>
	 * <li><strong>Command Description</strong> - JavaDoc documentation from component hint</li>
	 * <li><strong>Parameters</strong> - Run method parameters formatted as CLI flags and arguments</li>
	 * <li><strong>Usage Examples</strong> - CLI syntax examples derived from method signatures</li>
	 * <li><strong>Related Commands</strong> - Other commands in the same namespace</li>
	 * <li><strong>Technical Details</strong> - Component path, package information for developers</li>
	 * </ul>
	 * <h3>Template Arguments</h3>
	 * The CommandBox class.cfm template receives all standard arguments plus:
	 * <ul>
	 * <li><code>command</code> - Space-delimited CLI command path (e.g., "server start")</li>
	 * </ul>
	 * This enables the template to display CLI-appropriate syntax:
	 * <pre>
	 * // Instead of: <br>
	 * start.run( name="myServer" ) <br>
	 * <br>
	 * // Template shows: <br>
	 * server start name=myServer <br>
	 * </pre>
	 * <h3>File Organization</h3>
	 * Command pages are written to:
	 * <pre>
	 * outputDir/{package-path}/{CommandName}.html <br>
	 * <br>
	 * Example: <br>
	 * outputDir/commandbox/commands/server/start.html <br>
	 * </pre>
	 * <h3>Relationship Queries</h3>
	 * Like the parent method, this generates queries for:
	 * <ul>
	 * <li><strong>Subcommands</strong> - Commands extending this command (rare in CLI contexts)</li>
	 * <li><strong>Related Commands</strong> - Other commands in the same namespace</li>
	 * </ul>
	 * <h3>Inheritance Handling</h3>
	 * For component-type commands (not interfaces):
	 * <ul>
	 * <li>Queries for direct subclasses using extends relationship</li>
	 * <li>Empty implementing query (N/A for components)</li>
	 * </ul>
	 * For interface-type commands (uncommon):
	 * <ul>
	 * <li>Queries for extending interfaces via fullextends</li>
	 * <li>Queries for implementing commands via implements</li>
	 * </ul>
	 *
	 * @qPackage Query containing metadata for all commands in a single namespace/package
	 * @qMetaData Complete augmented metadata query for cross-references and relationship queries
	 *
	 * @return The strategy instance for method chaining
	 */
	function buildClassPages(
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
				metadata      = safeMeta,
				command       = thisRow.command
			);
		}

		return this;
	}

}
