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

    // (skip "help" special case)
	if ( local.row.name != "help" ) {
		local.currentNode[ local.row.name ][ "$command" ] = {
			"link"       : local.link,
			"searchList" : local.searchList,
			"hint"       : local.hint
		};
		// Add to flat allCommands list
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

/**
 * Recursively converts a namespace tree node into an Alpine.js-friendly item.
 *
 * @node          The struct node from namespaceTree to convert.
 * @namespacePath Space-separated namespace path to this node (e.g. "server java").
 * @return        A struct with name, fullNamespace, link, commands[], children[].
 */
function convertNamespaceNode( required struct node, required string namespacePath ) {
	var parts = listToArray( trim( arguments.namespacePath ), " " );
	var name  = parts[ arrayLen( parts ) ];

	var item = {
		"name"          : name,
		"fullNamespace" : arguments.namespacePath,
		"link"          : structKeyExists( arguments.node, "$link" ) ? arguments.node[ "$link" ] : "",
		"commands"      : [],
		"children"      : []
	};

	var nodeKeys = structKeyArray( arguments.node );
	arraySort( nodeKeys, "text" );

	for ( var nodeKey in nodeKeys ) {
		if ( left( nodeKey, 1 ) == "$" ) continue;
		var child = arguments.node[ nodeKey ];

		if ( isStruct( child ) && structIsEmpty( child ) ) continue;

		if ( structKeyExists( child, "$command" ) ) {
			// Direct command under this namespace
			var cmdData = child[ "$command" ];
			arrayAppend( item.commands, {
				"name"       : nodeKey,
				"command"    : arguments.namespacePath & " " & nodeKey,
				"link"       : structKeyExists( cmdData, "link" )       ? cmdData.link       : "",
				"searchList" : structKeyExists( cmdData, "searchList" ) ? cmdData.searchList : nodeKey,
				"hint"       : structKeyExists( cmdData, "hint" )       ? cmdData.hint       : ""
			} );
		} else {
			// Child namespace — recurse to any depth
			var childItem = convertNamespaceNode( child, arguments.namespacePath & " " & nodeKey );
			arraySort( childItem.commands, function( a, b ) {
				return a.name > b.name ? 1 : -1;
			} );
			arrayAppend( item.children, childItem );
		}
	}

	arraySort( item.commands, function( a, b ) {
		return a.name > b.name ? 1 : -1;
	} );

	return item;
}

local.nsKeys = structKeyArray( local.namespaceTree );
arraySort( local.nsKeys, "text" );

for ( local.nsKey in local.nsKeys ) {
	if ( left( local.nsKey, 1 ) == "$" ) continue;

	local.nsNode = local.namespaceTree[ local.nsKey ];
	local.nsItem = convertNamespaceNode( local.nsNode, local.nsKey );
	// Top-level namespace items don't need fullNamespace (it equals name)
	structDelete( local.nsItem, "fullNamespace" );

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
