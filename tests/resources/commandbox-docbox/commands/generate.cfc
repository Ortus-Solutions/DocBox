/**
 * Creates documentation for CFCs JavaDoc style via DocBox
 * .
 * You can pass the strategy options by prefixing them with 'strategy-'. So if a strategy takes
 * in a property of 'outputDir' you will pass it as 'strategy-outputdir='
 * Single source/mapping example:
 * {code:bash}
 * docbox generate source=/path/to/coldbox mapping=coldbox excludes=tests strategy-outputDir=/output/path strategy-projectTitle="My Docs"
 * {code}
 * Multiple source/mapping example:
 * {code:bash}
 * docbox generate mappings:v1.models=/path/to/modules_app/v1/models mappings:v2.models=/path/to/modules_app/v2/models strategy-outputDir=/output/path strategy-projectTitle="My Docs"
 * {code}
 *
 * @cite https://github.com/Ortus-Solutions/commandbox-docbox/blob/development/commands/docbox/Generate.cfc
 **/
component {

	/**
	 * Run DocBox to generate your docs
	 *
	 * @strategy The strategy class to use to generate the docs.
	 * @strategy.options docbox.strategy.api.HTMLAPIStrategy,docbox.strategy.uml2tools.XMIStrategy
	 * @source The directory source
	 * @mapping The base mapping for the folder.
	 * @excludes A regex that will be applied to the input source to exclude from the docs
	 * @mappings A struct provided by the dynamic parameters facility of CommandBox that defines one or more mappings.
	 **/
	function run(
		string strategy = "docbox.strategy.api.HTMLAPIStrategy",
		string source   = "",
		string mapping,
		string excludes,
		struct mappings
	){
		// Big thanks to https://github.com/Ortus-Solutions/commandbox-docbox/blob/development/commands/docbox/Generate.cfc
	}

}
