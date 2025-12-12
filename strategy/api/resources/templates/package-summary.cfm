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
	<h2>
	<span class="badge bg-success">#arguments.package#</span>
	</h2>

	<div class="table-responsive">
	<cfif arguments.qInterfaces.recordCount>
		<table class="table table-striped table-hover table-bordered">
			<thead class="table-info">
				<tr>
					<th colspan="2" class="fs-4">
					<strong>Interface Summary</strong></th>
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
	</cfif>

	<cfif arguments.qClasses.recordCount>
		<table class="table table-striped table-hover table-bordered">
			<thead class="table-info">
				<tr>
					<th colspan="2" class="fs-4">
					<strong>Class Summary</strong></th>
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
	</cfif>
	</div>

</body>
</html>
</cfoutput>