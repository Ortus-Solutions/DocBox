<cfscript>
	outputPath = expandPath( "/tests/apidocs" )

	if( directoryExists( outputPath ) ){
		directoryDelete( outputPath, true )
	}
	directoryCreate( outputPath )

	docbox = new docbox.DocBox(
		strategy = "HTML",
		properties={
			projectTitle 	= "ColdBox v8.0.0",
			outputDir 		= outputPath
	} );

	docbox.addStrategy( "JSON", {
		outputDir    = outputPath & "/json"
	} )

	// generate
	docbox.generate(
		source=expandPath( "/coldbox" ),
		mapping="coldbox"
	);
</cfscript>
<h1>Done!</h1>
<cfoutput>
<a href="apidocs/index.html">Go to Docs!</a>
<p>Generated at #now()#</p>
<p>&nbsp;</p>
<ul>
	<li><a href="coldbox.cfm">Refresh Default!</a></li>
</ul>
</cfoutput>