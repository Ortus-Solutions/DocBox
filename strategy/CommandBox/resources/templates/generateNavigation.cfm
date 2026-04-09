<cfsilent>
<cfscript>
/**
 * CommandBox Navigation Data Generator
 * Generates data/navigation.js for the Alpine.js SPA
 *
 * Called from packagePages.cfm after all command pages are built.
 * Requires navArgs.qMetaData (augmented query with command/namespace columns)
 * and navArgs.outputDir to be set in the calling scope.
 */

local.navData = {
	"namespaces"  : [],
	"topLevel"    : [],
	"allCommands" : []
};

// Re-build the namespace tree from the augmented metadata query
local.namespaceTree = {};
local.topLevelTree  = {};

for ( local.row in navArgs.qMetaData ) {
	if ( local.row.name == "CommandTemplate" ) continue;

	local.command        = local.row.command;
	local.namespace      = local.row.namespace;
	local.namespaceParts = len( trim( local.namespace ) ) > 0
		? listToArray( trim( local.namespace ), " " )
		: [];
	local.link        = replace( local.row.package, ".", "/", "all" ) & "/" & local.row.name & ".html";
	local.packageLink = replace( local.row.package, ".", "/", "all" ) & "/package-summary.html";
	local.searchList  = local.command;

	// Get first-line hint from metadata
	local.meta = local.row.metadata;
	local.doc  = server.keyExists( "boxlang" ) ? local.meta.documentation : local.meta;
	local.hint = "";
	if ( structKeyExists( local.doc, "hint" ) && len( trim( local.doc.hint ) ) ) {
		local.hint = listFirst( trim( local.doc.hint ), chr( 10 ) );
		if ( len( local.hint ) > 150 ) local.hint = left( local.hint, 150 ) & "...";
	}

	if ( !isNull( local.row.metadata.aliases ) && len( local.row.metadata.aliases ) ) {
		local.searchList &= "," & local.row.metadata.aliases;
	}

	// Determine target tree (top-level = single word command, e.g. "help")
	local.isTopLevel = ( listLen( local.command, " " ) == 1 );
	local.targetTree = local.isTopLevel ? local.topLevelTree : local.namespaceTree;
	local.targetTree[ "$link" ] = local.packageLink;

	// Navigate / create nested namespace structure
	local.currentNode = local.targetTree;
	for ( local.part in local.namespaceParts ) {
		if ( !structKeyExists( local.currentNode, local.part ) ) {
			local.currentNode[ local.part ] = { "$link" : local.packageLink };
		}
		local.currentNode = local.currentNode[ local.part ];
	}

	// Add command node
	if ( !structKeyExists( local.currentNode, local.row.name ) ) {
		local.currentNode[ local.row.name ] = {};
	}
	local.currentNode[ local.row.name ][ "$command" ] = {
		"link"       : local.link,
		"searchList" : local.searchList,
		"hint"       : local.hint
	};

	// Add to flat allCommands list (skip "help" special case)
	if ( local.row.name != "help" ) {
		arrayAppend( local.navData.allCommands, {
			"name"       : local.row.name,
			"command"    : local.command,
			"namespace"  : local.namespace,
			"link"       : local.link,
			"searchList" : local.searchList,
			"hint"       : local.hint
		} );
	}
}

// ── Convert namespaceTree struct → Alpine.js-friendly array ──────────────────

local.nsKeys = structKeyArray( local.namespaceTree );
arraySort( local.nsKeys, "text" );

