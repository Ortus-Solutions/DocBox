/**
 * Default Document Strategy for DocBox
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
	 * The theme to use for documentation generation
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
	 * Run this strategy
	 *
	 * @metadata The metadata
	 * @throws InvalidConfigurationException if directory does not exist or other invalid configuration is detected
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
	 * writes the package summaries
	 * @qMetaData The metadata
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
	 * builds the class pages
	 * @qPackage the query for a specific package
	 * @qMetaData The metadata
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
