<cfsilent>
<cfscript>
// Build navigation data structure
local.navData = {
	"packages"   : [],
	"allClasses" : []
};

// Use the metadata query from the calling template
local.md = navArgs.qMetaData;

// Get all packages
local.qPackages = queryExecute(
	"SELECT DISTINCT package FROM md ORDER BY package",
	{},
	{ dbtype : "query" }
);

// Process each package
for ( local.packageRow in local.qPackages ) {
	local.packageName = local.packageRow.package;

	// Get classes and interfaces for this package
	local.qPackageItems = queryExecute(
		"SELECT * FROM md WHERE package = :package ORDER BY name",
		{ package : local.packageName },
		{ dbtype : "query" }
	);

	local.packageData = {
		"name"       : local.packageName,
		"classes"    : [],
		"interfaces" : []
	};

	for ( local.item in local.qPackageItems ) {
		local.itemMeta = local.item.metadata;
		local.itemDoc  = server.keyExists( "boxlang" ) ? local.itemMeta.documentation : local.itemMeta;

		// Truncate hint to first 2 sentences or 200 chars
		local.fullHint      = local.itemDoc.keyExists( "hint" ) ? local.itemDoc.hint : "";
		local.truncatedHint = "";
		if ( len( local.fullHint ) ) {
			// Find first 2 sentence endings (. ? !)
			local.sentenceEnds = [];
			for ( local.i = 1; local.i <= len( local.fullHint ); local.i++ ) {
				local.char = mid( local.fullHint, local.i, 1 );
				if ( listFind( ".,?,!", local.char ) && local.i < len( local.fullHint ) ) {
					arrayAppend( local.sentenceEnds, local.i );
					if ( arrayLen( local.sentenceEnds ) >= 2 ) break;
				}
			}
			// Use 2nd sentence end if found, otherwise use 200 char limit
			if ( arrayLen( local.sentenceEnds ) >= 2 ) {
				local.truncatedHint = left( local.fullHint, local.sentenceEnds[ 2 ] );
			} else if ( arrayLen( local.sentenceEnds ) == 1 ) {
				local.truncatedHint = left( local.fullHint, local.sentenceEnds[ 1 ] );
			} else {
				local.truncatedHint = left( local.fullHint, 200 ) & ( len( local.fullHint ) > 200 ? "..." : "" );
			}
		}

		local.classInfo = {
			"name"     : local.item.name,
			"package"  : local.item.package,
			"fullname" : local.item.package & "." & local.item.name,
			"type"     : local.itemMeta.type,
			"hint"     : local.truncatedHint
		};

		// Add to package and allClasses
		if ( listFindNoCase( "interface", local.itemMeta.type ) ) {
			arrayAppend( local.packageData.interfaces, local.classInfo );
		} else {
			arrayAppend( local.packageData.classes, local.classInfo );
		}

		arrayAppend( local.navData.allClasses, local.classInfo );
	}

	arrayAppend( local.navData.packages, local.packageData );
}

// Ensure data directory exists
local.dataDir = navArgs.outputDir & "/data";
if ( !directoryExists( local.dataDir ) ) {
	directoryCreate( local.dataDir );
}

// Write JS file (for file:// protocol support - no CORS issues)
local.jsonContent = serializeJSON( local.navData, "struct" );
local.jsContent = "// DocBox Navigation Data" & chr(10) &
	"// This file is loaded as a script to avoid CORS issues with file:// protocol" & chr(10) &
	"window.DOCBOX_NAV_DATA = " & local.jsonContent & ";";
fileWrite(
	local.dataDir & "/navigation.js",
	local.jsContent
);
</cfscript>
</cfsilent>
