/**
 * Strategy Interface for DocBox Documentation Generation
 * <br>
 * This interface defines the contract that all DocBox documentation strategies must implement.
 * Strategies are responsible for generating documentation output in various formats (HTML, JSON, XMI, etc.)
 * from the component metadata collected by DocBox.
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 */
interface {

	/**
	 * Execute the documentation generation strategy
	 *
	 * This method receives the complete metadata query from DocBox and is responsible for:
	 * - Processing the component metadata
	 * - Generating the appropriate output format
	 * - Writing files to the configured output location
	 *
	 * @metadata Query object containing all component metadata with columns:
	 *            - package: The package name
	 *            - name: The component name
	 *            - metadata: The complete component metadata structure
	 *            - type: The component type (component, interface, etc.)
	 *            - extends: The extended component name (if any)
	 *            - implements: The implemented interfaces (if any)
	 *
	 * @return The strategy instance for method chaining
	 */
	IStrategy function run( required query metadata );

}
