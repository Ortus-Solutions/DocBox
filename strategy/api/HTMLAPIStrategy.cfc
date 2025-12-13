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
		string theme = "frames"
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
	 * @qMetaData The metadata
	 * @throws InvalidConfigurationException if directory does not exist or other invalid configuration is detected
	 */
	HTMLAPIStrategy function run( required query qMetadata ){
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
			.writeOverviewSummaryAndFrame( arguments.qMetaData )
			// Write classes frame
			.writeAllClassesFrame( arguments.qMetaData )
			// Write packages
			.writePackagePages( arguments.qMetaData );

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
		var md = arguments.qMetadata;
		var qPackages = queryExecute(
			"SELECT DISTINCT package
			FROM md
			ORDER BY package",
			{},
			{ dbtype="query" }
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

}
