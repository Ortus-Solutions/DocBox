<cfsilent>
<cfscript>
/**
 * Package Pages Generator for Default Theme
 * Generates individual class HTML files for each package
 */

// Get all packages
var md = arguments.qMetaData;
var qPackages = queryExecute(
	"SELECT DISTINCT package FROM md ORDER BY package",
	{},
	{ dbtype="query" }
);

// Loop through each package and build class pages
for ( var packageRow in qPackages ) {
	var currentPackage = packageRow.package;
	var currentDir = variables.outputDir & "/" & replace( currentPackage, ".", "/", "all" );

	// Create directory if it doesn't exist
	if ( !directoryExists( currentDir ) ) {
		directoryCreate( currentDir );
	}

	// Get all classes/interfaces in this package
	var qPackage = queryExecute(
		"SELECT * FROM md WHERE package = :package ORDER BY name",
		{ package: currentPackage },
		{ dbtype="query" }
	);

	// Build individual class pages
	buildClassPages( qPackage, arguments.qMetaData );
}

// Generate navigation JSON data
var navArgs = {
	outputDir: variables.outputDir,
	qMetaData: arguments.qMetaData
};
include "#variables.TEMPLATE_PATH#/generateNavigation.cfm";
</cfscript>
</cfsilent>
