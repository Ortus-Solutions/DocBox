<cfparam name="url.version" default="0">
<cfparam name="url.path" 	default="#expandPath( "./apidocs" )#">
<cfscript>
	if( directoryExists( url.path ) ){
		directoryDelete( url.path, true )
	}
	directoryCreate( url.path )

	docName = "DocBox v#url.version#";
	// init docbox with default strategy and properites
	docbox = new docbox.DocBox( properties={
		projectTitle 	= "DocBox v#url.version#",
		outputDir 		= url.path
	} );

	docbox.addStrategy( "JSON", {
		projectTitle = "DocBox v#url.version#",
		outputDir    = url.path & "/json"
	})
	.addStrategy( "HTML", {
		projectTitle = "DocBox v#url.version#",
		outputDir    = url.path
	})

	// generate
	docbox.generate(
		source=expandPath( "/docbox" ),
		mapping="docbox",
		excludes="(coldbox|build|testbox|tests|.engine)"
	);
</cfscript>
<h1>Done!</h1>
<cfoutput>
<a href="apidocs/index.html">Go to Docs!</a>
<p>Generated at #now()#</p>
</cfoutput>