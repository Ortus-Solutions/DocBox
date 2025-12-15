component
	hint     ="Strategy for generating the .uml file for Eclipse UML2Tools to generate diagrams from"
	accessors="true"
	extends  ="docbox.strategy.AbstractTemplateStrategy"
{

	/**
	 * The output file
	 */
	property name="outputFile" type="string";

	/**
	 * Static assets used in HTML templates
	 */
	variables.TEMPLATE_PATH = "/docbox/strategy/uml2tools/resources/templates";

	/**
	 * Constructor
	 *
	 * @outputFile The output file
	 */
	function init( required string outputFile ){
		super.init();

		if ( NOT arguments.outputFile.endsWith( ".uml" ) ) {
			arguments.outputFile &= ".uml";
		}

		variables.outputFile = arguments.outputFile;

		return this;
	}

	/**
	 * Execute the documentation generation strategy
	 *
	 * This method receives the complete metadata query from DocBox and is responsible for:
	 * - Processing the component metadata
	 * - Generating the appropriate output format
	 * - Writing files to the configured output location
	 *
	 * @metadata Query object containing all component metadata with columns:
	 *            - package: The package name
	 *            - name: The component name
	 *            - metadata: The complete component metadata structure
	 *            - type: The component type (component, interface, etc.)
	 *            - extends: The extended component name (if any)
	 *            - implements: The implemented interfaces (if any)
	 *
	 * @return The strategy instance for method chaining
	 */
	IStrategy function run( required query metadata ){
		var basePath = getDirectoryFromPath( getMetadata( this ).path );
		var packages = buildPackageTree( arguments.metadata, true );

		if ( !directoryExists( getDirectoryFromPath( getOutputFile() ) ) ) {
			throw(
				message = "Invalid configuration; configured output directory not found",
				type    = "InvalidConfigurationException",
				detail  = "Path #getDirectoryFromPath( getOutputFile() )# does not exist."
			);
		}

		// Generate the UML file
		var args = {
			path      : getOutputFile(),
			template  : "#variables.TEMPLATE_PATH#/template.uml",
			packages  : packages,
			qMetadata : arguments.metadata
		};

		writeTemplate( argumentCollection = args );

		return this;
	}

	/**
	 * Determine properties from getters and setters
	 *
	 * @meta The metadata
	 * @package The package name
	 *
	 * @return Query of properties
	 */
	private query function determineProperties(
		required struct meta,
		required string package
	){
		var qFunctions  = buildFunctionMetaData( arguments.meta );
		var qProperties = queryNew( "name, access, type, generic" );
		// is is used for boolean properties
		var qGetters    = getMetaSubQuery(
			qFunctions,
			"LOWER(name) LIKE 'get%' OR LOWER(name) LIKE 'is%'"
		);

		for ( var thisRow in qGetters ) {
			var propertyName = 0;
			if ( lCase( thisRow.name ).startsWith( "get" ) ) {
				propertyName = replaceNoCase( thisRow.name, "get", "" );
			} else {
				propertyName = replaceNoCase( thisRow.name, "is", "" );
			}

			var qSetters = getMetaSubQuery(
				qFunctions,
				"LOWER(name) = LOWER('set#propertyName#')"
			);
			var getterMeta = structCopy( thisRow.metadata );
			// lets just take getter generics, easier to do.
			var generics   = getGenericTypes( thisRow.metadata, arguments.package );

			if ( qSetters.recordCount ) {
				var setterMeta = qSetters.metadata;

				if (
					structKeyExists( setterMeta, "parameters" )
					AND arrayLen( setterMeta.parameters ) eq 1
					AND setterMeta.parameters.first().type eq getterMeta.returnType
				) {
					var access = "private";
					if ( setterMeta.access eq "public" OR getterMeta.access eq "public" ) {
						access = "public";
					} else if ( setterMeta.access eq "package" OR getterMeta.access eq "package" ) {
						access = "package";
					}

					queryAddRow( qProperties );

					// lower case the front
					querySetCell(
						qProperties,
						"name",
						reReplace(
							propertyName,
							"([A-Z]*)(.*)",
							"\L\1\E\2"
						)
					);

					querySetCell( qProperties, "access", access );

					querySetCell(
						qProperties,
						"type",
						getterMeta.returntype
					);
					querySetCell( qProperties, "generic", generics );
				}
			}
		}
		// for each getter
	}

}
