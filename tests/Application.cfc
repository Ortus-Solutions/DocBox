/**
 * Copyright 2015 Ortus Solutions, Corp
 * www.ortussolutions.com
 **************************************************************************************
 */
component {

	this.name = "DocBox Testing Suite";

	testsPath                  = getDirectoryFromPath( getCurrentTemplatePath() );
	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ]  = testsPath;
	rootPath                   = reReplaceNoCase( testsPath, "tests(\\|/)", "" );
	this.mappings[ "/docbox" ] = rootPath;

	// Dummy commandbox commands for testing the commandbox strategy
	this.mappings[ "/commands" ] = testsPath & "/resources/commandbox-docbox/commands/";
	this.mappings[ "/coldbox" ] = testsPath & "/resources/coldbox/";

}
