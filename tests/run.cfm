<cfparam name="url.version" default="0">
<cfparam name="url.path" 	default="#expandPath( "./apidocs" )#">
<cfparam name="url.theme" default="default">
<cfsetting requestTimeout="500">
<cfscript>
	if( directoryExists( url.path ) ){
		directoryDelete( url.path, true )
	}
	directoryCreate( url.path )

	docName = "DocBox v#url.version#";
	// init docbox with default strategy and properites
	docbox = new docbox.DocBox(
		strategy = "HTML",
		properties={
		outputDir 		= url.path,
		projectTitle = "DocBox v#url.version#",
		projectDescription = "Comprehensive documentation for DocBox version #url.version#.",
		theme        = url.theme
	} );

	docbox.addStrategy( "JSON", {
		projectTitle = "DocBox v#url.version#",
		outputDir    = url.path & "/json"
	})

	// generate
	docbox.generate(
		source=expandPath( "/docbox" ),
		mapping="docbox",
		excludes="(coldbox|build|testbox|tests|.engine|.artifacts|.github|.tmp|boxlang_modules)"
	);
</cfscript>
<h1>Done!</h1>
<cfoutput>
<a href="apidocs/index.html">Go to Docs!</a>
<p>Generated at #now()#</p>
<p>&nbsp;</p>
<ul>
	<li><a href="run.cfm">Refresh Default!</a></li>
	<li><a href="run.cfm?theme=frames">Refresh Frames!</a></li>
</ul>
</cfoutput>