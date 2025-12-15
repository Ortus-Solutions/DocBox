/**
 * XMI/UML Diagram Generation Strategy for DocBox
 * <h2>Overview</h2>
 * This strategy generates XMI (XML Metadata Interchange) files compatible with Eclipse UML2Tools and other
 * UML modeling applications. It transforms CFML component metadata into standardized UML class diagrams,
 * enabling visual representation of application architecture, class relationships, and inheritance hierarchies.
 * <h2>Key Features</h2>
 * <ul>
 * <li><strong>UML 2.0 Compliance</strong> - Generates standards-compliant XMI format</li>
 * <li><strong>Class Diagrams</strong> - Visual representation of components, interfaces, and relationships</li>
 * <li><strong>Inheritance Trees</strong> - Displays extends and implements relationships</li>
 * <li><strong>Property Detection</strong> - Infers properties from getter/setter method pairs</li>
 * <li><strong>Generic Type Support</strong> - Handles @doc_generic annotations for typed collections</li>
 * <li><strong>Access Modifiers</strong> - Preserves public/private/package visibility levels</li>
 * <li><strong>Tool Integration</strong> - Compatible with Eclipse UML2Tools, ArgoUML, and other UML viewers</li>
 * </ul>
 * <h2>Generated Output</h2>
 * <pre>
 * outputFile.uml - Single XMI file containing:
 *   ├── Package hierarchy
 *   ├── Class definitions
 *   ├── Interface definitions
 *   ├── Properties (inferred from accessors)
 *   ├── Methods with parameters
 *   ├── Inheritance relationships
 *   └── Implementation relationships
 * </pre>
 * <h2>Property Inference</h2>
 * Unlike explicit CFML properties, this strategy infers properties from accessor method pairs:
 * <pre>
 * // These methods in a component:
 * function getUsername() { return variables.username; }
 * function setUsername( string username ) { variables.username = arguments.username; }
 *
 * // Become this property in UML:
 * - username : string
 * </pre>
 * <h3>Inference Rules</h3>
 * A property is detected when:
 * <ul>
 * <li>A getter method exists (getName() or isName() for booleans)</li>
 * <li>A matching setter method exists (setName())</li>
 * <li>Setter accepts exactly one parameter</li>
 * <li>Setter parameter type matches getter return type</li>
 * </ul>
 * <h3>Access Level Resolution</h3>
 * Property access is determined from accessor visibility:
 * <ul>
 * <li><strong>Public</strong> - If either getter or setter is public</li>
 * <li><strong>Package</strong> - If either is package-level and neither is public</li>
 * <li><strong>Private</strong> - If both are private</li>
 * </ul>
 * <h2>Usage Examples</h2>
 * <h3>Basic XMI Generation</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy( "XMI", {
 *         outputFile : "/docs/architecture.uml"
 *     } )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>Using Strategy Directly</h3>
 * <pre>
 * new docbox.DocBox()
 *     .addStrategy(
 *         new docbox.strategy.uml2tools.XMIStrategy(
 *             outputFile = "/docs/myapp.uml"
 *         )
 *     )
 *     .generate( source = "/app", mapping = "app" );
 * </pre>
 * <h3>File Extension Handling</h3>
 * <pre>
 * // Automatically appends .uml extension if missing:
 * new XMIStrategy( outputFile = "/docs/diagram" )
 * // Results in: /docs/diagram.uml
 *
 * // Extension preserved if already present:
 * new XMIStrategy( outputFile = "/docs/diagram.uml" )
 * // Results in: /docs/diagram.uml
 * </pre>
 * <h2>Viewing Generated Diagrams</h2>
 * <h3>Eclipse UML2Tools</h3>
 * <ol>
 * <li>Install UML2Tools plugin in Eclipse</li>
 * <li>Import the generated .uml file</li>
 * <li>Open with UML Class Diagram editor</li>
 * <li>Auto-layout the diagram for optimal visualization</li>
 * </ol>
 * <h3>Other Compatible Tools</h3>
 * <ul>
 * <li><strong>ArgoUML</strong> - Open-source UML modeling tool</li>
 * <li><strong>Papyrus</strong> - Eclipse-based UML modeler</li>
 * <li><strong>StarUML</strong> - Sophisticated UML tool with XMI import</li>
 * <li><strong>Visual Paradigm</strong> - Professional UML modeling suite</li>
 * </ul>
 * <h2>Limitations</h2>
 * <ul>
 * <li>Only infers properties from getter/setter pairs (explicit properties in metadata are not included)</li>
 * <li>Does not capture method implementations or business logic</li>
 * <li>Sequence diagrams and other UML diagram types are not supported</li>
 * <li>Custom annotations beyond @doc_generic are not preserved</li>
 * </ul>
 * <h2>Best Practices</h2>
 * <ul>
 * <li>Use consistent naming for accessors (get/set/is prefixes)</li>
 * <li>Document generic types with @doc_generic for collections</li>
 * <li>Ensure setter parameter types match getter return types</li>
 * <li>Keep the output file in version control to track architectural changes</li>
 * <li>Regenerate diagrams periodically during development to maintain accuracy</li>
 * </ul>
 * <br>
 * <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
 *
 * @see AbstractTemplateStrategy
 * @see IStrategy
 */
