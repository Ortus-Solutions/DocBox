<cfscript>
	// Build out data
	local.classTree = {};
	// Loop over classes
	for( local.row in qMetaData ) {
		// Build nested package structure
		local.packageParts = listToArray( local.row.package, '.' );
		local.currentNode = local.classTree;

		// Navigate/create nested package structure
		for( local.packagePart in local.packageParts ) {
			if( !structKeyExists( local.currentNode, local.packagePart ) ) {
				local.currentNode[ local.packagePart ] = {};
			}
			local.currentNode = local.currentNode[ local.packagePart ];
		}

		// Set package link
		local.link = replace( local.row.package, ".", "/", "all") & '/' & local.row.name & '.html';
		local.packagelink = replace( local.row.package, ".", "/", "all") & '/package-summary.html';
		local.searchList = listAppend( local.row.package, local.row.name, '.' );
		local.currentNode[ "$link" ] = local.packagelink;

		// Create class entry
		if( !structKeyExists( local.currentNode, local.row.name ) ) {
			local.currentNode[ local.row.name ] = {};
		}

		local.currentNode[ local.row.name ][ "$class" ] = {
			"link" : local.link,
			"searchList" : local.searchList,
			"type" : local.row.type
		};
	}
</cfscript>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>	overview </title>
	<meta name="keywords" content="overview">
	<cfmodule template="inc/common.cfm" rootPath="">
	<link rel="stylesheet" href="jstree/themes/default/style.min.css" />
</head>

<body class="frame-sidebar">
	<div class="mb-3">
		<h5 class="text-primary mb-3"><i class="bi bi-book"></i> #arguments.projecttitle#</h5>
		<!--- Search box --->
		<input type="text" id="classSearch" placeholder="🔍 Search classes..." class="form-control form-control-sm">
	</div>
	<!--- Container div for tree --->
	<div id="classTree">
		<ul>
			<!--- Output classTree --->
			#writeItems( classTree )#
		</ul>
	</div>

	<script src="jstree/jstree.min.js"></script>
	<script language="javascript">
		$(function () {
			// Initialize tree
			$('##classTree')
				.jstree({
					"core" : {
						"expand_selected_onload" : true
					},
					// Shortcut types to control icons
				    "types" : {
				      "package" : {
				        "icon" : "bi bi-folder2-open"
				      },
				      "component" : {
				        "icon" : "bi bi-file-earmark-code"
				      },
					  "class" : {
				        "icon" : "bi bi-file-earmark-code"
				      },
				      "interface" : {
				        "icon" : "bi bi-info-circle"
				      }
				    },
				    // Smart search callback to do lookups on full class name and aliases
				    "search" : {
				    	"show_only_matches" : true,
				    	"search_callback" : function( q, node ) {
				    		q = q.toUpperCase();
				    		var searchArray = node.li_attr.searchlist.split(',');
				    		var isClass = node.li_attr.thissort != 1;
				    		for( var i in searchArray ) {
				    			var item = searchArray[ i ];
				    			// classes must be a super set of the search string, but packages are reversed
				    			// This is so "testbox" AND "run" highlight when you serach for "testbox run"
				    			if( ( isClass && item.toUpperCase().indexOf( q ) > -1 )
				    				|| ( !isClass && q.indexOf( item.toUpperCase() ) > -1 ) ) {
				    				return true;
				    			}
				    		}
				    		return false;
				    	}
				    },
				    // Custom sorting to force packages to the top
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
				.on("ready.jstree", function (e, data) {
					// Expand first 2 levels on load
					var depth = 2;
					data.instance.get_container().find('li').each(function() {
						if (data.instance.get_path(this).length < depth) {
							data.instance.open_node(this);
						}
					});
				})
				.on("changed.jstree", function (e, data) {
					var obj = data.instance.get_node(data.selected[0]).li_attr;
					if( obj.linkhref ) {
						window.parent.frames['classFrame'].location.href = obj.linkhref;
					}
			});

			// Bind search to text box
			var to = false;
			$('##classSearch').keyup(function () {
				if(to) { clearTimeout(to); }
				to = setTimeout(function () {
					var v = $('##classSearch').val();
					$('##classTree').jstree(true).search(v);
				}, 250);
			});

		 });
	</script>
</body>
</html>
</cfoutput>
