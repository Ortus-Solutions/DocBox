<cfoutput>
<cfset instance.class.root = RepeatString( '../', ListLen( arguments.package, ".") ) />
<cfset annotations = server.keyExists( "boxlang" ) ? arguments.metadata.annotations : arguments.metadata>
<cfset documentation = server.keyExists( "boxlang" ) ? arguments.metadata.documentation : arguments.metadata>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>#arguments.projectTitle# #arguments.command#</title>
	<meta name="keywords" content="#arguments.package# #arguments.command# CommandBox Command CLI">
	<!-- common assets -->
	<cfmodule template="inc/common.cfm" rootPath="#instance.class.root#">
	<!-- syntax highlighter -->
	<link type="text/css" rel="stylesheet" href="#instance.class.root#highlighter/styles/shCoreEmacs.css">
	<script src="#instance.class.root#highlighter/scripts/shCore.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushBash.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushBoxLang.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushColdFusion.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushCss.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJava.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJScript.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushPlain.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushSql.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushXml.js"></script>
	<script type="text/javascript">
		SyntaxHighlighter.config.stripBrs = true;
		SyntaxHighlighter.defaults.gutter = false;
		SyntaxHighlighter.defaults.toolbar = false;
		SyntaxHighlighter.all();
	</script>
	<style>
	.syntaxhighlighter table td.code { padding: 10px !important; }
	</style>
</head>

<body class="withNavbar">

<cfmodule template="inc/nav.cfm"
			page="Class"
			projectTitle= "#arguments.projectTitle#"
			package = "#arguments.package#"
			file="#replace(arguments.package, '.', '/', 'all')#/#arguments.name#"
			>

<!-- ======== start of class data ======== -->
<h1>#arguments.command#</h1>

<cfif structKeyExists( annotations, 'aliases' ) and len( annotations.aliases ) >
	<cfset aliases = listToArray( annotations.aliases )>
	<div class="panel panel-default">
		<div class="panel-body">
			<strong>Aliases:&nbsp;</strong>
			<cfloop array="#aliases#" index="local.alias">
				<li class="label label-danger label-annotations">
					#local.alias#
				</li>
				&nbsp;
			</cfloop>
		</div>
	</div>
</cfif>

<cfscript>
	// All we care about is the "run()" method
	local.qFunctions = buildFunctionMetaData( arguments.metadata );
	local.qFunctions = getMetaSubQuery(local.qFunctions, "UPPER(name)='RUN'");
</cfscript>

<cfif local.qFunctions.recordCount>
	<cfset local.func = local.qFunctions.metadata>
	<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func>
	<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func>
	<cfset local.params = local.func.parameters>

	<cfif arrayLen( local.params )>
		<div class="panel panel-default">
			<div class="panel-heading"><strong>Parameters:</strong></div>
				<table class="table table-bordered table-hover">
					<tr>
						<td width="1%"><strong>Name</strong></td>
						<td width="1%"><strong>Type</strong></td>
						<td width="1%"><strong>Required</strong></td>
						<td width="1%"><strong>Default</strong></td>
						<td><strong>Hint</strong></td>
					</tr>
					<cfloop array="#local.params#" index="local.param">
						<cfset local.paramDocumentation = server.keyExists( "boxlang" ) ? local.param.documentation : local.param>
						<cfset local.paramAnnotations = server.keyExists( "boxlang" ) ? local.param.annotations : local.param>
						<tr>
							<td>#local.param.name#</td>
							<td>
								<cfif local.param.type eq "any">
									string
								<cfelse>
									#local.param.type#
								</cfif>
							</td>
							<td>#local.paramAnnotations.required ?: false#</td>
							<td>
								<cfif !isNull(local.paramAnnotations.default) and local.paramAnnotations.default!= '[runtime expression]' >
									#local.paramAnnotations.default#
								</cfif>
							</td>
							<td>
								<cfif structKeyExists( local.paramDocumentation, 'hint' )>
									#local.paramDocumentation.hint#
								</cfif>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</div>
	</cfif>

</cfif>

<hr>

<cfif StructKeyExists( documentation, "hint")>
	<h3>Command Usage</h3>
	<div id="class-hint">
		<p>#writeHint(  documentation.hint )#</p>
	</div>
</cfif>

</body>
</html>
</cfoutput>
<cfscript>
	function writeHint( hint ) {

		// Clean up lines with only a period which is my work around for the Railo bug ignoring
		// line breaks in component annotations: https://issues.jboss.org/browse/RAILO-3128
		hint = reReplace( hint, '\n\s*\.\s*\n', chr( 10 )&chr( 10 ), 'all' );

		// Find code blocks
		// A {code} block on it's own line with an optional ":brush" inside it
		// followed by any amount of text
		// followed by another {code} block on it's own line
		var codeRegex = '(\n?\s*{\s*code\s*(:.*?)?\s*}\s*\n)(.*?)(\n\s*{\s*code\s*}\s*\n?)';
		hint = reReplaceNoCase( hint, codeRegex, '<pre class="brush\2">\3</pre>', 'all' );

		// Fix line breaks
		hint = reReplace( hint, '\n', '#chr(10)#<br>', 'all' );

		return hint;
	}
</cfscript>