for ( local.nsKey in local.nsKeys ) {
	if ( left( local.nsKey, 1 ) == "$" ) continue;

	local.nsNode = local.namespaceTree[ local.nsKey ];
	local.nsItem = {
		"name"     : local.nsKey,
		"link"     : structKeyExists( local.nsNode, "$link" ) ? local.nsNode[ "$link" ] : "",
		"commands" : [],
		"children" : []
	};

	// Separate direct commands from child namespaces
	local.nodeKeys = structKeyArray( local.nsNode );
	arraySort( local.nodeKeys, "text" );

	for ( local.nodeKey in local.nodeKeys ) {
		if ( left( local.nodeKey, 1 ) == "$" ) continue;
		local.nodeChild = local.nsNode[ local.nodeKey ];

		if ( structKeyExists( local.nodeChild, "$command" ) ) {
			// Direct command under this namespace
			local.cmdData = local.nodeChild[ "$command" ];
			arrayAppend( local.nsItem.commands, {
				"name"       : local.nodeKey,
				"command"    : local.nsKey & " " & local.nodeKey,
				"link"       : structKeyExists( local.cmdData, "link" )       ? local.cmdData.link       : "",
				"searchList" : structKeyExists( local.cmdData, "searchList" ) ? local.cmdData.searchList : local.nodeKey,
				"hint"       : structKeyExists( local.cmdData, "hint" )       ? local.cmdData.hint       : ""
			} );
		} else {
			// Child namespace (one level deep)
			local.childItem = {
				"name"          : local.nodeKey,
				"fullNamespace" : local.nsKey & " " & local.nodeKey,
				"link"          : structKeyExists( local.nodeChild, "$link" ) ? local.nodeChild[ "$link" ] : "",
				"commands"      : [],
				"children"      : []
			};

			local.childKeys = structKeyArray( local.nodeChild );
			arraySort( local.childKeys, "text" );

			for ( local.childKey in local.childKeys ) {
				if ( left( local.childKey, 1 ) == "$" ) continue;
				local.grandChild = local.nodeChild[ local.childKey ];
				if ( structKeyExists( local.grandChild, "$command" ) ) {
					local.gcData = local.grandChild[ "$command" ];
					arrayAppend( local.childItem.commands, {
						"name"       : local.childKey,
						"command"    : local.nsKey & " " & local.nodeKey & " " & local.childKey,
						"link"       : structKeyExists( local.gcData, "link" )       ? local.gcData.link       : "",
						"searchList" : structKeyExists( local.gcData, "searchList" ) ? local.gcData.searchList : local.childKey,
						"hint"       : structKeyExists( local.gcData, "hint" )       ? local.gcData.hint       : ""
					} );
				}
			}

			arraySort( local.childItem.commands, function( a, b ) {
				return a.name > b.name ? 1 : -1;
			} );
			arrayAppend( local.nsItem.children, local.childItem );
		}
	}

	arraySort( local.nsItem.commands, function( a, b ) {
		return a.name > b.name ? 1 : -1;
	} );
	arrayAppend( local.navData.namespaces, local.nsItem );
}

// ── Top-level commands (e.g. "help") ─────────────────────────────────────────

local.tlKeys = structKeyArray( local.topLevelTree );
arraySort( local.tlKeys, "text" );

for ( local.tlKey in local.tlKeys ) {
	if ( left( local.tlKey, 1 ) == "$" ) continue;
	local.tlNode = local.topLevelTree[ local.tlKey ];
	if ( structKeyExists( local.tlNode, "$command" ) ) {
		local.tlData = local.tlNode[ "$command" ];
		local.tlLink = structKeyExists( local.tlData, "link" ) ? local.tlData.link : "";
		if ( len( local.tlLink ) ) {
			arrayAppend( local.navData.topLevel, {
				"name"       : local.tlKey,
				"command"    : local.tlKey,
				"link"       : local.tlLink,
				"searchList" : structKeyExists( local.tlData, "searchList" ) ? local.tlData.searchList : local.tlKey,
				"hint"       : structKeyExists( local.tlData, "hint" )       ? local.tlData.hint       : ""
			} );
		}
	}
}

// ── Write data/navigation.js ──────────────────────────────────────────────────

local.dataDir = navArgs.outputDir & "/data";
if ( !directoryExists( local.dataDir ) ) {
	directoryCreate( local.dataDir );
}

local.jsonContent = serializeJSON( local.navData, "struct" );
local.jsContent   = "// CommandBox Documentation - Navigation Data" & chr( 10 )
	& "// Auto-generated by DocBox - Do not edit manually" & chr( 10 )
	& "window.COMMANDBOX_NAV_DATA = " & local.jsonContent & ";";

fileWrite( local.dataDir & "/navigation.js", local.jsContent );
</cfscript>
</cfsilent>
