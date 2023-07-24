<cfscript>
	// Build out data
	variables.namespaces = {};
	variables.topLevel = {};
	// Loop over commands
	for( local.row in qMetaData ) {
		// Skip our template CFC
		if( row.name == 'CommandTemplate' ) {
			continue;
		}
		local.command = row.command;
		local.bracketPath = '';
		// Build bracket notation
		for( local.item in listToArray( row.namespace, ' ' ) ) {
			bracketPath &= '[ "#item#" ]';
		}
		// Set "deep" struct to create nested data
		local.link = replace( row.package, ".", "/", "all") & '/' & row.name & '.html';
		local.packagelink = replace( row.package, ".", "/", "all") & '/package-summary.html';
		local.searchList = row.command;
		if( !isNull( row.metadata.aliases ) && len( row.metadata.aliases ) ) {
			searchList &= ',' & row.metadata.aliases;
		}

		local.thisTree = ( listLen( command, ' ' ) == 1 ? "topLevel" : "namespaces" );
		evaluate( '#local.thisTree##local.bracketPath#[ local.row.name ] = structNew()' );
		evaluate( '#local.thisTree##local.bracketPath#[ local.row.name ][ "$command"] = structNew()' );
		evaluate( '#local.thisTree#[ "$link" ] = packageLink' );
		if( row.name != 'help') {
			evaluate( '#local.thisTree##local.bracketPath#[ row.name ][ "$command"].link = link' );
			evaluate( '#local.thisTree##local.bracketPath#[ row.name ][ "$command"].searchList = searchList' );
		}
	}
	// writeDump( variables.topLevel );abort;
</cfscript>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>	#arguments.projectTitle# overview </title>
	<meta name="keywords" content="overview">
	<cfmodule template="inc/common.cfm" rootPath="">
	<link rel="stylesheet" href="jstree/themes/default/style.min.css" />
</head>

<body>
	<h3><strong>#arguments.projecttitle#</strong></h3>

	<!--- Search box --->
	<input type="text" id="commandSearch" placeholder="Search..."><br><br>
	<!--- Container div for tree --->
	<div id="commandTree">
		<ul>
			<!--- Output namespaces and their children --->
			#writeItems( namespaces, "namespace", "command" )#
			<li data-jstree='{ "type" : "system" }' linkhref="#topLevel.$link#" searchlist="System" thissort="3">
				System Commands
				<ul>
					<!--- These are all commands not in a namespace.--->
					#writeItems( topLevel, "namespace", "command" )#
				</ul>
			</li>
		</ul>
	</div>

	<script src="jstree/jstree.min.js"></script>
	<script language="javascript">
		$(function () {
			// Initialize tree
			$('##commandTree')
				.jstree({
					// Shortcut types to control icons
				    "types" : {
				      "namespace" : {
				        "icon" : "glyphicon glyphicon-th-large"
				      },
				      "command" : {
				        "icon" : "glyphicon glyphicon-flash"
				      },
				      "system" : {
				        "icon" : "glyphicon glyphicon-cog"
				      }
				    },
				    // Smart search callback to do lookups on full command name and aliases
				    "search" : {
				    	"show_only_matches" : true,
				    	"search_callback" : function( q, node ) {
				    		q = q.toUpperCase();
				    		var searchArray = node.li_attr.searchlist.split(',');
				    		var isCommand = node.li_attr.thissort != 1;
				    		for( var i in searchArray ) {
				    			var item = searchArray[ i ];
				    			// Commands must be a super set of the serach string, but namespaces are reversed
				    			// This is so "testbox" AND "run" highlight when you serach for "testbox run"
				    			if( ( isCommand && item.toUpperCase().indexOf( q ) > -1 )
				    				|| ( !isCommand && q.indexOf( item.toUpperCase() ) > -1 ) ) {
				    				return true;
				    			}
				    		}
				    		return false;
				    	}
				    },
				    // Custom sorting to force namespaces to the top and system to the bottom
				    "sort" : function( id1, id2 ) {
				    			var node1 = this.get_node( id1 );
				    			var node2 = this.get_node( id2 );
				    			// Concat sort to name and use that
					    		var node1String = node1.li_attr.thissort + node1.text;
					    		var node2String = node2.li_attr.thissort + node2.text;

								return ( node1String > node2String ? 1 : -1);
				    },
				    "plugins" : [ "types", "search", "sort" ]
				  })
				.on("changed.jstree", function (e, data) {
					var obj = data.instance.get_node(data.selected[0]).li_attr;
					if( obj.linkhref ) {
						window.parent.frames['classFrame'].location.href = obj.linkhref;
					}
			});

			// Bind search to text box
			var to = false;
			$('##commandSearch').keyup(function () {
				if(to) { clearTimeout(to); }
				to = setTimeout(function () {
					var v = $('##commandSearch').val();
					$('##commandTree').jstree(true).search(v);
				}, 250);
			});

		 });
	</script>
</body>
</html>
</cfoutput>