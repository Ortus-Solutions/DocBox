/**
 * Sync remote config settings with local settings for your configured endpoint.
 * Settings will be merged together.
 **/
component {

	/**
	 * Run the config sync pull command
	 *
	 * @endpointName  The name of the endpoint to sync from
	 * @overwrite     Overwrite local settings with remote values
	 **/
	function run(
		string endpointName  = "",
		boolean overwrite    = false
	){
	}

}