component
	hint     ="Strategy for generating the .uml file for Eclipse UML2Tools to generate diagrams from"
	accessors="true"
	extends  ="docbox.strategy.AbstractTemplateStrategy"
{

	/**
	 * The output file
	 */
	property name="outputFile" type="string";

	/**
	 * Static assets used in HTML templates
	 */
	variables.TEMPLATE_PATH = "/docbox/strategy/uml2tools/resources/templates";

	/**
	 * Constructor
	 *
	 * @outputFile The output file
	 */
	function init( required string outputFile ){
		super.init();

		if ( NOT arguments.outputFile.endsWith( ".uml" ) ) {
			arguments.outputFile &= ".uml";
		}

		variables.outputFile = arguments.outputFile;

		return this;
	}

	/**
	 * Executes the XMI documentation generation strategy
	 * <br>
	 * This is the main entry point for the strategy. It orchestrates the complete XMI/UML file generation
	 * process, transforming component metadata into a standards-compliant XMI structure suitable for
	 * UML modeling tools.
	 * <h3>Generation Process</h3>
	 * <ol>
	 * <li><strong>Validation</strong> - Ensures output directory exists (throws exception if missing)</li>
	 * <li><strong>Package Tree Building</strong> - Constructs hierarchical package structure from metadata</li>
	 * <li><strong>Template Rendering</strong> - Processes UML template with metadata to generate XMI content</li>
	 * <li><strong>File Writing</strong> - Writes complete XMI structure to .uml file</li>
	 * </ol>
	 * <h3>Validation</h3>
	 * Unlike JSONAPIStrategy which creates missing directories, this strategy requires the output
	 * directory to exist before execution. This is a safety measure since UML files are typically
	 * singular artifacts rather than directory structures.
	 * <h3>Package Tree</h3>
	 * The method uses <code>buildPackageTree()</code> with a second parameter (true) to build the
	 * hierarchical package structure needed for proper UML namespace organization.
	 * <h3>Template Processing</h3>
	 * The UML template receives:
	 * <ul>
	 * <li><code>packages</code> - Hierarchical package tree structure</li>
	 * <li><code>qMetadata</code> - Complete metadata query for all components</li>
	 * </ul>
	 * The template iterates through packages and components, generating XMI elements for each class,
	 * interface, property, and method while preserving relationships.
	 * <h3>Error Handling</h3>
	 * Throws <code>InvalidConfigurationException</code> if:
	 * <ul>
	 * <li>The output directory (parent of outputFile) does not exist</li>
	 * <li>The directory is not writable</li>
	 * </ul>
	 * <h3>Method Chaining</h3>
	 * Returns the strategy instance to enable fluent method chaining with other DocBox operations.
	 * <h3>Example Usage Context</h3>
	 * <pre>
	 * // This method is called automatically by DocBox:
	 * var xmiStrategy = new XMIStrategy( outputFile = "/docs/app.uml" );
	 * xmiStrategy.run( docboxMetadata ); // Generates /docs/app.uml
	 * </pre>
	 *
	 * @metadata Query object from DocBox containing all component metadata with columns: package, name, type, extends, implements, metadata, fullextends
	 *
	 * @return The strategy instance for method chaining
	 *
	 * @throws InvalidConfigurationException if output directory does not exist or is not writable
	 */
	IStrategy function run( required query metadata ){
		var basePath = getDirectoryFromPath( getMetadata( this ).path );
		var packages = buildPackageTree( arguments.metadata, true );

		if ( !directoryExists( getDirectoryFromPath( getOutputFile() ) ) ) {
			throw(
				message = "Invalid configuration; configured output directory not found",
				type    = "InvalidConfigurationException",
				detail  = "Path #getDirectoryFromPath( getOutputFile() )# does not exist."
			);
		}

		// Generate the UML file
		var args = {
			path      : getOutputFile(),
			template  : "#variables.TEMPLATE_PATH#/template.uml",
			packages  : packages,
			qMetadata : arguments.metadata
		};

		writeTemplate( argumentCollection = args );

		return this;
	}

	/**
	 * Infers properties from getter and setter method pairs
	 * <br>
	 * This method analyzes a component's methods to identify properties by detecting matching getter/setter
	 * pairs. This is necessary because UML diagrams display properties as class attributes, but CFML components
	 * often use accessor methods instead of explicit property declarations.
	 * <h3>Detection Algorithm</h3>
	 * <ol>
	 * <li><strong>Find Getters</strong> - Identifies methods starting with "get" or "is" (for booleans)</li>
	 * <li><strong>Extract Property Name</strong> - Removes the get/is prefix to determine the property name</li>
	 * <li><strong>Find Matching Setter</strong> - Looks for a "set" method with the same property name</li>
	 * <li><strong>Validate Signature</strong> - Ensures setter has exactly one parameter matching the getter's return type</li>
	 * <li><strong>Determine Access</strong> - Resolves access level from getter/setter visibility</li>
	 * <li><strong>Extract Generics</strong> - Processes @doc_generic annotations from getter for typed collections</li>
	 * </ol>
	 * <h3>Naming Conventions</h3>
	 * <strong>Getter Methods:</strong>
	 * <ul>
	 * <li><code>getName()</code> → property "name"</li>
	 * <li><code>getUserList()</code> → property "userList"</li>
	 * <li><code>isActive()</code> → property "active" (boolean properties)</li>
	 * </ul>
	 * <strong>Property Name Conversion:</strong>
	 * <pre>
	 * getUsername()  → username  (first char lowercased)
	 * getUserID()    → userID    (preserves camelCase)
	 * isEnabled()    → enabled   (removes "is" prefix)
	 * </pre>
	 * <h3>Access Level Resolution</h3>
	 * <table>
	 * <tr><th>Getter Access</th><th>Setter Access</th><th>Property Access</th></tr>
	 * <tr><td>public</td><td>public</td><td>public</td></tr>
	 * <tr><td>public</td><td>private</td><td>public</td></tr>
	 * <tr><td>private</td><td>public</td><td>public</td></tr>
	 * <tr><td>package</td><td>package</td><td>package</td></tr>
	 * <tr><td>package</td><td>private</td><td>package</td></tr>
	 * <tr><td>private</td><td>private</td><td>private</td></tr>
	 * </table>
	 * Rule: If either accessor is public, the property is public. Otherwise, if either is package, property is package.
	 * <h3>Type Matching</h3>
	 * For a valid property, the setter must:
	 * <ul>
	 * <li>Accept exactly one parameter (no more, no less)</li>
	 * <li>Parameter type must match getter's return type exactly</li>
	 * <li>Parameter name is ignored (only type matters)</li>
	 * </ul>
	 * <h3>Generic Types</h3>
	 * Generic type information from the getter's @doc_generic annotation is preserved:
	 * <pre>
	 * /**
	 *  * @doc_generic Array&lt;User&gt;
	 *  *&#47;
	 * function getUsers() { return variables.users; }
	 * function setUsers( array users ) { variables.users = arguments.users; }
	 *
	 * // Results in property:
	 * - users : array&lt;User&gt;
	 * </pre>
	 * <h3>Query Structure</h3>
	 * Returns a query with columns:
	 * <ul>
	 * <li><strong>name</strong> (string) - Property name in camelCase</li>
	 * <li><strong>access</strong> (string) - "public", "private", or "package"</li>
	 * <li><strong>type</strong> (string) - Data type from getter's return type</li>
	 * <li><strong>generic</strong> (array) - Generic type annotations from @doc_generic</li>
	 * </ul>
	 * <h3>Example</h3>
	 * <pre>
	 * // Component methods:
	 * public string function getFirstName() { return variables.firstName; }
	 * public void function setFirstName( string firstName ) { variables.firstName = arguments.firstName; }
	 *
	 * // Resulting query row:
	 * name     = "firstName"
	 * access   = "public"
	 * type     = "string"
	 * generic  = []
	 * </pre>
	 *
	 * @meta Component metadata structure containing functions array
	 * @package Package name for resolving generic type references
	 *
	 * @return Query with columns [name, access, type, generic] containing inferred properties, or empty query if no valid property pairs exist
	 */
	private query function determineProperties(
		required struct meta,
		required string package
	){
		var qFunctions  = buildFunctionMetaData( arguments.meta );
		var qProperties = queryNew( "name, access, type, generic" );
		// is is used for boolean properties
		var qGetters    = getMetaSubQuery(
			qFunctions,
			"LOWER(name) LIKE 'get%' OR LOWER(name) LIKE 'is%'"
		);

		for ( var thisRow in qGetters ) {
			var propertyName = 0;
			if ( lCase( thisRow.name ).startsWith( "get" ) ) {
				propertyName = replaceNoCase( thisRow.name, "get", "" );
			} else {
				propertyName = replaceNoCase( thisRow.name, "is", "" );
			}

			var qSetters = getMetaSubQuery(
				qFunctions,
				"LOWER(name) = LOWER('set#propertyName#')"
			);
			var getterMeta = structCopy( thisRow.metadata );
			// lets just take getter generics, easier to do.
			var generics   = getGenericTypes( thisRow.metadata, arguments.package );

			if ( qSetters.recordCount ) {
				var setterMeta = qSetters.metadata;

				if (
					structKeyExists( setterMeta, "parameters" )
					AND arrayLen( setterMeta.parameters ) eq 1
					AND setterMeta.parameters.first().type eq getterMeta.returnType
				) {
					var access = "private";
					if ( setterMeta.access eq "public" OR getterMeta.access eq "public" ) {
						access = "public";
					} else if ( setterMeta.access eq "package" OR getterMeta.access eq "package" ) {
						access = "package";
					}

					queryAddRow( qProperties );

					// lower case the front
					querySetCell(
						qProperties,
						"name",
						reReplace(
							propertyName,
							"([A-Z]*)(.*)",
							"\L\1\E\2"
						)
					);

					querySetCell( qProperties, "access", access );

					querySetCell(
						qProperties,
						"type",
						getterMeta.returntype
					);
					querySetCell( qProperties, "generic", generics );
				}
			}
		}

		return qProperties;
	}

}
