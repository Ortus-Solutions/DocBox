<cfoutput>
<cfset assetPath = repeatstring( '../', listlen( arguments.package, "." ) )>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>	#arguments.package# </title>
	<meta name="keywords" content="#arguments.package# package">
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
		<!-- Package Breadcrumb Navigation -->
		<nav aria-label="breadcrumb" class="mb-3">
			<ol class="breadcrumb package-breadcrumb">
				<li class="breadcrumb-item">
					<a href="#assetPath#overview-summary.html">📚 All Packages</a>
				</li>
				<cfset local.packageParts = listToArray(arguments.package, ".") />
				<cfset local.packagePath = "" />
				<cfloop array="#local.packageParts#" index="local.part">
					<cfset local.packagePath = listAppend(local.packagePath, local.part, ".") />
					<cfif local.part eq local.packageParts[arrayLen(local.packageParts)]>
						<li class="breadcrumb-item active" aria-current="page">
							📁 #local.part#
						</li>
					<cfelse>
						<li class="breadcrumb-item">
							<a href="#assetPath##replace(local.packagePath, '.', '/', 'all')#/package-summary.html">📁 #local.part#</a>
						</li>
					</cfif>
				</cfloop>
			</ol>
		</nav>

	<div class="table-responsive">
	<cfif arguments.qInterfaces.recordCount>
		<div class="card mb-4">
		<table class="table table-hover mb-0">
			<thead class="table-light">
				<tr>
					<th colspan="2" class="fs-5 py-3">
					<i class="bi bi-info-circle text-primary"></i> <strong>Interface Summary</strong></th>
				</tr>
			</thead>
			<tbody>
			<cfloop query="arguments.qinterfaces">
				<tr>
					<td width="15%"><b><a href="#name#.html" title="class in #package#">#name#</a></b></td>
					<td>
						<cfset meta = metadata>
						<cfif structkeyexists(meta, "hint")>
							#listgetat(meta.hint, 1, chr(13)&chr(10)&'.' )#
						</cfif>
					</td>
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
					<i class="bi bi-file-earmark-code text-primary"></i> <strong>Class Summary</strong></th>
				</tr>
			</thead>
			<tbody>
			<cfloop query="arguments.qclasses">
				<tr>
					<td width="15%"><b><a href="#name#.html" title="class in #package#">#name#</a></b></td>
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
</div>

</body>
</html>
</cfoutput>