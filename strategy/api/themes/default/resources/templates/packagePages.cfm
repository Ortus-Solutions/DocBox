<cfsilent>
<cfscript>
/**
 * Package Pages Generator for Default Theme
 * Generates individual class HTML files for each package
 */

// Get all packages
local.md = arguments.qMetaData;
local.qPackages = queryExecute(
	"SELECT DISTINCT package FROM md ORDER BY package",
	{},
	{ dbtype="query" }
);

// Loop through each package and build class pages
for (  local.packageRow in qPackages ) {
	local.currentPackage = packageRow.package;
	local.currentDir = variables.outputDir & "/" & replace( local.currentPackage, ".", "/", "all" );

	// Create directory if it doesn't exist
	if ( !directoryExists( local.currentDir ) ) {
		directoryCreate( local.currentDir );
	}

	// Get all classes/interfaces in this package
	local.qPackage = queryExecute(
		"SELECT * FROM md WHERE package = :package ORDER BY name",
		{ package: local.currentPackage },
		{ dbtype="query" }
	);

	// Build individual class pages
	buildClassPages( local.qPackage, arguments.qMetaData );
}

// Generate navigation JSON data
local.navArgs = {
	outputDir: variables.outputDir,
	qMetaData: arguments.qMetaData
};
include "#variables.TEMPLATE_PATH#/generateNavigation.cfm";
</cfscript>
</cfsilent>
