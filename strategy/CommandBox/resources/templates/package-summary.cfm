<cfoutput>
<cfset assetPath = repeatstring( '../', listlen( arguments.package, "." ) )>
<!DOCTYPE html>
<html lang="en">
<head>
	<title> #arguments.projectTitle# #arguments.namespace# </title>
	<meta name="keywords" content="#arguments.namespace# namespace">
	<cfmodule template="inc/common.cfm" rootPath="#assetPath#">
</head>
<body class="withNavbar">

	<cfmodule template="inc/nav.cfm"
				page="Package"
				projectTitle= "#arguments.projectTitle#"
				package = "#arguments.package#"
				file="#replace(arguments.package, '.', '/', 'all')#/package-summary"
				>
	<div class="container-fluid">
		<!-- Breadcrumb Navigation -->
		<nav aria-label="breadcrumb" class="mb-3">
			<ol class="breadcrumb package-breadcrumb">
				<li class="breadcrumb-item">
					<a href="#assetPath#overview-summary.html">⚡ All Namespaces</a>
				</li>
				<li class="breadcrumb-item active" aria-current="page">
					<i class="bi bi-terminal"></i> #arguments.namespace#
				</li>
			</ol>
		</nav>
		<h2 class="mb-4"><i class="bi bi-terminal text-primary"></i> #arguments.namespace#</h2>

	<cfset namespaces = {}>
	<cfloop query="arguments.qMetadata">
		<cfif reFind( '#arguments.namespace# [\S]*', arguments.qMetadata.namespace ) >
			<cfset namespaces[ arguments.qMetadata.namespace ] = replace( replace( arguments.qMetadata.package, arguments.package & '.', '' ), ".", "/", "all") & '/package-summary.html'>
		</cfif>
	</cfloop>

	<div class="table-responsive">
	<cfif structCount( namespaces )>
		<div class="card mb-4">
		<table class="table table-hover mb-0">
			<thead class="table-light">
				<tr>
					<th colspan="2" class="fs-5 py-3">
						<i class="bi bi-folder2 text-primary"></i> <strong>Namespaces</strong>
					</th>
				</tr>
			</thead>
			<tbody>
				<cfset sortedNamespaces = listToArray( structKeyList( namespaces ) )>
				<cfset arraySort( sortedNamespaces, 'text' )>
				<cfloop array="#sortedNamespaces#" index="thisNamespace">
					<tr>
						<td width="15%"><b><a href="#namespaces[ thisNamespace ]#">#thisNamespace#</a></b></td>
						<td>&nbsp;</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
		</div>
	</cfif>
	<cfif arguments.qClasses.recordCount>
		<div class="card mb-4">
		<table class="table table-hover mb-0">
			<thead class="table-light">
				<tr>
					<th colspan="2" class="fs-5 py-3">
						<i class="bi bi-lightning-charge text-primary"></i> <strong>Commands</strong>
					</th>
				</tr>
			</thead>
			<tbody>
			<cfloop query="arguments.qclasses">
				<tr>
					<td width="15%"><b><a href="#name#.html">#command#</a></b></td>
					<td>
						<cfset meta = metadata>
						<cfif structkeyexists(meta, "hint") and len(meta.hint) gt 0>
							#listgetat( meta.hint, 1, chr(13)&chr(10)&'.' )#
						</cfif>
					</td>
				</tr>
			</cfloop>
			</tbody>
		</table>
		</div>
	</cfif>
	</div>
	</div><!-- end container-fluid -->

</body>
</html>
</cfoutput>